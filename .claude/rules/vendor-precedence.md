# Vendor Precedence Rules

When a project has opted into both the foundation and one or more recommended **vendor skills** (see `docs/recipes/recommended-vendor-skills.md`), the two coexist in the same session and their guidance can collide. This rule resolves those conflicts so the user never gets contradictory advice. It is **global** (always applies); it governs *advice precedence*, not file activation.

## Foundation vs vendor — precedence ladder

Apply the **highest** matching tier; a lower tier never overrides a higher one.

| Tier | Domain | Winner | Why |
|------|--------|--------|-----|
| 1 | **Security & safety** — `security`, `deploy-safety`, secrets handling, the curation safety screen | **Foundation, always** | A vendor skill must never relax a security/safety guardrail. Popularity ≠ safety. If a vendor's snippet skips input validation, escaping, or a deploy check, the foundation rule wins. |
| 2 | **Workflow discipline** — `workflow`, `tdd-enforcement`, `verification` (Explore → Specify → Plan → TDD → Audit) | **Foundation** | Vendor "quick start / just ship it" shortcuts do not waive tests-first, the audit loop, or read-before-write. Use the vendor's *content* inside the foundation's *process*. |
| 3 | **Tool-specific API / stack patterns** — idiomatic usage of the tool the vendor authored (Prisma queries, Supabase auth, Next.js caching, Playwright selectors, …) | **Vendor** | This is exactly why the foundation *points* at the vendor instead of bundling depth: the vendor is more current and authoritative on its own tool. Prefer the vendor's API guidance over a stale foundation example. |
| 4 | **Everything else** (style, naming, structure) | **Foundation** | Keep the codebase consistent with the foundation conventions unless tier 3 dictates otherwise. |

Rule of thumb: **the foundation owns the _how-we-work_ (security, TDD, audit, conventions); the vendor owns the _how-this-tool-works_.** When in doubt, security and safety always win.

## Vendor vs vendor

When two recommended vendor skills could both apply:

1. **Condition-scoping first.** Each recommendation carries a `condition` (e.g. `"if using Supabase"`); only the skill whose condition matches the project's actual stack applies. Most overlaps dissolve here.
2. **Registry / rationale.** If both still apply, the curation records (`.claude/curation/registry.json` and each preset's `recommendedVendorSkills[].rationale`) state which is preferred for which need — follow that.
3. **Authority over community.** Absent a recorded preference, prefer the **canonical-vendor** skill (the tool maker's own, `trustTrack: authority`) over a third-party/community one (`trustTrack: community`) for that tool.
4. **Advice-neutrality tiebreak.** Never let a vendor skill steer the user toward proprietary lock-in or off their chosen stack/Claude; the more neutral guidance wins (see `docs/recipes/recommended-vendor-skills.md`).

## Anti-patterns

- Letting a vendor quick-start skip the TDD or audit phase.
- Adopting a vendor security shortcut (unvalidated input, `dangerouslySetInnerHTML`, disabled CSRF) because "the vendor docs do it that way".
- Following a stale foundation example over the vendor's current API when the two disagree on tool-specific usage.
- Applying two overlapping vendor skills at once instead of condition-scoping to the one matching the stack.
