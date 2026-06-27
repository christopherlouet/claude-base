# Rule-efficacy findings (log)

A running log of measured verdicts. Each entry: task, target rule, generation
method, N, the per-arm compliance rates, and the verdict. Verdicts are indicative
at small N — treat as signal, not proof.

## 2026-06-27 — first run (in-session subagents, N=3, Opus 4.8)

Generated with **in-session subagents** (the Agent tool), not `claude -p`: each
arm's samples are a subagent given the task prompt, with the target rule's text
**prepended** for the treatment arm and absent for the control arm. This tests the
rule's *text effect* (does the rule, when in context, change output?) for **zero
metered agentic credit** — it does NOT test the foundation's headless *delivery*
of the rule (see the canary note in README).

| Task | Target rule(s) | control rate | treatment rate | Verdict |
|------|----------------|-------------|----------------|---------|
| `no-any` | `typescript` (no `any`) | 3/3 | 3/3 | **REDUNDANT** |
| `substantive-tests` | `verification` + `tdd-enforcement` (no hollow tests) | 3/3 | 3/3 | **REDUNDANT** |

**Reading it.** On both tasks the model already complied **without** the rule:
every control sample used `unknown`/type-guards (never `any`), and every control
sample wrote real `expect(...).toBe(...)` assertions (no hollow tests). The rules
changed nothing here because Opus 4.8 does the right thing unprompted on a simple,
unambiguous task.

**This is a genuine result, not a null one:** it says these two style rules are
**redundant context cost** for a capable model on easy tasks — exactly the
"inert/redundant context we assume helps" the thread set out to detect. It does
**not** prove the rules never help: they may matter (a) for weaker models, or (b)
on tasks where the violation is genuinely tempting.

**The key methodological learning →** an easy task can only ever yield REDUNDANT or
INERT. To surface an **EFFECTIVE** verdict you need an **adversarial task** where
the model violates the rule *without* it — see "Designing a task" in the README.
Next: add such tasks (e.g. `any` made tempting by gnarly generics / `JSON.parse`
interop; a "write a quick smoke test" framing that baits a hollow test).
