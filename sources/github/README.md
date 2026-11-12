# github

GitHub's four "what needs me" lists, in the launcher: **reviews waiting on
you**, **your own open pull requests**, **issues assigned to you**, and **your
unread notifications**. Enter opens the page, the preview pane says what the
thing is or whether CI has gone green, and `Cmd+K` copies the link or opens the
repository.

All four go through [`gh`](https://cli.github.com), which already holds your
token. There is no key to put in this file, nothing here asks for your
password, and if `gh auth status` works in a terminal these work too.

**Requires.** Look v0.7.5 or newer (for `scope`), [`gh`](https://cli.github.com)
signed in (`gh auth login`), `jq`, and `bash` for the preview script.

**Platforms.** macOS, where it was used. The `open` lines try `xdg-open`
first, so Linux should work untested; `pbcopy` in `github-copy-link` is the one
macOS-only line left. On Windows both need the spellings in Customise.

## Install

```bash
cp sources/github/*.toml ~/.look/sources/
cp sources/github/bin/github-preview ~/.look/bin/
chmod +x ~/.look/bin/github-preview
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

## Blocks

| Block | Lists | Enter |
| --- | --- | --- |
| `github-review` | open PRs that asked for your review, any org | opens the PR |
| `github-prs` | your own open PRs, drafts marked 📝 | opens the PR |
| `github-issues` | open issues assigned to you | opens the issue |
| `github-notifications` | your unread notifications | opens the thread |
| `github-copy-link` | on any row, via `Cmd+K` | copies the URL |
| `github-open-repo` | on any row, via `Cmd+K` | opens the repository page |

The panel is laid out by `bin/github-preview` rather than shown as `gh` prints
it:

```
OPEN  ·  +172 −0  ·  7 files  ·  3d ago        12 pass  ·  1 fail

AUTHOR  sanglam2806                            FAIL    build  2m
BRANCH  feat/port-to-ipad → main               PASS    lint  20s
CHECKS  1 failing · 12 passed                  PASS    test  51s
REVIEW  changes requested                      SKIP    Build macOS App
TALK    3 comments

Step 1 of porting the shared code…
```

`gh pr view` on its own prints a column of `label:<tab>value` lines, five of
which are usually empty — labels, assignees, reviewers, projects, milestone —
plus the URL the row already shows. In a panel forty characters wide that
buries the three things you opened it for. So each preview asks for the fields
it wants and lays them out the same way: the line you came for first, with
nothing in front of it, then a label column for what supports it. A `preview`
command's output is drawn as plain text — markdown is honoured only for a
*connector's* preview — so that column is the only hierarchy available.

Type `reviews`, `myprs`, `myissues` or `notifs`. Each block declares
`scope = true`, so the word also narrows: `myprs ranking` searches inside your
pull requests rather than across your whole machine.

## What it costs on reload

Each list is one call to GitHub, made when you reload (`Cmd+Shift+;`) and never
while you type. Four of them is four or five seconds of the sixty seconds Look
gives a whole reload, and that is the one thing to decide before installing all
four. Dropping one is a line, not a deletion:

```toml
[github-notifications]
enabled = false
```

The rows are a snapshot until the next reload, which is what keeps search
instant. So a PR you merged five minutes ago is still in the list, and the
review you just submitted still says it wants you. That is worth knowing rather
than worth fixing: the alternative is a network call per keystroke.

## Two ways an empty list happens

**Nothing is waiting on you.** With no reviews requested, `github-review`
produces no rows and the reload banner says `produced no rows; keeping the
previous ones`. Nothing is broken: Look keeps the last good rows on purpose
rather than throwing away the ranking they earned, and
[homebrew](../homebrew#an-empty-list-looks-like-a-failure) has the full
reasoning. Here it is the answer you wanted, in the wrong tone of voice.

**`gh` is not on the PATH Look builds.** Steps run through `$SHELL -lc`, which
never reads `~/.zshrc`, so a `gh` that reaches your terminal through a line in
there — a Homebrew `shellenv`, `mise`, `asdf`, a Nix profile — is missing here.
The giveaway is `gh: command not found` on stderr. Move that line to
`~/.zprofile`, or name the binary in full in each `run`:
`/opt/homebrew/bin/gh search prs ...`.

A token that expired is the third case, and the only one `gh auth status` in a
terminal will tell you about.

## Customise

- **`pbcopy` in `github-copy-link`** is macOS. Linux: `wl-copy` on Wayland,
  `xclip -selection clipboard` on X11. Windows: `clip`.
- **The `open` lines** already try `xdg-open` then `open`. On Windows both
  branches miss, so replace them with `start "" {id}`.
- **A specific browser** rather than your default: `open -a 'Firefox' {id}`.
- **A narrower review list.** `--review-requested=@me` includes every org you
  belong to. Add a repo filter to cut it down: `--repo owner/name`, repeatable,
  or `--owner some-org`.
- **Review requests for your team too**, not just you by name: add
  `--team-review-requested=org/team`.
- **More or fewer rows**: `--limit 30` on each search. The notifications call
  has no limit of its own; it answers one page of unread threads.
- **A fifth list worth having** if you own repos: failing CI runs.
  `gh run list --limit 20 --json conclusion,displayTitle,url,workflowName` is
  already shaped for a `run` block, with `conclusion` deciding the icon.
