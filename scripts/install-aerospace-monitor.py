#!/usr/bin/env python3
"""Compile and install the local user LaunchAgent; preserve existing metrics/state."""
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parent
user = Path.home()
data = user / 'Library/Application Support/dotfiles/aerospace-monitor'
logs = user / 'Library/Logs/dotfiles/aerospace-monitor'
plist = user / 'Library/LaunchAgents/local.dotfiles.aerospace-monitor.plist'
job = f'gui/{os.getuid()}/local.dotfiles.aerospace-monitor'
os.umask(0o077)

with tempfile.TemporaryDirectory(prefix='aerospace-monitor-build-') as temporary:
    executable = Path(temporary) / 'aerospace-metrics'
    sdk = subprocess.check_output(['xcrun', '--sdk', 'macosx', '--show-sdk-path'], text=True).strip()
    subprocess.run(['clang', '-Wall', '-Wextra', '-Werror', '-isysroot', sdk,
                    str(root / 'aerospace-metrics.c'), '-lproc', '-o', str(executable)], check=True)
    # Stop only this collector before updating its runtime files.
    if subprocess.run(['launchctl', 'print', job], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
        subprocess.run(['launchctl', 'bootout', job], check=True)
    data.mkdir(parents=True, exist_ok=True, mode=0o700)
    logs.mkdir(parents=True, exist_ok=True, mode=0o700)
    plist.parent.mkdir(parents=True, exist_ok=True)
    error_output = logs / 'collector.error.log'
    error_output.touch(mode=0o600, exist_ok=True)
    error_output.chmod(0o600)
    shutil.copy2(executable, data / 'aerospace-metrics')
    shutil.copy2(root / 'aerospace-monitor.py', data / 'collector.py')
    (data / 'aerospace-metrics').chmod(0o700)
    (data / 'collector.py').chmod(0o600)
    (data / 'health').write_text('#!/bin/bash\nexec /usr/bin/python3 "' + str(data / 'collector.py') + '" summary "$@"\n')
    (data / 'health').chmod(0o700)
    configuration = {
        'Label': 'local.dotfiles.aerospace-monitor',
        'ProgramArguments': ['/usr/bin/python3', str(data / 'collector.py'), 'collect'],
        'RunAtLoad': True, 'StartInterval': 60, 'ProcessType': 'Background', 'Umask': 0o077,
        'LimitLoadToSessionType': 'Aqua', 'StandardOutPath': '/dev/null',
        'StandardErrorPath': str(logs / 'collector.error.log'),
    }
    plist.write_bytes(plistlib.dumps(configuration))
    plist.chmod(0o600)
    subprocess.run(['plutil', '-lint', str(plist)], check=True)
    subprocess.run(['launchctl', 'bootstrap', f'gui/{os.getuid()}', str(plist)], check=True)
print('Enabled:', job)
print('Summary:', data / 'health')
