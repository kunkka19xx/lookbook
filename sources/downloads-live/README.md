# downloads-live

Your Downloads folder as rows in Look, newest first, that **update themselves**. Save a file in the browser and it is in the launcher a second later, with no reload.

This is the only example here that uses `connect`, so it is also the one to read if you want to see what a connector is. It is about sixty lines of bash.

**Requires.** Look v0.7.5 or newer (`connect`), `bash`, and `jq`. Everything else it uses is in a base system: `ls`, `file`, `cksum`, `awk`.

**Platforms.** macOS, Linux. On Windows the `connect` line needs `%USERPROFILE%\.look\bin\downloads-live` and a bash (Git Bash, WSL); untested there.

## Install

```bash
cp sources/downloads-live/*.toml ~/.look/sources/
mkdir -p ~/.look/bin && cp sources/downloads-live/bin/downloads-live ~/.look/bin/
chmod +x ~/.look/bin/downloads-live
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux). Then type `downloads`, or `downloads` followed by part of a filename.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `downloads-live` | files in `~/Downloads`, newest first | opens the file |

## Why `connect` and not `run`

A `run` block is asked for rows and answers once. Its rows are then cached until the next reload, which is what keeps search instant no matter how slow the command is. The cost is that a `run` block listing your Downloads is only ever as fresh as your last `Cmd+Shift+;`.

`connect` inverts that. Look starts the program once, leaves it running, and listens. The program decides when there is news:

```json
look → {"op":"hello","v":1,"look":"0.7.5"}
you  → {"op":"ready","capabilities":["rows","preview"]}
you  → {"op":"rows","block":"downloads-live","rows":[{"id":"...","title":"invoice.pdf","path":"..."}]}
```

That third line is a **push**. Nobody asked for it, and sending it again whenever the folder changes is the whole feature.

Look also asks this program to fill the preview pane, rather than running a command for it:

```json
look → {"op":"preview","block":"downloads-live","id":"/Users/you/Downloads/invoice.pdf","req":7}
you  → {"op":"preview","block":"downloads-live","id":"...","req":7,"content_type":"markdown","text":"# invoice.pdf\n\n2.1M    Oct 27 17:28\n\nPDF document"}
```

The `req` is echoed back exactly as it arrived. It is how Look tells this answer from the one before it, and an answer without it is dropped.

## Three things the script does that are worth copying

- **One loop, one writer.** `read -t 2` waits two seconds for a frame from Look; if none arrives it falls through and re-reads the folder instead. Polling in a background process would mean two things writing to stdout, and two half-written frames interleaving.
- **Every frame is built by `jq`, never pasted together.** A file called `Q3 "final".pdf` has to come out as valid JSON. Quoting that by hand in shell is the classic way to send a frame Look cannot parse.
- **An unreadable folder is a push that does not happen.** This is the one place `connect` differs from `run` in a way that can lose you data: a `run` block that prints nothing *keeps* the rows it had, but an empty `rows` frame is a real answer and **clears** them. So the script checks the folder is readable first, and reports through an `error` frame rather than just pushing an empty list.

Look logs a connector's stderr too, each line prefixed with the block that wrote it, so `echo "..." >&2` is there for your own tracing. An `error` frame is the one to use when the user has a reason to hear about it.

## Customise

- **Another folder:** `LOOK_DOWNLOADS_DIR=~/Desktop`. Set it in the `connect` line, not in your shell rc, because Look runs commands through a *login* shell that never reads `~/.zshrc`:

  ```toml
  connect = "LOOK_DOWNLOADS_DIR=$HOME/Desktop ~/.look/bin/downloads-live"
  ```

- **How often it looks:** `LOOK_DOWNLOADS_POLL=5`, in seconds. It only pushes when the listing actually changed, so a short interval costs a `ls` and a `cksum`, not a re-index.
- **How many rows:** `LIMIT` at the top of the script. Fifty is enough to find something you downloaded today, which is what this is for. Look caps any one block at 2,000 regardless.
- **Drop `scope`** if you would rather not reserve `downloads` as the first word of a line.

## Troubleshooting

**Nothing appears.** Run it by hand and send it a hello:

```bash
printf '%s\n' '{"op":"hello","v":1}' | ~/.look/bin/downloads-live
```

You should see a `ready` frame and then a `rows` frame. If you see nothing, `jq` is missing. If you see `rows` with an empty list, the folder is empty; if you see an `error` frame, it is not readable.

**It worked, then stopped.** Look restarts a connector that exits the next time the launcher opens, and the rows it last sent stay in the meantime. Nothing you do in Look blocks on this program being alive.

**The preview is blank.** The pane waits about 400ms. This program answers from a `ls` and a `file`, which is well inside that, but a folder on a sleeping network drive is not.

## What a connector can do beyond this

Rows and a preview are the two most useful halves and all this example needs. A connector can also offer a verb on its rows, with a confirmation it computes itself, and a switch or button that it answers for. Both are in Look's own [Integrating your app](https://github.com/kunkka19xx/look/blob/main/docs/integrating.md), which is the full contract.
