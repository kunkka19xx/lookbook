# next-meeting

What you are next expected to be in, on the empty home screen, and one press to join it. Three lines: `NEXT MEETING`, then `in 24 min` in large type, then `Platform Weekly · Sat 15:27 – 15:57`. `Cmd+N` joins without the mouse.

It is the long tile in the strip, and it is the one that earns its width: a countdown alone tells you nothing, and the meeting it belongs to is the whole point.

Three things at once, which is why it is worth reading before you write your own: a `value` that reads, a `press` that acts on **what the value just read**, and a tile that takes itself off the strip when there is nothing to say.

**Requires.** Look v0.6.13 or newer, macOS, and the [`meeting`](../../sources/meeting) source installed, because this tile runs its script rather than carrying a second copy. That script needs **Full Disk Access for Look**, and a calendar account signed in to macOS for the store to have anything in it. Both are below, and [the source's README](../../sources/meeting/README.md) is worth reading before you grant the first one.

**Platforms.** macOS only. The calendar store it reads does not exist on Linux or Windows; `sources/meeting/README.md` says what would replace it.

> **Look already answers `join` on macOS**, through EventKit, with no Full Disk Access at all. If all you want is to join meetings, type `join` and skip this. What a tile does that a command cannot is tell you *without being asked*: the countdown is on the screen the moment you open Look, whether or not the meeting was on your mind.

## Before it shows anything

Two grants, in this order, and the tile is blank until both are done:

1. **Full Disk Access for Look.** System Settings → Privacy & Security → Full Disk Access, add Look, then **quit and relaunch it** - TCC is only read at launch, so toggling it while Look runs changes nothing. Until then the tile reports `could not read the calendar store (Full Disk Access?)` in the window rather than failing quietly.
2. **A calendar account signed in to macOS.** The store this reads is the system one, so it is empty until Calendar has an account in it: System Settings → Internet Accounts, add the Google or iCloud account your meetings live on, and tick Calendars. A Mac with no account has only birthdays and public holidays, which are all-day events and filtered out by design, so the tile correctly shows nothing at all.

A Google Calendar you only ever read in a browser tab is **not** in that store. It has to be added as an account for anything here to see it.

## Install

The script first, since the tile is only a way of running it:

```bash
make install NAME=meeting
```

Then the tile, which is **merged** into `~/.look/super-actions.toml` and never copied over it - that file holds your whole strip. Two edits:

1. Put `next-meeting` in the `layout` drawing, wide. Beside the clock rather than under it, so the strip stays two rows tall:

   ```toml
   layout = [
       "lslot  lslot  next-meeting next-meeting weather",
       "lslot  lslot  bluetooth    wifi         weather",
   ]
   ```

   A third row is the obvious first draft and the one to avoid. `lslot` and
   `weather` are each two rows tall already, so a long tile given a row of its
   own makes the strip half again as tall for one line of text. Put it in the
   space beside them instead.

2. Paste the block from [`next-meeting.toml`](next-meeting.toml) onto the end of the file.

`make show NAME=next-meeting` prints it. Reload with `Cmd+Shift+;`.

## The tile

| Tile | Shows | Press |
| --- | --- | --- |
| `next-meeting` | three lines: the countdown, then the meeting's name and time, re-read every 60s | opens the join link, or Calendar when the meeting has no link |

## Draw it wide

A one-cell tile shows the headline and nothing else, so this one would be a number with no meeting attached to it. The name and the time line only appear on a tile spanning more than a single cell, because there is nowhere else to put them.

Two cells across is the floor and is what the example draws. Four cells is a banner across the strip and reads well; it just costs a row, which is the thing to think about before you take one. Two wide by two tall works too, and reads as a card rather than a line.

Wide is cheaper than tall. A row is 76 points for every tile on it, and this one needs three short lines, all of which fit in a single row's height.

## Three lines, and no caption

```
NEXT MEETING
in 24 min
Platform Weekly  ·  Sat 15:27 – 15:57
```

A tile with a letter puts its **title** on the first line, because that is where the letter is highlighted - `caption` is only promoted to the label on a tile with no mnemonic. So a tile that wants both a key and a caption gets four lines, and four lines in a 76-point row is a wall. The name moves down beside the time instead, and `--tile` prints no `caption` at all.

The name is clipped, not the line. A tile truncates from the end, so a title long enough to fill the row would take the time with it and leave a countdown with no clock next to it.

The provider is deliberately missing from that line. `video.fill` already says the meeting has something to press, and naming Zoom or Meet is the icon a second time in words. A **room** is not the icon a second time, so a meeting with no link keeps its location: `Standup · Sat 16:30 – 17:00 · Meeting room 4`.

## Press joins what you are looking at

```toml
value = "~/.look/bin/meeting-next --tile"
press = "~/.look/bin/meeting-next --join"
```

The press does not receive the reading. `press` is a command declared in the file, not something handed the JSON the tile is currently showing, so it looks the meeting up again for itself - the same query, a second apart. That is the pattern for any tile whose action is about its own reading: **one script, two modes**, rather than a link smuggled from one to the other.

It also means the press is right even when the tile is stale. Open Look a minute after a meeting ended and the tile still says `started 4 min ago`; pressing it joins whatever is next *now*, not the meeting that was on the screen.

## No meetings, no tile

`--tile` prints nothing when the next 48 hours are empty, and **a tile that prints nothing is not drawn**. Every evening and all weekend you get the gap it would have filled rather than a tile saying "none" in a size meant for a countdown.

## The colour is the deadline

```json
{"value":"in 3 min","lines":["Platform Weekly  ·  Sat 15:06 – 15:33"],"icon":"video.fill","state":"on"}
```

`"state": "on"` inside ten minutes of the start, which gives the tile the active tint Wi-Fi takes for being on. It is the one thing on the strip you can read without reading: the tile changes colour, and you are late or you are not.

The icon changes with the reading too, and an icon in the JSON wins over one declared in the file. `video.fill` when the meeting has a link worth pressing, `calendar` when it is a room you have to walk to, which is why the block declares no `icon` of its own.

## Customise

Every setting is an environment variable, so you can try one without editing the script. Put it on the `value` line in the tile block, **not** in `~/.zshrc`: Look runs commands through a login shell, which never reads your rc file.

```toml
value = "LOOK_MEETING_SOON_MINUTES=5 ~/.look/bin/meeting-next --tile"
```

| Variable | Default | What it does |
| --- | --- | --- |
| `LOOK_MEETING_SOON_MINUTES` | `10` | How close counts as urgent, the point the tile takes the active tint |
| `LOOK_MEETING_AHEAD_HOURS` | `48` | How far ahead to look. 48 so Friday evening finds Monday's |
| `LOOK_MEETING_BEHIND_MINUTES` | `15` | How late you can still join. The window opens before now on purpose |
| `LOOK_MEETING_DB` | the system store | Point it at a copy to see the tile against a calendar you made up |

- **A shorter countdown.** `refresh = "60s"` is how stale the number may get, and a minute is already the resolution the text has: it says `in 24 min`, never `in 24m 12s`. `30s` buys nothing and doubles the reads.
- **`mnemonic = "N"`** asks for `Cmd+N`. Free on the default strip. A letter a built-in on *your* strip already holds is never given away, and the tile still works by click.
- **A confirm.** Not shipped, because a press you meant is two presses you have to make. If a stray `Cmd+N` dropping you into a room unmuted is the worse outcome, `confirm = "Join now?"` arms the tile on the first press and joins on the second.
- **Only meetings you can join.** Add `AND coalesce(conference_url,'') <> ''` to the query's `WHERE` in the script, and lunch stops being your next meeting.
- **Try it without a calendar.** Point `LOOK_MEETING_DB` at a sqlite file of your own with the three tables the query names. Faster than moving a real meeting around to see what the tile does at three minutes out.
