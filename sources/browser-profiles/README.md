# browser-profiles

Your browser profiles as rows. Type `lprofile` (or `lbp` for short), pick "Work (Chrome)", and a window opens in that profile: no profile picker to click through, and no `--profile-directory="Profile 3"` to remember. Firefox and the Chromium browsers (Brave, Chrome, Chromium, Edge, Vivaldi) are found by themselves.

`Cmd+K` on a profile opens a private window in it, or opens the link you just copied in it, which is the one for "this has to open signed in as work".

**Requires.** Look v0.7.5 or newer (for `scope` and the laid-out preview), `python3`, and at least one of those browsers. `wl-paste` or `xclip` on Linux for `Open copied link here`.

**Platforms.** Linux, tested on sway with Brave and Firefox, one profile each; several profiles, Chrome and a Flatpak install were tested against made-up profile folders, not real browsers. macOS is written (`open -na "Google Chrome" --args …`) and has not been run. Untested on Windows.

## Install

```bash
cp sources/browser-profiles/*.toml ~/.look/sources/
mkdir -p ~/.look/bin && cp sources/browser-profiles/bin/browser-profiles ~/.look/bin/
chmod +x ~/.look/bin/browser-profiles
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `browser-profiles` | every profile of every browser, titled `Name (Browser)`, most recently used first | opens a new window in it |
| `browser-profiles-private` | on a profile, via `Cmd+K` | opens a private window in it |
| `browser-profiles-url` | on a profile, via `Cmd+K` | opens the link on your clipboard in it |
| `browser-profiles-for-link` | on a link row of another source, once you add it to that block's `then` | opens that link in the profile you pick |

The preview shows whose profile it is and the exact command Enter runs, which is the line to lift if you want a profile on a keybinding or in a `.desktop` file.

## Open a link in a profile, from the link

`browser-profiles-url` starts from the profile. To start from the link instead, add one line to any block whose row id is a URL, such as `browser-bookmarks`, `browser-history`, `bookmarks` or `quicklinks`:

```toml
then = ["browser-profiles-for-link"]
```

`Cmd+K` on a bookmark then offers **Open in profile**, which lists your profiles; Enter opens the bookmark in the one you pick. It is not wired up for you because a `then` naming a block you have not installed is reported as an error.

## What it reads

Two files, both read and never written: Chromium's `Local State`, which is what the profile picker itself is drawn from, and Firefox's `profiles.ini`. That is where a profile's name, its folder and its signed-in account come from. No browser is launched to find them and nothing leaves the machine. The account's email address is shown on the row, so it is on screen when you type `lprofile`.

## Customise

- One browser only: `run = "LOOK_PROFILES_BROWSERS=chrome ~/.look/bin/browser-profiles rows"`. Several: `chrome,firefox`.
- A browser this does not know is one entry in `BROWSER` and one in `bases_of()` in the script: its name, its command, and where it keeps profiles.
- Rows refresh on reload. A profile you just created appears after `Cmd+Shift+;`.
- A Chromium profile is listed by the name you gave it but opened by its folder, so renaming one in the browser changes the row and keeps its ranking.
- Firefox opens a second profile beside a running one. If yours instead says it is already running, the profile is in use by a Firefox started with `--no-remote`.
