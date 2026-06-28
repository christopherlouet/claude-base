# QA-LOOP Agent

Autonomous loop AUDIT (parallel) → VALIDATE → FIX → VERIFY → CHECK with stopping criteria.

Aligned with the Anthropic 2026 pattern (official `code-review` plugin):
- AUDIT phase in parallel (4 sub-agents: qa-security, qa-perf, wcag-audit, qa-claudemd)
- VALIDATE phase filters out false positives (1 sub-agent per finding)
- High-signal filter: excludes nitpicks/style
- Auto-scope `git diff main...HEAD` by default

## Context
$ARGUMENTS

## Goal

Run a continuous quality improvement loop: audit the project in parallel,
validate findings (false-positive filter), fix high-signal P0/P1 issues,
verify tests, and repeat until the target score is reached.

## Parameters (extract from $ARGUMENTS)

- **Target score**: minimum score to stop (default: 90/100)
- **Max iterations**: maximum number of cycles (default: 5)
- **Domains**: security, perf, a11y, claudemd (default: all)
- **Severity**: P0+P1 (default), or P0 only
- **Scope**: `git diff main...HEAD` by default, or explicit path/glob/`--full`

## Flags

| Flag | Effect |
|------|--------|
| `--audit-only` | Audit + report, **no FIX** (read-only mode, equivalent to the Anthropic plugin) |
| `--comment` | Post inline on the current PR via `gh pr comment` (requires gh + open PR) |

## Workflow

```
AUDIT (4 parallel sub-agents) → VALIDATE (false-positive filter)
  → FILTER (high-signal P0/P1 only) → FIX (unless --audit-only)
  → VERIFY (tests) → CHECK (criteria) → LOOP or STOP
```

1. **AUDIT**: 4 Task sub-agents in parallel (qa-security/qa-perf/wcag-audit/qa-claudemd)
2. **VALIDATE**: 1 sub-agent per finding to confirm or reject
3. **FILTER**: excludes nitpicks/style, keeps only high-signal P0/P1
4. **FIX**: fix P0 then P1 with TDD, atomic commits (skipped if `--audit-only`)
5. **VERIFY**: full tests, lint, type-check, **+ re-run qa-security on the fixed files** (a fix can introduce a vuln that tests miss) — revert on regression
6. **CHECK**: score >= target AND 0 P0/P1 AND the post-fix security re-scan is clean → STOP, otherwise → AUDIT

## Expected output

1. **Per iteration**: scores table per domain, raw vs confirmed findings, applied fixes
2. **Final report**: initial → final score, total fixes, false positives filtered out, remaining issues
3. **Commits**: one per fix, format `fix(domain): description`
4. **(`--comment`)**: inline comments posted on the PR

## Related sub-agents (dispatched by AUDIT)

| Sub-agent | Model | Focus |
|-----------|-------|-------|
| `qa-security` | Opus | OWASP Top 10, secrets, injections |
| `qa-perf` | Sonnet | N+1, bundle, Core Web Vitals |
| `wcag-audit` | Sonnet | WCAG 2.1 AA |
| `qa-claudemd` | Sonnet | CLAUDE.md compliance + repo conventions |

## Related agents (orchestration)

| Agent | Usage |
|-------|-------|
| `/qa:qa-audit` | Initial full audit (single-agent alternative) |
| `/qa:qa-security` | In-depth security audit (outside the loop) |
| `/qa:qa-perf` | In-depth performance audit (outside the loop) |
| `/qa:wcag-audit` | In-depth accessibility audit (outside the loop) |
| `/dev:dev-tdd` | TDD cycle for fixes |

## Usage examples

```
/qa:qa-loop                              # Default: score 90, max 5 iterations, diff scope
/qa:qa-loop "score 95"                   # Target score 95/100
/qa:qa-loop "security+perf, max 3"       # 2 domains, 3 iterations max
/qa:qa-loop "P0 only"                    # Fix critical issues only
/qa:qa-loop --audit-only                 # Audit + report, no fix
/qa:qa-loop --audit-only --comment       # Faithful replica of the Anthropic code-review plugin
/qa:qa-loop --full                       # Audit the entire repo (ignore the diff)
```

---

IMPORTANT: AUDIT phase launches the 4 Task sub-agents **in parallel in a single message**.

IMPORTANT: VALIDATE phase is mandatory — no fix without prior validation.

IMPORTANT: Strict high-signal filter — a finding without measurable impact does not appear in the report.

IMPORTANT: Auto-scope `git diff main...HEAD` by default, never audit the entire repo without explicit request.

IMPORTANT: Clearly separate the AUDIT phase (read) from the FIX phase (write).

IMPORTANT: In `--audit-only` mode, NEVER modify the code.

IMPORTANT: Stop immediately if a fix introduces a regression.

YOU MUST produce a report with scores at every iteration.

NEVER exceed the maximum number of iterations.

NEVER fix P2/P3 — they no longer even appear in the report (high-signal filter).

Think hard about the optimal order of fixes to maximize impact and minimize regression risk.
