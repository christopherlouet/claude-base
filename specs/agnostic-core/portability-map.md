# Portability Map — scripts/hooks/ classification

> P3 record (US-5). Drift-guarded by `tests/policy-structure.bats`: every
> `scripts/hooks/*.sh` must appear in the table below.

Classification values:
- **core** — pure policy lib, no harness plumbing, directly tested.
- **shell+core** — thin Claude Code shell over an extracted core.
- **shell-env** — thin shell whose remaining body is machine/environment work (stack detection, git state), not policy.
- **assistant-only** — Claude-Code-specific by nature (output-rewriter envelope, CLI probing, self-integrity, install plumbing); not extracted, keeps working as-is.

| File | Classification | Core / notes |
|------|----------------|--------------|
| `_core-helpers.sh` | core | `strip_msg_values` (single canonical copy) |
| `_policy-dangerous-commands.sh` | core | `validate_command` — 9 categories |
| `_policy-secrets.sh` | core | patterns + placeholder allowlist + gitleaks helper |
| `_policy-destructive-sql.sh` | core | command + migration variants (2 shells, 1 core) |
| `_policy-write-targets.sh` | core | write-target extraction |
| `_policy-triggers.sh` | core | commit/push/deploy trigger detection |
| `_sensitive-paths.sh` | core | pre-existing: protected-config / secret-file classifiers |
| `_vendor-precedence-hint.sh` | core | pre-existing: pure-shell vendor-skill detection |
| `_hook-helpers.sh` | assistant-only | rewriter sentinel/envelope helpers; re-exports the core strip for compat |
| `command-validator.sh` | shell+core | fail-closed on missing core |
| `secret-scan.sh` | shell+core | fail-open on missing core (missing-jq philosophy) |
| `destructive-ops.sh` | shell+core | fail-closed on missing core |
| `destructive-migration.sh` | shell+core | fail-open on missing core |
| `bash-write-guard.sh` | shell+core | env checks (existence/branch/tracked) stay in shell |
| `pre-commit-tests.sh` | shell-env | trigger from core; body = run the stack's tests |
| `pre-push-ci.sh` | shell-env | trigger from core; body = run the stack's local CI |
| `pre-deploy-build.sh` | shell-env | trigger from core; body = run the prod build |
| `main-branch-guard.sh` | shell-env | git-state guard (branch creation); no pattern tables |
| `config-protection.sh` | shell+core | policy already lives in `_sensitive-paths.sh` |
| `prompt-context.sh` | assistant-only | context injection via the harness envelope; candidate for a later slice |
| `post-edit-typecheck-and-lint.sh` | assistant-only | output-rewriter envelope (CLI 2.1.121+) |
| `bash-output-filter.sh` | assistant-only | output-rewriter envelope |
| `check-cli-version.sh` | assistant-only | probes the `claude` binary, writes the rewriter sentinel |
| `base-integrity-check.sh` | assistant-only | foundation self-integrity (counters) |
| `substance-check.sh` | assistant-only | wrapper around `scripts/substance-check.sh` via the harness envelope |
| `setup-deps.sh` | assistant-only | install plumbing (`core.hooksPath`, deps) |

Content categories (context for a future emitter; measured 2026-07-17):
- **skills (53)** — SKILL.md open standard, near drop-in; ~10 carry slash-command cross-refs.
- **agents (44)** — clean bodies (0 slash refs); frontmatter fields are harness-specific (mapping work).
- **rules (32)** — 4 global (~14 KiB, fits a 32 KiB entry-file budget), 28 path-scoped (glob activation has no native equivalent elsewhere).
- **commands (106)** — hardest: 432 internal slash cross-refs; other harnesses converge on skills instead.
- **CLAUDE.md** — ~60% harness-specific; conventions/secrets/anti-patterns sections port cleanly.
