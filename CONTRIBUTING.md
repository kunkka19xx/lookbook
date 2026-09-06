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

Several files in one folder is the normal case. For a source they are independent, and a user can copy one, the other, or both. For a tile they are usually **alternatives** — `lock-macos.toml` and `lock-linux.toml` declare the same `[tiles.lock]` for two systems, and a user takes one. The checker reads each tile file on its own for exactly that reason.

## The naming rule

**Every file name and every block id starts with the folder name.**

```
sources/git/git-branches.toml     # good
sources/git/worktrees.toml        # NO: someone else will ship worktrees.toml
```

```toml
[git-branches]          # good
[git-branches-delete]   # good
[branches]              # NO: collides with everyone else's branches block
```

Block **ids** are not what anyone types, though. `name` and `aliases` are, and they answer to a different rule.

## The naming rule's other half: what people type

An id only has to be unique inside `~/.look/sources/`. A `name` or an `alias` competes with the user's whole index: their apps, files, folders, settings and browser history. Ship a generic one and you make every one of their searches for that word worse, silently, on a machine you have never seen.

```toml
name    = "tmux sessions"                    # good: two words, both distinctive
aliases = ["tm"]                             # good: short, means nothing else

name    = "Files"                            # NO: an app on macOS and GNOME
aliases = ["code", "git", "notes", "open"]   # NO: an editor, a directory, a folder, a verb
```

Ask what the word already means on a normal machine before you claim it. Two words are safer than one, since both reach the block and neither matches much alone. An alias earns its place only by being shorter than the name and colliding with less, so most blocks need none at all.

Do not paper over a generic name with `bias`. That shifts the whole block in *every* query, including the ones the user did not have in mind, and it is their call rather than yours.

This is not style, it is the only thing keeping installed examples apart. Everything lands in one flat `~/.look/sources/`, where a second `worktrees.toml` overwrites the first on copy, and where two blocks sharing an id means **only the alphabetically-first one loads** while the other is reported as a duplicate. CI enforces both.

## Checklist

