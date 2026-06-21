# Spec — Graduation supply audit (2026-06-21) + immediate graduations

> Status: ▶ In progress · 2026-06-21 · Owner: Chris
> Method: 9 parallel web-research sweeps over the full graduatable tool-wrapper surface,
> each applying the curation bar (authority=no★floor vs community ★≥500, ≤365d, not archived,
> advice-neutral, broad). Feeds: `specs/dev-command-vendor-graduation`, `curation-graduation-veille`.

## 1. Why

The graduation strategy was passive (watch + wait). This is a one-off **supply-side audit**:
for every foundation resource that wraps an external tool, does a credible vendor skill exist
*today*? It answers the session's original intent — **lighten the hardcoded skills** wherever a
vendor genuinely does it better — and corrects two doctrine errors surfaced along the way.

## 2. Readiness table (audit output)

| Resource | Verdict | Best vendor today | Action |
|---|---|---|---|
| **dev-mcp** | GRADUATE | `anthropics/skills` › `mcp-builder` (authority, Apache-2.0, neutral, broad) | **REDUCE** → pointer |
| **dev-ai-integration** | GRADUATE* | `anthropics/skills` › `claude-api` (authority, **bundled in Claude Code**) | **POINT** (see §3) |
| **dev-rag** | GRADUATE* | `langchain-ai/langchain-skills` › `langchain-rag` (authority, 810★) | **POINT** (framework-scoped) |
| dev-auth | KEEP (structural) | — (every vendor is single-provider lock-in) | permanent chooser (§3) |
| dev-api | KEEP (workflow) | — | methodology, permanent |
| dev-flutter | WATCH | `vp-k/flutter-craft` (10★, unlicensed) | watch |
| dev-i18n | WATCH | lingui (curated, single-lib); no broad neutral skill | watch |
| ops-k8s | WATCH (approaching) | `LukasNiessen/kubernetes-skill` (KubeShark, 239★, broad+neutral — covers helm+kustomize, **no bundle needed**) | watch → 500★ |
| ops-docker + ops-ci | WATCH (approaching) | `akin-ozer/cc-devops-skills` (236★, neutral, **covers both**) | watch → 500★ |
| dev-neovim (+ qa-neovim) | WATCH | `julianobarbosa/claude-code-skills` (83★) | watch |
| ops-proxmox | WATCH | `basher83/lunar-claude` (~21★) | watch |
| ops-opnsense | NO-SUPPLY | only MCP servers + an unstable TF provider | keep, low-priority watch |

Rot-check of the 7 already-graduated vendors: **6/7 HEALTHY**; `vercel-labs/agent-skills`
(dev-nextjs) = **DRIFT — no LICENSE file** (already flagged `no-license` in the registry).

## 3. Two doctrine refinements (both surfaced by the audit)

**(a) A neutral multi-vendor *chooser* layer is permanent — even though it is tool-ish.**
`dev-auth` (better-auth/Lucia/NextAuth/Clerk/Supabase/Auth0) and `dev-ai-integration`
(Anthropic/OpenAI/Google/Mistral/Cohere) arbitrate *between competing vendors*. No vendor can
own that neutrally (a Clerk skill won't recommend free self-hosted better-auth; a `claude-api`
skill won't tell you to use GPT). So graduating them fully = lock-in. They **POINT** to vendor
depth for a chosen stack while **keeping the neutral chooser**. This sits alongside
"workflow/discipline = permanent" as a second permanent category.

**(b) Concept-level wrappers had the *strongest* supply, not the weakest.** `dev-mcp` /
`dev-ai-integration` graduate to **authority** skills published by **Anthropic itself**
(`mcp-builder`, `claude-api`), and `dev-rag` to **LangChain's** own. The veille had *omitted*
these for "low keyword recall" — but they need no discovery at all: the target is known, so they
graduate directly. Lesson: a discovery-veille is for *unknown* supply; known-authority targets
graduate on sight.

## 4. Immediate graduations (this PR, commit 1)

- `dev-mcp` → **REDUCE** to a pointer-command (model: `dev-prisma`), → `mcp-builder`.
- `dev-ai-integration` → **POINT**: keep the neutral body, add `## See also` → bundled `claude-api`.
- `dev-rag` → **POINT**: keep the framework-neutral body, add `## See also` → `langchain-rag`.
- Registry: +3 authority records (pinned: `anthropics/skills`@`5754626…`, `langchain-skills`@`v0.1.0`).
- Recipe: +3 entries. All 3 are command-only (no skill/agent to touch).

## 5. Audit repercussion (this PR, commit 2)

- `awaiting-vendors.json`: drop `dev-auth` (permanent chooser, not awaiting); record each WATCH
  entry's current-best candidate + the bar it must cross; mark `ops-opnsense` no-supply; add
  `ops-docker`/`ops-ci` (approaching, one vendor covers both). Update the `_comment` doctrine.
- Doctrine note added to `specs/dev-command-vendor-graduation` + the project memory.

## 6. Out of scope

- Graduating the WATCH entries (no vendor cleared the bar yet — the veille will tag them).
- Re-pinning `vercel-labs` (license gap tracked, not blocking).
- Auto-mutation: every graduation here was human-reviewed off the audit; pins were fetched live.
