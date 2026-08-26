# Notes for whoever copies this folder

Delete this file in your own example. It is the instructions, not the shape.

## Start

```bash
make new NAME=my-thing
```

It does the copying and every rename: folder, file, block ids, display name, README heading and install line, plus the index row in the root `README.md`. You never need to copy this folder by hand.

## The four required parts of the README

The one in this folder is the whole shape. Keep it that short.

1. **A sentence or two** at the top saying what you get.
2. **Requires** and **Platforms** lines. Name only the OSes you actually ran it on: the checker fails without a `**Platforms.**` line, and an optimistic list wastes somebody's evening.
3. **Install**: the literal `cp` line, plus anything extra (a `bin/` script to copy, a `then` line to add elsewhere).
4. **Blocks** table, then **Customise** bullets for the two or three lines people will want to change first.

Anything beyond that is yours. The `git` example adds a short section on placeholders because it is genuinely confusing; most examples need nothing extra.

## More than one file is fine

A folder is a topic, not a single source. `git/` holds `git-branches.toml` and `git-worktrees.toml`, and a user can copy one or both. Name every file after the folder (`git-*.toml`) and prefix every block id the same way, so nothing collides in `~/.look/sources/`.

## Before you commit

`make check` proves the file parses. It never runs your commands. `make install NAME=my-thing`, reload, and actually use it: see [CONTRIBUTING](../CONTRIBUTING.md#test-it-in-look-before-you-commit).

Adding a GIF of it in use? Link it from somewhere else rather than committing the file: see [CONTRIBUTING](../CONTRIBUTING.md#link-a-gif-do-not-commit-it).
