# work-setup

One row called "Work setup". Enter opens every app and page you start the day with.

The simplest kind of source, and a good first one to write: no rows to pick from, no placeholders, just a name and a list of steps.

**Requires.** Look v0.6.12 or newer. Nothing else beyond the apps you name.

**Platforms.** macOS as written. Linux and Windows need different commands, see Customise.

## Install

```bash
cp examples/work-setup/*.toml ~/.look/sources/
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `work-setup` | one row | runs every step in order |

## Customise

- Edit the `do` list. Each string is one shell command, so anything you can type in a terminal works.
- A step that fails does not stop the rest, and steps are not waited on, so a slow app holds up nothing.
- **Linux**: `xdg-open https://github.com/pulls`, and apps by binary name (`slack`, `ghostty`).
- **Windows**: `start "" https://github.com/pulls`.
- Copy it for other routines (`[evening-shutdown]`, `[focus-mode]`). Rename the file and the block id together.
