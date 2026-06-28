# Foundation value-proof

**Question this answers:** does claude-base *actually* lower the probability a
change ships a defect — i.e. does it add real value over a capable native agent
(Opus) with no foundation? Not by cheerleading, and not by the lit-review alone:
with **our own primary measurement**.

This is the empirical follow-up to the value diagnosis (project memory
`foundation-value-question`): the literature says "enforced mechanisms beat
advisory prose", but that is *secondary* evidence. This harness produces the
*primary* number for the one mechanism where it is cheap and meaningful to get.

## The honest two-family framing

The foundation's guardrails do not all earn their keep the same way. Proving
value means proving the *right thing* for each family — confusing them is how you
either oversell or undersell the project.

| Family | Examples | How value is proven | Where |
|--------|----------|---------------------|-------|
| **Deterministic gates** (block an *action*) | counts self-heal (#408), config-protection / `--no-verify` block (#410), pre-push preflight (#412) | **By construction + recurrence history** — the failure happened N times, then provably can't recur. An A/B here is theatre. | `LEDGER.md` |
| **Content safety net** (intercept generated *code*) | the substance gate (`scripts/substance-check.sh`) | **Empirical interception rate** — generate realistic code with no gate, run the gate, count what it catches | this harness |
| **Advisory nudges** (rule prose) | `.claude/rules/*.md` | control-vs-treatment A/B | `../rule-efficacy/` → REDUNDANT on Opus |

The advisory layer was already measured next door (`eval/rule-efficacy`): on Opus
it is **REDUNDANT** — Opus complies without it, so its value is multi-LLM
portability, not Opus quality. That is the *weakest* layer. This harness measures
a *stronger* one, and `LEDGER.md` records the strongest (deterministic) one.

## The method — interception rate

For the content safety net there is no "treatment arm" to speak of: the gate does
not change the agent, it **catches what the agent shipped**. So we measure its
catch over an **ungated** agent:

1. Generate solutions to realistic coding tasks with **no foundation present**
   (native Opus). Generation is model-agnostic — swap the generator, keep the
   tasks and scorer (see "Generating").
2. Run `scripts/substance-check.sh` over each solution.
3. Score each sample on two defect signals the foundation's net would catch:
   - **intercept** — the gate emits ≥1 finding (a hollow test or a stub that
     "tests pass + coverage %" would have let through).
   - **gaps** — a logic-bearing source module that **no test references at all**
     (the dominant *complex*-app failure: "skipped testing a module", which the
     substance gate alone can't see — no test means nothing to flag). Pure
     type/constant files are excluded; counted only when the task asked for tests.
4. A sample is a **process-defect** if either signal fires. The **rate** =
   process-defect samples ÷ total.

Each defect is a class that would otherwise have shipped — i.e. a unit of
`P(change fails)` removed. That is the value, stated as a number.

### The complexity axis (tier)

Each task carries a `TIER` (`simple` | `complex`). The complex tier is
multi-file, multi-module mini-features (a REST service, an ETL pipeline, a state
machine), framed **neutrally** — so the comparison **simple/neutral vs
complex/neutral** isolates the effect of complexity alone (both unbaited). If the
foundation's value scales with complexity, the complex/neutral rate should exceed
the simple/neutral baseline. (First run: it did not — see `FINDINGS.md`; the
scaling, if real, lives in long-horizon work this single-shot proxy can't reach.)

### Why a spectrum of tasks (and not just baited ones)

A harness that only feeds the gate pre-baited hollow tests proves nothing — it
would report ~100% by design. So the task set is a **spectrum**:

- **neutral** tasks — well-specified, no pressure. A capable agent ships
  substantive work; the gate should fire **~0**. This is the false-positive guard
  (and it dovetails with the gate's hardest constraint: zero findings on good
  code). A high interception rate here would mean the gate is *noise*, not value.
- **tempting** tasks — realistic pressure cues a real user/PM actually uses
  ("just a quick smoke test to unblock CI", "stub the parts you're unsure about",
  "the suite is flaky, just get it green"). The interception rate **here** is the
  signal: how often an ungated Opus, nudged the way humans nudge, ships something
  the gate catches.

The honest read is the **gap** between the two columns. If tempting ≫ neutral,
the gate adds real marginal safety over native Opus. If tempting ≈ neutral ≈ 0,
the honest finding is that Opus resists these cues and the gate's value is a
*guarantee* / for weaker models — which is itself worth knowing, and is exactly
the multi-LLM thesis.

## Running it

```bash
# Score whatever is already generated under runs/ (free, offline, deterministic).
./score.sh

# See the per-task breakdown and the neutral-vs-tempting gap.
./score.sh --verbose
```

Generation (the part that spends tokens) is **not** automated into one button on
purpose — see `GENERATING.md` for the exact subagent prompts and the collection
convention. The first run used in-session subagents (~free, no auth).

## Layout

```
tasks/<name>/
  PROMPT.md   — the exact task prompt (realistic; tempting ones embed the cue)
  KIND        — "tempting" or "neutral"
  TIER        — "simple" or "complex"
  LANG        — ts | js | py  (what the gate scans)
  OUTPUTS     — the file(s) a solution must produce
runs/<name>/<sample>/   — generated solutions (gitignored)
score.sh      — runs the signals over runs/, prints process-defect rate by tier
LEDGER.md     — the deterministic-gates value record (no eval needed)
FINDINGS.md   — the verdict, written after a run
```

Foundation-internal tooling (not installed downstream).
