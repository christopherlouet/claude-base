# Findings — audit-detection (security)

Run: 2026-06-28, in-session subagents, 1 sample per arm, 2 cases. Recall read off
each arm's report against `GROUND_TRUTH.md` (unambiguous — the arms tie at
ceiling). Indicative.

## Round 1 — `security-node-api` (textbook vulns, 75-line file)

Planted: 7 (SQLi, XSS, path traversal, command injection, weak MD5, hardcoded
secret, broken access control). Decoys: 2 (parameterized `LIKE` query, cache-buster
`Math.random()`).

| Arm | Recall | Decoys flagged (FP) |
|-----|--------|---------------------|
| A — generic "list problems" | **7/7** | 0 |
| B — OWASP checklist | **7/7** | 0 |
| C — `qa-security` agent | **7/7** | 0 |

No detection gain — obvious vulns, native Opus catches them all. Case has no
headroom (calibration too easy).

## Round 2 — `security-auth-hard` (subtle vulns buried in hardened code)

The file is mostly correct (helmet, rate limiting, bcrypt, parameterized queries,
auth middleware). Planted: 6 **subtle** — JWT algorithm not pinned (H1), IDOR via
`req.query.accountId` (H2), non-constant-time API-key compare (H3), open redirect
(H4), SSRF (H5), ReDoS regex (H6). Decoys: 3 (correct bcrypt, parameterized
queries, present rate-limit/helmet).

| Arm | Recall | Decoys flagged (FP) | Notes |
|-----|--------|---------------------|-------|
| A — generic "list problems" | **6/6** | 0 | also found extras (user-enum timing, plaintext reset tokens, no reset rate-limit) |
| B — OWASP checklist | **6/6** | 0 | most *precise* — correctly noted H1 isn't classically exploitable with a symmetric secret |
| C — `qa-security` agent | **6/6** | 0 | most *structured* — severity, OWASP mapping, "no-finding" categories, remediation, priorities |

Still no recall gain. Even subtle classes (ReDoS, timing side-channel, JWT alg
pinning, SSRF behind an admin gate) are caught by **all three** arms, including the
casual one-liner prompt.

## The meta-finding (consistent across every measurement so far)

On **single-artifact / single-shot** work — whether *building* (the tier eval) or
*auditing* (here) — **Opus is at ceiling, and the foundation's model-behavioral
value over native Opus is ~zero.** This is the same result as the rule-efficacy
eval (rules REDUNDANT on Opus) and the value-proof content net (0% extra on
neutral tiers), now confirmed on security detection: a generic prompt already
finds the buried ReDoS and the timing attack.

What *does* differ between arms is **structure and consistency**, not detection:
arm C always runs the full OWASP pass with severity, remediation and a precision
note, the same way every time; arms A/B depend on how the user prompts and how
lucky the framing is. That is real value for a PR workflow — reproducible,
exhaustive, low-variance audits — but it is **not** "catches vulns Opus would
miss", and it should not be sold as such.

### Where an audit gain could still be real (and why it's not cheap)

The gain, if it exists, lives in the regime that **exceeds a single focused pass**:

- **Cross-file taint flows** — a source in module X reaching a sink in module Y,
  invisible to a one-file review. A tools-using agent that greps sinks
  systematically (qa-security has Bash/Grep) could beat a naive read; a single
  capable pass cannot see it.
- **Codebase-scale signal-to-noise** — one subtle bug in thousands of lines across
  many files, where methodical coverage beats eyeballing.
- **A weaker model** — the same harness via `GEN_CMD`/agent swap should show the
  detection gain the foundation's methodology buys when the base model isn't Opus.

All three are heavier than this single-file probe. The honest conclusion: **the
cheap, single-shot regimes ceiling on Opus — do not chase an Opus complexity-gain
there.** Put the proof effort where the value is real and measurable: the
deterministic gates (`../LEDGER.md`), the structure/consistency claim (qualitative),
and the **multi-LLM column** (where these harnesses are expected to finally show a
gain).
