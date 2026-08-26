# docker

Every container as a row, running ones marked 🟢 and stopped ones ⚫️, with status and image on the second line. The preview tails the logs, Enter opens a shell inside, `Cmd+K` offers stop and restart.

Read this one for per-row icons, `format = "json"`, and a helper script.

**Requires.** Look v0.6.12 or newer, `docker`, and `jq`.

**Platforms.** macOS as written, Linux with a different `open`, see Customise.

## Install

```bash
cp examples/docker/*.toml ~/.look/sources/
mkdir -p ~/.look/bin && cp examples/docker/bin/docker-rows ~/.look/bin/
chmod +x ~/.look/bin/docker-rows
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `docker-containers` | every container | opens a shell inside it |
| `docker-containers-stop` | on a container, via `Cmd+K` | `docker stop`, after asking |
| `docker-containers-restart` | on a container, via `Cmd+K` | `docker restart`, after asking |

## Customise

- Running containers only: drop `--all` from `docker ps` in `bin/docker-rows`.
- The icons are the two emoji in that script's `if`. Any emoji, SF Symbol name, or image path works.
- `open` is macOS + Ghostty. **Linux**: `ghostty -e docker exec -it {id} sh`. Images without `sh` want `bash`.
- `timeout = "10s"` because a cold Docker daemon is slow. The ceiling is 30s.
- Rows refresh on reload, not while you type. A container started since then appears after `Cmd+Shift+;`.
- Podman: replace `docker` with `podman` in both files.

**Why a script and not a one-liner.** `run` takes any shell text, so this could be one long line of `jq`. It is a file because a `jq` filter with a conditional in it is worth being able to read. Rule of thumb: once a command needs a pipe and a conditional, put it in `~/.look/bin`. The script emits one JSON object per line; Look also accepts a single array or pretty-printed objects run together.
