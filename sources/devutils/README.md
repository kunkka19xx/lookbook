# devutils

The eight one-liners you open a terminal, a browser tab or a "free online tool"
for. Type the word, then the value:

```
uuid                  genpw 32            b64 hello world       b64d aGVsbG8=
sha256 hello world    urlenc a & b        urldec a%20%26%20b    epoch
jsonfmt               epoch 1762900000
```

Every one of them **shows the answer in the preview pane first**, then copies it
on Enter. Nothing is sent anywhere, which is the actual argument for having
these here rather than on a website.

**Requires.** Look v0.7.5 or newer (for `{arg}`). Two of the eight want a
program the rest do not: `jsonfmt` needs `jq`, `urldec` needs `python3`. Each
says so by name if it is missing, rather than going blank.

**Platforms.** macOS, where it was written and used. The clipboard and the two
`date` dialects are detected rather than hard-coded, so Linux and Windows
(through `clip.exe`) should work as-is — but untested, and a bug report is
welcome.

## Install

```bash
cp sources/devutils/*.toml ~/.look/sources/
cp sources/devutils/bin/devutils ~/.look/bin/
chmod +x ~/.look/bin/devutils
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

Delete the blocks you will not use. Each one claims a word, and a word you
never type is a word competing with your own searches for nothing.

## Blocks

| Block | Type | Enter copies |
| --- | --- | --- |
| `devutils-uuid` | `uuid` | a fresh UUID v4 |
| `devutils-password` | `genpw [length]` | a random password, 24 characters by default |
| `devutils-base64` | `b64 <text>` | the base64 |
| `devutils-base64-decode` | `b64d <text>` | the decoded bytes |
| `devutils-sha256` | `sha256 <text>` | the hex digest |
| `devutils-urlencode` | `urlenc <text>` | the percent-encoded text |
| `devutils-urldecode` | `urldec <text>` | the decoded text |
| `devutils-epoch` | `epoch` / `epoch <number>` | the time now as a number, or that number as a time |
| `devutils-json` | `jsonfmt` | your clipboard, indented |

## The shape to copy

Every block is the same two lines:

```toml
preview = "~/.look/bin/devutils b64 {arg}"
do      = ["~/.look/bin/devutils b64 {arg} | ~/.look/bin/devutils copy"]
```

One command, named twice: `preview` is what the panel shows, `do` is the same
command with its output kept. Read the answer, then press Enter.

That is why the transforms live in `bin/devutils` rather than inline in the
TOML. Inline, each one is written out twice, which is eighteen commands that
have to agree — and the day two of them disagree, the panel shows you one
answer and Enter copies another. In the script each exists once, and the only
difference between seeing it and keeping it is `| devutils copy`.

It also means one file holds everything platform-specific: `copy`, `paste`, and
whether this machine's `date` takes `-r` or `-d @`. Porting this source is
reading one function.

**Two blocks cannot keep that promise, and say so in the panel.** A new UUID or
password does not exist until Enter runs, so their preview shows a sample of the
right shape and tells you it is one. A preview quietly showing a *different*
UUID from the one about to be copied would be worse than one that admits it.

## Adding your own

One arm in the script, one block in the TOML. The arm prints the answer and
nothing else, with **no trailing newline** — the answer is going on a clipboard,
and `echo` is how a hash quietly gains a byte:

```sh
    md5)  printf %s "$arg" | md5 -q | tr -d '\n' ;;
```

```toml
[devutils-md5]
name    = "MD5"
aliases = ["md5"]
icon    = "#️⃣"
preview = "~/.look/bin/devutils md5 {arg}"
do      = ["~/.look/bin/devutils md5 {arg} | ~/.look/bin/devutils copy"]
```

Reload, type `md5 hello`, and the answer is in the panel before you commit to
it. Worth stealing for: a JWT payload (`pbpaste | cut -d. -f2 | base64
--decode | jq .`, once you pad it), a slug, a line count, a hex-to-decimal.

## Two details that keep these correct

**`printf %s`, never `echo`.** `echo` appends a newline, and the base64 or the
SHA-256 of your text plus a newline is a different answer from the one you
wanted. It is the most common way a hand-written one-liner is quietly wrong, and
the reason every arm of the script starts the same way.

**`urlenc` uses no tool at all.** `{arg:url}` is percent-encoding, done by Look
before the shell sees the value, so that block is one `printf`. That is also why
`:url` is the one substitution safe to put inside quotes: what comes out of it
is only `A-Za-z0-9-._~%`.

## `jsonfmt` reads the clipboard, not the line

JSON you want indented came out of a log or a response body, so you would never
retype it into a launcher. Copy it, then type `jsonfmt`: the preview pane is
`jq .` of your clipboard, and Enter replaces the clipboard with the indented
version.

If what you copied is not JSON, the preview is `jq`'s parse error with the
column it gave up at, which is usually the answer you needed anyway.

## Customise

- **The clipboard** is `copy` and `paste` in `bin/devutils`, which try
  `pbcopy`, `wl-copy`, `xclip`, `xsel` and `clip.exe` in that order. Pin one by
  deleting the branches above it.
- **UTC instead of local time** for `epoch`: add `-u` to the `date_at` call, or
  change its format string. The format itself is
  `'%Y-%m-%d %H:%M:%S %Z'`, in one place.
- **Password shape** is `tr -dc 'A-Za-z0-9'`, alphanumeric because the first
  site that rejects a `+` costs more than the two bits per character it gives
  up. Widen it: `tr -dc 'A-Za-z0-9@#%^&*_-'`. The default length is the `n=24`
  beside it.
- **Arithmetic, translation and dictionary need no block.** Typing `2+2` pins a
  calculator row, `t"` translates and `tw"` looks a word up, all built in.
