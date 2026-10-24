# AeroSpace background monitoring

A user LaunchAgent (`local.dotfiles.aerospace-monitor`) starts a short collector
once a minute. It reads kernel resource counters through libproc and the existing
LaunchAgent PID; it does not access Accessibility, move windows or contact a server.

- CPU is the change in user+system Mach CPU time divided by elapsed monotonic time;
  100% means one full core. The first sample, restarts and gaps over 150 seconds
  establish a new baseline rather than producing a misleading percentage.
- Physical footprint and RSS are recorded separately in MiB.
- CPU above 10% for five minutes and footprint above 150 MiB for ten minutes produce
  one notification per continuous episode. Returning below threshold rearms it.
- A stopped process and subsequent restart/recovery are reported once per transition.
- The error file is observed by inode and size; existing content is baselined on
  installation. New error bytes are batched with a ten-minute notification cooldown.
- A collector failure is logged and may notify at most once per fifteen minutes.

Notifications use the built-in macOS notification facility through `osascript`.
Their visibility follows macOS notification permissions and Focus settings.
`notification_submitted` in event history records successful submission, not proof
that the user saw the notification. No window titles or error-message contents are
stored in monitoring history.

Runtime files:

- `~/Library/Application Support/dotfiles/aerospace-monitor/`: executable helper,
  state, lock and a `health` command.
- `~/Library/Logs/dotfiles/aerospace-monitor/`: UTC daily metrics/events JSONL files.
  The current UTC date and six preceding dates are retained. Collector stderr has
  two bounded files (rotation after 128 KiB).
- `~/Library/LaunchAgents/local.dotfiles.aerospace-monitor.plist`.

Install/update with `python3 scripts/install-aerospace-monitor.py`. The installer
stops only the collector, preserves its state/history and leaves the AeroSpace
application and its LaunchAgent unchanged.

Run the installed `health` command from iTerm2 for a 24-hour summary; pass `--hours`
for another range. Sampling runs only while this user is logged in. No point is
fabricated for sleep or missed intervals, and no historical CPU percentage is
available before the second collection.

To stop:

```sh
launchctl bootout "gui/$(id -u)/local.dotfiles.aerospace-monitor"
```

To start again, bootstrap the saved plist. The monitor is independent of
`local.dotfiles.aerospace-main`; stopping it does not stop AeroSpace.
