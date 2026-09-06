# Contributing an example

Two kinds live here, and which one you are writing decides where it goes and how it is installed:

- a **source** adds rows to the launcher, and is **copied** into `~/.look/sources/`;
- a **tile** adds a tile to the Super Actions strip, and is **merged** into `~/.look/super-actions.toml`, a single file that holds the user's whole strip.

Everything below applies to both unless it says otherwise. One folder is one **topic**: a tool, or a job you do. It holds one `.toml` file or several, plus a README.

```bash
make new NAME=tmux        # a source, in sources/
make new-tile NAME=disk   # a tile, in tiles/
```

That copies the right template, renames the folder, the file, the ids and the display name, and adds a row to the matching index table in this repo's README. What is left is the part only you can write: the commands, and the sentences describing them.

```bash
make install NAME=tmux    # a source: copy it into ~/.look/sources and try it for real
make show NAME=disk       # a tile: print the block to paste, and where
make check                # parse it the way Look would
make uninstall NAME=tmux
```

`make` on its own lists everything.

There is deliberately **no `make install` for a tile.** `~/.look/super-actions.toml` is the user's own layout, and a script that edited it would be rearranging their strip. Installing one is two edits they make by hand: the tile's name into the `layout` drawing, and the block onto the end.

> **Sources need Look v0.6.12 or newer to test; tiles and `applies` need v0.6.13.** An older build ignores what it does not know about, so your example looks broken when it is fine.

```
sources/git/                tiles/lock/
├── README.md            # required
├── git-branches.toml    ├── README.md          # required
├── git-worktrees.toml   ├── lock-macos.toml    # one file, or several
└── bin/                 └── lock-linux.toml
```

Several files in one folder is the normal case. For a source they are independent, and a user can copy one, the other, or both. For a tile they are usually **alternatives**: `lock-macos.toml` and `lock-linux.toml` declare the same `[tiles.lock]` for two systems, and a user takes one.

## The naming rule

**Every file name and every block id starts with the folder name.** Everything lands in one flat `~/.look/sources/`, where a second `worktrees.toml` overwrites the first on copy, and where two blocks sharing an id means only the alphabetically-first one loads.

```toml
# sources/git/git-branches.toml, not sources/git/worktrees.toml
[git-branches]          # good
[branches]              # NO: collides with everyone else's branches block
```

Block **ids** are not what anyone types, though. A `name` or an `alias` competes with the user's whole index: their apps, files, folders, settings and browser history. Ship a generic one and you make every one of their searches for that word worse, silently, on a machine you have never seen.

```toml
name    = "tmux sessions"                    # good: two words, both distinctive
aliases = ["tm"]                             # good: short, means nothing else

name    = "Files"                            # NO: an app on macOS and GNOME
aliases = ["code", "git", "notes", "open"]   # NO: an editor, a directory, a folder, a verb
```

Ask what the word already means on a normal machine before you claim it. Most blocks need no alias at all. Do not paper over a generic name with `bias` either: that shifts the whole block in *every* query, and it is the user's call rather than yours.

This is the one rule CI enforces on both halves, because it is the only thing keeping installed examples apart.

## Write it so Enter is safe

The rest is judgement, not a form to fill in. The things that actually bite:

- **Anything destructive declares `confirm`.** Deleting, stopping, force-pushing, resetting: a launcher makes Enter on the wrong row cheap. And `confirm` should read "Delete branch main?", not "Delete branch {id}?".
- **Do not quote placeholders.** `open {path}`, never `open "{path}"`. Look shell-escapes every substitution already, so your quotes are a second layer that breaks it.
- **No hard-coded home directory**, nothing that downloads and runs code, nothing that writes outside what the example is about.
- **Label commands only one OS understands.** `open -a` is macOS, `xdg-open` is Linux, `start` is Windows.
- **No metadata table in the `.toml`.** Every top-level table is a block, so a `[_meta]` fails to parse. Put context in the README or in `#` comments.
- **A `bin/` script** needs a shebang, the executable bit, and a README line saying where to put it.

For a **tile**, three more. Its `value` command has to finish in **under two seconds on a cold machine**, not just on yours; past that it is killed and the tile keeps its last good reading. It declares no `layout` — the drawing belongs to the user's file, so ship the `[tiles.<name>]` block alone. And `icon` is labelled per platform, since an SF Symbol name means nothing on Linux and an unrecognised name draws nothing at all.

## Say which platforms it works on

