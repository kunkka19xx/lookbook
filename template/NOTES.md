# Notes for whoever copies this folder

Delete this file in your own example. It is the instructions, not the shape.

## Start

```bash
make new NAME=my-thing        # a source, from source.toml + source-README.md
make new-tile NAME=my-tile    # a tile, from tile.toml + tile-README.md
```

It does the copying and every rename: folder, file, ids, display name, README heading and install line, plus the index row in the matching table of the root `README.md`. You never need to copy this folder by hand.

Which one you want depends on where the thing ends up. A **source** is copied into `~/.look/sources/` and adds rows to the launcher. A **tile** is merged into `~/.look/super-actions.toml` and adds a tile to the strip on the empty home screen; it ships the `[tiles.<name>]` block alone, with no `layout`, because the drawing belongs to the user's file.

## The four required parts of the README

The one in this folder is the whole shape. Keep it that short.

1. **A sentence or two** at the top saying what you get.
2. **Requires** and **Platforms** lines. Name only the OSes you actually ran it on: the checker fails without a `**Platforms.**` line, and an optimistic list wastes somebody's evening.
3. **Install**: the literal `cp` line, plus anything extra (a `bin/` script to copy, a `then` line to add elsewhere).
4. **Blocks** table, then **Customise** bullets for the two or three lines people will want to change first.

Anything beyond that is yours. The `git` example adds a short section on placeholders because it is genuinely confusing; most examples need nothing extra.

## More than one file is fine

A folder is a topic, not a single file. `sources/git/` holds `git-branches.toml` and `git-worktrees.toml`, and a user can copy one or both. Name every file after the folder (`git-*.toml`) and prefix every id the same way, so nothing collides in the flat directory they all land in.

For a tile the same naming rule holds, but several files usually means **alternatives** rather than additions: `tiles/lock/` ships `lock-macos.toml` and `lock-linux.toml`, both declaring `[tiles.lock]`, and a user takes the one for their system. The checker reads each on its own for that reason.

## Before you commit

`make check` proves the file parses. It never runs your commands. `make install NAME=my-thing` for a source, or `make show NAME=my-tile` and paste it in, then reload and actually use it: see [CONTRIBUTING](../CONTRIBUTING.md#test-it-in-look-before-you-commit).

For a tile, the one thing the checker cannot see is the one that matters: a `value` command runs **unattended**, every time its refresh window lapses, and is killed at two seconds. Time yours on a cold machine.

Adding a GIF of it in use? Link it from somewhere else rather than committing the file: see [CONTRIBUTING](../CONTRIBUTING.md#link-a-gif-do-not-commit-it).
