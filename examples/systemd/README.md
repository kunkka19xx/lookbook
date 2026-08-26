# systemd

Your user services as rows, running or not. The preview pane shows the last 40 lines of a service's log, `Cmd+K` restarts, stops or starts it, and Enter opens a terminal following the log live.

**Requires.** Look v0.6.12 or newer, and systemd. A terminal emulator for the `open` line.

**Platforms.** Linux. Tested on NixOS. Nothing here works on macOS or Windows, which have launchd and the Service Control Manager instead.

## Install

```bash
cp examples/systemd/*.toml ~/.look/sources/
```

Reload with `Ctrl+Shift+;`.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `systemd-units` | every `--user` service, active or not | follows the log in a terminal |
| `systemd-units-restart` | on a service, via `Cmd+K` | restarts it, after asking |
| `systemd-units-stop` | on a service, via `Cmd+K` | stops it, after asking |
| `systemd-units-start` | on a service, via `Cmd+K` | starts it |

## Why `--user` and not system units

Every command here is `--user`. A user unit belongs to your session and needs no privileges, which matters more than it sounds: **a launcher cannot answer a password prompt.** Steps run with no stdin and no TTY, so a `sudo` in one of these lines has nowhere to ask and simply hangs or fails silently.

To manage system units, drop `--user` from all five commands. Then:

- **Listing and previewing still work.** Reading unit state and the journal needs no privileges, though your own user only sees its own journal unless it is in the `systemd-journal` group.
- **Restart, stop and start go through polkit.** If your desktop runs a polkit authentication agent, you get a graphical prompt, which works because the agent is its own process rather than something this step has to talk to. With no agent running you get `Interactive authentication required` and nothing happens.

If you want both, keep two files: `systemd-units.toml` as it is, and a copy with `--user` dropped, every block id renamed (`systemd-system`, `systemd-system-restart`, …) and its own `name`. They are separate blocks and install independently.

## Customise

- **`open` names your terminal.** As written it is `ghostty -e journalctl --user -u {id} -f`. Others: `kitty journalctl --user -u {id} -f`, `wezterm start -- journalctl --user -u {id} -f`, `gnome-terminal -- journalctl --user -u {id} -f`. Drop the line entirely and Enter does nothing, since these rows have no path.
- **Hide the noise.** A session has a lot of `dbus-:1.x-org.…` units in it. Pipe the listing through `grep -v '^dbus-:'` before the `awk` if you would rather not see them.
- **Only what is running**: swap `--all` for `--state=running`. **Only what is broken**: `--state=failed`, which makes a short, useful list.
- **Timers** are the same shape with a different producer: `systemctl --user list-timers --all --no-legend`. Add it as a second file, `systemd-timers.toml`, with block ids to match.
- **Per-row status glyphs** need `format = "json"` and an `icon` per row; the [docker](../docker) example shows that shape. Words in the subtitle were chosen here instead because `active · running · Accessibility services bus` reads better than a coloured dot.

## Note on the row id

The id keeps its `.service` suffix because that is what `systemctl` wants handed back; the title drops it because that is what you are reading. When systemd has no description for a unit it prints the unit name in that column, so a description identical to the unit name is dropped rather than shown to you twice.
