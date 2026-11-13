# quicklinks

Ten search boxes you otherwise reach by opening a tab first. Type the word,
then what you are looking for, and Enter goes straight to the results:

```
ghs      ripgrep               npms     zustand
mdn      structuredClone       sof      rust lifetime
godoc    cobra                 crates   serde_json
yt       wgpu talk             maps     shibuya station
dhub     postgres              caniuse  subgrid
```

The row leads the results with what you typed as its subtitle, so Enter is
never a guess. Nothing is installed, configured or signed in to: each block is
one URL, which means this file is also the complete list of where it can send
you.

**Requires.** Look v0.7.5 or newer, for `{arg}`. Nothing else.

**Platforms.** macOS, Linux and Windows, from the same file. Look runs a
command through `sh` on the first two and `cmd` on Windows, so each block is
one line both can read; the comment at the top of the file takes it apart.

## Install

```bash
cp sources/quicklinks/*.toml ~/.look/sources/
```

On Windows (PowerShell):

```powershell
copy sources\quicklinks\quicklinks.toml $env:USERPROFILE\.look\sources\
```

Reload with `Cmd+Shift+;` (macOS) or `Ctrl+Shift+;` (Linux, Windows).

Keep the blocks you want and delete the rest. They are independent, and a word
you never type is a word competing with your own searches for nothing.

## Blocks

| Block | Type | Enter opens |
| --- | --- | --- |
| `quicklinks-github` | `ghs <query>` | GitHub repository search |
| `quicklinks-npm` | `npms <query>` | npm registry search |
| `quicklinks-mdn` | `mdn <query>` | MDN search |
| `quicklinks-stackoverflow` | `sof <query>` | Stack Overflow search |
| `quicklinks-godoc` | `godoc <query>` | pkg.go.dev search |
| `quicklinks-crates` | `crates <query>` | crates.io search |
| `quicklinks-youtube` | `yt <query>` | YouTube results |
| `quicklinks-maps` | `maps <query>` | Google Maps search |
| `quicklinks-dockerhub` | `dhub <query>` | Docker Hub search |
| `quicklinks-caniuse` | `caniuse <query>` | caniuse.com |

Typing the word alone, with nothing after it, opens that site's empty search
page. `{arg}` is empty when a row is reached any other way, so picking one of
these out of a plain search does the same.

## Why `{arg:url}` and not `{arg}`

The value lands inside a URL, and two different things have to be true of it.

Look shell-escapes every substitution, which protects the shell and does
nothing for the URL: a space would arrive as a second word, and a `&`, `+` or
`#` in what you typed would end the query string early so the site searched for
half of it. `:url` percent-encodes first, so `rust lifetime` is `rust%20lifetime`
and `C++ & C` survives intact.

That also explains the quotes around each URL, which look like the one thing
[CONTRIBUTING](../../CONTRIBUTING.md) tells you not to do. `?` and `&` are shell
punctuation, so the URL has to be quoted; and quoting is safe here because
`:url` is the one substitution Look does **not** escape — what comes out is only
`A-Za-z0-9-._~%`, which no shell reads as punctuation. A plain `{arg}` in
quotes would be the mistake.

## Adding your own

Any search box whose results live at a URL with the query in it. Open the site,
search for something, and look at the address bar:

```toml
[quicklinks-jira]
name    = "Jira"
aliases = ["jira"]
icon    = "🎟"
do      = ["""set "url=https://your-company.atlassian.net/issues/?jql=text~{arg:url}" \
           && call start "" "%url%" \
           || case ${OSTYPE:-$(uname)} in [Dd]arwin*) exec open "${1#url=}" ;; *) exec xdg-open "${1#url=}" ;; esac"""]
```

Copy any block and change only the URL in the first line; the other two are
the same in every block. Keep the triple `"""` and the trailing `\`: they are
what turns the three lines back into the one line `cmd` reads.

Two rules make the difference between one that works and one that nearly does:

- **the value has to be a query parameter, not a path segment.** `:url`
  encodes `/` as `%2F`, correctly, which is wrong for a URL like
  `github.com/owner/repo` where the slash is structure. Those need a different
  shape, not this one.
- **keep the word distinctive.** It competes with every app, file and setting
  on the machine. `mdn` and `caniuse` cost nothing; `docs`, `search` and `go`
  would make every search for those words worse.

## Customise

- **The browser** is whichever one the system opens a URL with. To pin one,
  change the opener on your platform: `open -a 'Firefox'` on macOS,
  `firefox` in place of `xdg-open` on Linux, `start "" firefox` on Windows.
- **Only one platform?** Each block can shrink to its own opener:
  `open "<url>"`, `xdg-open "<url>"` or `start "" "<url>"`.
- **Google, DuckDuckGo and a plain URL need no block.** Look already offers an
  **Open in browser** row for anything that looks like a URL, and `Cmd+Enter`
  on any query runs a web search with it.
- **Translation and dictionary need no block either**: `t"` translates and
  `tw"` looks a word up, both built in.
