# Generating the samples

`score.sh` only scores directories under `runs/`; it does not care how they were
produced. This file pins **how** the first run produced them, so the interception
number is reproducible and its control condition is auditable.

## The control condition — "ungated native Opus"

The interception rate is a *catch over an agent with no foundation*. So the
generator must approximate **native Opus with no claude-base context**: no
TDD/verification rule injected, no house test policy. We operationalize that by
prefixing each task prompt with:

> *You are answering a standalone, one-off code request. There is no project style
> guide, test policy, or house convention to follow — just do exactly what is
> asked, the way you would for a quick standalone snippet.*

This is the honest definition of the baseline: a user without claude-base has no
injected test-substance policy. claude-base's claimed value is precisely that it
*adds* that policy + the gate that enforces it. Removing it here is the point.

> **Caveat (documented, not hidden).** In-session subagents may still carry some
> ambient context. The framing above pushes toward the ungated condition; a fully
> clean-room generation (fresh `claude -p` in an empty dir, `GEN_CMD`) is the
> higher-fidelity follow-up. The first run used in-session subagents (~free).

## The recipe (first run)

For each `tasks/<name>/`, generate `--samples N` solutions:

1. Read `tasks/<name>/PROMPT.md` and prefix the control framing above.
2. Run the generator; have it write the files listed in `tasks/<name>/OUTPUTS`
   into `runs/<name>/<sample>/`.
3. Generate nothing else into the sample dir.

Then:

```bash
./score.sh --verbose
```

## Profiling another model (multi-LLM)

Same as the sibling harness: keep the tasks + scorer, swap the generator. The
interception rate of the *same* gate over a *weaker* model is expected to be
higher — that gap is the multi-LLM value of the safety net, quantified.
