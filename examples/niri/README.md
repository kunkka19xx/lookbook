# niri

Two things [niri](https://github.com/YaLTeR/niri) hands to a tool and then leaves you with: your **wallpaper**, which swww sets and cannot browse, and your **screenshots**, which niri drops in a folder and gives you nothing to get back out of it. Both are picked here by eye — a `dir` row is a real file, so Look draws the image in the panel while you arrow through them.

**Requires.** Look v0.6.12 or newer, niri. `jq` and `swww` (with its daemon running) for the wallpaper file, `wl-clipboard` and `feh` for the screenshots file. Each file works without the other's tools.

**Platforms.** Linux, niri. Tested on niri 26.04 on NixOS. `niri msg action spawn` is the only niri-specific part; on sway the same files work with `swaymsg exec`.

## Install

```bash
cp examples/niri/*.toml ~/.look/sources/
mkdir -p ~/.look/bin && cp examples/niri/bin/* ~/.look/bin/ && chmod +x ~/.look/bin/niri-*
```

Reload with `Ctrl+Shift+;`. Then open the two files and check the paths: the wallpaper script defaults to `~/Pictures/Wallpapers` (`NIRI_WALLPAPERS` overrides it), and `niri-screenshots.toml` at `~/Pictures/Screenshots`, which is niri's default `screenshot-path`.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `niri-wallpaper` | images in your wallpaper folder | hands it to the swww daemon |
| `niri-wallpaper-random` | one row, always | sets a random one |
| `niri-screenshots` | every PNG in your screenshot folder | puts it back on the clipboard |
| `niri-screenshots-view` | on a screenshot, via `Ctrl+K` | opens it in feh |
| `niri-screenshots-delete` | on a screenshot, via `Ctrl+K` | deletes it, after asking |

## If you do not have the tool

One of these two files tells you. The other cannot, and the difference is worth understanding before you write a source of your own.

**The wallpaper file says so at reload.** Its rows come from a `run` block, and Look captures a producer's stderr and shows it:

```
look sources: [niri-wallpaper] swww is not installed (0.12+ calls it awww);
              rows will list but Enter will do nothing
```

The images still list — the folder is readable either way — but you are told once, up front, instead of finding out by pressing Enter on nothing. That check is the reason the block is a `run` block at all: a `dir` block would produce the same rows and have nowhere to put the warning.

**The screenshots file cannot.** It is a `dir` block, so no command runs to make its rows, and there is no stderr to speak from. Nor can the step speak: a step is run detached with `stdin`, `stdout` and `stderr` all on `/dev/null`, and Look never waits for it, so `wl-copy: command not found` goes nowhere and Look reports success. **A missing binary is indistinguishable from a working one.** It stays a `dir` block anyway, because that is what refreshes on the normal index pass — a screenshot list that only updates on reload would never contain the shot you just took, which is the one you want.

So for that half, check it yourself:

```bash
command -v wl-copy feh
```

The two files are independent, which limits the damage: `niri-screenshots.toml` needs nothing from swww, and `niri-wallpaper.toml` needs nothing from wl-clipboard or feh. Install the half whose tools you have.

## Steps are detached; producers are not

Look runs the two kinds of command in opposite ways, and knowing which is which saves you from writing defensively in the wrong place.

A **step** — a `do` list, or a verb like `open` — is fire-and-forget: `setsid`, every stream on `/dev/null`, no wait. So a tool that runs forever is fine, a tool that forks a daemon is fine, and a trailing `&` buys you nothing. `feh` and `swaybg` sit directly in steps here for that reason.

A **producer** — a `run` block's command, or a `preview` — is the opposite: both pipes are drained, the process is waited on, and there is a timeout. That is where a daemonizing tool bites. `wl-copy` forks a clipboard daemon which inherits stdout, so as a producer it holds the pipe open long after the foreground process is gone:

```
wl-copy -t image/png < FILE                    blocked past 6s
wl-copy -t image/png < FILE >/dev/null 2>&1    rc=0 in 0.01s
```

The redirect in `[niri-screenshots]` is there so the line stays correct if you ever move it into a `preview`. In its current home it costs nothing and does nothing.

## Keeping the wallpaper after a logout

swww caches what it last displayed, so this needs one line rather than a state file of your own. In `config.kdl`:

```kdl
spawn-at-startup "swww-daemon"
```

The daemon has to be running before any row here can do anything — `swww img` talks to it, it does not draw by itself. If the wallpaper does not come back on its own, add `swww restore` after it.

## swww, or awww

Upstream renamed the binaries in 0.12: the project and most package names are still `swww`, but what lands on your `PATH` is `awww` and `awww-daemon`. On nixpkgs today, `nix run nixpkgs#swww` installs a program called `awww`.

`bin/niri-wallpaper` takes whichever it finds, so neither spelling is hard-coded and the source works before and after your distro catches up. The `spawn-at-startup` line above is the one place you have to know which you have.

## Customise

- **The folders.** `dir` in the screenshots file; `NIRI_WALLPAPERS` (or the script's default) for the wallpapers. Set it in `~/.zshenv`, not `~/.zshrc` — a step runs in a login shell that never reads the latter.
- **Other wallpaper tools.** `swaybg -i {path} -m fill` if you already run it — but it has no IPC, so the step has to `pkill swaybg` first and you get a visible gap. Note `pkill -x` misses a wrapped binary (`.swaybg-wrapped` on Nix) and `pkill -f` matches the step's own shell: bare `pkill swaybg` is the one that works. `hyprpaper` and `wbg` are the other options.
- **JPEG screenshots.** `open` declares `-t image/png`, since that is what niri writes. A folder with both needs `wl-copy -t $(file -b --mime-type {path}) < {path}`.
- **A different viewer.** `imv {path}`, `swayimg {path}`, `gwenview {path}` — keep the `niri msg action spawn --` in front of any of them.
- **Sweep old shots.** A `do` block with `confirm` and `find ~/Pictures/Screenshots -type f -mtime +30 -delete` is the block to add if that folder is where screenshots go to die.
- **`bias = -5`** on `[niri-screenshots]` once that folder is large: forty rows named `Screenshot from …` compete with everything else you type.
