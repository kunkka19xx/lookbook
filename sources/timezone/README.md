# timezone

Two halves of the same job, in one folder, independently installable.

**Convert.** Type `tz` and a line: `tz 3pm cet to jst`. The panel shows the
answer before you commit to it — the converted time, the date shift if there is
one, the offset, and how far the two zones are from each other and from you.
Enter copies the headline.

```
tz 3pm cet to jst

11:00 PM JST

ZONE   Asia/Tokyo · JST · UTC+09:00
DATE   Thu 12 Nov 2026
FROM   3:00 PM CET · Europe/Paris · Thu 12 Nov
SHIFT  8h ahead of Europe/Paris
       7h ahead of you
ISO    2026-11-12T23:00:00+09:00
```

The answer is the only line with nothing in front of it. That is the whole
reason for the label column: a `preview` command's output is drawn as plain
text - markdown is honoured only for a *connector's* preview - so the
hierarchy has to be made out of layout rather than type.

**World clock.** Type `clock` and your cities are there, each showing the time
right now. Not the time at the last reload: it is a `connect` block, so the
program stays running and pushes a new row the moment the minute changes.

Everything is offline. The zone data is the IANA database the operating system
already ships, read through Python's own `zoneinfo` and `TZ=... date`, so
nothing is downloaded, nothing is embedded here, and daylight saving is right
because the database says what it is.

This is the extension shape of [look#704](https://github.com/kunkka19xx/look/issues/704).
What it cannot be is that issue's third request: a calculator-style row pinned
above the results with no prefix at all. A source needs its own word first
(`tz`), and a connector cannot see what you are typing — `{"op":"query"}` is
listed under *Not yet* in [integrating.md](https://github.com/kunkka19xx/look/blob/main/docs/integrating.md).
That part only core can do. This is the rest of it, today.

**Requires.** Look v0.7.5 or newer (for `{arg}`, `scope` and `connect`),
`python3` for the convert half, and `bash` with `jq` for the clock.

**Platforms.** macOS, where both halves were written and used. Nothing in
either is macOS-specific by design — the clipboard is detected, the zone
database is read at `/usr/share/zoneinfo`, which macOS symlinks — but Linux and
Windows are untested.

## Install

```bash
cp sources/timezone/*.toml ~/.look/sources/
cp sources/timezone/bin/timezone sources/timezone/bin/timezone-clock ~/.look/bin/
chmod +x ~/.look/bin/timezone ~/.look/bin/timezone-clock
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

Take one half or both. `timezone.toml` is the convert half and `timezone-clock.toml`
the clock — but **copy both scripts either way**: the clock's rows use
`bin/timezone` for their preview and for what Enter copies, so that one city's
panel is the same panel `tz` gives you.

Installing from `Settings > Extend` does all of it, and asks which cities the
clock should show.

## Blocks

| Block | Type | Enter |
| --- | --- | --- |
| `timezone-convert` | `tz <zone>` or `tz <time> <zone> to <zone>` | copies the headline, `11:00 PM JST` |
| `timezone-iso` | `tziso <the same query>` | copies `2026-11-12T23:00:00+09:00` |
| `timezone-clock` | `clock`, one row per city, live | copies that city's time |

`tz` on its own is a row like any other, and its panel is the list of examples
rather than an empty pane.

## What you can type

```
tz tokyo                 the time there now
tz 3pm cet to jst        a conversion
tz 14:00 cet to jst      24-hour clocks work too
tz now tokyo in london   "to" and "in" both separate the zones
tz 9am gmt+8 in utc      a fixed offset is a zone
tz 3pm est               no target means your own zone
tz noon new york         "noon" and "midnight" count as times
```

A zone can be an **IANA name** (`Asia/Tokyo`), a **city** (`tokyo`,
`new york`, `kuala lumpur`), an **abbreviation** (`jst`, `cet`, `pst`) or an
**offset** (`gmt+8`, `utc-3`, `+05:30`).

Cities need no table: they are matched against the last segment of every zone
name in the database, underscores read as spaces. What the script's table is
for is the two things the database cannot answer — abbreviations, which are not
zone names at all, and nicknames like `nyc`, `sf` and `bangalore`.

**A time with no date means today in the source zone.** `tz 3pm est` is 3pm
today in New York, which may already be yesterday or tomorrow where you are;
that is what the `+1 day` marker and the `from` line are for.

## The three things it is careful about

**An abbreviation is not a zone.** `JST` names an offset; `Asia/Tokyo` names a
place with a history of them. People type the abbreviation and mean the place,
so `est` resolves to `America/New_York` — which is also what makes `3pm est`
right in both January and July, rather than frozen at UTC-5.

**Three abbreviations mean more than one place**, and the panel says so rather
than silently picking a continent:

```
tz 3pm ist to utc
...
"IST" read as India. Israel is Asia/Jerusalem, Ireland is Europe/Dublin
```

`CST` (US Central, China, Cuba) and `BST` (Britain, Bangladesh) get the same
treatment. Write the IANA name when you mean the other one.

**Daylight saving has two edges, and they are not the same edge.** Twice a year
a wall time either happens twice or never happens at all, and the panel names
which:

```
01:30 happens twice in America/New_York that day - the earlier one was used
02:30 does not exist in America/New_York that day - the clocks jump to 03:30
```

Those two are easy to conflate in code, because Python gives a time inside the
spring-forward gap two different offsets as well. The nonexistent case is
caught first, by whether the time survives a round trip through UTC.

## Why the clock is a connector and the converter is not

They need opposite things, and the two producers are exactly that difference.

A clock is **rows that go stale**: eight cities, each wrong within a minute. A
`run` block makes its rows on reload and caches them until the next one, which
is what keeps search instant and would also leave a clock reading 09:50 for an
hour. `connect` is the producer for that: the program stays up and pushes.

A converter is **a row that reads what you typed**. No list can do that, since
rows exist before you start typing. `{arg}` on a `do` block is the only shape
that can, and the answer appears in the panel because that is the only part of
a row a command gets to fill. It costs one subprocess per selected row — about
50ms, nearly all of it Python starting — against a preview budget of five
seconds.

## Customise

- **The cities**: the `LOOK_CLOCK_ZONES` list on the `connect` line, comma
  separated IANA names, in the order you want to read them. The installer asks
  for this.
- **24-hour clocks everywhere**: `LOOK_TZ_24H=1` in front of the commands in
  `timezone.toml`. The clock half is 24-hour already.
- **A home zone that is not the machine's**, for a laptop that travels:
  `LOOK_TZ_HOME=Europe/Berlin` on the same lines. It is what "ahead of you"
  measures from and what a missing target zone means.
- **Your own nicknames** are the `ZONES` table in `bin/timezone`, one line
  each: `"hq": "Europe/Amsterdam"`, `"ami": "America/Sao_Paulo"`.
- **How often the clock looks at the clock**: `LOOK_CLOCK_POLL=5`, seconds. It
  pushes when the minute changes, not on every wakeup, because every push makes
  Look re-read the declared sources.
- **The clipboard** is one function at the bottom of `bin/timezone`, trying
  `pbcopy`, `wl-copy`, `xclip`, `xsel` and `clip.exe` in that order.
