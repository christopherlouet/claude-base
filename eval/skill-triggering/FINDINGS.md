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

## 2026-09-27 — campaign 2: every other auto-triggerable inline skill

25 skills (the nine `disable-model-invocation` skills cannot fire and were left
out). 3 runs per case, `claude-opus-5-5`, about 10 USD at list price.

**23/25 fire alone, 3/3**: agent-teams, api-mocking, data-pipeline, dev-auth,
dev-error-handling, dev-flutter, dev-frontend-design, dev-i18n, dev-nextjs,
dev-prisma, dev-shadcn, dev-supabase, feature-flags, git-worktrees, growth-cro,
ops-infra-code, ops-mobile-release, ops-opnsense, ops-proxmox, qa-e2e,
session-handoff, state-management, writing-skills. Every deliberate neighbour
pair separated: dev-auth / dev-supabase, ops-infra-code / ops-proxmox /
ops-opnsense, dev-shadcn / dev-frontend-design, api-mocking / qa-e2e,
agent-teams / parallel-agents.

The other two:

- `dev-document` fired first 3/3, then loaded `dataviz`, a skill bundled with
  Claude Code, to draw the requested chart. A legitimate composition, not a
  conflict: the "no other skill" grader counts bundled skills too.
- `parallel-agents` fired 1/3 in an empty workspace. With five real services
  scaffolded, Opus launched parallel subagents itself, without the skill (0/2;
  the third run hit the 1 USD ceiling, subagents cost more). The behaviour the
  skill teaches happens anyway on this model. Left unchanged: making it fire
  would add its content to the session for something Opus already does.

Across all three campaigns: 34 auto-triggerable inline skills measured, 2
descriptions fixed (`work-quick`, `dev-debug`), 1 skill found redundant on
Opus (`parallel-agents`).

## 2026-10-03 — foundation skill and vendor skill installed together

Question: when a project installs the vendor skill the foundation points to,
which one fires? Same prompts as the `*-fires` cases, run with
`--extra-skills DIR`, DIR holding every skill of the five vendor repos at the
ref pinned in `.claude/curation/registry.json` (36 skills: `prisma/skills`,
`supabase/agent-skills`, `shadcn-ui/ui`, `apollographql/skills`,
`vercel-labs/agent-skills`). Cases `vendor-*-coexist`: pass = a vendor skill
fires and the foundation skill does not. 3 runs per case, `claude-opus-5-5`,
about 3 USD at list price.

| Case | Skills fired, per run |
|---|---|
| prisma — "Add a Comment model… create the migration" | `dev-prisma` · `dev-prisma` · `dev-prisma` — **the vendor never fires** |
| shadcn — "Install shadcn/ui… add a Dialog and a DataTable" | `dev-shadcn` + `shadcn` · `shadcn` · `shadcn` |
| supabase — "Store user avatars in Supabase Storage… RLS" | `supabase` ×3 |
| graphql — "Add a resolver… Apollo GraphQL server" | `apollo-server` ×3 |
| nextjs — "…statically generated and revalidated every hour" | `dev-nextjs` ×3 |

Three readings:

1. **Prisma: the pointer shadows the vendor.** `dev-prisma`'s description names
   the prompt's exact gestures ("add a model, create a migration,
   schema.prisma"); no vendor description does. The pointer then tells the
   model to install a skill that is already installed.
2. **Where the vendor wins, the pointer's safety rules are lost.** Supabase
   fires alone 3/3, so "RLS on every public table" and "never expose the
   `service_role` key client-side" — kept in `dev-supabase` under "Foundation
   rules preserved" — never reach the session. `vendor-precedence` (tier 1)
   says a vendor skill must never relax a foundation security rule; installed
   together, it does, silently. A rule that must survive the vendor cannot live
   in a skill the vendor out-triggers.
3. **Next.js has no vendor counterpart at this pin.** `vercel-labs/agent-skills`
   ships React performance, composition, deployment and view-transition skills,
   none on App Router caching or ISR; `dev-nextjs` fires because nothing else
   covers the prompt. Its registry record treats the repo as its replacement.

To replay: fetch each repo at its `pinnedRef`, copy every `<skill>/` dir holding
a `SKILL.md` into one flat DIR, then
`run.sh --extra-skills DIR --case vendor-<tool>-coexist` (one call per case).
Without `--extra-skills`, `run.sh` leaves these cases out.

Limits: N=3, one prompt per tool, one model. All skills sit in one plugin here;
in a project the vendor skills would live under `.claude/skills/`, the
foundation's beside them — same descriptions, same competition.

