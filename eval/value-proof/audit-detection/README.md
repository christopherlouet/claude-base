# Audit-detection — does the foundation's audit layer catch more than native?

A sibling of the value-proof harness aimed at the **audit domains** (security
first; accessibility / perf are the same shape). The question: do the foundation's
audit agents (`qa-security`, `wcag-audit`, `qa-perf`) detect real defects that a
**native** Claude review would miss?

Unlike the build-task harness, the ground truth here is **exact**: we *plant* the
defects, so detection is a clean recall/precision measurement, not a judgement
call.

## Method — recall over planted defects, 3 arms

Each `cases/<name>/` ships a code file with **planted** defects and a
`GROUND_TRUTH.md` oracle (the defect list + benign **decoys** that must NOT be
flagged). Each defect class is reviewed by three arms:

| Arm | What it is | The native baseline it represents |
|-----|-----------|-----------------------------------|
| **A** | general agent, "review this and list problems" | a casual user's one-liner |
| **B** | general agent, "thorough OWASP review, be precise" | a careful user who prompts well |
| **C** | the foundation's `qa-security` agent (its real system prompt) | what claude-base gives you automatically |

- **Recall** = planted defects detected ÷ planted total (the signal).
- **Precision** = decoys correctly left unflagged (the false-positive guard).
- **Gain `C − B`** is the honest marginal claim: does the specialized agent beat a
  *well-prompted* native Claude? `C − A` is the gain over a casual prompt.

### Calibration gate (the lesson from the build tier)

If arm A already detects everything, the case has no headroom and can't reveal a
gain — re-harden the case before reading anything into a tie. This is exactly what
happened (see FINDINGS): on single-file cases Opus ceilings at ~100% recall on
**all** arms, easy *and* subtle. The gain, if any, needs a regime that exceeds a
single focused pass — cross-file taint flows, codebase-scale signal-to-noise — or
a weaker model (the multi-LLM column).

## Layout

```
cases/<name>/
  <code>.js        — the seeded file with planted defects
  GROUND_TRUTH.md  — the oracle: planted defects + benign decoys
runs/              — captured arm reports (gitignored)
FINDINGS.md        — recall/precision per arm, per case, + the meta-finding
```

Generation/scoring is currently orchestrated by hand (subagents per arm, recall
read off the reports against GROUND_TRUTH — unambiguous when arms tie at ceiling).
A judge-subagent + tally scorer is the formalization once cases stop ceiling.
