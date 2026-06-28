# Gate scorecard — claude-base vs a bare Claude project, gate by gate

The gates aren't only guardrails — they're a **measuring stick**. Run the *same
task* on (A) a bare `claude` project with no config and (B) a claude-base session,
then score each produced project with `scorecard.sh`. The number of gates **A
trips** that **B doesn't** is the value, made concrete.

```bash
./scorecard.sh path/to/bare-claude-output     # e.g. Gates tripped: 4 / 4
./scorecard.sh path/to/claude-base-output     # e.g. Gates tripped: 0 / 4
```

## What it scores

The gates that can judge a **static artifact** (a produced project), in two tiers:

**Offline** (always scored — deterministic, zero-dependency):

| Gate | Failure it would have shipped |
|------|-------------------------------|
| `secret` | a hardcoded key/token |
| `substance` | a hollow test / stub / focused `.only` |
| `destructive-migration` | an unguarded DROP/TRUNCATE in a migration file |
| `untested-module` | a logic module no test references |
| `env-file-committed` | a real `.env` / secrets file committed |
| `debug-artifact` | a `debugger` / `pdb.set_trace` / `pry` left in the code |

**Toolchain** (scored only if the project's own tools are installed — else SKIP):

| Gate | Failure it would have shipped |
|------|-------------------------------|
| `typecheck` | type errors (`tsc --noEmit`) |
| `lint` | lint errors (`eslint`) |
| `tests` | a failing test suite (`npm test`) |

This is the **artifact** third of the comparison. The other two thirds:
- **action-time** gates (config-protection, command-validator, main-branch) — can't
  be scored on a static output (they intercept a *move*) → proven by
  [`../value-proof/gate-demo`](../value-proof/gate-demo/).
- **method** gates (explore/specify/plan/TDD/audit) — measured by which *process
  artifacts* the output contains → [`../cold-start`](../cold-start/).

Together the three cover the [`docs/GUARDRAILS.md`](../../docs/GUARDRAILS.md) catalogue.

## Demonstration

On the same task, the careless (bare-style) output trips every offline gate; the
disciplined (claude-base) output trips none:

| Project | offline gates tripped |
|---------|-----------------------|
| careless (bare-style) | **6 / 6** |
| disciplined (claude-base) | **0 / 6** |

(Toolchain gates SKIP here — the fixtures have no installed deps; on a real
project with `node_modules` they run `tsc`/`eslint`/`npm test`.)

## Honest reading (the recurring caveat)

On **Opus**, a bare session already self-secures most of the time (it parameterizes
queries, uses bcrypt, sanitizes paths — measured in
[`../value-proof/process-occurrence`](../value-proof/process-occurrence/)), so on a
single bounded task the bare-vs-base gap is often **small**. The scorecard's value
is twofold: (1) it makes the gap **visible and countable** whenever it exists, and
(2) it is the **model-agnostic instrument** for the multi-LLM column, where a weaker
base model trips far more gates and the gap becomes large. The point is not "Opus
needs this" — it's "the net is present, and here is exactly what it caught."
