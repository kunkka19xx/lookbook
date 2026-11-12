# convert

Unit conversion from one typed line, offline. Type `conv` and what you want:

```
conv 10 kg to lb         22.0462 lb
conv 1 km to dm          10000 dm
conv 100 c to f          212 f
conv 2.5 gib to mb       2684.35 mb
conv 10 inch in cm       25.4 cm
```

The panel shows the answer, what it came from, the exact value, and **the rule
it used**. Enter copies the headline.

```
22.0462 lb

FROM    10 kg
EXACT   22.046226218487757 lb
RULE    1 lb = 0.45359237 kg
```

The point of this one is the last line. Every unit it knows is a rule you can
read, and adding your own is a line in a file — which is the half of
[look#413](https://github.com/kunkka19xx/look/issues/413) that makes the
feature useful to anyone whose work does not happen in kilograms.

**Requires.** Look v0.7.5 or newer (for `{arg}`), and `python3`. No library:
the whole table is in `bin/convert`.

**Platforms.** macOS, where it was written and used. The clipboard is detected
rather than hard-coded, so Linux should work; the one macOS line is `open -t`
in `convert-rules`, which is `xdg-open` on Linux.

## Install

```bash
cp sources/convert/*.toml ~/.look/sources/
cp sources/convert/bin/convert ~/.look/bin/
chmod +x ~/.look/bin/convert
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Type | Enter |
| --- | --- | --- |
| `convert` | `conv 10 kg to lb` | copies `22.0462 lb` |
| `convert-rules` | `convrules` | opens `~/.look/convert.units`, creating it if it is not there |

Two shapes beyond the obvious one. **`conv` alone** shows the examples, and
**a unit alone** shows what that unit can become, which is how you find out
what is in the table without reading it:

```
conv gib

gib · data

INTO    b · bit · gb · gbit · kb · kbit · kib · mb · mbit · mib · pb · tb · tib
RULE    1 gib = 1073741824 b
YOURS   none yet - convrules opens ~/.look/convert.units
```

## Your own units

One line each in `~/.look/convert.units`, in the same language the preset
table is written in:

```
furlong = 201.168 m
story   = 6 h
sprint  = 10 story
cuppa   = 0.284 l
```

`conv 2 sprint to d` → `5 d`. A rule may be written in terms of anything
`convert` already knows, including a unit you defined on an earlier line,
which is how `sprint` works. Names are case-insensitive and a trailing `s` is
forgiven, so `2 sprints` is fine.

There is no second format for this. The presets are written the same way:

```
names : dimension              a base unit, what the others are measured in
names = <how many> <unit>      a unit made of another one
names = <how many> <unit> + <offset>     when zero is somewhere else
```

The third form is there because of temperature, which is the only group where
zero moves — `C = 1 K + 273.15` and `F = 5/9 K + 459.67*5/9` are lines of the
table like any other, not a special case in code. Offsets are why `-40 c to f`
answers `-40 f`.

A line it cannot read stops the conversion and names the file and line number.
That is deliberate: a rule silently ignored is a rule you cannot find.

## What it knows out of the box

`length`, `mass`, `time`, `temperature`, `volume`, `data`, `speed`, `area`,
`pressure`, `energy`, `power`, `angle` — about ninety units.

Two groups worth knowing about:

- **Data is spelled out rather than cased.** `mb` is a megabyte, `mib` a
  mebibyte, `mbit` a megabit. A launcher is one line typed in a hurry, and
  `MB`/`Mb`/`MiB` meaning three things is the kind of distinction that only
  works when you can see the shift key. `conv 1 gb to gib` answers `0.931323`,
  which is the whole reason anyone converts these.
- **Months and years are the average kind**, 30.44 and 365.25 days. Calendar
  arithmetic is a different question from unit conversion, and
  [timezone](../timezone) is the source for the one that involves a calendar.

Converting across dimensions says so rather than answering: `conv 10 kg to km`
tells you one is mass and the other length, and points at `conv kg`.

## Customise

- **Where your rules live**: `LOOK_CONVERT_UNITS=~/dotfiles/units` in front of
  the commands in `convert.toml`. Set there rather than exported from your
  shell rc, which a login shell never reads.
- **How many digits**: `LOOK_CONVERT_DIGITS=10`, same place. Six by default;
  the exact value is in the panel regardless.
- **`open -t`** in `convert-rules` is macOS. Linux: `xdg-open "$(…)"`. Or name
  an editor: `open -a 'Zed' "$(…)"`, `code "$(…)"`.
- **Add a whole dimension** the same way as a unit, in your own file — a base
  line and then rules against it:

  ```
  usd : money
  eur = 1.09 usd
  ```

  Which works, and is also the warning: those rates are frozen at whatever you
  typed. Look's own answer card does live currency; this is for things that do
  not move.
