# dev-projects

Every folder in `~/dev` as a row. Type a project name, Enter opens it, `Cmd+E` opens it in your editor.

The rows are real folders, so everything Look already does to a folder keeps working: the preview lists the children, `Cmd+F` reveals it, `Cmd+C` copies the path.

**Requires.** Look v0.7.5 or newer (for `scope`; on 0.7.4 the key is reported
and ignored, and everything else here still works). `code` if you keep the
`edit` line as written.

**Platforms.** macOS, Linux, Windows.

## Install

```bash
cp sources/dev-projects/*.toml ~/.look/sources/
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `dev-projects` | folders in `~/dev` | opens the folder |

## Narrowing to just your projects

`scope = true` reserves `projects`, `repo` and `proj` as the first word of a
line, so `projects look` lists only your projects matching "look" instead of
searching your whole machine for both words. The word alone (`projects`) is an
ordinary search, not a narrowing.

Every single-word name and alias becomes one of those openers, so an alias is
no longer free: `code` was dropped because it would have reserved the word your
editor is called. Drop `scope` if you would rather keep the words.

## Customise

- `dir = "~/dev"` is the line most people change. Several roots: `dirs = ["~/dev", "~/work"]`.
- `depth = 2` also lists each project's children, for a `~/dev/<org>/<repo>` layout.
- `only = "files"` or `"all"` if folders are not what you want. `match` and `exclude` take globs, tested against the entry name. Hidden entries are always skipped.
- `edit = "nvim {path}"`, or drop the line to use whatever `Cmd+E` already does.
- `bias = -5` pushes these below your apps and files.

**Pairs with** [git](../git), which drills into the branches and worktrees of the selected project. One line to add, in its README.
