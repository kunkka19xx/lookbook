# browser-bookmarks

Every bookmark you have, in the launcher. Firefox and the Chromium browsers
(Brave, Chrome, Chromium, Edge, Vivaldi), every profile of each, merged and
de-duplicated by URL. Type `marks jira` and you are one Enter from the page.

The sibling of [browser-history](../browser-history), and the two belong
together: history is where you have been, bookmarks are what you decided to
keep. Install both and these rows borrow the favicons that one already caches.

If you would rather curate a dozen links by hand than index the hundreds your
browser is holding, [bookmarks](../bookmarks) is that source: one text file,
no script, nothing read from a browser at all.

**Requires.** Look v0.7.5 or newer (for `scope`), and `python3`. No `sqlite3`
binary: Python has the library built in.

**Platforms.** macOS. The script already knows where Linux keeps profiles
(`~/.config`, Snap and Flatpak), and the `open` line handles both systems, but
it is untested there. Untested on Windows.

## Install

```bash
cp sources/browser-bookmarks/*.toml ~/.look/sources/
cp sources/browser-bookmarks/bin/browser-bookmarks-rows ~/.look/bin/
chmod +x ~/.look/bin/browser-bookmarks-rows
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `browser-bookmarks` | every bookmark, every browser, every profile | opens the URL in your default browser |

The preview pane holds the full URL, because the row deliberately shows a
shortened one: no scheme, no query string, no fragment. That is where you check
what Enter will open.

## What it reads, and what it does not

This finds your browser profiles by itself, the same way
[browser-history](../browser-history) does, and makes what is in them
searchable from the launcher. Two things are worth knowing before you install
it rather than after:

- **It reads bookmark stores only.** Chromium's `Bookmarks` file and Firefox's
  `places.sqlite`, both on disk, both read from a copy. Nothing is written to
  either, no browser is launched or spoken to, and nothing leaves the machine.
- **Your bookmarks become searchable from one keystroke.** That is the whole
  point, and it is also the thing to think about if somebody else looks over
  your shoulder while you type. `scope = true` is what keeps them out of
  unrelated searches: the rows only appear when you ask for them with `marks`.

On macOS, reading another application's data under `~/Library/Application
Support` may need Full Disk Access for Look, exactly as `browser-history` does.
Without it the script says `operation not permitted` on stderr and the list is
empty.

## The browser name on a row is where it was found first

With more than one browser installed, each row says which browser it came from.
That means the **first** one that had the URL, because identical bookmarks
collapse into one row rather than appearing per browser.

So if you once imported your Chrome bookmarks into Firefox, as most people have,
every one of those rows says Firefox, and `LOOK_BOOKMARKS_BROWSERS=chrome` is
how you check that Chrome's copy is being read at all. The alternative, a row
per browser per bookmark, is a list three times as long that answers the same
question three times.

## Customise

- **One browser only**, which is also how you make the list shorter:

  ```toml
  run = "LOOK_BOOKMARKS_BROWSERS=firefox ~/.look/bin/browser-bookmarks-rows"
  ```

  A list or a single name: `firefox`, `brave,chrome`, `chromium edge`.
- **How many rows**: `LOOK_BOOKMARKS_LIMIT=300`, on the same line. 1,500 by
  default, under Look's own 2,000-row cap.
- **Favicons** come from `~/.look/cache/favicons`, one PNG per host, which
  [browser-history](../browser-history) writes when it runs. This source only
  reads that cache; without it every row shows the block's 🔖 instead. Point
  somewhere else with `LOOK_BOOKMARKS_ICONS=/path/to/pngs`, named `<host>.png`.
- **`open`** tries `xdg-open` and falls back to `open`, so the same line works
  on Linux and macOS. On Windows it is `start "" {id}`.
- **A specific browser for Enter**, rather than your default:
  `open -a 'Firefox' {id}` on macOS, `firefox {id}` on Linux.
- **Folders are not in the rows.** What a bookmark is called is what you search
  for; the folder it sits in would be a second word repeated on hundreds of
  rows. If you want them, `walk()` in the script is where the folder name is
  available and dropped.
