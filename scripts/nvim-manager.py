#!/usr/bin/env python3
"""Manage the downloaded macOS arm64 Neovim installation and five backups."""

import argparse
from contextlib import contextmanager
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


URL = 'https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz'
VERSION = re.compile(r'NVIM v([A-Za-z0-9][A-Za-z0-9.+_-]*)$')
BACKUP = re.compile(r'nvim-[A-Za-z0-9][A-Za-z0-9.+_-]*$')


def version(installation, check_startup=False):
    # Even --version can write a log before Neovim reads its configuration.
    with tempfile.TemporaryDirectory(prefix='nvim-check-') as directory:
        env = dict(os.environ, NVIM_LOG_FILE=str(Path(directory) / 'nvim.log'))
        command = [str(installation / 'bin/nvim'), '--headless', '-n', '-i', 'NONE', '-u', 'NONE']
        result = subprocess.run(command + ['--version'], env=env, capture_output=True,
                                text=True, check=True, timeout=20)
        match = VERSION.fullmatch(result.stdout.splitlines()[0])
        if not match:
            raise ValueError('Cannot determine Neovim version')
        if check_startup:
            subprocess.run(command + ['+lua assert(vim.fn.has("nvim") == 1)', '+qa'],
                           env=env, capture_output=True, text=True, check=True, timeout=20)
        return match.group(1)


class Manager:
    def __init__(self, home):
        self.current = home / 'nvim-macos-arm64'
        self.backups = home / 'nvim-backups'

    def saved(self):
        if not self.backups.exists():
            return []
        return sorted((p for p in self.backups.iterdir()
                       if BACKUP.fullmatch(p.name) and p.is_dir() and not p.is_symlink()),
                      key=lambda p: (p.stat().st_mtime_ns, p.name), reverse=True)

    @contextmanager
    def locked(self):
        if self.current.is_symlink() or self.backups.is_symlink():
            raise ValueError('Installation and backup directory must not be symlinks')
        self.backups.mkdir(exist_ok=True)
        lock = self.backups / '.lock'
        try:
            lock.mkdir()
        except FileExistsError:
            raise ValueError('Another operation is running (nvim-backups/.lock exists)')
        try:
            if (self.backups / '.previous').exists():
                raise ValueError('Interrupted switch: recover nvim-backups/.previous first')
            yield
        finally:
            lock.rmdir()

    def switch(self, candidate):
        new_version = version(candidate, check_startup=True)
        old_version = version(self.current) if self.current.exists() else None
        if old_version == new_version:
            print(f'Already using {new_version}; no duplicate saved.')
            return
        destination = self.backups / f'nvim-{old_version}' if old_version else None
        if destination and destination.exists() and destination not in self.saved():
            raise ValueError(f'Unsafe backup destination: {destination}')
        # Keep recovery files outside temporary directories, even if restoration fails.
        old = self.backups / '.previous'
        if old_version:
            self.current.rename(old)
        try:
            candidate.rename(self.current)
            if old_version:
                if not destination.exists():
                    old.rename(destination)
                os.utime(destination, None)
        except BaseException:
            # Restore both sides if activation or saving the old installation fails.
            if self.current.exists():
                self.current.rename(candidate)
            if old.exists():
                old.rename(self.current)
            elif destination and destination.exists():
                destination.rename(self.current)
            raise
        if old.exists():
            shutil.rmtree(old)  # The same version is already safely stored in backups.
        for obsolete in self.saved()[5:]:
            shutil.rmtree(obsolete)
        print(f'Now using {new_version}. Backups: {len(self.saved())}/5.')

    def update(self):
        with self.locked(), tempfile.TemporaryDirectory(
                prefix='.nvim-update-', dir=self.current.parent) as directory:
            work = Path(directory)
            archive = work / 'nvim.tar.gz'
            subprocess.run(['curl', '--fail', '--location', '--show-error', '--output',
                            str(archive), URL], check=True)
            subprocess.run(['tar', 'xzf', str(archive), '-C', str(work)], check=True)
            self.switch(work / 'nvim-macos-arm64')

    def rollback(self, requested):
        with self.locked():
            saved = self.saved()
            if requested:
                name = requested if requested.startswith('nvim-') else f'nvim-{requested}'
                saved = [p for p in saved if p.name == name]
            if not saved:
                raise ValueError('No matching backup; use nvim-versions to list backups')
            self.switch(saved[0])

    def list_versions(self):
        print('Current:', version(self.current) if self.current.exists() else 'not installed')
        for p in self.saved():
            print(p.name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    commands.add_parser('update')
    commands.add_parser('list')
    commands.add_parser('rollback').add_argument('version', nargs='?')
    args = parser.parse_args()
    manager = Manager(Path.home())
    try:
        if args.command == 'update':
            manager.update()
        elif args.command == 'rollback':
            manager.rollback(args.version)
        else:
            manager.list_versions()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        parser.exit(1, f'Neovim: {error}\n')


if __name__ == '__main__':
    main()
