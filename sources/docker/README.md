# docker

Every container as a row, every Compose project as another, and every image as a third, with four guarded prunes for getting disk back. Running ones are marked 🟢, stopped ones ⚫️, unhealthy ones 🔴, and the second line carries the status, the published ports and the image. The preview shows ports, mounts and network above the last logs, Enter opens a shell inside, and `Cmd+K` follows the logs, opens the port in a browser, or starts, restarts, stops and removes.

It is here for the parts of the Docker CLI that are all typing: looking a name up before every command, remembering which port maps where, and `cd`-ing to wherever a compose file lives before `up` will work.

Read this one for per-row icons, `format = "json"`, a preview drawn as a layout, a drill-down shared between two blocks, and a helper script.

**Requires.** Look v0.7.5 or newer (for the laid-out preview), `docker` with the Compose plugin (`docker compose`), `jq`, and `bash`. A terminal for the shell and the logs; a clipboard tool (`wl-copy` or `xclip`) on Linux for `Copy name`.

**Platforms.** Linux, tested with alacritty on sway. macOS is written and the rows, preview and actions are the same commands, but the terminal half of `bin/docker-do` has not been run on a Mac since it was rewritten: if Enter opens nothing there, that function is where to look. Untested on Windows.

## Install

```bash
cp sources/docker/*.toml ~/.look/sources/
mkdir -p ~/.look/bin && cp sources/docker/bin/* ~/.look/bin/
chmod +x ~/.look/bin/docker-rows ~/.look/bin/docker-do
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

Four `.toml` files, and you can take any of them alone, with one exception: `docker-compose.toml` borrows the container actions from `docker-containers.toml`, so it needs that one beside it.

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `docker-containers` | every container, running first | opens a shell inside it, offering to start a stopped one |
| `docker-containers-logs` | on a container, via `Cmd+K` | follows its logs in a terminal |
| `docker-containers-browser` | on a container, via `Cmd+K` | opens `localhost` on its first published port |
| `docker-containers-start` | on a container, via `Cmd+K` | `docker start` |
| `docker-containers-restart` | on a container, via `Cmd+K` | `docker restart`, after asking |
| `docker-containers-stop` | on a container, via `Cmd+K` | `docker stop`, after asking |
| `docker-containers-copy` | on a container, via `Cmd+K` | copies its name |
| `docker-containers-copy-id` | on a container, via `Cmd+K` | copies its short ID, the one `docker ps` prints |
| `docker-containers-remove` | on a container, via `Cmd+K` | `docker rm`, after asking; refuses a running one |
| `docker-compose` | every Compose project, with its file as the row's path | follows the whole project's logs in a terminal |
| `docker-compose-containers` | on a project, via `Cmd+K` | descends into that project's containers |
| `docker-compose-up` | on a project, via `Cmd+K` | `docker compose up -d`, in a terminal so a pull is visible |
| `docker-compose-restart` | on a project, via `Cmd+K` | `docker compose restart`, after asking |
| `docker-compose-stop` | on a project, via `Cmd+K` | `docker compose stop`, after asking |
| `docker-compose-down` | on a project, via `Cmd+K` | `docker compose down`, after asking |
| `docker-images` | every image, marked 📦 in use, 💤 unused or 👻 untagged | opens a shell in a throwaway container from it |
| `docker-images-pull` | on an image, via `Cmd+K` | `docker pull`, in a terminal |
| `docker-images-copy` | on an image, via `Cmd+K` | copies its name |
| `docker-images-remove` | on an image, via `Cmd+K` | `docker rmi`, after asking; refuses one in use |
| `docker-cleanup-usage` | one row | `docker system df` in the preview, the long form in a terminal |
| `docker-cleanup-containers` | one row, previewing every stopped container | `docker container prune`, after asking |
| `docker-cleanup-dangling` | one row, previewing every untagged image | `docker image prune`, after asking |
| `docker-cleanup-unused` | one row, previewing every image no container uses | `docker image prune --all`, after asking |
| `docker-cleanup-cache` | one row, previewing the build cache size | `docker builder prune`, after asking |

A Compose project's row is its compose file, so `Cmd+E` edits that file and `Cmd+T` opens a terminal in its folder with nothing declared.

## Which terminal

Nothing in the `.toml` names one. `bin/docker-do` opens the terminal you already gave Look, the `terminal=` line in `~/.look/config` that `Cmd+T` uses. With none set it takes the first of `$TERMINAL`, ghostty, kitty, alacritty, foot, wezterm, gnome-terminal, konsole and xterm that is installed on Linux, and Terminal.app on macOS.

To use a different one here than everywhere else, set `LOOK_DOCKER_TERMINAL` on the line: `open = "LOOK_DOCKER_TERMINAL=kitty ~/.look/bin/docker-do shell {id}"`. A terminal that takes its command some other way than `-e` is one line in `in_terminal()`.

## Customise

- What to type: `ldocker` (or `ctr`) for containers, `lcompose` for projects, `limages` for images, `lprune` for the four prunes and `ldf` for disk usage. The first three are scopes, so `ldocker pg` lists only the containers matching "pg". The `l` is on purpose: the bare word `docker` also matches Docker Desktop and every Dockerfile on the machine.
- **`Prune stopped containers` takes stopped Compose projects with it.** Stopped is the only thing Docker checks. The panel lists exactly what would go; read it before saying yes.
- There is no volume prune. A volume is where a database keeps its data, and nothing Docker prints tells you which unused one you will miss.
- Enter on an image replaces its entrypoint with a shell, so an image that is only a server still gives you a prompt. An image with neither `bash` nor `sh` (distroless, scratch) cannot, and the terminal says so.
- Running containers only: drop `--all` from `args` in `bin/docker-rows`.
- The icons are the emoji in that script's `glyph`. Any emoji, SF Symbol name, or image path works.
- `Down` removes a project's containers, and Docker only lists projects that have some, so the row is gone after the next reload until you `up` it from its folder. `Stop` keeps it in the list, which is why it comes first.
- `Open in browser` takes the first published TCP port, whatever speaks on it. On a database that is a tab that never loads.
- `timeout = "10s"` because a cold Docker daemon is slow. The ceiling is 30s.
- Rows refresh on reload, not while you type. A container started since then appears after `Cmd+Shift+;`, and one you just stopped keeps its 🟢 until then. The preview is always live.
- `Start`, `Stop` and the other one-line actions say nothing when they fail, as any step does. The preview's Status line is the place to check.

**Why scripts and not one-liners.** `run` takes any shell text, so the rows could be one long line of `jq`. They are a file because a `jq` filter with a conditional in it is worth being able to read. Rule of thumb: once a command needs a pipe and a conditional, put it in `~/.look/bin`. `docker-rows` emits one JSON object per line; Look also accepts a single array or pretty-printed objects run together. `docker-do preview` prints a JSON array of blocks instead of text, which is what makes the panel a table of facts above a block of logs.
