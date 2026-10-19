# dotfiles

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
