# tiles

Ready-made **Super Actions tiles**: the strip Look shows on the empty home screen, before you type anything.

A tile is not a source. Everything in [`sources/`](../sources) is a file you copy into `~/.look/sources/`, where Look reads whatever it finds. A tile lives in `~/.look/super-actions.toml`, a single file you already own that holds your whole strip, so installing one is a **merge**, not a copy.

**Requires Look v0.6.13 or newer.** Earlier builds draw the built-in strip and ignore the file.

## The file is a drawing

Look seeds `~/.look/super-actions.toml` on your first run with the default strip, and the seeded file documents itself. The top of it is a drawing of the screen: each line is a row, each name is one cell.

```toml
layout = [
    "lslot       lslot       bluetooth   wifi        battery     weather",
    "lslot       lslot       theme       keepawake   screensaver weather",
    "mic         restart     shutdown    nowplaying  nowplaying  nowplaying",
]
```

Repeat a name across cells to make that tile span them; its cells must form a rectangle. `.` is a deliberate gap. Delete a name to take that tile off the strip, which takes its keyboard letter with it. Up to five rows and six columns, and every row needs the same number of names.

Three built-ins have a floor, in columns x rows: `lslot` 2x2, `weather` 1x2, `nowplaying` 2x1. Drawn smaller, they are left out rather than clipped.

## Installing one

Two edits, and neither can be a `cp`: the file is yours and already has your layout in it.

1. **Give it a cell.** Put the tile's name somewhere in your `layout`, replacing a built-in you do not use or taking a `.` gap.
2. **Append the block.** Paste the `[tiles.<name>]` entry from the example onto the end of the file.

```bash
# what a tile looks like once merged
$EDITOR ~/.look/super-actions.toml
```

Then reload: `Cmd+Shift+;` on macOS, `Ctrl+Shift+;` on Linux and Windows. The strip redraws without restarting Look, so you can arrange it while looking at it.

`make show NAME=disk` prints the block to paste. There is no `make install` for tiles, on purpose: a script that edited this file would be rearranging your strip.

**To undo:** delete the block and take the name back out of the drawing. **To start over:** delete `~/.look/super-actions.toml` and Look reseeds the default.

## What a tile can be

Only `value` or `press` is required, and which ones you declare decide what the tile *is*.

| You declare | You get |
| --- | --- |
| `value` | a readout. It runs on its own and shows what it printed |
| `press` | a button. Nothing runs until you press it, and there is nothing to display |
| both | a readout you can also act on |

`value` prints **one JSON object**, and every field but `value` is optional:

```json
{"value": "84Gi", "caption": "DISK FREE", "lines": ["of 460Gi"], "icon": "internaldrive", "state": "off"}
```

**Printing nothing hides the tile.** That is how a tile disappears on a machine that has nothing to report, rather than sitting there empty.

| Key | Does |
| --- | --- |
| `value` | shell command printing the JSON above |
| `refresh` | how stale that reading may get: `30s`, `5m`, `1h`. Nothing runs inside the window |
| `press` | what a click or the tile's key runs |
| `confirm` | arms on the first press, fires on the second, the way Restart does |
| `title` | what it is called. Without it the name is title-cased |
| `icon` | the symbol drawn on it |
| `mnemonic` | the letter that fires it, with `Cmd` on macOS and `Alt` elsewhere |

## Keep the command light

`value` runs unattended, which is the whole point of a live tile and also the reason it is capped: **two seconds**, then it is killed along with anything it started, and 16 KB of output. Within a tile's `refresh` window nothing runs at all, so most opens cost nothing.

Read something and print it. Anything that has to fetch, build or wait belongs behind `press`, or in a script that caches to a file the tile only reads. A tile that fails keeps its last good reading and says so; one broken tile never blanks the strip.

## Icons are per-platform

- **macOS**: any SF Symbol name (`internaldrive`, `lock.fill`, `calendar`).
- **Linux**: one of the strip's own glyphs (`bluetooth`, `wifi`, `theme`, `keepawake`, `battery`, `screensaver`, `mic`, `restart`, `shutdown`), or a path to an image of your own (`~/.look/icons/vpn.svg`, up to 256 KB). It is drawn as a mask, so only the shape survives: a flat silhouette reads at 16px, a detailed illustration collapses into a blob.
- **Windows**: the built-in names only.

An unrecognised name draws nothing rather than a placeholder, so a typo looks like a tile that asked for no icon. Every example here names its icon under a **Customise** heading for exactly this reason.

## Letters are requested, not granted

`mnemonic = "V"` asks for `Cmd+V` / `Alt+V`. A letter already held by a built-in **on your strip** is never given away, `Q` belongs to quitting Look, and between two of your own tiles the first one drawn wins. A tile that misses out keeps working; it just has no key.

So the letter a tile asks for depends on what else you drew. Take `wifi` off the strip and `W` is free.

## The tiles

The **Platforms** column is what the author tested, not what might work.

| Tile | Requires | Shows off | Platforms |
| --- | --- | --- | --- |
| [disk](disk) | none | `value`: a readout with a caption and a second line, on a `refresh` | macOS, Linux |
| [lock](lock) | none | `press` with no `value`: a button, with `confirm`, `icon` and `mnemonic` | macOS, Linux |
| [vpn](vpn) | NetworkManager (Linux), `scutil` (macOS) | `state` for the on/off treatment, and printing nothing to hide the tile | Linux, macOS |

## Read before you install

Every tile runs shell commands on your machine, and a `value` command runs **on its own**, every time its refresh window lapses, without you pressing anything. That is a higher bar than a source row you chose to press. They are short on purpose: open the `.toml` and read it before you paste it in.

Nothing here downloads anything, and anything that changes your machine sits behind `press` with a `confirm`.

## Writing your own

```bash
make new-tile NAME=my-thing
```

It scaffolds `tiles/my-thing/` with the block and README already renamed. The [contributing rules](../CONTRIBUTING.md) are the same as for sources, plus one thing: a tile's `value` has to finish in under two seconds on a cold machine, not just on yours.
