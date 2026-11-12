# emoji

Every emoji, searchable by name, with Enter putting it on the clipboard. Type
`emo` and then what you want:

```
emo rocket      🚀        emo like       👍        emo coffee     ☕
emo tada        🎉        emo bug        🐛        emo check      ✅
```

The row's icon is the emoji itself, so the list reads as the characters with
their names beside them. The subtitle carries the codepoint, which is what you
want the moment something does not render.

Nothing is downloaded and there is no emoji list in this folder. The names come
from `unicodedata`, the Unicode Character Database inside Python itself, which
is what everybody else's emoji list is generated from. A newer Python knows
newer emoji with nothing here to update.

**Requires.** Look v0.7.5 or newer (for `scope`), and `python3`.

**Platforms.** macOS. The only platform-specific line is `pbcopy`; Linux and
Windows spellings are in Customise.

## Install

```bash
cp sources/emoji/*.toml ~/.look/sources/
cp sources/emoji/bin/emoji-rows ~/.look/bin/
chmod +x ~/.look/bin/emoji-rows
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `emoji` | about 1,800 emoji, faces first | copies the character |

## Why `scope = true` is not optional here

A block's rows compete with your apps, files and settings on one scale, and
this block has 1,800 of them with names like "heavy check mark", "black
question mark ornament" and "white medium star". Unscoped, a search for `black`
or `white` or `mark` would have emoji in it forever.

`scope = true` reserves `emo` as the first word of a line, and the rows are
reachable only that way: `emo check`. Delete the line and you get an emoji
list in every other search you make. That is the trade the key exists for, and
this is the clearest case of it in the whole repository.

## Unicode's names are not always yours

Unicode froze a character's name when it was assigned, so some of them read
oddly now: 👍 is "thumbs up sign", ⭐ is "white medium star", 🎉 is "party
popper". The names are correct and they are not how anyone searches.

`bin/emoji-rows` carries a short table for that gap: about thirty of the ones
people reach for, with the words they actually type (`like`, `+1`, `ship it`,
`wip`, `deadline`), added to the subtitle so Look searches them too. It is
hand-written and deliberately short. If you reach for one that is not in it,
add a line:

```python
ALSO = {
    "🧊": "ice, cold, freeze, frozen",
    ...
}
```

## Customise

- **`pbcopy`** is macOS. Linux: `wl-copy` on Wayland,
  `xclip -selection clipboard` on X11. Windows: `clip`.
- **Fewer rows**, if 1,800 feels like a lot: `LOOK_EMOJI_LIMIT=400` on the
  `run` line. Faces and hands come first, so a small limit keeps the ones you
  reach for. The default is 1,900, which is under Look's own 2,000-row cap on
  purpose: the list is then trimmed by this file's own order rather than by
  wherever the cap happens to land.
- **Which blocks count as emoji** is the `RANGES` table in the script, with a
  comment on each line. Flags, skin-tone modifiers and keycaps are left out
  deliberately: a flag is two regional indicators and a modifier only means
  something appended to another character, so neither works as a row of its
  own.
- **Kaomoji and symbols** (¯\\_(ツ)_/¯, →, ±) are not emoji and are not in
  here. A short hand-written list is a different shape of source: a `file`
  block like [bookmarks](../bookmarks), or a [snippets](../snippets) folder.
