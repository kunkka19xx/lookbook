# template

One or two sentences: what the tile shows, and what pressing it does.

**Requires.** Look v0.6.13 or newer. Name anything else that has to be installed.

**Platforms.** macOS, Linux

## Install

Tiles are merged, not copied. Two edits in `~/.look/super-actions.toml`:

1. Put `template` in the `layout` drawing, in place of a built-in you do not use:

   ```toml
   layout = [
       "lslot       lslot       template    wifi        battery     weather",
       "lslot       lslot       theme       keepawake   screensaver weather",
       "mic         restart     shutdown    nowplaying  nowplaying  nowplaying",
   ]
   ```

2. Paste the block from [`template.toml`](template.toml) onto the end of the file.

`make show NAME=template` prints it. Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## The tile

| Tile | Shows | Press |
| --- | --- | --- |
| `template` | the time, re-read every 5 minutes | echoes a line |

## Customise

- What the `value` command reads, and how often `refresh` lets it run.
- `icon` is per-platform: an SF Symbol on macOS, a strip glyph or an image path on Linux, built-ins only on Windows.
- `mnemonic` is the letter it asks for. Say which, and that a busy letter is not given away.
