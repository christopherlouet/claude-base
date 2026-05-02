# Neovim Config Project

> Modern Neovim configuration in Lua with lazy.nvim and LSP.

## Essential Commands

| Command | Description |
|---------|-------------|
| `nvim` | Launch Neovim |
| `nvim --headless "+Lazy! sync" +qa` | Sync plugins (CI) |
| `nvim --headless "+checkhealth" +qa` | Check config health |
| `nvim --headless "+luafile %" +qa` | Run a Lua file |
| `luacheck lua/` | Lua linter (if installed) |
| `stylua lua/` | Lua formatter (if installed) |

## Project Structure

```
~/.config/nvim/          # or XDG_CONFIG_HOME/nvim
├── init.lua             # Main entry point
├── lua/
│   ├── config/          # Base configuration
│   │   ├── options.lua  # vim.opt settings
│   │   ├── keymaps.lua  # Global mappings
│   │   ├── autocmds.lua # Autocommands
│   │   └── lazy.lua     # Bootstrap lazy.nvim
│   ├── plugins/         # Plugin specs (lazy.nvim)
│   │   ├── editor.lua   # Editing plugins (treesitter, etc.)
│   │   ├── ui.lua       # UI (statusline, colorscheme, etc.)
│   │   ├── lsp.lua      # LSP and completion
│   │   ├── git.lua      # Git integration
│   │   └── tools.lua    # Miscellaneous tools
│   └── utils/           # Utility functions
├── after/
│   └── ftplugin/        # Per-filetype config
│       ├── lua.lua
│       ├── python.lua
│       └── markdown.lua
├── snippets/            # Custom snippets (LuaSnip)
└── spell/               # Spell dictionaries
```

## Lua/Neovim Conventions

### Naming
| Type | Convention | Example |
|------|------------|---------|
| Variables | snake_case | `local buffer_name` |
| Functions | snake_case | `function get_cursor_pos()` |
| Modules | snake_case | `require("config.keymaps")` |
| Constants | SCREAMING_SNAKE | `local MAX_LINES = 1000` |
| Files | snake_case or kebab-case | `treesitter.lua`, `nvim-cmp.lua` |

### Lua Rules
- IMPORTANT: Use `local` for all variables
- IMPORTANT: Prefer `vim.keymap.set()` over `vim.api.nvim_set_keymap()`
- YOU MUST use `vim.opt` rather than `vim.o/vim.bo/vim.wo` when possible
- Prefer Lua functions over Vimscript commands
- Use `vim.schedule()` for async operations in autocmds

### Neovim API
```lua
-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Keymaps (modern)
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to clipboard" })

-- Autocommands
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.lua",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
  desc = "Format Lua on save",
})

-- Augroups (to avoid duplicates)
local augroup = vim.api.nvim_create_augroup("MyConfig", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
  end,
})
```

## Plugin Manager (lazy.nvim)

### Bootstrap
```lua
-- lua/config/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  defaults = { lazy = true },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})
```

### Plugin spec
```lua
-- lua/plugins/editor.lua
return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "python", "javascript" },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
}
```

## LSP Configuration

### Recommended structure
```lua
-- lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- LSP keymaps (buffer-local)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        end,
      })

      -- LSP servers
      local servers = { "lua_ls", "pyright", "tsserver" }
      for _, server in ipairs(servers) do
        lspconfig[server].setup({ capabilities = capabilities })
      end

      -- lua_ls-specific config
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })
    end,
  },

  -- Mason (LSP/linters manager)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "pyright" },
      automatic_installation = true,
    },
  },
}
```

## Completion (nvim-cmp)

```lua
-- lua/plugins/completion.lua
return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}
```

## Tests

### With plenary.nvim
```lua
-- tests/config_spec.lua
describe("config", function()
  it("should load without errors", function()
    assert.has_no.errors(function()
      require("config.options")
    end)
  end)

  it("should set correct options", function()
    require("config.options")
    assert.is_true(vim.opt.number:get())
    assert.equals(2, vim.opt.tabstop:get())
  end)
end)
```

### Run the tests
```bash
# With plenary (inside Neovim)
:PlenaryBustedDirectory tests/

# From the command line
nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
```

### minimal_init.lua for tests
```lua
-- tests/minimal_init.lua
vim.opt.rtp:append(".")
vim.opt.rtp:append("~/.local/share/nvim/lazy/plenary.nvim")
vim.cmd("runtime plugin/plenary.vim")
```

## Debugging

### Techniques
```lua
-- Inspect a variable
vim.print(some_table)
print(vim.inspect(some_table))

-- Log to a file
vim.fn.writefile({ vim.inspect(data) }, "/tmp/nvim-debug.log", "a")

-- Check whether a plugin is loaded
:Lazy
:checkhealth

-- Profiling
:Lazy profile

-- Error messages
:messages
```

