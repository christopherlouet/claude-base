# Process-occurrence — does the audit step happen at all?

The other harnesses measured `P(good output | discipline applied)` and found it ≈
equal on Opus. That is the **wrong conditional** for claude-base's value. A casual
user never *asks* for an audit, so the question is `P(a defect ships | the user
didn't mention security)` — and whether claude-base's default flow (which *runs*
an audit) closes that gap a casual native session leaves open.

## Method

`cases/<name>/` is a **casual** feature request (`PROMPT.md`) where security is an
unmentioned side-concern, plus a hidden oracle (`VULN.md`) defining the classic
vuln that a careless implementation introduces. Two arms, 2 samples each:

| Arm | Prompt | Models |
|-----|--------|--------|
| **native** | "implement X" (one-off snippet, no checklist) | a casual `claude` ask |
| **base** | "implement X, then to a professional definition-of-done review for OWASP issues and fix them" | claude-base's flow incl. its audit phase |

A judge classifies each output against `VULN.md` → `VERDICT` (VULNERABLE | SAFE).
`score-occurrence.sh` reports the **ship-rate** per arm. The gap = defects a casual
native user ships that claude-base's audit step catches.

## Result (Opus, 4 cases × 2 samples, 2026-06-28)

| Arm | ship-rate |
|-----|-----------|
| native (casual) | **1/8 (12%)** |
| base (flow incl. audit) | **0/8 (0%)** |

Cases: path-traversal, SQL injection, XSS, weak password hashing. The single
native slip: a casual `/hello` route interpolated `?name=` straight into HTML — a
**reflected XSS**. The base arm's audit caught it; the other 7 native samples
spontaneously parameterized queries, used bcrypt/scrypt, and sanitized paths.

## Honest read

The reframe was methodologically right but the **Opus answer is still a small gap**:
casual native Opus self-secures ~88% unprompted. claude-base's value here is the
**residual catch** — real and concrete (a shipped XSS caught), but rare on Opus.
The gap is expected to widen on **weaker models** (which slip far more often when
not prompted) — the multi-LLM column. The deterministic **gates** (`../LEDGER.md`,
and the `gate-demo` matrix) remain the strongest, model-independent value.

This is the 5th consistent measurement: on Opus the foundation's behavioral edge
is small; its defensible value is gates + consistency + weaker-model insurance, not
"better code". One honest, citable instance of the audit earning its keep, though.
