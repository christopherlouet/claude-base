# QA-NEOVIM Agent

Quality and performance audit of a Neovim configuration.

## Target
$ARGUMENTS

## Objective

Assess the performance, plugins, keymaps, health and Lua code quality of a Neovim configuration.

## Workflow

- Measure startup time (target < 50ms)
- Audit plugins: lazy loading, duplicates, maintenance
- Check keymaps: descriptions, conflicts, LSP conventions
- Run health checks (:checkhealth)
- Lint Lua code (luacheck, vim.keymap.set conventions, augroups)
- Check security (secrets, exrc, plugin sources)
- Assess file structure and organization

## Expected output

### Overall score /100
| Category | Score |
|----------|-------|
| Performance | /20 |
| Plugins | /20 |
| Keymaps | /15 |
| Health | /15 |
| Code quality | /15 |
| Organization | /15 |

### Priority recommendations
1. [Recommendation 1]
2. [Recommendation 2]
3. [Recommendation 3]

## Related agents

| Agent | When to use |
|-------|-------------|
| `/dev:dev-neovim` | Implement fixes |
| `/dev:dev-refactor` | Restructure the config |
| `/dev:dev-debug` | Investigate a specific issue |

---

IMPORTANT: Measure startup time BEFORE and AFTER each optimization.

YOU MUST check keymaps with `desc` for which-key.

NEVER disable health checks - they reveal the real problems.

Think hard about the benefit/complexity ratio of plugins.
