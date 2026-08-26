# template

One or two sentences: what rows you get, and what Enter does.

**Requires.** Look v0.6.12 or newer. Name anything else that has to be installed.

**Platforms.** macOS, Linux, Windows

## Install

```bash
cp examples/template/*.toml ~/.look/sources/
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `template` | folders in `~/Documents` | opens the folder |
| `template-action` | on a row, via `Cmd+K` | echoes the path, after asking |

## Customise

- `dir` is the directory to list. `dirs = [...]` takes several.
- `edit` is what `Cmd+E` runs. Drop it to use your global editor.
- Delete `[template-action]` and the `then` line for one flat list.
