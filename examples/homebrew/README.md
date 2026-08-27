# homebrew

Two lists you otherwise open a terminal for. **Outdated** is everything `brew` would upgrade, formulae and casks in one list with a glyph telling them apart; Enter upgrades that one package in a terminal you can watch. **Services** is every background service Homebrew manages, running or not, with `brew services info` in the preview pane and start, stop and restart on `Cmd+K`.

**Requires.** Look v0.6.12 or newer, [Homebrew](https://brew.sh), and `jq`. A terminal emulator for the upgrade rows.

**Platforms.** macOS. Homebrew on Linux works the same way and `brew services` there drives systemd instead of launchd, but the `open -na Ghostty` lines are macOS as written; see Customise.

## Install

```bash
cp examples/homebrew/*.toml ~/.look/sources/
```

Or copy one of the two. They are independent.

Reload with `Cmd+Shift+;`.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `homebrew-outdated` | formulae and casks with an update available | upgrades that one, in a terminal |
| `homebrew-outdated-all` | a row of its own, and on `Cmd+K` | upgrades everything, after asking |
| `homebrew-outdated-home` | on a package, via `Cmd+K` | opens the project's homepage |
| `homebrew-services` | every service `brew services` manages | restarts it, after asking |
| `homebrew-services-stop` | on a service, via `Cmd+K` | stops it, after asking |
| `homebrew-services-start` | on a service, via `Cmd+K` | starts it |

## Two things that will bite you

**`brew` has to be on the PATH your login shell builds.** Look runs steps through `$SHELL -lc`, which reads `~/.zshenv`, `~/.zprofile` and `~/.zlogin` but *never* `~/.zshrc`. Homebrew's installer puts its `eval "$(/opt/homebrew/bin/brew shellenv)"` in `~/.zprofile`, so the normal setup is already fine. If you moved that line into `~/.zshrc` — plenty of dotfile repos do — every block here produces an empty list and says `brew: command not found` on stderr. Move it back to `~/.zprofile`, or name the binary in full: `/opt/homebrew/bin/brew` on Apple Silicon, `/usr/local/bin/brew` on Intel.

**The preview turns analytics off on purpose.** `brew info` ends with an install-count block it fetches over the network, and that fetch is most of the ~3.7s the command takes. A `preview` gets a fixed 5 seconds whatever `timeout` says, so the honest version of this line loses the race about as often as it wins it. `HOMEBREW_NO_ANALYTICS=1` in front drops it to about half a second, and the only thing missing from the panel is a download count.

## An empty list looks like a failure

Both blocks here can legitimately produce nothing — no service installed, nothing outdated — and when they do, Look puts a red banner on the reload:

```
[homebrew-services] produced no rows; keeping the previous ones
```

That is not this example breaking, and there is no key that turns it off. Look refuses empty output on purpose: a command that returns nothing is far more often broken — network down, tool missing, wrong directory — than genuinely empty, and keeping the last good rows costs nothing while clearing them would throw away the ranking those rows had earned. A source cannot tell it the difference.

What that means for each block:

- **`homebrew-services` on a machine with no services** shows the banner on every single reload, for nothing. Most formulae ship no service at all; `postgresql`, `redis`, `mysql` and `syncthing` do. If `brew services list` prints nothing in your terminal, do not install this file yet — copy it the day you install something that needs it.
- **`homebrew-outdated` with everything up to date** does the same, but there the banner is arguably the answer you wanted: nothing to upgrade. Worth knowing so you read it as "up to date" rather than "broken".

The genuine failures look different. `brew: command not found` on stderr is a PATH problem, and an empty list with no banner at all means the block never ran.

## The rows go stale after you upgrade

A `run` block's rows are made on reload and cached until the next one, which is what keeps search instant. So the package you just upgraded is still sitting in the outdated list, and will be until you reload with `Cmd+Shift+;`. That is worth knowing rather than worth fixing: the alternative is a `brew outdated` on every keystroke.

## Customise

- **`open -na Ghostty --args -e ...` names a terminal, and it is the line most people change.** iTerm2: `open -na iTerm --args ...` does not take a command, so use `osascript` or drop the terminal entirely. WezTerm: `open -na WezTerm --args start -- brew upgrade {id}`. kitty: `open -na kitty --args brew upgrade {id}`. Alacritty: `open -na Alacritty --args -e brew upgrade {id}`.
- **No terminal at all**: `open = "brew upgrade {id}"` works and is silent. It runs, it finishes, and nothing tells you either way — which is fine for a cask and unnerving for a formula that builds from source.
- **Casks only**, which is the list most people actually want to act on: `brew outdated --cask --json=v2`, then drop the `.formulae[]?` line from the jq filter. **Greedy** adds the casks that auto-update themselves: `--greedy`, and expect the list to triple.
- **`brew services` needs no `sudo` here**, and should not get one. These are user agents in `~/Library/LaunchAgents`, started at login. The system-wide form (`sudo brew services`) cannot work from a launcher at all: steps run with no stdin and no TTY, so a password prompt has nowhere to appear and the step simply hangs.
- **A third list worth having** is what you have installed at all: `brew list --formula --versions` is already tab-shaped enough for a `run` block, with `HOMEBREW_NO_ANALYTICS=1 brew info {id}` in the preview and `brew uninstall {id}` behind a `confirm`.