### Custom checkhealth
```lua
-- lua/utils/health.lua
local M = {}

M.check = function()
  vim.health.start("My Config")

  -- Check dependencies
  if vim.fn.executable("rg") == 1 then
    vim.health.ok("ripgrep installed")
  else
    vim.health.warn("ripgrep not found (telescope will be slower)")
  end

  -- Check Neovim version
  if vim.fn.has("nvim-0.9") == 1 then
    vim.health.ok("Neovim >= 0.9")
  else
    vim.health.error("Neovim 0.9+ required")
  end
end

return M
```

## Performance

### Lazy loading
```lua
-- Load only for certain filetypes
{ "rust-lang/rust.vim", ft = "rust" }

-- Load on command
{ "folke/trouble.nvim", cmd = "Trouble" }

-- Load on keymap
{
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
  },
}

-- Load on event
{ "nvim-treesitter/nvim-treesitter", event = { "BufReadPre", "BufNewFile" } }
```

### Measure startup time
```bash
# Startup time
nvim --startuptime /tmp/startup.log

# Analyze with a plugin
:Lazy profile
```

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore
- Scope: plugin name or module (`lsp`, `keymaps`, `treesitter`)
- Example: `feat(lsp): add rust-analyzer configuration`

## Claude Code 2.1+ Hooks

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Blocks modifications on main/master |
| Lua format | PostToolUse | `stylua` on modified Lua files |
| Lua lint | PostToolUse | `luacheck` after editing |
| Syntax check | PostToolUse | `nvim --headless "+luafile %" +qa` |
| Secret detection | PreToolUse | Blocks hardcoded secrets |

### Lua hooks configuration

Add to `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "if command -v stylua &>/dev/null && [[ \"$CLAUDE_FILE\" == *.lua ]]; then stylua \"$CLAUDE_FILE\"; fi",
            "description": "Format Lua with stylua"
          },
          {
            "type": "command",
            "command": "if command -v luacheck &>/dev/null && [[ \"$CLAUDE_FILE\" == *.lua ]]; then luacheck \"$CLAUDE_FILE\" --no-color 2>&1 | head -20; fi",
            "description": "Lint Lua with luacheck"
          }
        ]
      }
    ]
  }
}
```

### Lua quality tools

Installation:
```bash
# macOS
brew install stylua luacheck

# Linux (via luarocks)
luarocks install luacheck
cargo install stylua

# With mise (version manager)
mise use -g stylua
mise use -g luacheck
```

Recommended configuration:

```toml
# .stylua.toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
```

```lua
-- .luacheckrc
std = "lua51+luajit"
cache = true
max_line_length = 120
globals = { "vim" }
ignore = { "212" }  -- Unused argument
```

## Available Skills

| Skill | Trigger | Usage |
|-------|---------|-------|
| `exploring-codebase` | "explore", "understand" | Analyze an existing config |
| `planning-implementation` | "plan", "architecture" | Define a plan before modifying |
| `test-driven-development` | "TDD", "test first" | Tests with plenary.nvim |
| `reviewing-code` | "review", "verify" | Configuration review |
| `debugging-issues` | "debug", "bug", "error" | Plugin diagnostics |
| `generating-commit-messages` | "commit", "message" | Conventional Commits |
| `creating-pull-requests` | "PR", "pull request" | Complete and documented PR |

## Recommended Plugins

### Essentials
```lua
-- Plugin manager
"folke/lazy.nvim"

-- LSP
"neovim/nvim-lspconfig"
"williamboman/mason.nvim"
"williamboman/mason-lspconfig.nvim"

-- Completion
"hrsh7th/nvim-cmp"
"hrsh7th/cmp-nvim-lsp"
"L3MON4D3/LuaSnip"

-- Treesitter
"nvim-treesitter/nvim-treesitter"

-- Fuzzy finder
"nvim-telescope/telescope.nvim"
"nvim-lua/plenary.nvim"

-- Git
"lewis6991/gitsigns.nvim"

-- UI
"nvim-lualine/lualine.nvim"
"folke/tokyonight.nvim"
```

### Popular optional
```lua
-- File explorer
"nvim-neo-tree/neo-tree.nvim"

-- Which-key (keymap helper)
"folke/which-key.nvim"

-- Diagnostics
"folke/trouble.nvim"

-- Formatting
"stevearc/conform.nvim"

-- Linting
"mfussenegger/nvim-lint"

-- Tests
"nvim-neotest/neotest"
```

## Anti-patterns to avoid

- NEVER use Vimscript when Lua is possible
- NEVER put the entire config in init.lua (modularize)
- NEVER hardcode paths (use `vim.fn.stdpath()`)
- NEVER ignore plugin loading errors
- Avoid mappings without a description (use `desc =`)
- Avoid `vim.cmd` for what can be done in Lua
- Avoid plugins that duplicate builtin features

## Migrating from Vimscript

```lua
-- Vimscript: set number
vim.opt.number = true

-- Vimscript: let g:variable = 'value'
vim.g.variable = "value"

-- Vimscript: autocmd BufRead * ...
vim.api.nvim_create_autocmd("BufRead", { ... })

-- Vimscript: command! MyCmd ...
vim.api.nvim_create_user_command("MyCmd", function() ... end, {})

-- Vimscript: nnoremap <leader>x :...
vim.keymap.set("n", "<leader>x", ...)
```
