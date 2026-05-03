---
sidebar_position: 14
title: "/dev:dev-neovim"
description: "Create and configure Neovim plugins, LSP, keymaps and features in Lua."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# DEV-NEOVIM Agent

Create and configure Neovim plugins, LSP, keymaps and features in Lua.

## Request context
`<arguments>`

## Objective

Create Neovim components (plugin spec, keymap, autocommand, LSP config)
in Lua with lazy loading, documentation and tests.

## Workflow

- Define the component type (Plugin spec, Keymap, Autocommand, LSP config, User command)
- Identify dependencies and the lazy loading mode (event, cmd, ft, keys)
- Implement the plugin spec with lazy.nvim (opts, config, init, dependencies)
- Configure keymaps with descriptions (`desc = "..."`) for which-key
- Create autocommands inside augroups (avoid duplicates)
- For LSP: configure capabilities (cmp), buffer-local keymaps, servers via mason
- Add tests with plenary if logic is complex
- Use LuaDoc annotations (`---@param`, `---@return`)

## Expected output

For a plugin: `lua/plugins/[category].lua`
For a complete feature: spec + config + tests

## Related agents

| Agent | When to use it |
|-------|------------------|
| `/qa:qa-neovim` | Audit the config (perf, keymaps) |
| `/dev:dev-debug` | Debug a problem |
| `/work:work-explore` | Understand an existing config |
| `/dev:dev-test` | Write more tests |

---

IMPORTANT: Always use lazy loading to optimize startup time.

YOU MUST add `desc` to all keymaps for which-key.

NEVER use global variables - always `local`.

Think hard about dependencies before adding a plugin.


---

## See also

- [Back to DEV commands](/docs/commands/dev)
- [All commands](/docs/commands)
