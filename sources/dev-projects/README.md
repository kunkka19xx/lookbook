# dev-projects

Every folder in `~/dev` as a row. Type a project name, Enter opens it, `Cmd+E` opens it in your editor.

The rows are real folders, so everything Look already does to a folder keeps working: the preview lists the children, `Cmd+F` reveals it, `Cmd+C` copies the path.

**Requires.** Look v0.6.12 or newer, and v0.7.5 for the empty `edit` to mean your usual editor.

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

## Customise

- `dir = "~/dev"` is the line most people change. Several roots: `dirs = ["~/dev", "~/work"]`.
- `depth = 2` also lists each project's children, for a `~/dev/<org>/<repo>` layout.
- `only = "files"` or `"all"` if folders are not what you want. `match` and `exclude` take globs, tested against the entry name. Hidden entries are always skipped.
- `edit` is empty, so `Cmd+E` opens your usual editor (`code_editor` in `~/.look/config`). For one just for these rows, write a command with `{path}`: `open -a 'Zed' {path}` opens any app by name on macOS, `code {path}` needs that command installed, and `nvim {path}` opens in your `terminal`.
- `bias = 200` puts your projects above folders that merely start with what you typed (`repo` finds your repos, not every `repository/` inside them). Lower it if they crowd out other results; `bias = -5` pushes them below your apps and files instead.

**Pairs with** [git](../git), which drills into the branches and worktrees of the selected project. One line to add, in its README.
