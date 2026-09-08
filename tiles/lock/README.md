# lock

Lock the screen from the empty home screen: click the tile, or press `Cmd+L` (macOS) / `Alt+L` (Linux).

The other shape a tile has. It declares `press` and no `value`, so nothing ever runs on its own, there is nothing to display, and it draws as a button the way Mic and Screensaver do.

**Requires.** Look v0.6.13 or newer. Nothing else: `pmset` ships with macOS and `loginctl` with systemd.

**Platforms.** macOS and Linux, one file each. Both blocks parse and place correctly; neither `press` command has been fired here, because running one locks the machine you are testing on. Run yours in a terminal once before trusting the tile - on macOS it locks only if System Settings > Lock Screen asks for a password after sleep, and on Linux only if something in your session is listening (see below).

> [!NOTE] Note for macOS users
> The `pmset displaysleepnow` command may fail or wake up immediately if active power assertions, connected peripherals, or background applications are blocking display sleep. If that is the case, see [here](#alternative-methods-for-macos) for alternative methods.

## Install

Tiles are merged, not copied. Two edits in `~/.look/super-actions.toml`:

1. Put `lock` in the `layout` drawing. A one-cell tile fits anywhere a built-in you do not use sits, or in a `.` gap:

   ```toml
   layout = [
       "lslot       lslot       bluetooth   wifi        battery     weather",
       "lslot       lslot       theme       keepawake   lock        weather",
       "mic         restart     shutdown    nowplaying  nowplaying  nowplaying",
   ]
   ```

2. Paste the block from [`lock-macos.toml`](lock-macos.toml) or [`lock-linux.toml`](lock-linux.toml) onto the end of the file. Take one, not both: they declare the same tile.

`make show NAME=lock` prints them. Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux).

## The tile

| Tile | Shows | Press |
| --- | --- | --- |
| `lock` | its title and icon; there is nothing to read | locks the screen |

## Whether it actually locks

Both commands ask the system to lock rather than drawing a lock screen themselves, which is why one line covers every desktop, and also why either can quietly do nothing.

- **macOS.** `pmset displaysleepnow` sleeps the display. That locks the Mac only when System Settings > Lock Screen is set to require a password *immediately* (or soon) after sleep. Set to "never", the display sleeps and the machine stays open.
- **Linux.** `loginctl lock-session` raises the lock signal and waits for something to answer: GNOME and KDE answer themselves, and a tiling WM answers through `swayidle`, `xss-lock` or `hypridle`. With no locker running, nothing happens and nothing is reported.

Test it once before you trust it, because a lock tile that silently does nothing is worse than no tile.

## Alternative methods for macOS

If `pmset displaysleepnow` fails or allows background activity to wake the display, you can use AppleScript as a reliable alternative. Instead of relying solely on background commands, AppleScript simulates the native macOS lock screen keystroke to force a secure state.

> [!IMPORTANT]
> Because AppleScript simulates system-level keystrokes, Look requires Automation permission. You will see a macOS system prompt asking you to grant this access.

The following command uses `osascript` to trigger the lock screen shortcut via AppleScript `System Events` before running `pmset displaysleepnow` to put the display to sleep. This will prevent background activity from immediately waking the system.

*(Note: We use hardware key code 12 instead of the literal character "q" to ensure this command works reliably across all international keyboard layouts, such as AZERTY or Dvorak).*

```bash
osascript -e 'tell application "System Events" to key code 12 using {control down, command down}'; pmset displaysleepnow
```

Of course, if you only want to lock the computer without putting the display to sleep, you can omit the `pmset` command entirely.

### Troubleshooting Permissions
If you accidentally decline the prompt or the command fails, you can grant permission manually:
1. Open **System Settings** on your Mac.
2. Navigate to **Privacy & Security** > **Automation**.
3. Locate **Look** and toggle the switch to enable access for **System Events**.

## Customise

- **`mnemonic = "L"`** asks for `Cmd+L` / `Alt+L`. A letter held by a built-in on *your* strip is never given away, so if you keep a tile using `L` this one goes without a key and still works by click. `Q` always belongs to quitting Look.
- **`confirm`** ships commented out. Uncomment it and the tile arms on the first press and fires on the second, the way Restart and Shut Down do. Locking is cheap to undo, which is why it is off by default; a tile that suspends or logs out should have one.
- **Suspend instead.** `press = "systemctl suspend"` on Linux, `pmset sleepnow` on macOS. Those *are* worth a `confirm`.
- **`icon`.** macOS takes any SF Symbol (`lock.fill`, `lock.shield`). Linux has no padlock among the strip's own glyphs, so point at an image: `icon = "~/.look/icons/lock.svg"`, drawn as a mask, so a flat silhouette reads and a detailed drawing does not.
- **`title`** is what the tile is called. Without it the name is title-cased, which for `lock` gives the same word.
