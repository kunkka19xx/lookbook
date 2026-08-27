# shortcuts

Every shortcut from the Shortcuts app, as rows. Enter runs one, `Cmd+E` opens it in the editor. A second file lists your folders and drills into whichever one you pick.

**Requires.** Look v0.6.12 or newer, and macOS Monterey or later for `/usr/bin/shortcuts`. Nothing to install.

**Platforms.** macOS. There is no Shortcuts app on Linux or Windows.

## Install

```bash
cp examples/shortcuts/*.toml ~/.look/sources/
```

Or copy one of the two: `shortcuts.toml` is the flat list, `shortcuts-folders.toml` is the same library by folder. They are independent.

Reload with `Cmd+Shift+;`.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `shortcuts` | every shortcut in your library | runs it |
| `shortcuts-view` | on a shortcut, via `Cmd+K` | opens it in the Shortcuts app |
| `shortcuts-folders` | your shortcut folders | opens the Shortcuts app |
| `shortcuts-folders-in` | on a folder, via `Cmd+K` | drills in; Enter on a row runs it |

## Running one tells you nothing

`shortcuts run` prints nothing, opens no window, and returns as soon as the shortcut is handed off. A shortcut that shows you something shows it itself: a notification, an app it opens, a file it writes. One that does not — a shortcut that flips a HomeKit switch, say — is indistinguishable from a shortcut that failed.

That is the CLI's behaviour and not something a source can fix, but two things help while you are setting one up:

- **Add a notification action** to the end of a shortcut you want feedback from. It is one action and it makes the shortcut better everywhere, not just here.
- **Run it once from a terminal** to see the error. `shortcuts run "My Shortcut"` prints failures to stderr, which is where a launcher cannot show them to you.

## Customise

- **The list is everything**, including the templates Shortcuts adds for you and every one you have ever tapped "Add Shortcut" on. Narrow it with a grep: `run = "shortcuts list | grep -i deploy"`, or install `shortcuts-folders.toml` and browse by folder instead.
- **`bias = -5`** if these should sit below your apps and files. A library of thirty shortcuts is thirty rows competing with everything else you type.
- **Input.** `shortcuts run` takes `--input-path`, so a shortcut that expects a file can be reached from another block: `do = ["shortcuts run 'Resize Image' --input-path {path}"]` on a `dir` block of screenshots.
- **`shortcuts list --show-identifiers`** appends a UUID to each name. Only worth it if two of your shortcuts share a name, since `shortcuts run` takes either.
- **`--folder-name` fails open.** A folder name `shortcuts` does not recognise is not an error: it prints your whole library, the same as passing no folder at all. That does not bite `shortcuts-folders-in`, whose name comes from `shortcuts list --folders` in the first place, but it will if you hard-code a folder into a block of your own and mistype it. `--folder-name none` is a real value, and means the shortcuts in no folder.
