# Agent DEV-MCP (pointer)

Guide for creating quality MCP (Model Context Protocol) servers.

## Context
$ARGUMENTS

## Delegate to the vendor toolkit

`claude-base`'s prior `dev-mcp` content is **superseded** by [`anthropics/skills` › `mcp-builder`](https://github.com/anthropics/skills/tree/main/skills/mcp-builder) — the **protocol authors' own** skill. It covers MCP server design (workflows-not-endpoints, tool annotations, input validation, actionable errors, evaluation) for both Python (FastMCP) and the Node/TS SDK, at a depth and currency a hand-maintained checklist cannot match; this command wrapped a protocol the vendor owns.

Install:

```bash
# Vendor path (verify on their README):
npx skills add anthropics/skills

# Fallback — clone the canonical repo:
git clone --depth 1 https://github.com/anthropics/skills ~/dev/vendor-skills/anthropic
ln -s ~/dev/vendor-skills/anthropic/skills/mcp-builder ./.claude/skills/mcp-builder
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Anthropic — `mcp-builder`". Reduction rationale: [`specs/graduation-supply-audit/spec.md`](../../../specs/graduation-supply-audit/spec.md).

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-api` | If creating a REST API in parallel |
| `/dev:dev-tdd` | MCP server tests |
| `/doc:doc-api-spec` | OpenAPI documentation of the target API |

---

YOU MUST validate all inputs (Pydantic/Zod) and return actionable errors; NEVER expose internal technical details in error messages.
