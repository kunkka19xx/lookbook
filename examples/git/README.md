# git

Branches and worktrees of whichever project you have selected.

**Requires.** Look v0.6.12 or newer, and `git`.

**Platforms.** macOS, Linux, Windows. The `open` line in `git-worktrees.toml` is macOS; see Customise.

## Install

```bash
cp examples/git/*.toml ~/.look/sources/
```

Two files, independent of each other: copy just one if you only want one. Then point your project rows at them. With [dev-projects](../dev-projects), add one line to `~/.look/sources/dev-projects.toml`:

```toml
then = ["git-branches", "git-worktrees"]
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `git-branches` | branches of the selected repo, newest first | `git switch` to it |
| `git-branches-delete` | on a branch, via `Cmd+K` | deletes it, after asking |
| `git-worktrees` | worktrees of the selected repo | opens the folder |

None of them appear when you just type. All three name a row, so Look reaches them only through `then`. That is the rule, not a setting.

## Which placeholder goes where

The one thing worth getting right:

| Line | Runs while... | So the repo is |
| --- | --- | --- |
| `run` | the **repo** is the selected row | `{path}` |
| `preview`, `open`, `git-branches-delete` | a **branch** row is selected | `{parent.path}` |

A producer is asked for rows before its own rows exist, so the row it sees is the one you drilled from. Everything after that acts on a row it produced, one level deeper.

## Customise

- Drop `--sort=-committerdate` for alphabetical branches.
- `git switch` needs git 2.23 or newer. Older git: `git -C {parent.path} checkout {id}`.
- The delete uses `-d`, which refuses an unmerged branch. `-D` forces it. If you change that, keep the `confirm`.
- Worktree rows open with `open {id}` (macOS). **Linux**: `xdg-open {id}`. **Windows**: `start "" {id}`.
- Worktree rows are text, not folders, so `Cmd+F` and the preview pane do nothing on them. Switch the block to `format = "json"` and emit a `path` field to make them real folders.
