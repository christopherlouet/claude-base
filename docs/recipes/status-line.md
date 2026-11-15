# Recipe: a status line that earns its row

**Audience**: anyone who wants a custom Claude Code status line. claude-base ships **no** status line script. Claude Code builds one for you natively, and this recipe says what is worth asking it for.

Field reference, checked 2026-11-15: <https://code.claude.com/docs/en/statusline>.

---

## Why no script ships

- **It is native.** `/statusline <what you want>` writes a script into `~/.claude/` and points your `settings.json` at it. `/statusline remove` takes it out again. A foundation template would duplicate that and would need upkeep every time the payload changes.
- **It is personal.** Colours, glyphs and themes differ from one user to the next. A shipped script would be either bland or overwritten by `update`.
- **It belongs at user level.** The line describes *your* session: context, rate limits, cost. Put it in `~/.claude/settings.json`, not in a project's committed `.claude/settings.json`, where it would be forced on every teammate.

---

## What a glance should tell you

The line is read in a split second, so order it by what changes a decision:

1. **The limits that stop the work.** `context_window.used_percentage`, then the rate limits `rate_limits.five_hour` and `rate_limits.seven_day` (`used_percentage`, plus `resets_at` as a local time).
2. **Where you are.** Folder and git branch, with a dirty marker.
3. **Optional session stats.** Tokens, duration, lines added and removed. Drop these first when space runs short.
4. **Cost, only on API billing.** `cost.total_cost_usd` is an estimate computed client-side at list price (unless a `modelPricing` table is in effect), and the docs warn it may differ from your bill. A claude.ai subscription is not billed per token, so the figure is not money you spend: leave it out. On the API, round it to two decimals (`$0.42`).

`rate_limits` exists only for Pro, Max and Ultra subscribers, or behind a gateway with a spend limit. It appears after the first API response, each window can be absent on its own, and Claude Code drops a window once its `resets_at` passes, so the segment must vanish cleanly. The documented subscriber windows are `five_hour` and `seven_day`, nothing monthly. A daily, weekly or monthly period appears only as `rate_limits.spend_limit`, behind a Claude apps gateway.

---

## Checklist

| Rule | Why |
|------|-----|
| One threshold scheme for every gauge: green, yellow at 60 %, red at 80 % | The eye learns one code, not one per segment |
| Width from `$COLUMNS`, never `tput cols` | Output is captured, so `tput` cannot see the terminal; Claude Code sets `COLUMNS` and `LINES` |
| In a narrow pane, drop segments bottom-up by the priority above | A wrapped or truncated line hides the gauge at its end (seen: `7d` cut off in a normal-width pane) |
| Hide a field that is absent or `null` (`// empty` in `jq`); don't print `null%` | `rate_limits` windows can be missing, and `context_window.used_percentage` may be `null` early in a session |
| Respect `NO_COLOR`; offer an ASCII fallback for the glyphs | Not every terminal or font renders them |
| Parse the payload with **one** `jq` call | The script runs on every update; a dozen `jq` spawns add up |
| Cache `git status` for a few seconds, keyed by `session_id` | It is the slow part in a large repository (see the docs' caching example) |
| Set `refreshInterval` for time-based segments (a countdown, a clock), or when background subagents change git state while the session is idle | Otherwise updates are event-driven, debounced at 300 ms, and the line also refreshes when a rate-limit window reaches `resets_at`; idle sessions emit no events |
| Don't re-display the footer hints | A custom line hides `esc to interrupt` and the like by design |

---

## A prompt that applies it

```text
/statusline two lines. Line 1: folder, git branch with a * when dirty (cache git for 5 s).
Line 2: context % as a 10-cell bar, then 5h and 7d rate limits with their reset time,
each hidden when absent. Green below 60 %, yellow from 60, red from 80, no colour when
NO_COLOR is set. Read the width from $COLUMNS and drop segments from the right instead of
wrapping. One jq call. No cost.
```

---

## Check it before you trust it

Feed it payloads and look: every segment present, then the fields missing. A missing field must disappear, not print garbage. Take the script path from `statusLine.command` in your settings:

```bash
s=$(jq -r '.statusLine.command' ~/.claude/settings.json); s=${s/#\~/$HOME}
reset=$(( $(date +%s) + 3600 ))
jq -n --arg dir "$PWD" --argjson r "$reset" '{session_id:"check", model:{display_name:"Opus"},
  workspace:{current_dir:$dir}, context_window:{used_percentage:83},
  rate_limits:{five_hour:{used_percentage:65,resets_at:$r}, seven_day:{used_percentage:12,resets_at:$r}}}' \
  | COLUMNS=60 "$s"
echo '{"session_id":"check","context_window":{"used_percentage":null}}' | NO_COLOR=1 "$s" | cat -v
```

The second run must print no `null` and, with `NO_COLOR` set, no `^[[` escape sequence.

Time it as well (`time` over a few runs). A slow script leaves the line stale until it finishes, and a new update cancels it.
