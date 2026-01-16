# Projet Neovim Config

> Configuration Neovim moderne en Lua avec lazy.nvim et LSP.

## Commandes Essentielles

| Commande | Description |
|----------|-------------|
| `nvim` | Lancer Neovim |
| `nvim --headless "+Lazy! sync" +qa` | Synchroniser les plugins (CI) |
| `nvim --headless "+checkhealth" +qa` | Vérifier la santé de la config |
| `nvim --headless "+luafile %" +qa` | Exécuter un fichier Lua |
| `luacheck lua/` | Linter Lua (si installé) |
| `stylua lua/` | Formatter Lua (si installé) |

## Structure du Projet

```
~/.config/nvim/          # ou XDG_CONFIG_HOME/nvim
├── init.lua             # Point d'entrée principal
├── lua/
│   ├── config/          # Configuration de base
│   │   ├── options.lua  # vim.opt settings
│   │   ├── keymaps.lua  # Mappings globaux
│   │   ├── autocmds.lua # Autocommands
│   │   └── lazy.lua     # Bootstrap lazy.nvim
│   ├── plugins/         # Specs des plugins (lazy.nvim)
│   │   ├── editor.lua   # Plugins d'édition (treesitter, etc.)
│   │   ├── ui.lua       # UI (statusline, colorscheme, etc.)
│   │   ├── lsp.lua      # LSP et completion
│   │   ├── git.lua      # Intégration Git
│   │   └── tools.lua    # Outils divers
│   └── utils/           # Fonctions utilitaires
├── after/
│   └── ftplugin/        # Config par type de fichier
│       ├── lua.lua
│       ├── python.lua
│       └── markdown.lua
├── snippets/            # Snippets personnalisés (LuaSnip)
└── spell/               # Dictionnaires orthographiques
```

## Conventions Lua/Neovim

### Nommage
| Type | Convention | Exemple |
|------|------------|---------|
| Variables | snake_case | `local buffer_name` |
| Fonctions | snake_case | `function get_cursor_pos()` |
| Modules | snake_case | `require("config.keymaps")` |
| Constantes | SCREAMING_SNAKE | `local MAX_LINES = 1000` |
| Fichiers | snake_case ou kebab-case | `treesitter.lua`, `nvim-cmp.lua` |

### Règles Lua
- IMPORTANT: Utiliser `local` pour toutes les variables
- IMPORTANT: Préférer `vim.keymap.set()` à `vim.api.nvim_set_keymap()`
- YOU MUST utiliser `vim.opt` plutôt que `vim.o/vim.bo/vim.wo` quand possible
- Préférer les fonctions Lua aux commandes Vimscript
- Utiliser `vim.schedule()` pour les opérations asynchrones dans les autocmds

### API Neovim
```lua
-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Keymaps (moderne)
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

-- Augroups (pour éviter les doublons)
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

### Spec de plugin
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

### Structure recommandée
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

      -- Keymaps LSP (buffer-local)
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

      -- Serveurs LSP
      local servers = { "lua_ls", "pyright", "tsserver" }
      for _, server in ipairs(servers) do
        lspconfig[server].setup({ capabilities = capabilities })
      end

      -- Config spécifique lua_ls
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

  -- Mason (gestionnaire de LSP/linters)
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

### Avec plenary.nvim
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

### Lancer les tests
```bash
# Avec plenary (dans Neovim)
:PlenaryBustedDirectory tests/

# En ligne de commande
nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
```

### minimal_init.lua pour tests
```lua
-- tests/minimal_init.lua
vim.opt.rtp:append(".")
vim.opt.rtp:append("~/.local/share/nvim/lazy/plenary.nvim")
vim.cmd("runtime plugin/plenary.vim")
```

## Debugging

### Techniques
```lua
-- Inspecter une variable
vim.print(some_table)
print(vim.inspect(some_table))

-- Logger dans un fichier
vim.fn.writefile({ vim.inspect(data) }, "/tmp/nvim-debug.log", "a")

-- Vérifier si un plugin est chargé
:Lazy
:checkhealth

-- Profiling
:Lazy profile

-- Messages d'erreur
:messages
```

### Checkhealth personnalisé
```lua
-- lua/utils/health.lua
local M = {}

M.check = function()
  vim.health.start("My Config")

  -- Vérifier les dépendances
  if vim.fn.executable("rg") == 1 then
    vim.health.ok("ripgrep installed")
  else
    vim.health.warn("ripgrep not found (telescope will be slower)")
  end

  -- Vérifier la version de Neovim
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
-- Charger uniquement pour certains filetypes
{ "rust-lang/rust.vim", ft = "rust" }

-- Charger sur commande
{ "folke/trouble.nvim", cmd = "Trouble" }

-- Charger sur keymap
{
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
  },
}

-- Charger sur événement
{ "nvim-treesitter/nvim-treesitter", event = { "BufReadPre", "BufNewFile" } }
```

### Mesurer le temps de démarrage
```bash
# Temps de démarrage
nvim --startuptime /tmp/startup.log

# Analyser avec un plugin
:Lazy profile
```

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, docs, chore
- Scope: plugin name ou module (`lsp`, `keymaps`, `treesitter`)
- Exemple: `feat(lsp): add rust-analyzer configuration`

## Hooks Claude Code 2.1+

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Bloque les modifications sur main/master |
| Lua format | PostToolUse | `stylua` sur fichiers Lua modifiés |
| Lua lint | PostToolUse | `luacheck` après édition |
| Syntax check | PostToolUse | `nvim --headless "+luafile %" +qa` |
| Détection secrets | PreToolUse | Bloque les secrets hardcodés |

## Skills disponibles

| Skill | Déclenchement | Usage |
|-------|---------------|-------|
| `exploring-codebase` | "explorer", "comprendre" | Analyser une config existante |
| `planning-implementation` | "planifier", "architecture" | Définir un plan avant de modifier |
| `test-driven-development` | "TDD", "test first" | Tests avec plenary.nvim |
| `reviewing-code` | "review", "vérifier" | Revue de configuration |
| `debugging-issues` | "debug", "bug", "erreur" | Diagnostic de plugins |
| `generating-commit-messages` | "commit", "message" | Conventional Commits |
| `creating-pull-requests` | "PR", "pull request" | PR complète et documentée |

## Plugins Recommandés

### Essentiels
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

### Optionnels populaires
```lua
-- File explorer
"nvim-neo-tree/neo-tree.nvim"

-- Which-key (aide keymaps)
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

## Anti-patterns à éviter

- NEVER utiliser Vimscript quand Lua est possible
- NEVER mettre toute la config dans init.lua (modulariser)
- NEVER hardcoder les chemins (utiliser `vim.fn.stdpath()`)
- NEVER ignorer les erreurs de chargement de plugins
- Éviter les mappings sans description (utiliser `desc =`)
- Éviter `vim.cmd` pour ce qui peut être fait en Lua
- Éviter les plugins qui dupliquent des fonctionnalités builtin

## Migration depuis Vimscript

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
