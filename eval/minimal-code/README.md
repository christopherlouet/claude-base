# Minimal-code discipline — eval harness

**Question this answers:** does the `research` minimal-code / YAGNI rule (#391/#392)
*actually* make generated code leaner **without** making it worse — or are we just
assuming it? This harness measures it instead of guessing.

It is deliberately split:

| Half | Cost | Automated? |
|------|------|-----------|
| **Scoring + verdict** (`eval.sh`) | free, offline, deterministic | yes — unit-tested in `tests/eval-minimal-code.bats` |
| **Generating** the control/treatment solutions | spends **metered LLM credit** | **no — you run it manually**, see below |

This is foundation-internal tooling (not installed into downstream projects).

## The method (control vs treatment)

For each task, generate the solution **twice**, identically except for the rule:

- **CONTROL** — the `research` rule is **absent** from the project.
- **TREATMENT** — the `research` rule is **present** (the default foundation).

Then score both. The treatment is an improvement only if it is **leaner AND still
correct AND still tested** — the verdict logic refuses to call a leaner-but-broken
or leaner-but-untested result a win (that is precisely the regression to fear).

### 1. Generate (manual — spends credit)

> ⚠️ Billing: each run invokes a coding agent. Keep the task set small; this is an
> occasional check, not a CI job. See the agentic-billing note in the project memory.

For a task (e.g. `debounce`):

```bash
TASK=tasks/debounce
PROMPT="$(cat "$TASK/PROMPT.md")"

# CONTROL: a scratch project WITHOUT the research rule
mkdir -p /tmp/eval-control && cd /tmp/eval-control
#   (start from a foundation install, then: rm .claude/rules/research.md)
claude -p "$PROMPT"          # writes debounce.js
cd -

# TREATMENT: a scratch project WITH the research rule (default install)
mkdir -p /tmp/eval-treatment && cd /tmp/eval-treatment
claude -p "$PROMPT"
cd -
```

(Generate a few samples per arm if you want to average out run-to-run variance.)

### 2. Score + compare (free)

```bash
./eval.sh score   /tmp/eval-treatment tasks/debounce
./eval.sh compare /tmp/eval-control /tmp/eval-treatment tasks/debounce
```

`compare` emits, e.g.:

```json
{"control":{"task":"debounce","loc":58,"files":1,"hasTests":false,"correctness":"pass"},
 "treatment":{"task":"debounce","loc":21,"files":1,"hasTests":false,"correctness":"pass"},
 "deltaLocPct":-64,"verdict":"LEANER_AND_CORRECT"}
```

## Metrics & verdicts

`score` reports, per solution: `loc` (non-blank lines of **source** files, tests
excluded), `files`, `hasTests`, and `correctness` (`pass`/`fail` from the task's
`verify.sh`).

`compare` returns one verdict — **the feared regressions are checked first**:

| Verdict | Meaning |
|---------|---------|
| `TREATMENT_BROKEN` | treatment fails correctness → leaner but **wrong** (the fear). |
| `CONTROL_BROKEN` | baseline already failed → inconclusive, fix the task/run. |
| `TREATMENT_DROPPED_TESTS` | treatment dropped tests the control had → leaner by cutting safety (the fear). |
| `LEANER_AND_CORRECT` | fewer LOC, still correct, tests kept → **the win we want**. |
| `HEAVIER` / `SAME_SIZE` | no LOC reduction. |

Reading it: only `LEANER_AND_CORRECT` (with a negative `deltaLocPct`) supports the
claim that the discipline helps. The two `*_BROKEN`/`DROPPED_TESTS` verdicts are
the alarms — they catch "less code, more errors / less maintainable" directly.

> LOC is a crude proxy for "less code". Correctness and hasTests are the guardrails
> that stop us optimizing the proxy at the expense of quality. For a qualitative
> read (readability, over-engineering), also eyeball both solutions.

## Adding a task

Create `tasks/<name>/` with:
- `PROMPT.md` — the exact prompt (pin the output filename + signature so `verify` can find it).
- `verify.sh <solution-dir>` — exit `0` iff correct (wrap a language test runner; see the two examples).
