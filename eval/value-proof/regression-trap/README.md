# Regression-trap — does enforced discipline beat native on an existing codebase?

The build/audit probes were greenfield single-shot. This one targets the regime
where the foundation's value is supposed to live: a **change to a pre-existing
multi-file codebase** with a **documented invariant** and a **tempting naive
solution that violates it**, run through a **real edit→test→fix loop**.

## Method

`cases/regression-cents/` ships a small but real Node project (`seed/`) — a
pricing/cart/discounts module with an existing passing suite, an `assertCents`
boundary guard, and a documented integer-cents invariant (`CONVENTIONS.md`). The
task (`TASK.md`): add a `percentage` discount. The naive `subtotal * percent/100`
yields fractional cents and violates the invariant; the fix is `Math.round`.

Three arms, each run as an agent in the project with a real test runner, isolated
to a neutral self-contained copy (no eval framing visible):

| Arm | Intervention | Native baseline it represents |
|-----|--------------|-------------------------------|
| **A** | bare task ("implement it") | a casual `claude` ask |
| **B** | + "be rigorous: explore conventions, run the full suite, don't break anything" | a careful user's prompt |
| **C** | + the foundation's workflow text (EXPLORE → TDD → VERIFY-before-done) | the discipline claude-base injects |

`score-regression.sh <sol>` runs the existing suite **plus** the hidden
`oracle/acceptance.test.js` (percentage correct, integer-cents held, no
regression). PASS = all green.

### Honest scope (read before the result)

This is a **text-effect** proxy: arms B and C deliver discipline *via the prompt*,
so it measures whether the disciplined **behaviors** have value — NOT whether
claude-base **delivers** them automatically (that needs real hooks/rules headless
= Stage B). And B≈C by construction (both prompt explore+verify), so the
informative comparison is **A vs B/C**.

## Result (Opus, 2 samples/arm, 2026-06-28)

| Arm | PASS rate |
|-----|-----------|
| A — bare task | **2/2** |
| B — disciplined prompt | **2/2** |
| C — foundation workflow | **2/2** |

**All arms passed.** Even arm A, told only "implement it", spontaneously read
`CONVENTIONS.md`, used `Math.round`, and added integer-cents tests. The trap did
not bite: on a project small enough to skim, Opus self-explores and self-verifies
without being told.

## The meta-finding (now 4 consistent measurements)

Rule-efficacy, the build tier, audit-detection, and now a regression/invariant
trap with a real loop **all** land the same way: **on any task an agent can hold
in one focused pass, Opus self-disciplines, and the foundation's behavioral value
over native ≈ 0.** Telling Opus to be rigorous (B) changes nothing because it
already is.

This does **not** mean the prod-scale gain is unreal — it means the cheap,
single-task regimes structurally can't show it, because the thing that would make
a naive agent fail (skipping exploration / full verification) doesn't happen when
exploration is free. The gain, if real, requires **scale or duration**:

- a codebase large enough that the invariant is **not skimmable** (the naive agent
  genuinely won't open the distant file) — a big fixture, and easy to over-engineer
  into a rigged result;
- **long, multi-session work** where context degrades and discipline lapses
  accumulate — not reproducible in a one-shot subagent;
- the **deterministic gates** (`../LEDGER.md`, already proven) and **weaker models**
  (the multi-LLM column).

Conclusion: stop building synthetic single-task traps (4/4 ceiling). The prod-scale
gain is **statistical and longitudinal**, so the experiment that can actually catch
it is **real-usage instrumentation** (aggregate CI-failure / revert rates,
claude-base vs native, over many real tasks) — the gold standard. See the parent
`FINDINGS.md` trail.
