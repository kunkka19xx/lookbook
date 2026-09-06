# images

Three verbs on any picture Look already found: **Optimise PNG**, **Convert to WebP**, **Copy dimensions**. Select an image, press `Cmd+K` / `Ctrl+K`, and the ones that apply to it are there.

Like [archives](../archives), these blocks produce no rows. They use `applies` to attach to rows anything else produced, so a screenshot on the desktop and a PNG four directories into a repo get the same verbs, without a block listing either place.

Where archives shows `match` globs, this one is the `ext` end of `applies`: each block names the extensions it can actually handle, so nothing turns up on a file it would only fail on.

**Requires.** Look v0.6.13 or newer, which is when `applies` arrived. Then one tool per block, and you only need the ones you keep: [`oxipng`](https://github.com/shssoichiro/oxipng) for optimise, `cwebp` (libwebp) for convert, `identify` (ImageMagick) plus `wl-copy` (wl-clipboard) for dimensions.

**Platforms.** Linux, where the blocks were written and parsed. Every tool named exists on macOS too, but the clipboard line does not: see Customise. Untested on both macOS and Windows.

## Install

```bash
cp sources/images/*.toml ~/.look/sources/
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

Nothing new appears in the launcher, which is correct: `applies` blocks are verbs, not lists. Select a `.png` and press `Cmd+K` to see them. **Delete the blocks whose tool you do not have.** An action whose command is missing is listed like any other, and fails when you press it.

## Blocks

| Block | Attaches to | Does |
| --- | --- | --- |
| `images-optimize` | `.png` | shrinks it in place, losslessly |
| `images-webp` | `.png`, `.jpg`, `.jpeg` | writes `<name>.webp` beside it |
| `images-dimensions` | eight raster formats | copies `1920x1080` to the clipboard |

## Why three blocks and not one

A block has one `do` and one `applies`, and that pairing is the point: **Optimise PNG** reaches only PNGs because that is the only thing `oxipng` reads, and **Copy dimensions** reaches everything because `identify` reads everything. Written as one block with the union of the extensions, two of the three verbs would appear on files they cannot act on.

That is the whole discipline for `applies`: match what the command can actually do.

## In place, or beside

Worth knowing before you press, because the two behave differently:

- **`images-optimize` rewrites the file.** `oxipng` is lossless, so the picture is pixel-identical and only the encoding changes, which is why it ships without a `confirm`. `--strip safe` drops metadata that cannot change how it renders, and keeps colour profiles.
- **`images-webp` writes a new file** and leaves the original alone. Nothing to undo, so nothing to ask about.
- **`images-dimensions` only reads.**

Add `confirm = "..."` to any of them and the verb asks before it runs. Anything lossy should have one.

## Shell, not Look

```sh
p={path}; cwebp -quiet -q 82 "$p" -o "${p%.*}.webp"
```

Every step is shell text run by your login shell, so `${p%.*}`, which strips the shortest match of `.*` from the end, is the shell's parameter expansion and not something Look provides. Assigning `{path}` to `p` first is what makes it available: the placeholder is substituted as one shell-escaped word, and you cannot expand inside it.

The same trick covers any "same name, different extension" output.

## Keep them narrow

Every `applies` block puts one more entry on the `Cmd+K` menu of every row it matches, forever. **Ten per row is the ceiling**; past that the rest are dropped, highest `bias` first, and the overflow is reported. Three image verbs on image files spends that budget where it is worth it. `applies = "paths"` on a verb you rarely want does not.

## Customise

- **`wl-copy` is Wayland.** X11 is `xclip -selection clipboard`, macOS is `pbcopy`. That is the only line in this file that is not portable as written.
- **Quality.** `-q 82` is the WebP knob, 0-100. `-o4` is how hard `oxipng` looks, 0-6; `-o6` is slower and rarely much smaller.
- **JPEG optimisation** is a different tool: `jpegoptim --strip-all {path}` with `applies = { ext = ["jpg", "jpeg"] }`.
- **Resize for sharing**, which is the other thing worth having on a screenshot:

  ```toml
  [images-half]
  name    = "Halve size"
  applies = { ext = ["png", "jpg", "jpeg"] }
  do      = ["p={path}; magick \"$p\" -resize 50% \"${p%.*}-half.${p##*.}\""]
  ```

- **More formats for dimensions.** The list is eight because that is what `identify` reads without extra delegates on a plain install. Add `heic` or `raw` if yours does.