## 2026-10-03 — fix: rules out of the pointers, `dev-prisma` steps aside

The "Foundation rules preserved" lists of `dev-prisma` and `dev-supabase` moved
to `.claude/rules/prisma.md` and `.claude/rules/supabase.md`, scoped to the
tool's files, so they load whichever skill fires. `dev-prisma`'s description now
presents it as the pointer it is, for use "only when no prisma-* skill is
installed". Same method, 3 runs per case, `claude-opus-5-5`, about 0.75 USD.

| Case | Before | After |
|---|---|---|
| `vendor-prisma-coexist` (vendor skills installed) | `dev-prisma` ×3 | **`prisma-cli` ×3**, pointer silent |
| `dev-prisma-fires` (no vendor skill) | `dev-prisma` ×3 | `dev-prisma` ×3 — still the switch when the vendor is absent |

That the rules load from the files was proven by effect, outside this harness: a
canary token in each rule, a throwaway project, `claude -p` reading one file per
session. `README.md` (control) → no token; `prisma/schema.prisma` → the Prisma
token; `lib/supabase.ts` and `supabase/migrations/001.sql` → the Supabase token.

Left as measured: `dev-shadcn` also fired once in three next to the vendor's
`shadcn`. Its kept rules are styling conventions, not security, so nothing is
lost when it stays silent.

Review follow-up: `prisma.md` also matches `**/*prisma*` (the client module,
where the singleton and `select`-over-`include` rules apply) — canary loaded on
`lib/prisma.ts`, not on `lib/db.ts` (control). `supabase.md` also ships to
Flutter projects. Known limits, no glob reaches them at an acceptable cost: a
Prisma client named `db.ts`, query code in arbitrary files, and a `service_role`
key written into a component or a `NEXT_PUBLIC_` variable — the rule loads only
once the session touches a Supabase or Prisma file.

## 2026-10-03 — `dev-react-perf` and `dev-document` next to their vendor skills

Same method (`--extra-skills`, 3 runs, `claude-opus-5-5`).

**`dev-document` vs Anthropic's `docx`/`pdf`/`xlsx`/`pptx`.** The two do different
jobs: Anthropic's skills make Claude write or edit a file itself; `dev-document`
teaches the code an application uses to generate one. Its description claimed
both ("create a document… produce an office file").

| Case | Before (old description) | After (scoped to application code) |
|---|---|---|
| `vendor-document-author-coexist` — "Write a one-page Word memo (memo.docx)…" | `docx` ×3 | `docx` ×3 |
| `vendor-document-app-coexist` — "Add an endpoint GET /invoices/:id/pdf to our Express app…" | `dev-api` ×3 — no document skill | **`dev-document` ×3** |
| `dev-document-fires` (no vendor skill), same endpoint prompt | — | `dev-document` ×3 |
| `dev-document-script-fires` — "Write scripts/monthly-report.js, run by cron… writes reports/<YYYY-MM>.pdf" | — | `dev-document` ×3, with or without the vendor skills |

The old `dev-document-fires` prompt ("Generate our monthly sales report as a PDF…
from sales.csv") is a file Claude produces: after the change it fires `pdf` ×3
with the vendor skills installed, `dataviz` ×3 without. The case now carries the
endpoint prompt, which is what the skill is for.

**`dev-react-perf` vs Vercel's `react-best-practices`** (`dev-react-perf-fires`):

| Pointer description | Vendor installed | Fired |
|---|---|---|
| fires on React perf work (reduced to pointer + gaps) | no | `dev-react-perf` ×3 |
| same | yes | `dev-react-perf` ×3 — vendor never fires |
| defers to the vendor when installed | yes | **nothing ×3** |
| fires, body says "invoke the vendor skill now" | yes | `dev-react-perf` ×3, vendor still not loaded |

The vendor skill does not fire on this prompt by itself, so a pointer that steps
aside leaves the session with no skill. Kept: the pointer fires and carries a
five-line condensed top of the vendor's ranking (MIT, attributed).

A blind outcome comparison (12 planted defects in a React dashboard, Opus grader,
`tsc` on every result) found no measurable difference between the two skills:
11/12 for both, and for no skill, on Opus 5.5; on Haiku 4.5, 5 to 9 out of 12
with a run-to-run spread larger than any gap between arms (vendor 7.0 mean over
5 runs, pointer 7.25 over 4, no skill 6.3 over 3). An early "vendor 8 vs 6–7"
from two runs per arm did not survive more runs.
