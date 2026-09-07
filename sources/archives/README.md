# archives

**Unpack here** on any archive Look finds, and **Compress as tar.gz**, **Compress as ZIP**, or **Compress as RAR** on any folder. Select one, press `Cmd+K` / `Ctrl+K`, and the verb is there.

No list to declare and nothing to keep up to date. These blocks produce no rows at all: they use `applies` to attach themselves to rows *everything else* produced, including the files and folders Look already indexes. The tarball you downloaded five minutes ago has the verb on it because the file index found the file, not because this source knows about `~/Downloads`.

**Requires.** Look v0.6.13 or newer, which is when `applies` arrived. `tar` for the tar verbs, `zip` plus `unzip` for the ZIP verbs, and `rar` plus `unrar` for the RAR verbs.

**Platforms.** Linux, where the commands above were run as written. macOS ships the same `tar`, `zip`, and `unzip`; the RAR commands need `rar` and `unrar` installed separately. Windows has none of these commands in the same form.

## Install

```bash
cp sources/archives/*.toml ~/.look/sources/
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

Nothing appears in the launcher afterwards, and that is correct. `applies` blocks are verbs, not lists: to see them, select a `.tar.gz`, a `.zip`, a `.rar`, or a folder and press `Cmd+K`.

## Blocks

| Block | Attaches to | Does |
| --- | --- | --- |
| `archives-untar` | `*.tar`, `*.tar.gz`, `*.tgz`, `*.tar.bz2`, `*.tar.xz`, `*.tar.zst` and friends | extracts beside the archive |
| `archives-unzip` | any `.zip` | extracts beside the archive |
| `archives-unrar` | any `.rar` | extracts beside the archive without overwriting existing files |
| `archives-compress` | any folder | writes `<folder>.tar.gz` next to it, after asking |
| `archives-zip` | any folder | writes `<folder>.zip` next to it, after asking |
| `archives-rar` | any folder | writes `<folder>.rar` next to it, after asking |

## How `applies` picks rows

Only a `do` block can declare it. A block that produces rows is a list, and a list is not a verb.

| Written as | Matches |
| --- | --- |
| `applies = "files"` | any row whose path is not a directory |
| `applies = "dirs"` | any row whose path is a directory |
| `applies = "paths"` | any row with a path, apps included |
| `applies = "apps"` | app rows |
| `applies = { ext = ["zip"] }` | that extension, any case, written without the dot. Files only |
| `applies = { ext = ["rar"] }` | the same extension match for RAR files |
| `applies = { match = ["*.tar.gz"] }` | a glob on the file **name**, not the whole path |
| `applies = { only = "dirs", match = ["*.xcodeproj"] }` | both at once |

Both forms are here on purpose. `ext` is shorter and is what you want when the extension really is one word; `match` is the one that reaches `*.tar.gz`, because two dots is not an extension and `ext = ["gz"]` would also claim every lone `.gz` file.

A row with nothing on disk, such as a settings pane, matches nothing: `{path}` would be empty.

**They land after the built-in verbs, never in place of them.** `Cmd+E` still edits and `Cmd+F` still reveals. A row from a block that declares `then` shows that block's own targets first, and these after.

## `{dir}` is not the parent of a folder

The one thing that catches people writing an `applies` block for folders:

- on a **file** row, `{dir}` is the file's parent, which is what "unpack here" means;
- on a **folder** row, `{dir}` is **that folder**, not its parent.

So `tar -C {dir}` is exactly right for extracting and exactly wrong for compressing, where it would ask `tar` to find the folder inside itself. The compression blocks use `dirname` and `basename` on `{path}` instead. Both substitutions are shell-escaped before they land, so a folder called `My Project` is handled and a folder called `; rm -rf ~` is inert.

## Keep them narrow

Every `applies` block puts one more entry on the `Cmd+K` menu of every row it matches, forever. **Ten per row is the ceiling**; past that the rest are dropped, highest `bias` first, and the overflow is reported.

That is the argument against `applies = "paths"` for anything but a verb you genuinely want on every row in the launcher. These six are narrow by construction: three extension sets and three directory actions.

## Customise

- **Extract into a subfolder** rather than beside the archive, which is what you want for a tarball that is not tidy about it:

  ```toml
  do = ["mkdir -p {path}.d && tar -xf {path} -C {path}.d"]
  ```

- **More formats.** `7z x {path} -o{dir}` for `.7z` or `zstd -d {path}` for a lone `.zst`. Each is another block with its own `applies`; a block has one `do` and one match.
- **A `confirm` on extraction.** Not shipped: extracting adds files and adds nothing else. All three compression actions write a new file, so they ask.
- **Narrow it to one directory.** `applies` has no path filter, on purpose. If you only ever unpack in `~/Downloads`, a plain `dir` block over that folder with a `then` target is the better shape, and it gives you the list too.
