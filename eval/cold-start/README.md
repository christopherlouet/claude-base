# Cold-start — the method gates, bare Claude vs claude-base

The artifact gates ([`../gate-scorecard`](../gate-scorecard/)) and action gates
([`../value-proof/gate-demo`](../value-proof/gate-demo/)) cover the *deterministic*
guardrails. This covers the third family — the **method gates** (Explore →
Specify → Plan → TDD → Audit → Commit) — whose value isn't a line of code but the
**process trail a bare session never produces**.

`coldstart.sh <dir>` scores a session's output by which method artifacts it
contains: `spec`, `plan`, `tests`, `audit`, `commit` (conventional message), `pr`.
Run it on a bare-Claude output and a claude-base output for the **same task**.

## Real run (2026-06-28, Opus, task = "a coupon-code validator")

| Output | spec | plan | tests | audit | commit | pr | total |
|--------|------|------|-------|-------|--------|----|-------|
| **bare** ("just build it") | – | – | – | – | – | – | **0 / 6** |
| **claude-base** (workflow) | ✓ | ✓ | ✓ | ✓ | ✓ | – | **5 / 6** |

The bare arm shipped one file (`validateCoupon.js`) — working code, nothing else.
The claude-base arm shipped `SPEC.md` (user stories + Given/When/Then), `PLAN.md`,
`coupon.test.js` (tests first), `coupon.js`, `AUDIT.md`, and a conventional
`COMMIT_MSG.txt`.

## Why this is the *clearest* part of the value story

Every other measurement in this repo found the bare-vs-base gap **small on Opus**
(it self-secures, self-tests, writes good code). The **method gates are the
exception**: the gap is **large even on Opus** — not because Opus *can't* write a
spec or an audit, but because it *doesn't, unprompted*. claude-base's workflow
makes that paper trail happen by default. That is the most honest, most visible
answer to "what does claude-base give me that a bare project doesn't": **the
discipline and the artifacts, every time, without you having to ask.**

## How the run was produced

Two agents, same task, isolated dirs:
- **bare** — "quick one-off, no process to follow, just build it".
- **base** — "follow Explore → Specify → Plan → TDD → Audit → Commit, producing
  SPEC.md / PLAN.md / tests-first / code / AUDIT.md / COMMIT_MSG.txt".

Then `coldstart.sh` scored each. Deterministic, offline; re-runnable for any model
(the multi-LLM column reuses the same scorer).
