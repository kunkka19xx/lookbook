# meeting

Your next meeting as one row. The preview pane shows what it is, how long until it starts, and the link it will open; Enter joins. A second row lists what is left in your day.

Nothing to install: it reads macOS's own calendar store with the `sqlite3` already in `/usr/bin`.

**Requires.** Look v0.6.12 or newer, and macOS. No packages, no OAuth, no account setup — but **Full Disk Access for Look**, which is the real price and is discussed below.

**Platforms.** macOS only. The store it reads does not exist on Linux or Windows — see [Linux](#linux) for what would be needed there instead.

> **This needs Full Disk Access, and that is a big ask.** The calendar store lives in a TCC-protected group container, so Look cannot read it until you add Look under System Settings → Privacy & Security → **Full Disk Access** and relaunch it. That grant is not scoped to calendars: it lets Look read Mail, Messages, Safari's data and every other app's container.
>
> Look's built-in `join` needs none of that. It calls EventKit, so it holds `kTCCServiceCalendar` — permission to read your calendar and nothing else. A shell script cannot call EventKit, which is the whole reason this example goes around the API to the file underneath, and the whole reason it costs so much more permission to do the same job. **Weigh that before you grant it.**

> **Look already answers `join` on macOS.** Type `join`, `join my next meeting` or `join standup` and Look reads EventKit itself, through Apple's supported API, with permissions handled for you. **That is the one to use.** This example exists for the things a source can do that a built-in cannot: rank in your list like any other row, show the next meeting in the preview pane without you typing anything, and be edited — change the lookahead, add a provider, make Enter do something else entirely. If you only want to join meetings, use `join` and skip this.

## Install

```bash
cp examples/meeting/*.toml ~/.look/sources/
mkdir -p ~/.look/bin && cp examples/meeting/bin/meeting-next ~/.look/bin/
chmod +x ~/.look/bin/meeting-next
```

Reload with `Cmd+Shift+;`.

## Blocks

| Block | Row | Enter |
| --- | --- | --- |
| `meeting` | one row, always | opens the next meeting's join link |
| `meeting-agenda` | one row, always | opens Calendar; the preview lists what is left |
| `meeting-list` | one row per meeting, via `Cmd+K` | joins that meeting |

## What the panel shows

```
Platform Weekly & Design Review

  starts  in 3h 24m
  time    Fri 14:00 – 15:00
  join    Google Meet
  link    meet.google.com/abc-defg-hij
  where   Meeting Room 4 (10) [Display]

  then    19:00  Quarterly Planning Revi…
```

The preview pane is monospaced, so a fixed-width label column costs nothing and turns five facts into something you scan rather than read. `link` drops the `https://` — nine characters that identify nothing — and keeps the part that says which room. `where` appears only when the location says something the link does not, since a Meet invite often repeats the URL there. `then` names the meeting after this one, because "is there another one right after" is most of what you were about to ask; it drops the weekday when it is the same day and clips the title, so it stays one line.

## What to type

- **`meeting`** — also `next meeting`, `call`, `standup`, `huddle`. Enter joins the next one; the preview says which, when, and where it will send you.
- **`agenda`** — also `schedule`, `my day`, `what is next`. The preview lists the rest of your day; Enter opens Calendar.
- **`Cmd+K` on either** → **Pick a meeting**, which is the list as real rows: arrow to one, Enter joins it. Type before you press `Cmd+K` and the list is filtered by it — `meeting standup` then `Cmd+K` shows only the standups.

Not `join`. That word belongs to Look's own built-in, and these blocks deliberately stay out of its way.

## Why the list is a drill-down and not a top-level block

`meeting-list` is the one block here that produces rows, and it is reachable only through `then`. That is not a stylistic choice — it is the only shape that works, and it turns on one line in Look:

> A block whose command names a row placeholder is a level, run live when the user descends.

Both the indexer and the reload refresh skip any block whose producer names a placeholder. So `run = "... --rows {query}"` buys three things at once:

- **The countdowns are right.** A drilled block runs when you descend, not on reload, so `in 21 min` was computed as you looked at it. As a top-level `run` block the same rows would be served from the cache and could be hours stale.
- **No red banner.** A top-level `run` block that produces nothing reports `produced no rows` on every reload, and "no meetings" is the normal state most evenings. An empty level is just an empty level.
- **`{query}` earns its keep twice.** It is the filter, *and* it is the placeholder that makes the block a level at all.

## Why both blocks are `do` and not `run`

A `run` block's rows are produced on reload and cached until the next one. That is what keeps search instant, and it is exactly wrong for a countdown: a row reading `Standup · in 15 min` would still say that an hour later, confidently and wrongly.

A `do` block has one row whose text never changes, so nothing can go stale. The lookup happens when you press Enter, and `preview` runs live for whichever row is selected — so the panel is computed at the moment you are looking at it.

It also sidesteps a second problem. A `run` block that produces no rows puts a red `produced no rows` banner on every reload, and "no meetings" is the normal state most evenings and every weekend. These blocks are always exactly one row, so there is nothing to be empty.

That trade is worth knowing generally: **anything clock-dependent belongs in a `do` block's steps or a `preview`, never in `run` rows.**

## What it reads, and the risk that comes with it

`~/Library/Group Containers/group.com.apple.calendar/Calendar.sqlitedb` — the store behind Calendar.app and EventKit. Three things in it do the work:

- **`conference_url`, which is emptier than it looks.** Apple has a column for the extracted join link, and it is checked first — but on the machine this was written against it was **empty for all twelve** Google Meet invites in a synced Google Workspace account. The link was in the notes body every time. So the fallback is not a fallback in practice: the script scans the location and the notes for a Zoom, Meet, Teams, Webex, Whereby, BlueJeans, Chime or GoToMeeting URL, and that is the path that actually runs. Do not delete it on the assumption that the column is filled.
- **`OccurrenceCache`.** This is the one that makes the example possible. A recurring meeting is stored **once**, with `has_recurrences = 1` and its rule in a separate `Recurrence` table — so a weekly standup is invisible if you only read `CalendarItem`, because the single stored row sits on whatever date the series began. `OccurrenceCache` is Apple's own expansion of those rules into dated rows, which is why this script never parses an `RRULE`. Getting that right by hand — with `EXDATE`, `UNTIL`/`COUNT` and DST shifts — is the actual work that `khal` and `gcalcli` exist to do.
- **`Location` and `CalendarItem.description`**, joined for the fallback scan.

**This schema is private and undocumented.** Apple can rename a column in any point release, and browsers at least have a community that notices. If a macOS update breaks it, the failure is quiet: you get "No meetings in the next 48 hours" rather than an error, because a query against a missing column returns nothing. That is the trade for having no dependencies, and it is why the built-in `join` is the better tool if joining is all you want.

**It never writes.** The database is copied to a temp directory with its `-wal` before being read, so a running Calendar is neither locked nor missing this session's edits — the same snapshot trick the `browser-history` example uses.

## Customise

Every setting is an environment variable with a default, so you can try one without editing the script. Put it on the `do` line in `meeting.toml`, **not** in `~/.zshrc` — Look runs commands through a login shell, which never reads your rc file.

```toml
do = ["LOOK_MEETING_AHEAD_HOURS=8 ~/.look/bin/meeting-next --join"]
```

| Variable | Default | What it does |
| --- | --- | --- |
| `LOOK_MEETING_AHEAD_HOURS` | `48` | How far ahead to look. 48 so Friday evening finds Monday's |
| `LOOK_MEETING_BEHIND_MINUTES` | `15` | How late you can still join. The window opens before now on purpose |
| `LOOK_MEETING_AGENDA_LIMIT` | `10` | Rows `--agenda` lists |
| `LOOK_MEETING_DB` | the path above | Point it at a copy to test against |

- **Add a provider.** `PROVIDER_RE` in the script is one alternation; add your company's `meet.corp.example.com` beside `zoom\.us`.
- **Make Enter do something else.** `do = ["~/.look/bin/meeting-next --agenda"]` will not work — a `do` step's output goes nowhere. To act on the meeting rather than join it, add a step: opening the link *and* muting Slack is two lines.
- **Only meetings with a link.** Add `AND coalesce(conference_url,'') <> ''` to the query's `WHERE`, and lunch stops being your next meeting.

## Nothing appears

Run `~/.look/bin/meeting-next` in a terminal — it prints the same text the preview shows.

- **"No meetings in the next 48 hours"** with meetings in Calendar means either the window is too narrow, or the schema moved. Check the store is readable at all: `sqlite3 "$HOME/Library/Group Containers/group.com.apple.calendar/Calendar.sqlitedb" "select count(*) from CalendarItem;"`
- **"could not read the calendar store (Full Disk Access?)"** is the expected first run. Add Look under System Settings → Privacy & Security → **Full Disk Access**, then **quit and relaunch Look** — TCC is only re-read at launch, so toggling it while Look is running changes nothing. It works from your terminal and not from Look because your terminal already has the grant and Look does not; having `kTCCServiceCalendar` is not enough, since that authorises EventKit rather than the file.
- **Only birthdays and holidays are in there** if you have no calendar account signed in. Those are all-day events and are filtered out by design, so an account-less Mac correctly reports nothing.

## Linux

The file this reads is macOS-only, and Look's own EventKit backend is macOS-only for the same reason — [`docs/ai-eventkit.md`](https://github.com/kunkka19xx/look/blob/main/docs/ai-eventkit.md) puts it plainly: *"there is no unified system calendar to drive on Linux."*

A Linux version is the same script with the query replaced by `khal list now 2d` (CalDAV via `vdirsyncer`) or `gcalcli agenda` (Google, after an OAuth setup). Both expand recurrences properly, which is the part you cannot skip. That is a separate example and needs someone who runs one of them to write it.
