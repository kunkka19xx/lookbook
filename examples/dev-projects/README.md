# dev-projects

Every folder in `~/dev` as a row. Type a project name, Enter opens it, `Cmd+E` opens it in your editor.

The rows are real folders, so everything Look already does to a folder keeps working: the preview lists the children, `Cmd+F` reveals it, `Cmd+C` copies the path.

**Requires.** Look v0.6.12 or newer. `code` if you keep the `edit` line as written.

**Platforms.** macOS, Linux, Windows.

## Install

```bash
cp examples/dev-projects/*.toml ~/.look/sources/
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `dev-projects` | folders in `~/dev` | opens the folder |

## Customise

- `dir = "~/dev"` is the line most people change. Several roots: `dirs = ["~/dev", "~/work"]`.
- `depth = 2` also lists each project's children, for a `~/dev/<org>/<repo>` layout.
- `only = "files"` or `"all"` if folders are not what you want. `match` and `exclude` take globs, tested against the entry name. Hidden entries are always skipped.
- `edit = "nvim {path}"`, or drop the line to use whatever `Cmd+E` already does.
- `bias = -5` pushes these below your apps and files.

**Pairs with** [git](../git), which drills into the branches and worktrees of the selected project. One line to add, in its README.
