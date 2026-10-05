# Rule-efficacy findings (log)

A running log of measured verdicts. Each entry: task, target rule, model, N, the
per-arm compliance rates, and the verdict. Verdicts are indicative at small N —
treat as signal, not proof.

## 2026-06-27 — first runs (in-session subagents)

Generated with **in-session subagents** (the Agent tool), not `claude -p`: each
arm's samples are a subagent given the task prompt, with the target rule's text
**prepended** for the treatment arm and absent for the control arm. This tests the
rule's *text effect* (does the rule, when in context, change output?) for **zero
metered agentic credit** — it does NOT test the foundation's headless *delivery*
of the rule (see the canary note in README).

### Opus 4.8 — N=3 per arm

| Task | Target rule(s) | control | treatment | Verdict |
|------|----------------|---------|-----------|---------|
| `no-any` | `typescript` (no `any`) | 3/3 | 3/3 | **REDUNDANT** |
| `substantive-tests` | `verification` + `tdd-enforcement` | 3/3 | 3/3 | **REDUNDANT** |
| `no-any-hard` (adversarial deep-merge, `any`-bait) | `typescript` | 3/3 | 3/3 | **REDUNDANT** |
| `kebab-filename` (agent chooses the filename) | `typescript` file-naming | 3/3 | 3/3 | **REDUNDANT** |

**Opus complied in 12/12 control samples — it never violated, with or without the
rule.** Even the adversarial `any`-bait task (recursive deep-merge of unknown
shapes) and the "arbitrary" convention (kebab-case filenames, freely chosen)
turned out to be Opus's defaults. For a frontier model these style/convention
rules are **redundant context cost**.

### Haiku 4.5 — same `no-any-hard` task, N=3 per arm

| Task | Target rule | control | treatment | deltaPct | Verdict (margin 0.34) |
|------|-------------|---------|-----------|----------|------------------------|
| `no-any-hard` | `typescript` (no `any`) | **2/3** | 3/3 | +33% | INERT (borderline) |

**Haiku DID violate** — one control sample reached for `any` (`(v: any)`,
`(x as any)[key]`) where every Opus sample wrote a proper recursive type. The rule
corrected it (treatment 3/3). The effect is **directional EFFECTIVE**, but at N=3
one sample = 0.333, so deltaPct 33 sits just under the default 0.34 margin and the
formal verdict reads INERT; at margin 0.30 it flips to EFFECTIVE. A concrete
instance of the small-N caveat — see "Method notes".

## 2026-10-05 — promotion eval: `positive-control` (blind-probe), `claude -p`

**Question.** Should the personal lesson "when a check answers nothing, make it find a
planted case first" be promoted into the foundation's rules? The candidate rule
(`tasks/blind-probe/CANDIDATE/`) is added to the treatment arm only; control = the
foundation as it ships. The project's own check answers "OK" through a glob that skips
`.tsx`, where both real call sites live. Compliance = the report says the helper is still
used and names both call sites.

**Isolation.** `claude -p` with `claudeMdExcludes: ["$HOME/.claude/**"]`, so the
operator's own lessons (which carry this very rule) reach neither arm — verified by a
two-arm canary (user lesson gone, project-rule codename kept). Delivery of the candidate
verified on Haiku (it quotes the rule's title).

| Model | control | treatment | Verdict |
|-------|---------|-----------|---------|
| Opus 5.5 | **5/5** | 5/5 | REDUNDANT |
| Haiku 4.5 | **0/5** | 0/5 | INERT (rule delivered, ignored) |

Opus cross-checks unprompted (`grep -rn legacyFetch src`) and names the blind glob.
Haiku writes `SAFE TO DELETE: yes` ten times out of ten, with the rule in context.

**Decision: not promoted.** As text, the rule changes neither model: redundant where the
model already doubts, inert where it does not. This matches why the lesson was graduated
in the first place — it kept recurring while loaded. If the failure is worth preventing,
it needs a mechanism at the moment of the empty answer, not more prose.
Caveats: N=5, one task, short isolated sessions (the operator's recurrences happened in
long ones); the run dirs sit inside the repo, so both arms also inherit its root
`CLAUDE.md` — identical across arms, so the comparison holds.

## Thesis (what these runs say)

> **These verdicts are Claude-specific — do not read "REDUNDANT" as "drop the rule".**
> The redundancy is a property of *Opus's training distribution*, not of the rule.
> A different LLM has different defaults: it may violate rules Opus never would, and
> the 4/4 REDUNDANT picture can **invert**. If the foundation will run on **another
> LLM** (the stated goal), the rules are **model-portability insurance** whose value
> is realized exactly when you switch models — so the deliverable is a **rule × model
> matrix**, re-run per target model, not a single global verdict. Run it with
> `GEN_CMD=<that model>` (see README) before trimming anything.

1. **Rule efficacy is model-dependent.** The foundation's style/convention rules
   largely encode *industry-standard best practices*. A frontier model (Opus 4.8),
   trained on that corpus, already embodies them → the rules are **REDUNDANT** for
   it. A weaker model (Haiku) violates more often → the same rule starts to **bite**.
   A non-Claude model (different training) is where the rules most likely **earn
   their keep** — and is untested here (the subagent `model:` override is Claude-only;
   use `GEN_CMD` to profile an external model).
2. **A "redundant" verdict is not "worthless".** The rule's value moves off
   behavioral-lift-on-a-strong-model onto: (a) weaker / non-Claude models, (b)
   human/team documentation & shared convention, (c) genuinely non-standard,
   project-specific conventions a model can't guess (none of the 4 tested were —
   even kebab-case was Opus's default).
3. **The honest capstone answer to "are the rules inert context?"** For Opus, on
   these rules: largely yes (redundant). That argues for justifying each rule's
   context cost by its human-doc / weaker-model value, not by assuming it steers a
   frontier model.

## Method notes / next

- **N matters.** A one-in-three effect (0.33) is unresolvable against a 0.34
  margin. To call EFFECTIVE vs INERT for a modest effect, use **N ≥ ~10 per arm**,
  or report rates + CI rather than a single threshold. The harness exposes
  `RULE_EVAL_MARGIN` / `RULE_EVAL_HIGH_BAR` for sensitivity.
- **Confirm Haiku EFFECTIVE** with more samples (the directional signal is clear).
- **Test non-standard conventions** (a rule whose choice a model can't guess) to
  find a clean EFFECTIVE on a strong model.
- **Headless delivery** (the canary) is still unmeasured — these runs force-inject
  the rule text, so they bound efficacy from above (best case the rule is delivered).
