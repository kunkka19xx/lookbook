# vpn

Whether your VPN is up, on the empty home screen, and one press to flip it. `ON` in the active tint, `OFF` in the plain one, with the connection's name under it.

Both shapes at once: a `value` that reads, and a `press` that acts. It is also the example for the two things a readout can do that a plain number cannot, namely take the toggle treatment with `state`, and **remove itself** from the strip on a machine that has nothing to report.

**Requires.** Look v0.6.13 or newer, and NetworkManager (`nmcli`), which is what GNOME and KDE already use to manage connections.

**Platforms.** Linux, tested on NetworkManager with `nmcli`. The macOS equivalent is two lines and is written out below, but it is **untested** and is not shipped as a file for that reason.

## Install

Tiles are merged, not copied. Two edits in `~/.look/super-actions.toml`:

1. Put `vpn` in the `layout` drawing. Give it two cells across if you want the connection name to have room:

   ```toml
   layout = [
       "lslot       lslot       vpn         vpn         battery     weather",
       "lslot       lslot       theme       keepawake   screensaver weather",
       "mic         restart     shutdown    nowplaying  nowplaying  nowplaying",
   ]
   ```

2. Paste the block from [`vpn-linux.toml`](vpn-linux.toml) onto the end of the file.

`make show NAME=vpn` prints it. Reload with `Ctrl+Shift+;`.

## The tile

| Tile | Shows | Press |
| --- | --- | --- |
| `vpn` | `ON` / `OFF` and the connection's name, re-read every 15s | brings that connection up, or takes it down |

## Nothing to report, no tile

```sh
name=$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2 == "vpn" || $2 == "wireguard" { print $1; exit }')
[ -n "$name" ] || exit 0
```

On a machine with no VPN configured, `value` prints nothing, and **a tile that prints nothing is not drawn**. You get the gap it would have filled rather than a tile reading `OFF` forever about a connection that does not exist.

That is worth copying for anything conditional: a "next meeting" tile disappears on a day with no meetings, a "pending updates" tile disappears when there are none.

The name is found rather than hard-coded, so the same block works on every machine you paste it into. `exit` in the `awk` takes the first VPN and stops.

## `state` is what makes it look like a toggle

```json
{"value": "ON", "caption": "VPN", "state": "on", "lines": ["Work"]}
```

`"state": "on"` gives the tile the same active treatment Bluetooth and Wi-Fi take when they are on, so it reads as a switch rather than a label that happens to say ON. `"off"` is the plain one. Any other value, or none, means "not a toggle".

## Customise

- **Which connection.** The `awk` takes the first `vpn` or `wireguard` connection. Pin one instead by replacing both `name=$(...)` lines with `name="Work"`, which is also faster: no `nmcli` call to find it.
- **`refresh = "15s"`** is how stale the reading may get. A VPN goes up and down while you watch, so this one is deliberately short; nothing runs inside the window, and 15 seconds is one `nmcli` call per quarter minute at worst.
- **`mnemonic = "V"`** asks for `Alt+V`. Free on the default strip. A letter held by a built-in you kept is never given away, and the tile still works by click.
- **`confirm`.** Not shipped: dropping a VPN is instantly undone by pressing again. Add one if yours takes thirty seconds to renegotiate.
- **A third-party client.** Tailscale, Mullvad and WireGuard.app do not appear in `nmcli`. Each has its own two commands, and the shape of the block does not change:

  ```sh
  # value: tailscale
  if tailscale status --json | grep -q '"BackendState":"Running"'; then
      printf '{"value":"ON","caption":"TAILSCALE","state":"on"}'
  else
      printf '{"value":"OFF","caption":"TAILSCALE","state":"off"}'
  fi
  # press: tailscale up   /   tailscale down
  ```

- **macOS, untested.** `scutil --nc list` prints one line per VPN service in Network settings, with `(Connected)` or `(Disconnected)` and the name in quotes. `scutil --nc start "Work"` and `scutil --nc stop "Work"` are the press:

  ```sh
  line=$(scutil --nc list | grep -m1 '"')
  [ -n "$line" ] || exit 0
  name=$(printf '%s' "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p')
  if printf '%s' "$line" | grep -q '(Connected)'; then
      printf '{"value":"ON","caption":"VPN","state":"on","lines":["%s"]}' "$name"
  else
      printf '{"value":"OFF","caption":"VPN","state":"off","lines":["%s"]}' "$name"
  fi
  ```

  Run those two commands in a terminal first. If they work on your Mac, that is a `vpn-macos.toml` worth sending back here.
