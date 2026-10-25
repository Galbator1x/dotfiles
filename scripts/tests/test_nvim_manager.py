"""Isolated installation fixtures; never download or launch the real Neovim."""

import importlib.util
from pathlib import Path
import subprocess
import shutil
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location(
    'nvim_manager', Path(__file__).resolve().parents[1] / 'nvim-manager.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def installation(path, number, broken=False):
    (path / 'bin').mkdir(parents=True)
    binary = path / 'bin/nvim'
    binary.write_text(
        '#!/bin/sh\n'
        'test -n "$NVIM_LOG_FILE" || exit 10\n'
        'test "$*" = "--headless -n -i NONE -u NONE --version" && { '
        f'echo "NVIM v0.13.0-dev-{number}+gabc{number}"; exit 0; }}\n'
        + ('exit 1\n' if broken else 'exit 0\n'))
    binary.chmod(0o755)
    return path


class ManagerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.manager = module.Manager(self.home)
        installation(self.manager.current, 0)

    def switch(self, number, broken=False):
        with self.manager.locked(), tempfile.TemporaryDirectory(dir=self.home) as td:
            work = Path(td)
            self.manager.switch(installation(work / 'new', number, broken))

    def test_retains_five_and_rollback_can_be_reversed(self):
        for n in range(1, 8):
            self.switch(n)
        self.assertEqual({p.name for p in self.manager.saved()},
                         {f'nvim-0.13.0-dev-{n}+gabc{n}' for n in range(2, 7)})
        self.manager.rollback(None)
        self.assertEqual(module.version(self.manager.current), '0.13.0-dev-6+gabc6')
        self.manager.rollback('0.13.0-dev-7+gabc7')
        self.assertEqual(module.version(self.manager.current), '0.13.0-dev-7+gabc7')
        self.assertEqual(len(self.manager.saved()), 5)

    def test_same_version_is_noop(self):
        self.switch(0)
        self.assertEqual(self.manager.saved(), [])

    def test_existing_duplicate_not_preserved_twice(self):
        self.manager.backups.mkdir()
        installation(self.manager.backups / 'nvim-0.13.0-dev-0+gabc0', 0)
        self.switch(1)
        self.assertEqual(len(self.manager.saved()), 1)
        self.assertEqual(module.version(self.manager.saved()[0]), '0.13.0-dev-0+gabc0')

    def test_broken_candidate_keeps_current(self):
        with self.assertRaises(subprocess.CalledProcessError):
            self.switch(1, broken=True)
        self.assertEqual(module.version(self.manager.current), '0.13.0-dev-0+gabc0')
        self.assertEqual(self.manager.saved(), [])

    def test_failed_move_restores_current(self):
        rename = Path.rename

        def fail_candidate(path, target):
            if path.name == 'new':
                raise OSError('simulated failed activation')
            return rename(path, target)

        with patch.object(Path, 'rename', fail_candidate), self.assertRaises(OSError):
            self.switch(1)
        self.assertEqual(module.version(self.manager.current), '0.13.0-dev-0+gabc0')

    def test_failed_backup_restores_both_installations(self):
        self.switch(1)
        rename = Path.rename

        def fail_backup(path, target):
            if path.name == '.previous' and Path(target).parent == self.manager.backups:
                raise OSError('simulated failed backup')
            return rename(path, target)

        with patch.object(Path, 'rename', fail_backup), self.assertRaises(OSError):
            self.manager.rollback(None)
        self.assertEqual(module.version(self.manager.current), '0.13.0-dev-1+gabc1')
        self.assertEqual(module.version(self.manager.saved()[0]), '0.13.0-dev-0+gabc0')

    def test_failed_download_or_extraction_never_moves_current(self):
        for failure in ['curl', 'tar']:
            def run(command, **kwargs):
                if command[0] == failure:
                    raise subprocess.CalledProcessError(1, command)
                return subprocess.CompletedProcess(command, 0)

            with patch.object(module.subprocess, 'run', side_effect=run):
                with self.assertRaises(subprocess.CalledProcessError):
                    self.manager.update()
            self.assertEqual(module.version(self.manager.current), '0.13.0-dev-0+gabc0')
            self.assertFalse((self.manager.backups / '.lock').exists())
            self.assertFalse(list(self.home.glob('.nvim-update-*')))

    def test_update_with_local_archive(self):
        candidate = installation(self.home / 'fixture/nvim-macos-arm64', 1)
        archive = self.home / 'fixture.tar.gz'
        with tarfile.open(archive, 'w:gz') as output:
            output.add(candidate, arcname='nvim-macos-arm64')
        real_run = subprocess.run

        def run(command, **kwargs):
            if command[0] == 'curl':
                shutil.copyfile(archive, command[command.index('--output') + 1])
                return subprocess.CompletedProcess(command, 0)
            return real_run(command, **kwargs)

        with patch.object(module.subprocess, 'run', side_effect=run):
            self.manager.update()
        self.assertEqual(module.version(self.manager.current), '0.13.0-dev-1+gabc1')
        self.assertEqual(module.version(self.manager.saved()[0]), '0.13.0-dev-0+gabc0')
        self.assertFalse(list(self.home.glob('.nvim-update-*')))

    def test_failed_restoration_preserves_recovery_files(self):
        rename = Path.rename

        def fail_activation_and_restore(path, target):
            if path.name in ('new', '.previous'):
                raise OSError('simulated unavailable destination')
            return rename(path, target)

        with patch.object(Path, 'rename', fail_activation_and_restore):
            with self.assertRaises(OSError):
                self.switch(1)
        self.assertEqual(module.version(self.manager.backups / '.previous'),
                         '0.13.0-dev-0+gabc0')
        with self.assertRaises(ValueError):
            self.manager.update()

    def test_lock_prevents_concurrent_changes(self):
        with self.manager.locked(), self.assertRaises(ValueError):
            self.manager.update()

    def test_symlink_installation_is_rejected(self):
        self.manager.current.rename(self.home / 'real')
        self.manager.current.symlink_to(self.home / 'real')
        with self.assertRaises(ValueError):
            self.manager.update()


if __name__ == '__main__':
    unittest.main()
