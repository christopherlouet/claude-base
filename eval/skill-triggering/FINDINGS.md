# Skill triggering — findings

Run with `eval/skill-triggering/run.sh` (`claude plugin eval`, with-plugin arm only).
Model: `claude-opus-5-5` (read from the traces; the JSON report does not name it).
Sessions load the skills only: no `CLAUDE.md`, rules, hooks or routing hint.
A run passes when the expected skill is invoked **and no other skill is**.

## 2026-09-27 — pilot: `work-quick` shadowed `dev-tdd`

| Case | Before (`work-quick` description as shipped) | After (description narrowed) |
|---|---|---|
| `dev-tdd-fires` — "Add a function `slugify(title)` to a new file…" | 0/3 — every run invoked `work-quick` first, which then redirected to `dev-tdd` | **3/3** — `dev-tdd` alone |
| `work-quick-fires` — "Fix the typo in README.md" | 2/3 — `work-quick`; one run used no skill | **3/3** — `work-quick` alone |
| `dev-tdd-quiet` — "What does this regex match? Just explain" | 3/3 — no skill | **3/3** — no skill |

Cause: `work-quick` triggered on "a simple change", and "add a function" reads as
one. Its body already excluded new files and features; its description, the only
part the model reads to choose, did not. Since 43 skills run inline (#602), the
detour injected two skills into the session instead of one.

Change: the description now says "trivial edits to EXISTING code" and "not for
adding a function, a file or a feature, however small (that is dev-tdd)".

Cost: about 0.13 USD a session at list price (0.07 for a one-turn negative). On a
Pro/Max plan that is an estimate, drawn from the plan's usage limits, not billed.

Limits: N=3 per case, one model, three prompts. This fixes one measured conflict;
it says nothing yet about the other skills.

## 2026-09-27 — campaign: four overlapping pairs

Same method, after the `work-quick` fix. 3 runs per case, `claude-opus-5-5`, about
2.5 USD at list price for the campaign.

| Case | Result |
|---|---|
| `ops-ci-fix` — "Our GitHub Actions workflow fails on every push…" | 3/3 alone |
| `qa-perf` — "Our Express API takes 3 seconds on GET /orders…" | 3/3 alone |
| `dev-react-perf` — "My React list re-renders every item…" | 3/3 alone |
| `dev-refactor` — "Our 400-line utils.js has grown messy. Restructure it…" | 3/3 alone |
| `dev-api` — "Add a REST endpoint POST /users…" | 3/3 alone |
| `dev-graphql` — "Add a resolver for a `user(id)` query…" | 3/3 alone (although `dev-api` also claims GraphQL) |
| no skill — "Difference between `let` and `const`?" | 3/3 no skill |
| `dev-debug` — "`node list.js` crashes with TypeError… Why, and how do I fix it?" | **0/3 — no skill**, with or without the buggy file in the workspace |

Every pair separated cleanly. `dev-debug` was the exception: Opus read the code,
explained and fixed the bug without loading any skill, on a one-file bug (0/3)
and on a three-file one whose cause sits two modules from the symptom (0/3).

## 2026-09-27 — `dev-debug` never fired

The description ("Use when the user has a bug, an error…") matched every prompt
and still lost to reading the code directly. It now states the method and asks to
be used first: "Systematic debugging - reproduce, isolate the root cause, fix,
pin it with a regression test. Use it first whenever the user reports a bug, a
crash, an error message, a wrong result or a failing test (a failing CI pipeline
is ops-ci-fix), before reading code to guess at the cause."

| Case | Before | After |
|---|---|---|
| `dev-debug` — one-file bug | 0/3 | **3/3** alone |
| `dev-debug` — three-file bug | 0/3 | **3/3** alone |
| `ops-ci-fix` (its neighbour) | 3/3 | 3/3 alone |
| no skill — `let` vs `const` | 3/3 | 3/3 |
| `dev-tdd` — "Add a function…" | 3/3 | 3/3 alone |
| `work-quick` — typo | 3/3 | 3/3 alone |
| `dev-tdd` quiet — "explain this regex" | 3/3 | 3/3 |

Trade-off to keep in mind: inline, a fired skill puts its content into the
session. On a bug that one read would solve, that is extra context for a
method the model would not have needed.
