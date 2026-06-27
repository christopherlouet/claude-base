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

## Thesis (what these runs say)

1. **Rule efficacy is model-dependent.** The foundation's style/convention rules
   largely encode *industry-standard best practices*. A frontier model (Opus 4.8),
   trained on that corpus, already embodies them → the rules are **REDUNDANT** for
   it. A weaker model (Haiku) violates more often → the same rule starts to **bite**.
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
