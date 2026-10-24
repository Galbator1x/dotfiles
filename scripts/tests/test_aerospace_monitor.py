import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location('monitor', Path(__file__).parents[1] / 'aerospace-monitor.py')
monitor = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(monitor)


def sample(t, cpu=0, memory=20, pid=123, start=1):
    return {'pid': pid, 'start': start, 'monotonic': t, 'cpu_ns': cpu * 1e9,
            'footprint_bytes': memory * 1048576, 'rss_bytes': 50 * 1048576}


class MonitorTest(unittest.TestCase):
    def test_cpu_alert_after_five_full_minutes_and_once_per_episode(self):
        state, _, _ = monitor.evaluate({}, sample(0), 1000, None, 0)
        alerts = []
        for minute in range(1, 8):
            state, row, events = monitor.evaluate(state, sample(minute * 60, minute * 12),
                                                  1000 + minute * 60, None, 0)
            self.assertAlmostEqual(row['cpu_percent'], 20)
            alerts.extend((minute, kind) for kind, _ in events)
        self.assertEqual(alerts, [(5, 'cpu')])
        state, _, _ = monitor.evaluate(state, sample(480, 84), 1480, None, 0)
        self.assertFalse(state['cpu_alerted'])

    def test_memory_alert_after_ten_minutes(self):
        state = {}
        events = []
        for minute in range(12):
            state, _, current = monitor.evaluate(state, sample(minute * 60, memory=160),
                                                 1000 + minute * 60, None, 0)
            events.extend((minute, kind) for kind, _ in current)
        self.assertEqual(events, [(10, 'memory')])

    def test_gap_reboot_and_pid_reuse_reset_cpu_and_thresholds(self):
        state, _, _ = monitor.evaluate({}, sample(100, 200, 160), 1000, None, 0)
        state, row, events = monitor.evaluate(state, sample(110, 210, 160), 2000, None, 0)
        self.assertIsNone(row['cpu_percent'])
        self.assertEqual(state['memory_since'], 2000)
        state, row, events = monitor.evaluate(state, sample(5, 1, pid=123, start=2), 2060, None, 0)
        self.assertIsNone(row['cpu_percent'])
        self.assertEqual([kind for kind, _ in events], ['restart'])

    def test_outage_once_then_restart_without_duplicate_recovery(self):
        state, _, events = monitor.evaluate({}, sample(1), 1000, None, 0)
        self.assertEqual(events, [])
        state, _, events = monitor.evaluate(state, None, 1060, None, 0)
        self.assertEqual([kind for kind, _ in events], ['down'])
        state, _, events = monitor.evaluate(state, None, 1120, None, 0)
        self.assertEqual(events, [])
        state, _, events = monitor.evaluate(state, sample(121, pid=124), 1180, None, 0)
        self.assertEqual([kind for kind, _ in events], ['restart'])

    def test_errors_baseline_growth_rotation_and_creation(self):
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / 'errors'
            cursor, growth = monitor.error_delta(path, None)
            self.assertEqual(growth, 0)
            path.write_text('new error')
            cursor, growth = monitor.error_delta(path, cursor)
            self.assertEqual(growth, 9)
            baseline, growth = monitor.error_delta(path, None)
            self.assertEqual(growth, 0)
            path.write_text('new error more')
            cursor, growth = monitor.error_delta(path, cursor)
            self.assertEqual(growth, 5)
            path.rename(path.with_suffix('.old'))
            path.write_text('rotated')
            _, growth = monitor.error_delta(path, cursor)
            self.assertEqual(growth, 7)

    def test_error_notifications_batch_and_keep_unnotified_bytes(self):
        state, _, events = monitor.evaluate({}, sample(1), 1000, None, 10)
        self.assertEqual([kind for kind, _ in events], ['errors'])
        state, _, events = monitor.evaluate(state, sample(61), 1060, None, 20)
        self.assertEqual(events, [])
        self.assertEqual(state['pending_error_bytes'], 20)
        state, _, events = monitor.evaluate(state, sample(121), 1600, None, 0)
        self.assertEqual([kind for kind, _ in events], ['errors'])
        self.assertIn('20', events[0][1])

    def test_retention_only_deletes_old_owned_daily_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            for name in ['metrics-2026-10-17.jsonl', 'events-2026-10-17.jsonl',
                         'metrics-2026-10-18.jsonl', 'collector.error.log', 'other.jsonl']:
                (root / name).touch()
            now = monitor.datetime(2026, 10, 24, tzinfo=monitor.timezone.utc).timestamp()
            monitor.prune(root, now)
            self.assertEqual(sorted(p.name for p in root.iterdir()),
                             ['collector.error.log', 'metrics-2026-10-18.jsonl', 'other.jsonl'])

    def test_collect_persists_history_state_and_no_normal_notifications(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            with patch.object(monitor, 'sample_process', return_value=sample(1)), \
                 patch.object(monitor, 'ERROR_LOG', root / 'absent-errors'), \
                 patch.object(monitor, 'notify') as notify:
                monitor.collect(root / 'data', root / 'logs', root / 'helper')
            notify.assert_not_called()
            self.assertTrue((root / 'data/state.json').exists())
            self.assertEqual(len(list((root / 'logs').glob('metrics-*.jsonl'))), 1)
            self.assertEqual((root / 'data/state.json').stat().st_mode & 0o777, 0o600)


if __name__ == '__main__':
    unittest.main()
