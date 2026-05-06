# Marketplace audit pilot — `ops-*` skills (10 skills)

**Date**: 2026-05-06
**Status**: Pilot complete — verdict applied (3 SKILL.md updated, 7 KEEP-OURS)
**Scope**: Fourth domain audited under `specs/marketplace-audit/spec.md`. Follows cli-tools (PR #133), dev-* (PR #141), qa-* (PR #144).

## Scope

10 ops-* skills:
1. ops-ci, 2. ops-ci-fix, 3. ops-database, 4. ops-docker, 5. ops-infra-code,
6. ops-mobile-release, 7. ops-monitoring, 8. ops-opnsense, 9. ops-proxmox, 10. ops-standup

## Findings

| Skill | Verdict | Source / reason |
|-------|---------|-----------------|
| ops-database | **POINT-TO-VENDOR** | `mongodb/agent-skills` (102★, official MongoDB) + Supabase Postgres best practices already pointed from dev-supabase |
| ops-infra-code | **POINT-TO-COMMUNITY + VENDOR** | `antonbabenko/terraform-skill` (1,797★, the de-facto Terraform skill) + `pulumi/agent-skills` (44★, official Pulumi) |
| ops-monitoring | **POINT-TO-VENDOR** | `grafana/skills` (31★, official Grafana Labs, LGTM stack) |
| ops-mobile-release | KEEP-OURS (HOLD) | `greenstevester/fastlane-skill` (18★, last commit 2026-01-02 = 4 months stale, Android still incomplete). Re-evaluate when parity ships. |
| ops-ci | KEEP-OURS | `ahmedasmar/devops-claude-skills` (141★) is broader on DevSecOps but our skill tightly integrates with `ops-ci-fix` and `ops-deploy`. Margin too thin to justify pointer. |
| ops-docker | KEEP-OURS | Docker Inc. has no official skill. Community skills skew opinionated bundles (FastAPI+Next+Postgres). Our minimal stack-neutral patterns outperform for the typical user. |
| ops-proxmox | KEEP-OURS | `danielrosehill/Proxmox-Mgmt-Plugin` (0★) and `eddygk/proxmox-ops` (4★) are too thin and SSH-operational rather than IaC-focused like ours. |
| ops-opnsense | KEEP-OURS | No vendor or meaningful community skill. Homelab niche. |
| ops-ci-fix | KEEP-OURS | Workflow-specific (autonomous diagnosis-and-repair loop tied to `gh` CLI + foundation PR workflow). No marketplace equivalent. |
| ops-standup | KEEP-OURS | Workflow-specific (cross-repo morning briefing). No vendor interest in publishing this. |

**3 vendor pointers added, 7 KEEP-OURS, 0 GAP.** The ops-* domain marketplace is thinner than qa-* but the vendor-published sources (MongoDB, Grafana, Pulumi, antonbabenko/terraform-skill) are solid.

## Vendor-neutrality assessment

| Skill | Vendor | Verdict | Reason |
|-------|--------|---------|--------|
| ops-database | MongoDB Inc., Supabase | ACCEPT | Both independent |
| ops-infra-code | Anton Babenko (independent), Pulumi (independent) | ACCEPT | Community-authored Terraform skill; Pulumi independent. HashiCorp acquired by IBM (2025) but the skill author is independent and IBM is not a direct Anthropic/OpenAI competitor. |
| ops-monitoring | Grafana Labs | ACCEPT | Independent |

No CASE-BY-CASE vendor-neutrality decisions in this audit (unlike qa-e2e Playwright/Microsoft).

## Methodology lessons after 4 audits

Cumulative results :

| Domain | Skills evaluated | KEEP-OURS | POINT-TO-VENDOR/COMMUNITY | GAP |
|--------|------------------|-----------|---------------------------|-----|
| cli-tools (plugins) | 4 | n/a | 0 (all 4 rejected) | n/a |
| dev-* | 17 | 9 | 6 | 2 |
| qa-* | 7 | 1 | 5 | 1 |
| ops-* | 10 | 7 | 3 | 0 |
| **Total** | **38** | **17** | **14** | **3** |

Patterns observed:
- **Vendor-published skills accelerate in 2026** — Supabase, Prisma, Apollo, Vercel, Anthropic, Grafana, MongoDB, Pulumi, Astral, Microsoft (Playwright) all ship now
- **Workflow-specific skills (ops-ci-fix, ops-standup, ops-opnsense, ops-proxmox) have no marketplace equivalent** — these are claude-base's irreducible value
- **Niche homelab skills** (Proxmox, OPNsense) have minimal community alternatives — long-tail value confirmed
- **The case-by-case Microsoft/Google framing is rare** — only triggered on Playwright; most vendors are clearly neutral or clearly disqualified

## Outcome

Documentation-only updates (no code, no skill deletions, no counter changes):

- 3 SKILL.md gain `## See also`: `ops-infra-code`, `ops-monitoring`, `ops-database`
- `docs/recipes/recommended-vendor-skills.md` extended with the 4 new vendor entries (MongoDB, Grafana, antonbabenko/terraform-skill, Pulumi). Recipe "Last verified" stays 2026-05-06.
- CHANGELOG `[Unreleased]` documents the pilot.

## Honest limits

1. **Adoption signals not verified via gh search code**. Same constraint as previous audits.
2. **Fastlane skill held**: `greenstevester/fastlane-skill` (18★) is too small + 4 months stale + Android incomplete. Decision to hold rather than recommend, with explicit re-evaluation criteria documented.
3. **`ahmedasmar/devops-claude-skills` for ops-ci**: 141★, broader DevSecOps coverage. Margin debatable. Decision: KEEP-OURS but mention available as enhancement option in the pilot trace.

## Re-evaluation criteria

- Quarterly: re-check the 3 source repos (last commit, ownership, vendor-neutrality)
- Specific re-trigger if Fastlane skill ships Android parity (POINT-TO-COMMUNITY)
- Specific re-trigger if HashiCorp's roadmap diverges meaningfully under IBM (extremely low probability today)
- Re-check after the next major Claude Code marketplace expansion (e.g. official Anthropic ops plugins beyond what we found)
