# lookbook

Ready-made sources for [Look](https://github.com/kunkka19xx/look). Copy a file, reload, done.

A **source** is a small TOML file that adds your own rows to Look: your repos, your SSH hosts, your morning routine. One folder here is one topic, holding a README and one or more `.toml` files you can install independently.

New to sources? Read the [format guide](https://github.com/kunkka19xx/look/blob/main/docs/user-sources.md) first. It is short.

> **Needs Look v0.6.12 or newer.** Earlier builds do not read `~/.look/sources/`, so nothing here will appear. 0.6.12 is not released yet: [build from source](https://github.com/kunkka19xx/look/blob/main/DEVELOPMENT.md) to try these today.

**_Tmux source in action_**  
![tmux](./examples/tmux/open-in-tmux.gif)

## Install any example

```bash
cp examples/<name>/*.toml ~/.look/sources/
```

Or copy a single file out of a folder if you only want that one.

Then reload Look: `Cmd+Shift+;` on macOS, `Ctrl+Shift+;` on Linux and Windows.

Copy only the `.toml`. Look reads `~/.look/sources/` flat, so it never looks inside subdirectories, and a stray `README.md` in there is reported as an ignored file. If an example ships a script in `bin/`, its README says where to put it.

## Change it to fit your machine

Every file here was written against somebody else's setup, and what makes an example useful is exactly what makes it personal: a projects directory, a terminal, an editor. Open the `.toml` and change those lines before you reload.

The four that catch people:

- **A path that is not yours.** `dev-projects` lists `~/dev`. If your repos are in `~/code` or `~/work`, you get an empty list and nothing else.
- **An app you do not have.** `ssh` and `docker` open Ghostty, `tmux` attaches with WezTerm, `work-setup` opens Slack, Ghostty and Safari, `dev-projects` edits with `code`.
- **`open`, which is macOS.** On Linux that is `xdg-open`, on Windows `start ""`. Most of these were tested on macOS only; the table below says which.
- **A file that has to be there.** `ssh` reads your `~/.ssh/config`. Anything shipping a `bin/` script needs that script in `~/.look/bin/` first, which its README tells you.

Each example's README has a **Customise** section naming the two or three lines people change first, with the Linux and Windows variants written out. That is the section to read before you reload.

**A mismatch is quiet in the UI.** A `dir` that is not there gives you an empty list, and Enter on a row naming an app you do not have does nothing at all. The reason goes to stderr rather than into the window, so launch Look from a terminal while you are setting these up:

```
look sources: [dev-projects] could not read /home/you/dev
```

Every line it prints starts `look sources:` and names the block, which is the fastest way to tell a source that is misconfigured from one that is simply empty.

## The examples

The **Platforms** column is what the author tested, not what might work. Where an example needs a change to run elsewhere, its README says which line.

| Example                               | Tools      | Shows off                                                     | Platforms             |
| ------------------------------------- | ---------- | ------------------------------------------------------------- | --------------------- |
| [work-setup](examples/work-setup)     | none       | `do`: one row, several apps                                   | macOS                 |
| [dev-projects](examples/dev-projects) | none       | `dir`: rows from a directory, custom verbs                    | macOS, Linux, Windows |
| [ssh](examples/ssh)                   | ssh        | `run`: rows from a command, and the `file` alternative        | macOS                 |
| [git](examples/git)                   | git        | two files in one folder; drill-downs, `confirm`, `{parent.*}` | macOS, Linux, Windows |
| [docker](examples/docker)             | docker, jq | `format = "json"`, per-row icons, a helper script             | macOS                 |
| [tmux](examples/tmux)                 | tmux       | a `bin/` script doing real work; session per project          | macOS                 |

## Read before you install

Every example runs shell commands on your machine when you press Enter. They are short and readable on purpose: **open the `.toml` and read it before you install it**, the same way you would read a shell script someone handed you. Nothing here downloads anything, pipes a URL into a shell, or touches a file you did not point it at, and anything destructive asks first.

## Contributing

Yes please. `make new NAME=tmux` scaffolds one with every rename already done. One folder per example, [the checklist is short](CONTRIBUTING.md), and CI parses every file with Look's own parser so a typo cannot reach anyone. Two things we ask beyond that: **install it and use it before you commit** (parsing is not running), and **say which platforms you actually tested on**.

## License

MIT. Use these however you like.
