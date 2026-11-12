# snippets

Text you retype: your address, a standup template, a tricky SQL join, the
apology you send when CI goes red. One file per snippet in `~/.look/snippets`,
and Enter puts it on the clipboard. `snip sql` searches inside them, the preview
pane shows the one you have selected, and `snipnew <name>` saves whatever is on
your clipboard as a new one.

Snippets are plain files on purpose. Nothing is imported into a database, so
they edit with `Cmd+E`, sync with the rest of your dotfiles, and still grep from
a terminal.

This is not Look's clipboard history, which is built in (`c"`) and holds the
last ten things you copied. These are the things you want to copy again next
month.

**Requires.** Look v0.7.5 or newer (for `scope` and `{arg}`). Nothing else.

**Platforms.** macOS. The only platform-specific lines are `pbcopy` and
`pbpaste`; the Linux and Windows spellings are in Customise.

## Install

```bash
cp sources/snippets/*.toml ~/.look/sources/
mkdir -p ~/.look/snippets
```

Then put something in it:

```bash
printf 'Thanks for the review!\n' > ~/.look/snippets/thanks.txt
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

The folder has to exist and have a file in it. An empty one is an empty list,
with nothing on stderr to explain why: `dir` blocks report a folder that is
missing, not one that is merely empty.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `snippets` | every file in `~/.look/snippets`, and one level of folders inside it | copies the contents |
| `snippets-new` | `snipnew <name>` | saves the clipboard as `<name>.txt` |

## How to organise them

The file name is what you search for, so it is the only metadata worth
thinking about. Two habits that pay off:

- **Name it after what you would type to find it**, not after what it is:
  `sql-last-week.sql` beats `query3.sql`.
- **One level of folders is indexed**, so `sql/`, `email/` and `k8s/` work and
  are worth it once you pass a dozen snippets. Deeper than that is not read;
  raise `depth` if you want it.

Copying is all Enter does, deliberately. Look hides itself as it copies, so
`Cmd+V` lands in whatever you were typing in a moment ago, and the clip also
shows up in Look's own clipboard history (`c"`) afterwards.

## Customise

- **`pbcopy < {path}`** is macOS. Linux: `wl-copy < {path}` on Wayland,
  `xclip -selection clipboard < {path}` on X11. Windows: `clip < {path}`.
  `pbpaste` in `snippets-new` is `wl-paste`, `xclip -selection clipboard -o`,
  or `powershell -c Get-Clipboard`.
- **Somewhere else than `~/.look/snippets`.** Change `dir`, and the path in
  `snippets-new` to match. A folder inside a dotfiles repo works; Look reads
  through symlinks.
- **Markdown snippets** render as headings and lists in the preview pane rather
  than showing their source. Use `.txt` for anything whose exact characters
  matter.
- **`depth = 2`** is the folder and one level in. Raise it for a deeper tree,
  and expect the list to get long: ranking sorts it out, but a snippet you have
  never pressed Enter on starts level with every other one.
