# sleep

Put your Mac to sleep - Sleep mode is a low-power state that turns off your display and pauses most activity while keeping your apps, documents, and session open.

**Requires.** Look v0.6.13 or newer. `osascript` ships with macOS.

**Platforms.** macOS.

## Install

Tiles are merged, not copied. Two edits in `~/.look/super-actions.toml`:

1. Put `sleep` in the `layout` drawing, in place of a built-in you do not use:

   ```toml
   layout = [
       "lslot       lslot       sleep       wifi        battery     weather",
       "lslot       lslot       theme       keepawake   screensaver weather",
       "sleep       restart     shutdown    nowplaying  nowplaying  nowplaying",
   ]
   ```

2. Paste the block from [`sleep-macos.toml`](sleep-macos.toml) onto the end of the file.

`make show NAME=sleep` prints it. Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## The tile

| Tile | Shows | Press |
| --- | --- | --- |
| `sleep` | title and icon; there’s nothing to read | puts the system to sleep |

## Customise

- **`mnemonic = “S"`** asks for `Cmd+S`. A letter held by a built-in on *your* strip is never given away, so if you keep a tile using `S` this one goes without a key and still works by click. `Q` always belongs to quitting Look.
- **`confirm`** the tile arms on the first press and fires on the second, the way Restart and Shut Down do.
- **`icon`.** macOS takes any SF Symbol (`moon.zzz.fill`).
- **`title`** is what the tile is called. Without it the name is title-cased, which for `sleep` gives the same word.