- [ ] Every `.toml` file name and every block id starts with the folder name.
- [ ] `name` and `aliases` are distinctive, not words the user's apps and files already answer to.
- [ ] No hard-coded home directory. Write `~/dev`, never `/Users/you/dev`.
- [ ] Anything destructive declares `confirm`. Deleting, stopping, force-pushing, resetting: a launcher makes Enter on the wrong row cheap.
- [ ] No placeholder is quoted by you. `open {path}`, never `open "{path}"`. Look shell-escapes every substitution already, so your quotes are a second layer that breaks it.
- [ ] Nothing downloads and runs code (`curl ... | sh`), and nothing writes outside what the example is about.
- [ ] The README has a **Platforms** line naming every OS you actually ran it on. See below.
- [ ] The README says what has to be installed (`git`, `jq`, `docker`).
- [ ] Commands that only work on one OS are labelled. `open -a` is macOS, `xdg-open` is Linux, `start` is Windows.
- [ ] **You installed it and used it**, not just parsed it. See below.
- [ ] A `bin/` script is executable, has a shebang, and the README says where to put it.
- [ ] A demo GIF or screenshot is **linked**, not committed. [See below](#link-a-gif-do-not-commit-it).
- [ ] No metadata table in the `.toml`. Every top-level table is a block, so a `[_meta]` fails to parse. Put context in the README or in `#` comments.

Four more for a **tile**:

- [ ] Its `value` command finishes in **under two seconds on a cold machine**, not just on yours. Past that it is killed along with anything it started, and the tile keeps its last good reading.
- [ ] It declares no `layout`. The drawing belongs to the user's file; ship the `[tiles.<name>]` block alone.
- [ ] The README says it is **merged** into `~/.look/super-actions.toml`, and shows the `layout` line to change. No `cp` install line: copying over that file takes the user's whole strip with it.
- [ ] `icon` is labelled per platform. An SF Symbol name means nothing on Linux, an image path means nothing on Windows, and an unrecognised name draws nothing at all rather than a placeholder.

## Say which platforms it works on

Every example README needs this line, and the checker fails without it:

```markdown
**Platforms.** macOS, Linux, Windows
```

Name **only the ones you actually ran it on.** Not the ones you assume it works on, and not "should work anywhere". Someone on Windows reading "macOS, Linux" knows to expect work; reading "macOS, Linux, Windows" from a guess wastes their evening.

Say it plainly when support is partial, which is the normal case:

```markdown
**Platforms.** macOS as written, Linux with a one-line change to `open`. Untested on Windows.
```

This matters more here than in most repos, because the commands are the example. `open -a Ghostty`, `xdg-open`, and `start ""` are three different things, and a launcher command that silently does nothing is hard to debug from the outside. If you cannot test an OS, say so and let someone who has one send the variant.

## Link a GIF, do not commit it

A GIF of your example in use is welcome. Put it somewhere else and link it:

```markdown
![tmux](https://user-images.githubusercontent.com/.../open-in-tmux.gif)
```

The easy way to get such a URL is to drag the file into a GitHub issue, pull request, or release. GitHub uploads it and hands back a permanent link, and no `media/` folder is needed.

Committing it instead is a decision nobody can undo. Git keeps every version of a binary forever and cannot delta-compress one, so a 5 MB recording is 5 MB in every clone of this repo from now on, and re-recording it twice makes that 15 MB. What is being shared here is a handful of small text files people copy; a demo of them should not outweigh them.

## Test it in Look before you commit

`make check` proves your file **parses**. It cannot prove your commands **work**: it never runs them. A block can be perfectly valid TOML and still open the wrong thing, or nothing at all.

So install it for real first:

```bash
make install NAME=my-thing
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows), then walk the list:

- [ ] **The rows appear**, and typing the name you gave finds them.
- [ ] **Enter does the right thing** on a row, and on a row whose name has a space or a quote in it.
- [ ] **`preview` fills the panel**, if you declared one.
- [ ] **Every `then` target works** from `Cmd+K`, including the drill-downs.
- [ ] **`confirm` names the right row.** The question is expanded, so it should read "Delete branch main?", not "Delete branch {id}?".
- [ ] **The failure mode is not silent.** Rename the tool it depends on, reload, and check that you get something readable instead of an empty list.

A **tile** is merged rather than installed, so the walk is its own:

```bash
make show NAME=my-tile    # then paste it in, and add the name to your layout
```

- [ ] **The tile is drawn**, in the cell you drew it in, at the size you gave it.
- [ ] **What it shows is right**, and still right after its `refresh` window lapses.
- [ ] **Press does what it says**, and `confirm` arms on the first press and fires on the second.
- [ ] **Its letter works**, or is legitimately taken by a built-in on your strip.
- [ ] **The failure mode is not silent.** Rename the tool it depends on and reload: the tile should keep its last reading and say what happened, never blank the strip.
- [ ] **It behaves when there is nothing to report.** A tile whose `value` prints nothing is not drawn, which is usually what you want; check it is not printing an empty box instead.

Two things to know while you are testing:

- **A failing `run` block keeps its previous rows.** That is deliberate, since losing them would also lose their ranking, but during development it means you can be looking at output from two edits ago. If a change seems to do nothing, check the command in a terminal.
- **Errors go to stderr, not the UI.** Launch Look from a terminal while you work and watch for lines starting `look sources:`.

## README shape

Short. [`template/source-README.md`](template/source-README.md) and [`template/tile-README.md`](template/tile-README.md) are the whole thing, and each fits on a screen:

- **A sentence or two** at the top saying what you get.
- **Requires** and **Platforms** lines.
- **Install**: for a source, the `cp` line plus anything extra (a `bin/` script, a `then` line to add elsewhere). For a tile, the `layout` line to change and the block to paste.
- **Blocks** (or **The tile**): a table of id, what it shows, what Enter or a press does.
- **Customise**: the two or three lines people will want to change first.

Add a section beyond that only when something is genuinely confusing. The `git` example explains `{path}` versus `{parent.path}` because that one catches everybody; most examples need nothing extra.

## Check it before you open a PR

```bash
make check                # everything
make check NAME=tmux      # just the one you are working on
```

It borrows Look's own parsers — `look-sources` for `sources/`, the launchpad resolver for `tiles/` — so it catches exactly what Look would: unknown keys, a block with no producer, a dangling `then`, a duplicate id, a bad glob. Then it reads the checklist above back to you: a hard-coded home directory, a placeholder you quoted, a `curl` into a shell, a missing **Requires** or **Platforms** line, a block your README never mentions, an install line naming somebody else's folder, the `TODO` row `make new` left in the index, a committed GIF. For a tile it also synthesizes a `layout` naming everything the file declares, so a tile that parses but cannot be placed — drawn under its minimum size, asking for a letter nothing can grant — fails here rather than on someone's strip. The same script runs in CI.

Two boxes it cannot tick, and they are the two that catch the most: **that you installed it and used it**, and **that a command only one OS understands is labelled as such**. Neither is decidable from the text, so both stay yours.

It is the floor, not the bar. It reads your file; it never runs your commands. The [walkthrough above](#test-it-in-look-before-you-commit) is the part that catches a source that parses beautifully and does nothing.
