# disk

Free space on your root filesystem, on the empty home screen. `301G`, with `of 915G` under it.

The plainest shape a tile has: a `value` command, a `refresh`, and nothing else. It never acts, so pressing it does nothing and it does not draw like a button.

**Requires.** Look v0.6.13 or newer. `df` and `awk`, which you already have.

**Platforms.** Linux, where the command above was run as written. macOS takes the same line unchanged - `$2` and `$4` are the size and available columns on BSD `df` too - but it has not been run there. Not Windows: there is no `df`, and the equivalent is a different command entirely.

## Install

Tiles are merged, not copied. Two edits in `~/.look/super-actions.toml`:

1. Put `disk` in the `layout` drawing, in place of a built-in you do not use:

   ```toml
   layout = [
       "lslot       lslot       disk        wifi        battery     weather",
       "lslot       lslot       theme       keepawake   screensaver weather",
       "mic         restart     shutdown    nowplaying  nowplaying  nowplaying",
   ]
   ```

2. Paste the block from [`disk.toml`](disk.toml) onto the end of the file.

`make show NAME=disk` prints it. Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux).

## The tile

| Tile | Shows | Press |
| --- | --- | --- |
| `disk` | free and total space on `/`, re-read every 5 minutes | nothing: it is a readout |

## How it reads

```sh
df -h / | awk 'NR==2 {printf "{\"value\":\"%s\",...}", $4, $2}'
```

`NR==2` is the line under the header. `$4` is available space and `$2` is the total on both BSD and GNU `df`, which is why one line covers macOS and Linux. `awk` builds the JSON from the same line it already read, so the whole tile is one process rather than two `df` calls.

The output is one JSON object. Only `value` is required; `caption` is the small line under the number, and `lines` is everything after that, shown by a tile with the room for it.

## Customise

- **A different filesystem.** `df -h /` is the root volume. `df -h ~` follows your home to wherever it actually lives, which on a machine with a separate `/home` is the number you care about.
- **`refresh = "5m"`** is how stale the reading may get. Inside that window nothing runs at all, so most opens of Look cost nothing. Disk space does not move quickly; `30s` would just be work.
- **Give it two cells** (`disk disk` in one row) and the `of 915G` line has room to show. In a single cell only the big number and its caption fit.
- **`icon`** is commented out because `internaldrive` is an SF Symbol and means nothing off macOS. On Linux, name one of the strip's own glyphs or point at an image: `icon = "~/.look/icons/disk.svg"`.
- **A warning colour.** Add `"state": "on"` to the JSON when space runs low and the tile takes the active tint:

  ```sh
  df -h / | awk 'NR==2 {s = ($5+0 > 90) ? "on" : "off"; printf "{\"value\":\"%s\",\"caption\":\"DISK FREE\",\"state\":\"%s\"}", $4, s}'
  ```

  `$5` is the use percentage. `+0` drops the `%` so it compares as a number.
