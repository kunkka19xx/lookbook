# bookmarks

A handful of links you keep by hand, as rows. Enter opens one in your browser, `Cmd+E` opens the list to edit it.

This is the `file` producer: no command runs and nothing is discovered. The file *is* the source, so the list changes when you change it and never on its own.

**Requires.** Look v0.6.12 or newer. An editor and a terminal for the edit rows.

**Platforms.** Linux as written. macOS and Windows need one line changed each, both named below. The format itself is identical everywhere, and a list edited on Windows works unaltered: line endings are stripped when the row is read.

## Install

```bash
cp examples/bookmarks/*.toml ~/.look/sources/
```

Then write the list. It does not exist yet, and an absent file is simply an empty block:

```bash
cat > ~/.look/bookmarks.txt <<'EOF'
https://github.com/kunkka19xx/look	Look	the launcher these are for
https://github.com/kunkka19xx/lookbook	lookbook	ready-made sources
https://news.ycombinator.com	Hacker News	orange website
https://example.com
EOF
```

Those are real tabs. Reload with `Ctrl+Shift+;`.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `bookmarks` | one row per line of `~/.look/bookmarks.txt` | opens the URL |
| `bookmarks-edit` | one row, always | opens the list in your editor |

## The format

```
id <TAB> title <TAB> subtitle
```

- The **id** is what `{id}` gives your commands and what usage is recorded against. Here it is the URL.
- The **title** is what you read and what you search. **Only the title is matched**, so write the words you will actually type.
- The **subtitle** is the grey line under it. Optional.
- A line with **no tabs** is a row whose id and title are the same text, which is all a bare URL needs.
- Blank lines are skipped. **There are no comments** — every non-blank line is a row, so a `#` line appears as one. Keep notes in the subtitle instead.

## Customise

- **`open` is the platform line.** Linux `xdg-open {id}`, macOS `open {id}`, Windows `start "" {id}`.
- **The editor rows** name `ghostty -e nvim`. Use whatever you edit with: `kitty -e hx`, `gnome-terminal -- vim`, or a GUI editor with no terminal at all (`code ~/.look/bookmarks.txt`, `zed ~/.look/bookmarks.txt`).
- **Not only URLs.** Any id your `open` line understands works, so a list of `ssh` targets, docker images or ticket numbers is the same block with a different command.
- **Somewhere else**: point `file` at a list your dotfiles already keep. It takes `~` on every platform.

## When the list is generated, drop the TOML entirely

If the list is produced rather than kept by hand, you do not need a `.toml` at all. An executable dropped straight into `~/.look/sources/` is read as a `run` block whose id and name are the file name:

```bash
cat > ~/.look/sources/repos <<'EOF'
#!/usr/bin/env bash
find ~/dev -maxdepth 2 -name .git -printf '%h\n' | sed 's|.*/||'
EOF
chmod +x ~/.look/sources/repos
```

That is the fastest way to try an idea. Everything else is a default, so when it needs an `open`, a `preview` or a `then`, write a block that names the script in `run` — the way [docker](../docker) and [browser-history](../browser-history) do. On Windows the executable bit does not exist, so the extension decides: `.exe`, `.cmd`, `.bat`, `.com` and `.ps1` count.
