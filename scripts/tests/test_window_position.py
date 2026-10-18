"""Regression checks using isolated AeroSpace/helper fixtures; no real windows move.

Run: python3 scripts/tests/test_window_position.py /path/to/compiled/helper
"""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest

SCRIPTS = Path(__file__).resolve().parents[1]
HELPER = Path(sys.argv.pop(1)).resolve() if len(sys.argv) > 1 else None


@unittest.skipIf(HELPER is None, "Pass the compiled Swift helper")
class WindowPositionTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.state = self.root / "state"
        self.positions = self.state / "window-positions"
        self.positions.mkdir(parents=True)
        self.cache = self.root / "cache"
        self.cache.mkdir()
        self.fixture = self.root / "fixture.json"
        self.log = self.root / "writes"
        self.started = self.root / "started"
        self.queries = self.root / "queries"
        self.aerospace = self.root / "aerospace"
        self.aerospace.write_text(
            "#!/usr/bin/python3\n"
            "import json, pathlib, sys\n"
            f"f=json.loads(pathlib.Path({str(self.fixture)!r}).read_text())\n"
            f"pathlib.Path({str(self.started)!r}).touch()\n"
            f"with open({str(self.queries)!r}, 'a') as log: log.write(json.dumps(sys.argv[1:])+'\\n')\n"
            "a=sys.argv[1:]\n"
            "if a[0]=='list-windows' and '--all' in a and '--app-bundle-id' in a:\n"
            " sys.exit('--all conflicts with filtering flags; use --monitor all')\n"
            "if a[0]=='list-workspaces': print(f['workspace'])\n"
            "elif '--focused' in a:\n"
            " print('example.App' if a[-1]=='%{app-bundle-id}' else '42')\n"
            "else: print(f['windows'])\n"
        )
        self.aerospace.chmod(0o755)
        self.fake_helper = self.cache / "window-position-helper"
        self.fake_helper.write_text(
            "#!/usr/bin/python3\n"
            "import os, pathlib, sys\n"
            f"p=pathlib.Path({str(self.log)!r})\n"
            f"if sys.argv[1] in ('begin','commit'): os.execv({str(HELPER)!r}, [{str(HELPER)!r}]+sys.argv[1:])\n"
            "if sys.argv[1]=='save': print('100 120 600 700')\n"
            "else: p.write_text(' '.join(sys.argv[1:]))\n"
        )
        self.fake_helper.chmod(0o755)
        # Copy the runner with isolated storage; keep the actual control flow intact.
        source = (SCRIPTS / "window-position.sh").read_text()
        self.assertEqual(source.count('state_root="$HOME/Library/Application Support/dotfiles"'), 1)
        self.assertEqual(source.count('helper_dir="$HOME/Library/Caches/dotfiles"'), 1)
        source = source.replace('state_root="$HOME/Library/Application Support/dotfiles"',
                                f"state_root='{self.state}'")
        source = source.replace('helper_dir="$HOME/Library/Caches/dotfiles"',
                                f"helper_dir='{self.cache}'")
        self.runner = self.root / "runner.sh"
        self.runner.write_text(source)
        self.env = dict(os.environ, PATH=f"{self.root}:/usr/bin:/bin")
        self.env.pop("AEROSPACE_FOCUSED_WORKSPACE", None)
        self.configure()

    def configure(self, workspace="E", windows="42|E|floating|false"):
        replacement = self.root / "fixture.new"
        replacement.write_text(json.dumps(dict(workspace=workspace, windows=windows)))
        replacement.replace(self.fixture)

    def save_file(self, text="E\n100 120 600 700\n", bundle="example.App"):
        path = self.positions / f"{bundle}.txt"
        path.write_text(text)
        return path

    def run_script(self, action="restore"):
        return subprocess.run(["/bin/bash", str(self.runner), action], env=self.env,
                              capture_output=True, text=True, timeout=10)

    def paused_restore(self):
        waiting = self.root / "restore-waiting"
        release = self.root / "restore-release"
        source = self.fake_helper.read_text()
        pause = (
            "if sys.argv[1]=='begin' and os.environ.get('WINDOW_POSITION_TEST_PAUSE'):\n"
            " import subprocess, time\n"
            f" result=subprocess.run([{str(HELPER)!r}]+sys.argv[1:], capture_output=True)\n"
            f" pathlib.Path({str(waiting)!r}).touch()\n"
            f" while not pathlib.Path({str(release)!r}).exists(): time.sleep(.01)\n"
            " sys.stdout.buffer.write(result.stdout)\n"
            " sys.stderr.buffer.write(result.stderr)\n"
            " sys.exit(result.returncode)\n"
        )
        source = source.replace("if sys.argv[1] in ('begin','commit'):", pause + "if sys.argv[1] in ('begin','commit'):")
        self.fake_helper.write_text(source)
        pending = subprocess.Popen(["/bin/bash", str(self.runner), "restore"],
                                   env=dict(self.env, WINDOW_POSITION_TEST_PAUSE="1"),
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        def cleanup():
            release.touch()
            pending.communicate(timeout=10)
        self.addCleanup(cleanup)
        deadline = time.monotonic() + 5
        while not waiting.exists() and time.monotonic() < deadline:
            time.sleep(0.01)
        self.assertTrue(waiting.exists())
        return pending, release

    def test_restore_passes_saved_geometry_to_helper(self):
        self.save_file()
        self.assertEqual(self.run_script().returncode, 0)
        self.assertIn("example.App E auto 100 120 600 700", self.log.read_text())

    def test_missing_helper_does_not_trigger_runtime_build(self):
        self.save_file()
        self.fake_helper.unlink()
        result = self.run_script()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Build the helper first", result.stderr)
        self.assertFalse(self.fake_helper.exists())

    def test_corrupt_file_does_not_abort_other_restores(self):
        self.save_file("E\n", bundle="aaa.Broken")
        self.save_file()
        self.assertEqual(self.run_script().returncode, 0)
        self.assertTrue(self.log.exists())

    def test_leaving_cancels_pending_restore_even_after_return(self):
        self.save_file()
        pending, release = self.paused_restore()
        self.configure(workspace="empty", windows="")
        self.assertEqual(self.run_script().returncode, 0)
        self.configure()
        release.touch()
        pending.communicate(timeout=10)
        self.assertEqual(pending.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_save_and_forget(self):
        self.assertEqual(self.run_script("save").returncode, 0)
        saved = self.positions / "example.App.txt"
        self.assertEqual(saved.read_text(), "E\n100 120 600 700\n")
        self.assertEqual(self.run_script("forget").returncode, 0)
        self.assertFalse(saved.exists())

    def test_pending_save_cannot_undo_forget(self):
        saved = self.save_file()
        waiting = self.root / "save-waiting"
        release = self.root / "save-release"
        source = self.fake_helper.read_text()
        source = source.replace(
            "if sys.argv[1]=='save': print('100 120 600 700')",
            "if sys.argv[1]=='save':\n"
            f" pathlib.Path({str(waiting)!r}).touch()\n"
            " import time\n"
            f" while not pathlib.Path({str(release)!r}).exists(): time.sleep(.01)\n"
            " print('100 120 600 700')",
        )
        self.fake_helper.write_text(source)
        pending = subprocess.Popen(["/bin/bash", str(self.runner), "save"], env=self.env,
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            deadline = time.monotonic() + 5
            while not waiting.exists() and time.monotonic() < deadline:
                time.sleep(0.01)
            self.assertTrue(waiting.exists())
            self.assertEqual(self.run_script("forget").returncode, 0)
            self.assertFalse(saved.exists())
            release.touch()
            output, error = pending.communicate(timeout=10)
            self.assertEqual(pending.returncode, 0, error)
            self.assertFalse(saved.exists(), "An obsolete save recreated the forgotten position")
            self.assertNotIn(b"Saved", output)
        finally:
            release.touch()
            if pending.poll() is None:
                pending.kill()
            pending.communicate(timeout=10)

    def test_stale_commit_cannot_overwrite_or_delete_new_position(self):
        token = self.state / "token"
        token.write_text("new\n")
        saved = self.save_file()
        new_contents = "E\n200 220 800 900\n"
        def commit(generation, action, contents=None):
            arguments = [str(HELPER), "commit", str(token), generation, str(saved), action]
            if contents is not None:
                arguments.append(contents)
            result = subprocess.run(arguments, capture_output=True, text=True, timeout=10)
            self.assertEqual(result.returncode, 0, result.stderr)
            return result.stdout.strip()
        self.assertEqual(commit("new", "save", new_contents), "committed")
        self.assertEqual(commit("old", "save", "E\n0 0 500 500\n"), "superseded")
        self.assertEqual(commit("old", "forget"), "superseded")
        self.assertEqual(saved.read_text(), new_contents)

    def test_obsolete_callback_does_not_cancel_current_restore(self):
        self.save_file()
        pending, release = self.paused_restore()
        obsolete_env = dict(self.env, AEROSPACE_FOCUSED_WORKSPACE="W")
        result = subprocess.run(["/bin/bash", str(self.runner), "restore"], env=obsolete_env,
                                capture_output=True, timeout=10)
        self.assertEqual(result.returncode, 0)
        release.touch()
        pending.communicate(timeout=10)
        self.assertEqual(pending.returncode, 0)
        self.assertTrue(self.log.exists(), "Obsolete W callback cancelled the current E restore")

    def test_workspace_check_and_publication_are_serialized(self):
        self.configure(workspace="W")
        waiting = self.root / "waiting"
        release = self.root / "release"
        original = self.aerospace.read_text()
        barrier = (
            "if sys.argv[1]=='list-workspaces' and f['workspace']=='W':\n"
            f" pathlib.Path({str(waiting)!r}).touch()\n"
            " import time\n"
            f" while not pathlib.Path({str(release)!r}).exists(): time.sleep(.01)\n"
        )
        self.aerospace.write_text(original.replace("a=sys.argv[1:]\n", barrier + "a=sys.argv[1:]\n"))
        token = self.state / "token"
        processes = []
        try:
            old = subprocess.Popen([str(HELPER), "begin", str(self.aerospace), "W", str(token)],
                                   stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            processes.append(old)
            deadline = time.monotonic() + 5
            while not waiting.exists() and time.monotonic() < deadline:
                time.sleep(0.01)
            self.assertTrue(waiting.exists())
            self.configure()
            current = subprocess.Popen([str(HELPER), "begin", str(self.aerospace), "E", str(token)],
                                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            processes.append(current)
            # E must wait while W holds the lock across its suspended workspace query.
            time.sleep(0.2)
            self.assertIsNone(current.poll(), "E published a token while W could still overwrite it")
            release.touch()
            old.communicate(timeout=10)
            output, error = current.communicate(timeout=10)
            self.assertEqual(old.returncode, 0)
            self.assertEqual(current.returncode, 0, error)
            workspace, generation = output.decode().splitlines()
            self.assertEqual(workspace, "E")
            self.assertEqual(token.read_text().strip(), generation)
        finally:
            release.touch()
            for process in processes:
                if process.poll() is None:
                    process.kill()
                process.communicate(timeout=10)

    @unittest.skipIf(HELPER is None, "Pass the compiled Swift helper to test its real guards")
    def test_swift_rechecks_layout_id_workspace_and_cancellation(self):
        token = self.state / "token"
        token.write_text("current")
        cases = [
            ("E", "42|E|h_tiles|false", "current"),
            ("E", "42|E|floating|true", "current"),
            ("E", "99|E|floating|false", "current"),
            ("E", "42|W|floating|false", "current"),
            ("empty", "42|E|floating|false", "current"),
            ("E", "42|E|floating|false\n99|E|floating|false", "current"),
            ("E", "42|E|floating|false", "old"),
        ]
        for workspace, windows, generation in cases:
            with self.subTest(workspace=workspace, windows=windows, generation=generation):
                self.configure(workspace, windows)
                self.queries.write_text("")
                result = subprocess.run([
                    str(HELPER), "restore", str(self.aerospace), "example.App", "E", "42",
                    "100", "120", "600", "700", str(token), generation,
                ], capture_output=True, text=True, timeout=10)
                self.assertEqual(result.returncode, 0, result.stderr)
                queries = [json.loads(line) for line in self.queries.read_text().splitlines()]
                if generation == "old":
                    self.assertEqual(queries, [])
                elif workspace != "E":
                    self.assertEqual(queries, [["list-workspaces", "--focused"]])
                else:
                    self.assertEqual(len(queries), 3 if windows == "99|E|floating|false" else 2)
                    self.assertEqual(queries[0], ["list-workspaces", "--focused"])
                    self.assertEqual(queries[1], [
                        "list-windows", "--monitor", "all", "--app-bundle-id", "example.App",
                        "--format", "%{window-id}|%{workspace}|%{window-layout}|%{window-is-fullscreen}",
                    ])

    @unittest.skipIf(HELPER is None, "Pass the compiled Swift helper to test window selection")
    def test_swift_auto_selection_skips_unsupported_windows(self):
        token = self.state / "token"
        token.write_text("current")
        for windows in ("42|E|h_tiles|false", "42|E|floating|true",
                        "42|W|floating|false", "42|E|floating|false\n43|W|floating|false", ""):
            with self.subTest(windows=windows):
                self.configure(windows=windows)
                self.queries.write_text("")
                result = subprocess.run([
                    str(HELPER), "restore", str(self.aerospace), "example.App", "E", "auto",
                    "100", "120", "600", "700", str(token), "current",
                ], capture_output=True, text=True, timeout=10)
                self.assertEqual(result.returncode, 0, result.stderr)
                queries = [json.loads(line) for line in self.queries.read_text().splitlines()]
                self.assertEqual(len(queries), 2)
                self.assertEqual(queries[0], ["list-workspaces", "--focused"])
                self.assertEqual(queries[1][0], "list-windows")


if __name__ == "__main__":
    unittest.main()
