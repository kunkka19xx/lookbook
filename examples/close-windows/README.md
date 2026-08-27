# close-windows

One row that ends the day: everything you have open goes away. Type "end work", or "close all".

Two files, one per platform. **`close-windows.toml`** is Linux, and closes every window except Look's. **`close-windows-macos.toml`** is macOS, and quits every app except Finder — apps are the unit there, since one with no windows is still running and still in the Dock.

Either way it is a **request**, not a kill: the same thing the window's close button and `Cmd+Q` send, so an editor with unsaved work still stops and asks you. Nothing here signals a process.

**Requires.** Look v0.6.12 or newer. On Linux, `jq` for niri, sway, Hyprland and i3, or `wmctrl` for anything else on X11. On macOS, nothing — `osascript` is already there, but [it needs permission](#macos-asks-for-permission-once-per-app).

**Platforms.** Linux and macOS, in separate files. On Linux, **tested on sway only**: the niri, Hyprland, i3 and generic-X11 branches are written but unverified — each is the same two calls in that window manager's dialect, and [checking one takes a moment](#check-yours-before-you-trust-it). **GNOME on Wayland cannot work at all**; see below. Nothing here works on Windows.

**It closes your games too.** Everything goes: the browser you were reading, the terminal running a build, the game you are mid-match in. Applications that guard unsaved work will interrupt and ask, and applications that do not will simply be gone. That is what the `confirm` line is for, and it is the reason not to delete it.

## Install

```bash
cp examples/close-windows/*.toml ~/.look/sources/
```

Copy just the one for your platform if you would rather not carry the other: the Linux file on a Mac finds no window IPC and says so on stderr, and the macOS file on Linux has no `osascript` to run.

Reload with `Ctrl+Shift+;`, or `Cmd+Shift+;` on macOS.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `close-windows` | one row, always (Linux) | asks, then closes every window but Look's |
| `close-windows-macos` | one row, always (macOS) | asks, then quits every app but Finder |

## macOS asks for permission once per app

Sending `quit` to another application is an Apple Event, and macOS gates those behind Automation permission. The first run puts up a dialog — "Look wants to control System Events" — and then, in the worst case, one more per app it is about to quit. Allow them and you are never asked again; they are listed afterwards under **System Settings → Privacy & Security → Automation → Look**, where you can take any of them back.

Two things about that first run:

- **A dialog you dismiss is a "no", and it sticks.** Deny System Events and the block quits nothing at all, silently, forever after. Toggle it back on in that Automation list.
- **The prompts are attributed to Look**, not to the terminal you tested from, because Look is what launched the script. So test the row in Look, not by pasting the command into a shell: the shell's answers do not transfer.

## macOS: what it skips, and what it will not save

`background only is false` is the filter, and it means every app with a user interface: what is in your Dock and your `Cmd+Tab` list, and not the several dozen agents, helpers and XPC services that are also processes. Two names come off that list by hand:

- **Finder**, which owns your desktop and is not usefully quittable.
- **Look**, which never appears there anyway. Look is an `LSUIElement` agent with no Dock icon, so it is "background only" as far as System Events is concerned and is filtered out for free. The line stays as insurance against a build that stops being one.

To spare more, add them to the same test — `if n is not "Finder" and n is not "Look" and n is not "Music" then`. Run this to see what your own apps are called, which is not always what their window says:

```bash
osascript -e 'tell application "System Events" to get name of every process whose background only is false'
```

**An app that hangs on a save dialog stops there and stays open.** The `try` around the `quit` means the loop moves on rather than waiting, so a run can end with two apps still up and no error to say so. That is the right trade — the alternative is a launcher command that blocks on a modal you cannot see — but it means "quit all" is a request to all of them, not a promise about any of them.

## Customise (Linux)

**Spare a few applications.** The list is matched against `app_id`, or against `window_properties.class` for XWayland clients, which have no `app_id` at all. Bind it once and compare against it, rather than reaching for `.app_id` inside the `index()` argument, where `.` is the array and not the window:

```jq
["lookapp", "steam", "dota2"] as $keep
| .. | objects | select(.pid != null)
| (.app_id // .window_properties.class // "") as $app
| select($keep | index($app) | not)
| .id
```

Run `swaymsg -t get_tree | jq -r '.. | objects | select(.pid != null) | .app_id // .window_properties.class'` to see what your own windows call themselves.

**Add your window manager.** Each branch is two calls: ask for the window list, then send one close per id. Five are there already, tried in order — niri, sway, Hyprland, i3, then `wmctrl` for anything else on X11. River, Wayfire and the rest follow the same shape; add a branch beside them.

**Keep Look out of it.** `lookapp` is the `app_id` GTK derives from `argv[0]`, which is why it is spelled that way and not `Look` or `com.look.desktop`. Change it only if you have renamed the binary.

## Check yours before you trust it (Linux)

Only the sway branch has actually been run. On any other window manager, list what *would* close before you close it — every branch selects windows the same way, so if this prints your windows, the branch works:

```bash
niri msg -j windows      | jq -r '.[] | select((.app_id // "") != "lookapp") | .app_id'
swaymsg -t get_tree      | jq -r '.. | objects | select(.pid != null) | .app_id // .window_properties.class'
hyprctl -j clients       | jq -r '.[] | select(.mapped) | .class'
i3-msg -t get_tree       | jq -r '.. | objects | select(.window != null) | .window_properties.class'
wmctrl -l -x             | awk '{ print $3 }'
```

Nothing printed means the branch would close nothing. **i3 is the one that catches people**: its tree does not carry `.pid` the way sway's does, so borrowing the sway filter matches zero nodes and does nothing at all. That is why the i3 branch keys on `.window`, the X11 window id.

## GNOME on Wayland cannot do this

Not a missing dependency, and not something a package installs. Mutter exposes no window-management interface on the session bus, and `org.gnome.Shell.Eval` — the usual way round it — has been locked behind unsafe-mode since GNOME 41. Closing other applications' windows is precisely what that lock exists to prevent.

The two ways out are a shell extension that exposes its own D-Bus method, or a GNOME session on **Xorg** rather than Wayland, where the `wmctrl` branch works like any other X11 desktop.

## One thing worth knowing

**Do not close the terminal Look is running from.** If you started Look with `cargo tauri dev` in a plain terminal, that terminal is Look's parent, and closing it takes Look down in the middle of the run. Under tmux you are safe, because the tmux server owns the process and a closed window only detaches a client. Add your terminal to the keep-list above if you run Look this way.
