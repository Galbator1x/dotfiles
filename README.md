# dotfiles

## Bash startup files

`~/.bashrc` links to `files/bashrc`, and `~/.bash_profile` links to
`files/bash_profile`, which sources `~/.bashrc`. Interactive login and non-login
shells therefore share aliases, completion, vi mode, and shell integrations.
The configuration avoids adding duplicate PATH entries and loading integrations
again when sourced twice in the same shell.

## Neovim nightly updates and rollback

Close running Neovim sessions before replacing their runtime files.

- `nvim-update` downloads and checks the nightly in a temporary directory before
  replacing `~/nvim-macos-arm64`. A failed replacement restores the previous install.
- `nvim-versions` lists the current version and backups, newest saved first.
- `nvim-rollback` swaps the current installation with the most recently saved backup.
  Pass a version or its directory name to select another backup.

Backups live in `~/nvim-backups/nvim-<full-version>`, with at most five previous
versions plus the current installation. Duplicate versions are not saved twice;
updating to the current version does nothing. Old backups are pruned only after
a successful switch. Rollback also saves the installation being replaced.
Existing manually saved directories outside `nvim-backups` are left untouched.
Plugins, Mason packages, parsers, and configuration are not included in backups.
If a switch is interrupted, `.previous` inside `nvim-backups` preserves the old
installation, and `.lock` prevents concurrent operations. Inspect these recovery
files before retrying; do not delete `.previous` without recovering its contents.

Run isolated checks without downloading or replacing the real editor:

```sh
python3 -B scripts/tests/test_nvim_manager.py
```

## Russian Ctrl shortcuts in iTerm2

Import `files/iterm2-keybindings.itermkeymap` in iTerm2 via Settings → Profiles →
Default → Keys → Key Mappings → Presets → Import. This file includes the profile's
existing bindings at the time it was created; export the current preset before
reimporting it if you have since changed your shortcuts, because importing
replaces the profile's key mappings.

Russian Ctrl+letter combinations send the same control bytes as their English
QWERTY keys. Ctrl+х and Ctrl+ъ send Ctrl+[ and Ctrl+] as well. This applies to
every application in that iTerm2 profile, including all Neovim modes and the shell.
Plain Russian typing and the English Ctrl shortcuts keep their usual behavior.
Neovim's `langmap` handles plain Normal/Visual commands; no mode-dependent
switching or separate Cyrillic Ctrl mappings are needed in Neovim.

## Codex instructions

Global Codex instructions are stored in `files/codex-agents.md` and linked to
`~/.codex/AGENTS.md`. To restore the link on another machine (preserve any existing
instructions first):

```sh
mkdir -p ~/.codex
ln -s ~/projects/dotfiles/files/codex-agents.md ~/.codex/AGENTS.md
```

Repository-specific instructions are stored in the root `AGENTS.md`.

- [ ] When trying another agent harness or Claude Code, revisit global agent
  instructions: decide which guidance should be shared and how to connect it to
  each tool's instruction files (`AGENTS.md`, `CLAUDE.md`, etc.).

## Floating window positions

AeroSpace restores explicitly saved window positions when entering their saved
workspace. On an English keyboard layout, press Option+Shift+P to save the focused
application's window size, position, and workspace. Press Option+Control+Shift+P
to forget its saved position. After moving or resizing the window, save it again.

Use this for floating applications with one managed standard window. Applications
with multiple managed windows, tiled windows, minimized windows, and fullscreen
windows are skipped. The Accessibility window must match AeroSpace's window ID.
Saved coordinates are absolute; save again after changing monitors or
display resolution. Geometry is stored per application across restarts under
`~/Library/Application Support/dotfiles/window-positions/`.

Build the Swift helper once after installation or changing its source (requires
Xcode Command Line Tools):

```sh
bash ~/projects/dotfiles/scripts/window-position.sh build
```

It is installed at `~/Library/Caches/dotfiles/window-position-helper`.
Add this helper to System Settings → Privacy & Security → Accessibility and
enable its access. In the file picker, press Command+Shift+G and paste the path
above. macOS also considers the launching app: a `check-access` invocation from
Terminal or Codex can report different access than the same helper launched by
AeroSpace. A denial from that terminal check alone does not diagnose a hotkey failure.
After rebuilding, macOS may require removing and adding this helper in
Accessibility again because the locally built executable uses an ad-hoc signature.
The helper uses the same private window-ID API as AeroSpace; macOS updates can
affect compatibility.

Newer workspace callbacks cancel pending restores. A pending save cannot undo a
subsequent forget or overwrite a newer saved position. Workspace checks
run immediately before each geometry write, but macOS and AeroSpace do not offer
an atomic check-and-move operation: a narrow switching race remains possible.

### Local checks and diagnostics

Check the real AeroSpace CLI command used by restores, without moving windows:

```sh
bash ~/projects/dotfiles/scripts/window-position.sh check
```

Run `window-position.sh diagnose` to collect the window ID, layout, workspace,
saved/current geometry, and why a window was skipped. For AeroSpace's permission
context, launch it through a temporary AeroSpace callback during investigation
and remove that callback afterward. The last report is stored at
`~/Library/Logs/dotfiles/window-position-check.log`; it omits window titles and
app content. Ordinary workspace callbacks do not produce these logs.

To check real restoration: save with Option+Shift+P, move the window slightly,
switch away and back, then compare current and saved geometry using diagnostics
in AeroSpace's context. This is a manual local check; no background monitoring
is installed.

Regression checks (isolated fixtures; do not move real windows):

```sh
swiftc scripts/window-position.swift -o /tmp/window-position-helper
python3 scripts/tests/test_window_position.py /tmp/window-position-helper
```
