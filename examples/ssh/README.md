# ssh

Every host in your `~/.ssh/config` as a row. Type its name, Enter opens a terminal connected to it.

No list to maintain: it reads the config you already keep. Wildcard patterns (`Host *`) are skipped, since they are settings rather than machines.

**Requires.** Look v0.6.12 or newer, `ssh`, a `~/.ssh/config`, and a terminal emulator to launch.

**Platforms.** macOS as written, Linux and Windows with a different `open`, see Customise.

## Install

```bash
cp examples/ssh/*.toml ~/.look/sources/
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `ssh-hosts` | non-wildcard `Host` entries in `~/.ssh/config` | opens a terminal running `ssh <host>` |

## Customise

`open` is the line to change, because it names your terminal:

- **macOS**: `open -na Terminal --args ssh {id}`, or `open -na iTerm`, `open -na kitty`. `-na` opens a new instance rather than focusing the one you have, which is what you want when each row is a different machine.
- **Linux**: `ghostty -e ssh {id}`, `kitty ssh {id}`, `gnome-terminal -- ssh {id}`, `wezterm start -- ssh {id}`.
- **Windows**: `start "" wt.exe ssh {id}`.

Show the config stanza for the selected host in the preview pane:

```toml
preview = "awk -v h={id} '$1 == \"Host\" || $1 == \"host\" { p = 0; for (i = 2; i <= NF; i++) if ($i == h) p = 1 } p' ~/.ssh/config"
```

Prefer a hand-kept list? Swap the producer for a `file` block, one row per line, `id<TAB>title<TAB>subtitle`:

```toml
file = "~/.look/hosts.txt"
```

```
prod-web-1	Production web	us-east-1, nginx
db-primary	Primary database	us-east-1, postgres 16
```

A bare line with no tabs is a row whose id and title are the same.
