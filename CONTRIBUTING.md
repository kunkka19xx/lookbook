# Contributing an example

One folder under `examples/` is one **topic**: a tool, or a job you do. It holds one `.toml` file or several, plus a README.

```bash
make new NAME=tmux
```

That copies the template into `examples/tmux/`, renames the folder, the file, the block ids and the display name, and adds a row to the index table in this repo's README. What is left is the part only you can write: the commands, and the sentences describing them.

```bash
make install NAME=tmux    # copy it into ~/.look/sources and try it for real
make check                # parse it the way Look would
make uninstall NAME=tmux
```

`make` on its own lists everything.

> **You need Look v0.6.12 or newer to test anything here.** An older build never reads `~/.look/sources/`, so your example will look broken when it is fine.

```
examples/git/
├── README.md            # required
├── git-branches.toml    # one file, or several
├── git-worktrees.toml
└── bin/                 # optional helper scripts
```

Several files in one folder is the normal case for a tool with more than one useful source. They are independent: a user can copy one, the other, or both.

## The naming rule

**Every file name and every block id starts with the folder name.**

```
examples/git/git-branches.toml     # good
examples/git/worktrees.toml        # NO: someone else will ship worktrees.toml
```

```toml
[git-branches]          # good
[git-branches-delete]   # good
[branches]              # NO: collides with everyone else's branches block
```

This is not style, it is the only thing keeping installed examples apart. Everything lands in one flat `~/.look/sources/`, where a second `worktrees.toml` overwrites the first on copy, and where two blocks sharing an id means **only the alphabetically-first one loads** while the other is reported as a duplicate. CI enforces both.

## Checklist

- [ ] Every `.toml` file name and every block id starts with the folder name.
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

Two things to know while you are testing:

- **A failing `run` block keeps its previous rows.** That is deliberate, since losing them would also lose their ranking, but during development it means you can be looking at output from two edits ago. If a change seems to do nothing, check the command in a terminal.
- **Errors go to stderr, not the UI.** Launch Look from a terminal while you work and watch for lines starting `look sources:`.

## README shape

Short. [`template/README.md`](template/README.md) is the whole thing, and it fits on a screen:

- **A sentence or two** at the top saying what you get.
- **Requires** and **Platforms** lines.
- **Install**: the `cp` line, plus anything extra (a `bin/` script, a `then` line to add elsewhere).
- **Blocks**: a table of id, what it lists, what Enter does.
- **Customise**: the two or three lines people will want to change first.

Add a section beyond that only when something is genuinely confusing. The `git` example explains `{path}` versus `{parent.path}` because that one catches everybody; most examples need nothing extra.

## Check it before you open a PR

```bash
make check
```

It borrows Look's own parser, so it catches exactly what Look would: unknown keys, a block with no producer, a dangling `then`, a duplicate id, a bad glob. It also checks the paperwork: a README with a Platforms line, an entry in the root index, executable `bin/` scripts. The same script runs in CI.

It is the floor, not the bar. It reads your file; it never runs your commands. The [walkthrough above](#test-it-in-look-before-you-commit) is the part that catches a source that parses beautifully and does nothing.
