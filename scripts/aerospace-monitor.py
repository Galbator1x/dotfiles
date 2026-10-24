#!/usr/bin/env python3
"""Minute-based local AeroSpace metrics. No Accessibility requests or window changes."""
import argparse
from datetime import datetime, timedelta, timezone
import fcntl
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import time

USER_ROOT = Path.home()
DATA = USER_ROOT / 'Library/Application Support/dotfiles/aerospace-monitor'
LOGS = USER_ROOT / 'Library/Logs/dotfiles/aerospace-monitor'
ERROR_LOG = USER_ROOT / 'Library/Logs/dotfiles/aerospace-main.error.log'
JOB = f'gui/{os.getuid()}/local.dotfiles.aerospace-main'
NOTIFICATION_SCRIPT = '''on run argv
    display notification (item 1 of argv) with title "AeroSpace"
end run'''


def atomic_json(path, value):
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix='.' + path.name)
    try:
        with os.fdopen(fd, 'w') as stream:
            json.dump(value, stream, separators=(',', ':'))
            stream.write('\n')
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def evaluate(previous, sample, now, error_cursor, error_growth):
    """Pure policy: reset intervals on gaps/restarts; alert once per sustained episode."""
    state = dict(previous)
    events = []
    old = previous.get('sample')
    valid = bool(old and sample and old['pid'] == sample['pid'] and old['start'] == sample['start']
                 and 0 < now - previous.get('time', now) <= 150
                 and sample['monotonic'] > old['monotonic'] and sample['cpu_ns'] >= old['cpu_ns'])
    cpu = None
    if valid:
        cpu = 100 * (sample['cpu_ns'] - old['cpu_ns']) / 1e9 / (sample['monotonic'] - old['monotonic'])
    if sample:
        key = [sample['pid'], sample['start']]
        if previous.get('process') and previous['process'] != key:
            events.append(('restart', 'Процесс перезапущен; новый PID ' + str(sample['pid'])))
        elif previous.get('down'):
            events.append(('recovery', 'Процесс снова работает'))
        state['process'] = key
        state['down'] = False
    else:
        if not previous.get('down'):
            events.append(('down', 'Процесс AeroSpace не работает или его метрики недоступны'))
        state['down'] = True
    for name, high, seconds, message in [
        ('cpu', cpu is not None and cpu > 10, 300, 'CPU выше 10% не менее 5 минут'),
        ('memory', bool(sample and sample['footprint_bytes'] > 150 * 1048576), 600,
         'Physical footprint выше 150 МиБ не менее 10 минут'),
    ]:
        since = previous.get(name + '_since') if valid else None
        alerted = previous.get(name + '_alerted', False) if valid else False
        if high:
            if since is None:
                since = previous.get('time', now) if name == 'cpu' and valid else now
            if not alerted and now - since >= seconds:
                events.append((name, message))
                alerted = True
        else:
            since, alerted = None, False
        state[name + '_since'], state[name + '_alerted'] = since, alerted
    pending = previous.get('pending_error_bytes', 0) + error_growth
    if pending and now - previous.get('error_notified_at', 0) >= 600:
        events.append(('errors', f'Новые ошибки в aerospace-main.error.log: {pending} байт'))
        pending = 0
        state['error_notified_at'] = now
    state.update(sample=sample, time=now, error_cursor=error_cursor, pending_error_bytes=pending)
    row = {'time': datetime.fromtimestamp(now, timezone.utc).isoformat(), 'status': 'running' if sample else 'unavailable',
           'cpu_percent': round(cpu, 3) if cpu is not None else None, 'new_error_bytes': error_growth}
    if sample:
        row.update(pid=sample['pid'], start=sample['start'],
                   footprint_mib=round(sample['footprint_bytes'] / 1048576, 3),
                   rss_mib=round(sample['rss_bytes'] / 1048576, 3))
    return state, row, events


def error_delta(path, previous):
    try:
        stat = path.stat()
    except FileNotFoundError:
        return {'inode': None, 'size': 0}, 0
    cursor = {'inode': [stat.st_dev, stat.st_ino], 'size': stat.st_size}
    if previous is None:
        return cursor, 0  # Baseline existing errors rather than replaying them on installation.
    offset = previous['size'] if previous['inode'] == cursor['inode'] and stat.st_size >= previous['size'] else 0
    return cursor, stat.st_size - offset


def sample_process(helper):
    result = subprocess.run(['/bin/launchctl', 'print', JOB], capture_output=True, text=True, timeout=5)
    match = re.search(r'^\s*pid = (\d+)$', result.stdout, re.M) if result.returncode == 0 else None
    if not match:
        return None
    result = subprocess.run([str(helper), match.group(1)], capture_output=True, text=True, timeout=5)
    return json.loads(result.stdout) if result.returncode == 0 else None


