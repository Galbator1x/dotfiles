# dotfiles

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

Regression checks (isolated fixtures; do not move real windows):

```sh
swiftc scripts/window-position.swift -o /tmp/window-position-helper
python3 scripts/tests/test_window_position.py /tmp/window-position-helper
```
