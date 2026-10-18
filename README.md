# dotfiles

## Floating window positions

AeroSpace restores explicitly saved window positions when entering their saved
workspace. On an English keyboard layout, press Option+Shift+P to save the focused
application's window size, position, and workspace. Press Option+Control+Shift+P
to forget its saved position. After moving or resizing the window, save it again.

Use this for floating applications with one standard window. Applications with
multiple standard windows, minimized windows, and native fullscreen windows are
skipped. Saved coordinates are absolute; save again after changing monitors or
display resolution. Geometry is stored per application across restarts under
`~/Library/Application Support/dotfiles/window-positions/`.

The scripts require macOS Automation/Accessibility access for AeroSpace to
control System Events.
