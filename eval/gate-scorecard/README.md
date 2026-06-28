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

Only the gates that can judge a **static artifact** (a produced project), since a
bare project generated offline has no live action to intercept:

| Gate | Failure it would have shipped |
|------|-------------------------------|
| `secret` | a hardcoded key/token |
| `substance` | a hollow test / stub / focused `.only` |
| `destructive-migration` | an unguarded DROP/TRUNCATE in a migration file |
| `untested-module` | a logic module no test references |

The **action-time** gates (config-protection, command-validator, main-branch
protection) can't be scored on a static output — they intercept a *move*. Those
are proven by the executable [`../value-proof/gate-demo`](../value-proof/gate-demo/)
matrix. Together, gate-demo (action gates) + scorecard (artifact gates) cover the
deterministic half of the [`docs/GUARDRAILS.md`](../../docs/GUARDRAILS.md) catalogue.

## Demonstration

| Project | secret | substance | destructive-migration | untested-module | tripped |
|---------|--------|-----------|-----------------------|-----------------|---------|
| careless (bare-style) | TRIPPED | TRIPPED | TRIPPED | TRIPPED | **4 / 4** |
| disciplined (claude-base) | clean | clean | clean | clean | **0 / 4** |

## Honest reading (the recurring caveat)

On **Opus**, a bare session already self-secures most of the time (it parameterizes
queries, uses bcrypt, sanitizes paths — measured in
[`../value-proof/process-occurrence`](../value-proof/process-occurrence/)), so on a
single bounded task the bare-vs-base gap is often **small**. The scorecard's value
is twofold: (1) it makes the gap **visible and countable** whenever it exists, and
(2) it is the **model-agnostic instrument** for the multi-LLM column, where a weaker
base model trips far more gates and the gap becomes large. The point is not "Opus
needs this" — it's "the net is present, and here is exactly what it caught."
