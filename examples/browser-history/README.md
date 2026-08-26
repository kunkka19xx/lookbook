# browser-history

Your browser history as rows in Look, most recent first, each with the site's own favicon. Enter opens the page in your default browser.

Firefox and the Chromium browsers are read together and de-duplicated by URL, so a page you opened in both is one row.

<img width="1139" height="816" alt="image" src="https://github.com/user-attachments/assets/f63f9f61-0b83-4548-96e4-cc62a47156ed" />


**Requires.** Look v0.6.12 or newer, and the `sqlite3` command on your `PATH`. At least one of Firefox, Brave, Chrome, Chromium, Edge or Vivaldi.

The binary is always `sqlite3`; the package often is not. macOS ships it at `/usr/bin/sqlite3` and needs nothing installed. Debian and Ubuntu call the package `sqlite3`; Arch, Fedora and nixpkgs call it `sqlite`. A language binding is not a substitute: this uses `readfile()` and `writefile()`, which exist only in the command-line shell and not in the library every binding wraps.

**Platforms.** Linux. Tested against Firefox and Brave on Linux. macOS and Windows keep browser profiles in different places and need a different `open`; see Customise.

**It reads your browsing history and makes it searchable in your launcher.** That is the point of it, and it sends nothing anywhere, but three things are worth saying out loud before you install it.

- **`auto` means every browser and every profile.** Not only the browser you think of as yours: if work lives in one Chrome profile and everything else in Firefox, both land in one list. Name the one you want instead, on the `run` line. Private and incognito windows are never written to history in the first place, so those are already out.
- **Anyone at your screen can read it.** A launcher is one keystroke away at all times, and three letters typed into it now surface where you have been. `LOOK_HISTORY_DAYS=30` is the first thing to set if that matters to you.
- **The favicon cache outlives the source.** One PNG per host is written to `~/.look/cache/favicons`, each named after its host, so that directory is a readable list of the sites you visit. Removing the `.toml` does not remove it: `rm -rf ~/.look/cache/favicons`.

## Install

```bash
cp examples/browser-history/*.toml ~/.look/sources/
mkdir -p ~/.look/bin && cp examples/browser-history/bin/browser-history-rows ~/.look/bin/
chmod +x ~/.look/bin/browser-history-rows
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `browser-history` | pages from every browser profile found | opens the URL in your default browser |

## Customise

Everything is an environment variable with a default, so you can try a change without editing the script. Set it on the `run` line in the `.toml`, **not** in `~/.zshrc`: Look runs commands through a login shell, which does not read your interactive rc file.

```toml
run = "LOOK_HISTORY_BROWSERS=firefox ~/.look/bin/browser-history-rows"
```

| Variable | Default | What it does |
| --- | --- | --- |
| `LOOK_HISTORY_BROWSERS` | `auto` | `auto` is every browser found. Or a list: `firefox`, `brave`, `firefox,chrome` |
| `LOOK_HISTORY_DAYS` | `0` | Only pages seen in the last N days. `0` is no limit. The one to reach for first |
| `LOOK_HISTORY_LIMIT` | `900` | Rows the query builds before the byte cap trims them |
| `LOOK_HISTORY_BYTES` | `240000` | Output ceiling. Look drops stdout past 256KB, so there is little room above this |
| `LOOK_HISTORY_ICONS` | `~/.look/cache/favicons` | Where the per-host PNGs are written |
| `LOOK_HISTORY_MAX_DB` | `10` | Profile databases to attach. SQLite is built with `MAX_ATTACHED=10` |

- **`open` is Linux as written.** macOS: `open {id}`. Windows: `start "" {id}`.
- **Profile paths are Linux.** The script looks in `~/.mozilla/firefox`, `~/.config/<browser>`, plus the Snap and Flatpak locations. macOS keeps Firefox in `~/Library/Application Support/Firefox/Profiles` and Chromium browsers in `~/Library/Application Support/<vendor>`; edit `bases_of()`.

**Narrowing browsers reaches further back.** The row and byte budgets are shared across everything merged, so `auto` spends them on whatever is most recent across all your browsers. On the machine this was written for, `auto` reached back twelve days while `LOOK_HISTORY_BROWSERS=brave` alone reached three months. If a browser you care about keeps falling off the end, name it on its own.

**Nothing appears.** Run `~/.look/bin/browser-history-rows` in a terminal. It prints one JSON object per line; the two things it says on stderr are a missing `sqlite3` and a browser name it does not know. A browser that is running is fine, its database is snapshotted rather than locked.

**It works in your terminal but Look says `sqlite3 is not installed`.** Then it is on your interactive `PATH` and not your login one. Look runs every command through `$SHELL -lc`, which reads `~/.zshenv` and `~/.zprofile` but never `~/.zshrc`. Move the `PATH` export into one of those, or name the binary in full.
