# vscode

Every project you have opened in VS Code lately, as a row. Enter reopens it in
the editor; `Cmd+E`, `Cmd+T`, `Cmd+F` and the preview pane work on it as they
would on any folder Look found by itself, because the row **is** that folder.

Type `vsc` and the list is yours; `vsc api` searches inside it.

The list is the editor's own, read from the `state.vscdb` file it keeps for
itself. Nothing talks to a running editor, so this works with every window
closed, and it picks up a project the moment the editor remembers it.

If your projects all live in one folder, [dev-projects](../dev-projects) is
the simpler source: a `dir` block, no script, and it lists the ones you have
not opened yet too. This one is for a recent list that spans `~/work`,
`~/dev`, a client folder and `/tmp`, ordered by when you last touched them.

**Requires.** Look v0.7.5 or newer (for `scope`), `python3`, and one of VS
Code, Code - Insiders, VSCodium, Cursor or Windsurf.

**Platforms.** macOS. The script already knows where Linux keeps these files
(`~/.config/Code/...`), but it is untested there and the `open -a` line is
macOS; on Linux that is `code {path}`. Untested on Windows.

## Install

```bash
cp sources/vscode/*.toml ~/.look/sources/
cp sources/vscode/bin/vscode-recents ~/.look/bin/
chmod +x ~/.look/bin/vscode-recents
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

Installing from `Settings > Extend` inside Look does all of that, and asks
which editor Enter should use.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `vscode` | folders, files and `.code-workspace` files your editor has open recently | reopens it in the editor |

The glyph says which kind a row is: 📁 a folder, 📄 a single file, 🗂 a
workspace.

## Two things it does on purpose

**A project that is no longer on disk gets no row.** The editor's list keeps a
folder long after you delete or rename it, and a row that cannot open is worse
than a shorter list. So the list you see is shorter than the one in the
editor's own File > Open Recent, sometimes much shorter.

**A remote project gets no row either.** A Codespace, a container or an
`ssh-remote` entry has no path on this machine, so there would be nothing for
Enter, the preview pane or `Cmd+F` to act on. Those are dropped rather than
shown as rows that do nothing.

## Customise

- **`open` is the editor Enter uses.** `open -a 'Cursor' {path}` for Cursor,
  `open -a 'VSCodium' {path}`, and so on, spelled as the app is in
  `/Applications`. Drop the line entirely and Enter opens the folder the way
  Look opens any folder, which is usually not what you want here.
- **One editor's list, not all of them.** With several installed the lists are
  merged and each row says which editor it came from. To read just one:

  ```toml
  run = "LOOK_VSCODE_FLAVORS=Cursor ~/.look/bin/vscode-recents"
  ```

  The value is the directory name the editor uses: `Code`, `Code - Insiders`,
  `VSCodium`, `Cursor` or `Windsurf`.
- **How many rows**, newest first: `LOOK_VSCODE_LIMIT=40`, on the same line.
  150 by default.
- **`scope = true` reserves `vsc`** as the first word of a line. Delete it and
  the rows still rank normally in a plain search; you just lose `vsc api`.
