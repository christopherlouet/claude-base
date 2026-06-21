# DEV-SUPABASE Agent (pointer)

Configure and use Supabase as a backend (Auth, Database, Storage, Realtime, Edge Functions).

## Context
$ARGUMENTS

## Delegate to the vendor toolkit

`claude-base`'s prior `dev-supabase` content (48-line checklist) is **superseded** by [`supabase/agent-skills`](https://github.com/supabase/agent-skills) — Supabase's own toolkit, maintained by the Supabase team in sync with the current API (Auth, DB, Edge Functions, Realtime, Storage), goes deeper than a hand-maintained checklist on a backend the vendor owns. The repo ships two skills (client patterns + Postgres best-practices). The sibling `dev-supabase` **skill** already graduated to this pointer.

Install:

```bash
# Vendor publishes via marketplace (verify on their README):
claude plugin install supabase@supabase

# Fallback — clone and symlink both skills:
git clone --depth 1 https://github.com/supabase/agent-skills ~/dev/vendor-skills/supabase
ln -s ~/dev/vendor-skills/supabase/skills/supabase ./.claude/skills/supabase
ln -s ~/dev/vendor-skills/supabase/skills/supabase-postgres-best-practices \
      ./.claude/skills/supabase-postgres-best-practices
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Supabase — `supabase/agent-skills`". Reduction rationale: [`specs/dev-command-vendor-graduation/spec.md`](../../../specs/dev-command-vendor-graduation/spec.md).

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-api` | GraphQL/REST alternative/complement |
| `/dev:dev-flutter` | Flutter widgets and screens (if mobile) |
| `/ops:ops-database` | Schema design |
| `/qa:qa-security` | RLS security audit |

---

YOU MUST enable RLS on every table with appropriate policies; NEVER expose the `service_role` key in client-side code or disable RLS in production.
