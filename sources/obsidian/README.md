# obsidian

Your vault in Look. Every note is a row you can type for, the preview shows the
note itself, and `newnote Meeting with Bob` creates one with that title. Opening
and searching hand off to Obsidian; the listing and the preview are plain files
on disk, so they work with Obsidian closed.

**Requires.** Look v0.7.5 or newer (`{arg}` and `{path:url}`; on 0.7.4 they pass
through as literal text and the note would be called `{arg:url}`), Obsidian, and
the vault **opened once in Obsidian** so it knows the name the URIs use.
`python3` for the preview script, which macOS ships.

**Platforms.** macOS, because the actions call `open`. On Linux and Windows the
same URIs work through `xdg-open` and `start`; see [Elsewhere](#elsewhere).

## Install

```bash
cp sources/obsidian/*.toml ~/.look/sources/
mkdir -p ~/.look/bin && cp sources/obsidian/bin/note-preview ~/.look/bin/
chmod +x ~/.look/bin/note-preview
```

Then **edit the vault in `~/.look/sources/obsidian.toml`**. It appears twice and
in two forms, which the file marks:

- the **folder**, `~/Documents/notes`, which Look reads directly
- the **name**, `notes`, which is that folder's own name and what every
  `obsidian://` URI needs

Reload with `Cmd+Shift+;`.

## Blocks

| Block | Row | Enter |
| --- | --- | --- |
| `obsidian` | one row per note | opens the note |
| `obsidian-new` | one row, type into it | creates a note titled by what you typed |
| `obsidian-search` | one row, type into it | runs Obsidian's own search |
| `obsidian-daily` | one row, always | creates today's daily note if missing, then opens it |
| `obsidian-open` | via `Cmd+K` on a note | opens it in Obsidian rather than your editor |
| `obsidian-append-daily` | via `Cmd+K` on **any** `.md` | appends a link to today's daily note |

## What it shows off

- **`{arg}`**, a block you type into. `newnote Meeting with Bob` passes
  `Meeting with Bob` to the command, and the row shows the argument before you
  press Enter. `{query}` cannot do this: it means "the query that found this
  row", so a producer using it is reachable only through another block's `Cmd+K`.
- **`{path:url}`**, percent-encoding for a command that builds a URL. Shell
  quoting protects the shell and does nothing for a query string, so a note
  called `Notes & ideas (draft).md` would otherwise end the URL early and open
  the wrong note. The encoded form is the one value Look does not shell-quote,
  which is why it can sit inside the quotes a URL needs.
- **A `preview` that prints blocks.** `bin/note-preview` prints a JSON array and
  Look draws it as a layout: where the note will land, a warning when that name
  is taken, and the three most recently touched notes. A preview printing
  anything else is still shown as plain text.
- **`applies`**, so "Append to daily note" joins the `Cmd+K` menu of every
  markdown file Look knows about, not only the notes this source produced.

## Notes

**It does not rename anything.** A title with spaces stays a title with spaces,
because that is Obsidian's own convention and a note created by Look should not
look foreign in the vault. A title containing `/` will make Obsidian create a
folder, so avoid it or add your own sanitising to the script.

**Creating goes through Obsidian rather than writing the file.** Writing it
directly would be faster and would work with Obsidian closed, but it would also
ignore Obsidian's "default location for new notes", its templates and its
filename rules. The URI keeps the app's conventions, at the cost of needing it
running.

## Elsewhere

The `obsidian://` URIs are the same on every platform; only the opener differs.
Replace `open -g "..."` with `xdg-open "..."` on Linux or `start "" "..."` on
Windows, and `sed -n 1,80p` with whatever your shell has. The `dir` block, the
preview and `applies` need no changes at all.