def append_record(folder, category, value, now):
    day = datetime.fromtimestamp(now, timezone.utc).strftime('%Y-%m-%d')
    with (folder / f'{category}-{day}.jsonl').open('a') as stream:
        stream.write(json.dumps(value, ensure_ascii=False, separators=(',', ':')) + '\n')


def prune(folder, now):
    cutoff = (datetime.fromtimestamp(now, timezone.utc).date() - timedelta(days=6)).isoformat()
    for category in ('metrics', 'events'):
        for path in folder.glob(category + '-????-??-??.jsonl'):
            if path.name[len(category) + 1:-6] < cutoff:
                path.unlink()


def notify(message):
    result = subprocess.run(['/usr/bin/osascript', '-e', NOTIFICATION_SCRIPT, '--', message],
                            capture_output=True, text=True, timeout=5)
    return result.returncode == 0


def collect(data, logs, helper, notifications=True):
    data.mkdir(parents=True, exist_ok=True, mode=0o700)
    logs.mkdir(parents=True, exist_ok=True, mode=0o700)
    with (data / 'lock').open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        state_file = data / 'state.json'
        previous = json.loads(state_file.read_text()) if state_file.exists() else {}
        now = time.time()
        sample = sample_process(helper)
        cursor, growth = error_delta(ERROR_LOG, previous.get('error_cursor'))
        state, row, events = evaluate(previous, sample, now, cursor, growth)
        append_record(logs, 'metrics', row, now)
        for kind, message in events:
            delivered = False
            if notifications:
                try:
                    delivered = notify(message)
                except (subprocess.TimeoutExpired, OSError):
                    pass
            append_record(logs, 'events', {'time': row['time'], 'kind': kind, 'message': message,
                                          'notification_requested': notifications, 'notification_submitted': delivered}, now)
        atomic_json(state_file, state)
        prune(logs, now)


def summary(logs, hours):
    cutoff = time.time() - hours * 3600
    rows = []
    for path in sorted(logs.glob('metrics-*.jsonl')):
        for line in path.read_text().splitlines():
            try:
                row = json.loads(line)
                if datetime.fromisoformat(row['time']).timestamp() >= cutoff:
                    rows.append(row)
            except (ValueError, KeyError):
                continue
    if not rows:
        print('Нет сохранённых измерений')
        return
    latest = datetime.fromisoformat(rows[-1]["time"]).astimezone().isoformat(timespec="seconds")
    print(f'Последние {hours:g} ч: {len(rows)} измерений; последнее {latest}')
    for field, title in [('cpu_percent', 'CPU, % одного ядра'), ('footprint_mib', 'Physical footprint, МиБ')]:
        values = sorted(row[field] for row in rows if row.get(field) is not None)
        if values:
            print(f'{title}: среднее {sum(values) / len(values):.2f}, p95 {values[max(0, (95 * len(values) + 99) // 100 - 1)]:.2f}, максимум {values[-1]:.2f}')
    print('Недоступен:', sum(row['status'] != 'running' for row in rows))
    latest = rows[-1]
    age = max(0, int(time.time() - datetime.fromisoformat(latest['time']).timestamp()))
    print(f'Текущее состояние: {latest["status"]}; возраст {age} с; PID {latest.get("pid", "—")}')


def main():
    os.umask(0o077)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['collect', 'summary'])
    parser.add_argument('--data', type=Path, default=DATA)
    parser.add_argument('--logs', type=Path, default=LOGS)
    parser.add_argument('--helper', type=Path, default=DATA / 'aerospace-metrics')
    parser.add_argument('--hours', type=float, default=24)
    parser.add_argument('--no-notifications', action='store_true')
    args = parser.parse_args()
    if args.command == 'collect':
        args.logs.mkdir(parents=True, exist_ok=True, mode=0o700)
        error_output = args.logs / 'collector.error.log'
        if error_output.exists() and error_output.stat().st_size > 131072:
            os.replace(error_output, error_output.with_suffix('.log.1'))
        try:
            collect(args.data, args.logs, args.helper, not args.no_notifications)
        except Exception as error:
            now = time.time()
            message = 'Ошибка сбора метрик AeroSpace: ' + str(error)[:300]
            append_record(args.logs, 'events', {'time': datetime.fromtimestamp(now, timezone.utc).isoformat(),
                                              'kind': 'monitor_error', 'message': message}, now)
            args.data.mkdir(parents=True, exist_ok=True, mode=0o700)
            notice = args.data / 'failure-notice.json'
            try:
                last_notice = json.loads(notice.read_text()).get('time', 0) if notice.exists() else 0
            except (ValueError, OSError):
                last_notice = 0
            if not args.no_notifications and now - last_notice >= 900:
                try:
                    notify(message)
                except (OSError, subprocess.TimeoutExpired):
                    pass
                atomic_json(notice, {'time': now})
            prune(args.logs, now)
            raise SystemExit(1)
    else:
        summary(args.logs, args.hours)


if __name__ == '__main__':
    main()
