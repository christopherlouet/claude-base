# Marketplace audit pilot — `qa-*` skills (7 skills)

**Date**: 2026-05-06
**Status**: Pilot complete — verdict applied (selective `## See also` updates + recipe update)
**Scope**: Third domain audited under the methodology in `specs/marketplace-audit/spec.md`. Follows the `cli-tools` plugin pilot (PR #133) and the `dev-*` skills pilot (PR #141).

---

## Why this pilot

After the `dev-*` pilot showed strong vendor signal (6 of 17 skills had vendor alternatives), apply the same methodology to the QA domain. The hypothesis: QA tooling has its own ecosystem of vendors (Microsoft for Playwright, Google for Chrome DevTools / Lighthouse, OWASP for security) that may publish their own skills.

## Methodology applied

Same as PR #141 dev-* pilot:

1. For each `qa-*` skill, search for community alternatives (web search via biz-competitor subagent)
2. Prioritise tool-vendor or tool-author skills over solo community efforts
3. Verify existence and maintenance via direct `gh api repos/<owner>/<repo>` checks
4. Apply the vendor-neutrality filter (per `feedback_plugin_curation_vendor_neutrality` memory):
   - REJECT if owned by OpenAI / direct Anthropic competitor
   - **CASE-BY-CASE for Microsoft tools predating their OpenAI investment** (per memory rule)
5. Assign one verdict per skill: KEEP-OURS / POINT-TO-VENDOR / POINT-TO-COMMUNITY / GAP-OUTSCOPE-POINTER

## Findings — top-line numbers

- **1 KEEP-OURS** — qa-tech-debt
- **1 GAP-OUTSCOPE-POINTER** — qa-design (no canonical vendor skill)
- **5 POINT-TO-VENDOR/COMMUNITY** — qa-review, qa-perf, qa-chrome, qa-security, qa-e2e (with vendor-neutrality disclosure)

QA domain has the **strongest vendor signal of the three audits done so far**. The audit reveals a healthy ecosystem of QA tool vendors publishing their own skills. The hypothesis was correct.

## Per-skill verdicts

### qa-review → POINT-TO-VENDOR

**Source**: [`anthropics/claude-plugins-official` plugin `code-review`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review)

Verified: 18,629★, last commit 2026-05-06 (actively maintained by Anthropic). Multi-agent code-review plugin with confidence scoring (default 80%). Same intent as our `qa-review` but in plugin format vs our SKILL.md format.

**Vendor-neutrality**: Anthropic — by definition the home ecosystem. Zero concern.

**Action**: Add `## See also` to `qa-review/SKILL.md`.

### qa-perf → POINT-TO-VENDOR

**Source**: [`addyosmani/web-quality-skills`](https://github.com/addyosmani/web-quality-skills)

Verified: 1,862★, last commit 2026-05-03. Maintained by Addy Osmani (Chrome DevTools / Lighthouse engineering lead at Google for 14 years). Covers Core Web Vitals (LCP, INP, CLS), perf, a11y, SEO.

**Vendor-neutrality**: Personal repo, not Google-org-owned. Author has Google affiliation but the project is independent. Google has competitive AI products (Gemini) but this skill is web-tooling, not AI. Acceptable.

**Action**: Add `## See also` to `qa-perf/SKILL.md`.

### qa-chrome → POINT-TO-VENDOR

**Source**: [`ChromeDevTools/chrome-devtools-mcp`](https://github.com/ChromeDevTools/chrome-devtools-mcp)

Verified: 38,221★, last commit 2026-05-05. Official Google Chrome DevTools team repo. Apache-2.0.

**Format note**: This is an MCP server, NOT a SKILL.md. Pointing to it as a `## See also` is appropriate — it's complementary tooling, not a duplicate skill.

**Vendor-neutrality**: Google. Same consideration as `qa-perf` (Google has Gemini but Chrome DevTools is web-tooling, neutral).

**Action**: Add `## See also` to `qa-chrome/SKILL.md` with format caveat.

### qa-security → POINT-TO-COMMUNITY

**Source**: [`agamm/claude-code-owasp`](https://github.com/agamm/claude-code-owasp)

Verified: 171★, last commit 2026-04-28. Covers OWASP Top 10:2025, ASVS 5.0, 20 language quirks. Independent author.

**Adoption signal**: 171 stars is below the typical "≥3 real-product repos" bar of confidence, but the OWASP framework is itself authoritative content (the value is in pointing to a faithful implementation of the standard, not in popularity). Includes Semgrep's official plugin as a complementary tool integration.

**Vendor-neutrality**: Independent for agamm. Semgrep is an independent security company.

**Action**: Add `## See also` to `qa-security/SKILL.md` mentioning both.

### qa-e2e → POINT-TO-VENDOR (with disclosure)

**Source**: [`microsoft/playwright-cli`](https://github.com/microsoft/playwright-cli/tree/main/skills/playwright-cli)

Verified: 9,978★, last commit 2026-05-04. Microsoft's official Playwright skill.

**Vendor-neutrality decision (CASE-BY-CASE)**: Per memory `feedback_plugin_curation_vendor_neutrality`: *"Microsoft-owned tools predating their OpenAI investment (e.g. VSCode, GitHub) are debatable — flag for case-by-case review rather than auto-reject."*

Decision rationale (locked 2026-05-06):
- Playwright was created in 2020, predates Microsoft's deepening OpenAI commercial relationship
- MIT-licensed, governance independent of any AI product roadmap
- De-facto standard for E2E testing (Playwright core repo has 78,000★)
- Authoritative skill comes from the project's own maintainers
- The community alternative `lackeyjb/playwright-skill` (2,570★) exists but its last commit is 2025-12-19 — almost 5 months stale at audit time, with API drift risk

**Decision**: Point to `microsoft/playwright-cli` (option A in the case-by-case framing). Do NOT also point to the stale community alternative — the staleness risk outweighs the vendor-neutrality benefit.

**Re-evaluation triggers** specific to this skill:
- If Microsoft's commercial alignment with OpenAI deepens to direct integration of OpenAI products into the Playwright roadmap, revisit
- If the playwright-cli repo's maintenance signal weakens (no commits for 3+ months), revisit
- If a vendor-neutral fork gains adoption (3+ real-product repos), revisit

**Action**: Add `## See also` to `qa-e2e/SKILL.md` with the explicit disclosure that the recommendation rests on Microsoft+Playwright+OpenAI's specific historical timeline.

### qa-design → GAP-OUTSCOPE-POINTER

**Source**: None at the bar. Figma has Claude integrations (`claude.com/plugins/figma`) but those are code-gen workflows, not design audits.

**Adjacent**: Figma's MCP for design-to-code is complementary tooling, not a duplicate of our `qa-design` skill (which audits existing UI/UX).

**Action**: Note in SKILL.md that no canonical vendor skill exists for design-audit at this time. Mention Figma plugin as adjacent for design-to-code flows. Re-evaluate quarterly.

### qa-tech-debt → KEEP-OURS

**Sources evaluated**:
- `ksimback/tech-debt-skill` — single-author, 9 debt dimensions, no verifiable multi-product adoption
- `fastruby/tech-debt-skill` — Ruby/Rails-specific

**Verdict**: Neither clears the bar. Our `qa-tech-debt` skill is framework-agnostic and stays as the primary reference. Re-evaluate when a vendor / well-adopted community skill ships.

## Vendor-neutrality summary

| Skill | Vendor | Acceptable? | Reason |
|-------|--------|------------|--------|
| qa-review | Anthropic | ✓ unconditional | Home ecosystem |
| qa-perf | Addy Osmani (personal) | ✓ unconditional | Personal repo, web-tooling, not AI |
| qa-chrome | Google Chrome DevTools | ✓ conditional | Google has AI products but this skill is web-tooling, neutral |
| qa-security | agamm + Semgrep | ✓ unconditional | Both independent |
| qa-e2e | **Microsoft (Playwright)** | ✓ **case-by-case** | Predates OpenAI deepening, MIT, de-facto standard |
| qa-design | n/a | n/a | No vendor source |
| qa-tech-debt | n/a | n/a | No vendor source at the bar |

If Microsoft's commercial alignment with OpenAI further deepens (e.g. direct OpenAI product integration into Playwright), the qa-e2e pointer must be revisited.

## Outcome

Documentation-only updates:

1. Add `## See also` to 5 SKILL.md files: `qa-review`, `qa-perf`, `qa-chrome`, `qa-security`, `qa-e2e`
2. Update `docs/recipes/recommended-vendor-skills.md` with the new vendor entries (5 added)
3. No skill deletions, no counter changes
4. CHANGELOG `[Unreleased]` documents the pilot

Our skills remain in place. They cover the framework-agnostic / opinionated workflow angle that complements vendor-specific guidance.

## Honest limits

1. **Real-product adoption count not verified**. Same limitation as the dev-* pilot: web search alone cannot count `gh search code` results for SKILL.md adoption in real-product repos. Inferred from author credibility + maintenance signal.
2. **`agamm/claude-code-owasp` adoption is thin** (171★). If the user wants strict ≥3-real-product-repos verification, this verdict would downgrade to GAP-OUTSCOPE-POINTER.
3. **`ChromeDevTools/chrome-devtools-mcp` is not a SKILL.md** but an MCP server. The `## See also` pointer should clarify the format mismatch.
4. **Playwright/Microsoft case-by-case** — re-evaluation triggers documented above.

## Methodology lessons

After 3 pilots (cli-tools, dev-*, qa-*):

| Domain | KEEP-OURS | POINT-TO-VENDOR | POINT-TO-COMMUNITY | GAP | Notes |
|--------|-----------|-----------------|---------------------|-----|-------|
| cli-tools (4 candidates eval'd) | n/a (plugin-format audit) | 0 | 0 | n/a | All 4 rejected — 3 technical, 1 positioning (Astral) |
| dev-* (17 skills) | 9 | 6 | 0 | 2 | Strong vendor signal in 2026 |
| qa-* (7 skills) | 1 | 4 | 1 | 1 | Strongest vendor signal so far |

**Trend**: tool-vendor adoption of the SKILL.md format is accelerating in 2026. The methodology continues to produce defensible signal. Worth running on remaining domains (`ops-*` 9 skills + `growth-*` 1 skill + others) when bandwidth allows.
