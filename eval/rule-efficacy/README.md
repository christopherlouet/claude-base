# Rule efficacy — eval harness

**Question this answers:** do the foundation's `.claude/rules` *actually change
agent behavior*, or are they inert context we pay for and assume works? This
harness measures it, **per rule and per model**, instead of guessing — the
capstone of the "anti-gaming of quality gates" thread (after counts self-heal,
anti-tamper, and the substance gate).

> **Per-model, on purpose.** Efficacy is **model-dependent** (FINDINGS.md): a rule
> a frontier model already embodies is REDUNDANT for it but can be EFFECTIVE for a
> weaker or differently-trained model. If the foundation will run on **another LLM**
> (e.g. a Mistral-driven harness), the deliverable is a **rule × model matrix** —
> which rules earn their context cost *for the model you target*. The scorer is
> model-agnostic; you swap the model via `GEN_CMD` (see "Generating samples").

It is deliberately split, like the minimal-code eval next door:

| Half | Cost | Automated? |
|------|------|-----------|
| **Scoring + verdict** (`eval.sh`) | free, offline, deterministic | yes — unit-tested in `tests/eval-rule-efficacy.bats` |
| **Generating** the control/treatment arms (`run.sh --execute`) | spends **metered LLM credit** | opt-in — DRY-RUN by default |

Foundation-internal tooling (not installed downstream).

## The method (control vs treatment)

For a task crafted to **tempt a violation** of one rule, generate solutions twice:

- **CONTROL** — the target rule is **removed** from the project.
- **TREATMENT** — the rule is **present** (the default foundation).

Score the **compliance rate** of each arm (fraction of samples whose `verify.sh`
passes), then read the 4-way verdict:

| Verdict | control → treatment | Meaning |
|---------|---------------------|---------|
| **EFFECTIVE** | low → high | the rule changes behavior — it fires *and* matters (the win) |
| **REDUNDANT** | high → high | the model already complies without the rule — it may be noise |
| **INERT** | low → low | the rule moves nothing — ignored **or not injected** (see canary) |
| **HARMFUL** | high → low | the rule makes things worse (rare) |

`EFFECTIVE` justifies the rule's context cost. `REDUNDANT` / `INERT` are the
findings the thread is after: rules we assume help but don't.

## ⚠️ CANARY FIRST — validate that rules even reach the headless agent

`INERT` has **two** causes: the rule was injected and ignored, *or* it was never
injected. In `claude -p` (headless), path-activated rules may not be loaded the
way they are in an interactive session. **Before trusting any `INERT` verdict**,
prove rules reach the agent:

1. Add a throwaway rule `/.claude/rules/_probe.md` with `paths: ["**/*.ts"]` and a
   single arbitrary, non-default instruction (e.g. *"every file must start with
   the comment `// CANARY-7F3`"*).
2. `cd` into a project that has it and run `claude -p "write hello.ts"`.
3. If the marker appears → rules are injected headless; `INERT` is real. If not →
   the harness can't see rules headless, every verdict is confounded, and the
   real finding is *"rules don't load in `-p` mode"* (itself worth knowing).

## Running it

```bash
# Free: see exactly what it would do, spend nothing.
./run.sh no-any --samples 3

# Spends credit (2 x N `claude -p` calls): build both arms, generate, score.
./run.sh no-any --samples 3 --execute
```

`run.sh` builds each arm as a minimal project (`CLAUDE.md` + `.claude/rules/`,
the target rule removed for control), runs the agent once per sample, collects the
task's `OUTPUTS`, and prints `eval.sh compare`. Override the agent with
`CLAUDE_CMD`. Keep N small — this is an occasional check, not CI (see the
agentic-billing note in project memory).

Score already-generated dirs by hand:

```bash
./eval.sh rate    runs/no-any/treatment tasks/no-any
./eval.sh compare runs/no-any/control runs/no-any/treatment tasks/no-any
```

## Generating samples — three ways

`eval.sh` only scores directories; it does not care *how* the samples were
produced. Three ways to generate the two arms, cheapest last:

| Method | Tests | Cost |
|--------|-------|------|
| `claude -p` (what `run.sh` drives) | the **full chain** — rule file → harness injection → behavior | metered agentic credit + headless-delivery uncertainty |
| Raw Claude API, rule text injected by hand | the rule's **text effect** | API key + standard billing |
| **In-session subagents** (the Agent tool), rule text prepended for treatment | the rule's **text effect** | ~free (session tokens), runs now, no auth |

The text-effect methods can't see whether the foundation *delivers* the rule, but
they answer the prior question first: **if a rule is INERT even when force-injected,
no delivery fixes it.** The first run (see FINDINGS.md) used in-session subagents.

**Profiling another LLM (the multi-LLM goal).** `run.sh` is model-agnostic: set
`GEN_CMD` to any command that takes the prompt and writes the output file(s) in its
CWD, and the same tasks/scorer produce that model's verdicts. The scorer never
changes — only the generator does.

```bash
GEN_CMD='claude -p --permission-mode acceptEdits' ./run.sh no-any --execute   # Claude (default)
GEN_CMD='python gen_mistral.py'                    ./run.sh no-any --execute   # any other model
```

Run each target model and tabulate the verdicts into a **rule × model matrix** —
that is the artifact that tells you which rules to keep/emphasize/rephrase per model.

## Tasks included

| Task | Targets rule(s) | Compliance = |
|------|-----------------|--------------|
| `no-any` | `typescript` | a real `parseConfig` in `config.ts` that uses **no `any`** type |
| `substantive-tests` | `verification` + `tdd-enforcement` | impl **plus a test the substance gate flags 0 hollow findings on** (dogfoods `scripts/substance-check.sh`) |

## Adding a task

Create `tasks/<name>/` with:
- `PROMPT.md` — the exact agent prompt, **crafted to tempt the violation** and
  pinning the output filename(s) so `verify.sh` can find them.
- `RULE` — the `.claude/rules/...md` path(s) to remove for the control arm.
- `OUTPUTS` — the file(s) `run.sh` collects into each sample dir.
- `verify.sh <solution-dir>` — exit `0` **iff the solution complies** with the
  rule. Make it require a non-trivial solution, so "compliance" can't be won by
  doing nothing.

**Make the task ADVERSARIAL.** A task where the model complies *without* the rule
can only ever score REDUNDANT or INERT — it can never reveal an EFFECTIVE rule.
The first run found both `no-any` and `substantive-tests` REDUNDANT precisely
because they were too easy (Opus does the right thing unprompted). To detect a
rule that *works*, design the prompt so the model is genuinely tempted to violate
it without the nudge: gnarly generics / `JSON.parse` interop that bait `any`; a
"just write a quick smoke test" framing that baits a hollow test; an ambiguous
spec where the rule's convention is one of several reasonable choices.

## Caveats

- **Compliance is structural, not semantic** — `verify.sh` checks a checkable
  proxy (no `any`, no hollow test), not "good code" in full.
- **Small-N variance** — LLM output varies run-to-run; use enough samples
  (≥5 per arm) before reading a verdict as anything but indicative.
- **One rule per task** — to attribute the effect, the arms must differ in exactly
  one rule (a task removing two tightly-coupled rules attributes to the pair).
