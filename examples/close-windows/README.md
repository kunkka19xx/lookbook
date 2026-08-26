# close-windows

One row that closes every window except Look. Type "end work", or "close all".

What it sends is a close **request** per window, the same one the window's own close button sends, so an editor with unsaved work still stops and asks you. Nothing here signals a process or kills anything outright.

**Requires.** Look v0.6.12 or newer. `jq` for niri, sway, Hyprland and i3; `wmctrl` for anything else on X11.

**Platforms.** Linux. **Tested on sway only.** The niri, Hyprland, i3 and generic-X11 branches are written but unverified — each is the same two calls in that window manager's dialect, and [checking one takes a moment](#check-yours-before-you-trust-it). Nothing here works on macOS or Windows, and **GNOME on Wayland cannot work at all**; see below.

**It closes your games too.** Everything with a window goes: the browser you were reading, the terminal running a build, the game you are mid-match in. Applications that guard unsaved work will interrupt and ask, and applications that do not will simply be gone. That is what the `confirm` line is for, and it is the reason not to delete it.

## Install

```bash
cp examples/close-windows/*.toml ~/.look/sources/
```

Reload with `Ctrl+Shift+;`.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `close-windows` | one row, always | asks, then closes every window but Look's |

## Customise

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

## Check yours before you trust it

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