Every example README needs this line, and the checker fails without it:

```markdown
**Platforms.** macOS, Linux, Windows
```

Name **only the ones you actually ran it on** — not the ones you assume, and not "should work anywhere". Say it plainly when support is partial, which is the normal case:

```markdown
**Platforms.** macOS as written, Linux with a one-line change to `open`. Untested on Windows.
```

This matters more here than in most repos, because the commands are the example. Someone on Windows reading "macOS, Linux" knows to expect work; reading "macOS, Linux, Windows" from a guess wastes their evening. If you cannot test an OS, say so and let someone who has one send the variant.

## Link a GIF, do not commit it

A GIF of your example in use is welcome. Put it somewhere else and link it:

```markdown
![tmux](https://user-images.githubusercontent.com/.../open-in-tmux.gif)
```

The easy way to get such a URL is to drag the file into a GitHub issue, pull request, or release. GitHub uploads it and hands back a permanent link, and no `media/` folder is needed.

Committing it instead is a decision nobody can undo. Git keeps every version of a binary forever and cannot delta-compress one, so a 5 MB recording is 5 MB in every clone of this repo from now on. What is being shared here is a handful of small text files people copy; a demo of them should not outweigh them.

## Test it in Look before you commit

`make check` proves your file **parses**. It cannot prove your commands **work**: it never runs them. A block can be perfectly valid TOML and still open the wrong thing, or nothing at all. So install it for real first:

```bash
make install NAME=my-thing    # a source
make show NAME=my-tile        # a tile: paste it in, add the name to your layout
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows), then actually use it. The rows appear and typing the name finds them; Enter does the right thing, including on a row whose name has a space or a quote in it; `preview` fills the panel; every `then` target works from `Cmd+K`. For a tile: it is drawn in the cell and at the size you gave it, its reading is still right after the `refresh` window lapses, press does what it says, and its letter works.

Then break it on purpose. Rename the tool it depends on, reload, and check that **the failure mode is not silent** — a readable message rather than an empty list, and a tile that keeps its last reading rather than blanking the strip. This is the one that catches most examples.

Two things to know while you are testing:

- **A failing `run` block keeps its previous rows.** That is deliberate, since losing them would also lose their ranking, but during development it means you can be looking at output from two edits ago. If a change seems to do nothing, check the command in a terminal.
- **Errors go to stderr, not the UI.** Launch Look from a terminal while you work and watch for lines starting `look sources:`.

## README shape

Short. [`template/source-README.md`](template/source-README.md) and [`template/tile-README.md`](template/tile-README.md) are the whole thing, and each fits on a screen:

- **A sentence or two** at the top saying what you get.
- **Requires** and **Platforms** lines.
- **Install**: for a source, the `cp` line plus anything extra (a `bin/` script, a `then` line to add elsewhere). For a tile, the `layout` line to change and the block to paste — no `cp`, since copying over that file takes the user's whole strip with it.
- **Blocks** (or **The tile**): a table of id, what it shows, what Enter or a press does.
- **Customise**: the two or three lines people will want to change first.

Add a section beyond that only when something is genuinely confusing. The `git` example explains `{path}` versus `{parent.path}` because that one catches everybody; most examples need nothing extra.

## Check it before you open a PR

```bash
make check                # everything
make check NAME=tmux      # just the one you are working on
```

It borrows Look's own parsers, built from a checkout **pinned to Look's latest release tag**, so it catches exactly what Look would: unknown keys, a block with no producer, a dangling `then`, a duplicate id, a bad glob. Then it re-reads the rules above back to you — a hard-coded home directory, a quoted placeholder, a `curl` into a shell, a missing **Requires** or **Platforms** line, a block your README never mentions, the `TODO` row `make new` left in the index, a committed GIF. For a tile it also synthesizes a `layout` naming everything the file declares, so a tile that parses but cannot be placed fails here rather than on someone's strip. The same script runs in CI.

Because the pin is a release and not `main`, a key that has not shipped yet fails here by name, which is how the **Requires** line in your README stays true. Writing an example for something unreleased is the one case to override it:

```bash
LOOK_REF=main make check
```

Two things it can never check, and they are the two that catch the most: **that you installed it and used it**, and **that a command only one OS understands is labelled as such**. Neither is decidable from the text, so both stay yours.

It is the floor, not the bar. It reads your file; it never runs your commands. The [walkthrough above](#test-it-in-look-before-you-commit) is the part that catches a source that parses beautifully and does nothing.
