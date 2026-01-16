# Agent DEV-NEOVIM

Créer et configurer des plugins, LSP, keymaps et fonctionnalités Neovim en Lua.

## Contexte
$ARGUMENTS

## Processus de création

### 1. Définir le composant

#### Questions clés
- Type de composant (Plugin spec, Keymap, Autocommand, LSP config) ?
- Dépendances requises (autres plugins) ?
- Lazy loading nécessaire (event, cmd, ft, keys) ?
- Configuration utilisateur exposée ?

### 2. Structure par type

#### Plugin spec (lazy.nvim)
```
lua/plugins/
└── [plugin_category].lua   # Ex: editor.lua, ui.lua, lsp.lua
```

#### Configuration
```
lua/config/
├── options.lua    # vim.opt settings
├── keymaps.lua    # Mappings globaux
├── autocmds.lua   # Autocommands
└── lazy.lua       # Bootstrap lazy.nvim
```

#### Utilitaires
```
lua/utils/
├── init.lua       # Module principal
├── keymap.lua     # Helpers pour keymaps
└── lsp.lua        # Helpers LSP
```

### 3. Templates

#### Plugin spec simple
```lua
-- lua/plugins/[name].lua
return {
  "[author]/[plugin]",
  event = { "BufReadPre", "BufNewFile" }, -- Lazy loading
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    -- Configuration par défaut
    option1 = true,
    option2 = "value",
  },
  config = function(_, opts)
    require("[plugin]").setup(opts)
  end,
}
```

#### Plugin spec avec keymaps
```lua
return {
  "[author]/[plugin]",
  cmd = { "PluginCommand" }, -- Charge au premier appel de commande
  keys = {
    { "<leader>p", "<cmd>PluginCommand<cr>", desc = "Plugin action" },
    { "<leader>P", function() require("[plugin]").toggle() end, desc = "Toggle plugin" },
  },
  opts = {},
}
```

#### Plugin spec complexe
```lua
return {
  "[author]/[plugin]",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "optional/dep", optional = true },
  },
  init = function()
    -- Exécuté au démarrage (avant le chargement)
    vim.g.plugin_setting = true
  end,
  opts = function()
    -- Configuration dynamique
    return {
      option = vim.fn.has("mac") == 1 and "mac_value" or "linux_value",
    }
  end,
  config = function(_, opts)
    require("[plugin]").setup(opts)

    -- Setup additionnel après chargement
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "lua",
      callback = function()
        -- Config spécifique Lua
      end,
    })
  end,
}
```

#### Configuration LSP
```lua
-- lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "folke/neodev.nvim", opts = {} }, -- Pour lua_ls
    },
    config = function()
      -- Capabilities pour nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Keymaps LSP (buffer-local)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }

          -- Navigation
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

          -- Documentation
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

          -- Actions
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, opts)

          -- Diagnostics
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
        end,
      })

      -- Configuration des serveurs
      local lspconfig = require("lspconfig")

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
            completion = { callSnippet = "Replace" },
          },
        },
      })

      -- Ajouter d'autres serveurs ici
      local servers = { "pyright", "tsserver", "rust_analyzer" }
      for _, server in ipairs(servers) do
        lspconfig[server].setup({ capabilities = capabilities })
      end
    end,
  },

  -- Mason (gestionnaire de LSP)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "pyright", "tsserver" },
      automatic_installation = true,
    },
  },
}
```

#### Keymaps avec which-key
```lua
-- lua/config/keymaps.lua
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Leader mappings
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>quitall<cr>", { desc = "Quit all" })

-- Buffers
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase width" })

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Copy line to clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
```

#### Autocommands
```lua
-- lua/config/autocmds.lua
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Resize splits on window resize
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Go to last location when opening a buffer
autocmd("BufReadPost", {
  group = augroup("LastLocation", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = { "help", "lspinfo", "man", "qf", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto create dir when saving a file
autocmd("BufWritePre", {
  group = augroup("AutoCreateDir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Filetype-specific settings
autocmd("FileType", {
  group = augroup("FiletypeSettings", { clear = true }),
  pattern = { "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

autocmd("FileType", {
  group = augroup("MarkdownSettings", { clear = true }),
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
```

#### User command
```lua
-- Créer une commande utilisateur
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true, desc = "Format buffer or range" })

-- Commande avec complétion
vim.api.nvim_create_user_command("Colorscheme", function(opts)
  vim.cmd.colorscheme(opts.args)
end, {
  nargs = 1,
  complete = function()
    return vim.fn.getcompletion("", "color")
  end,
  desc = "Set colorscheme with completion",
})
```

### 4. Patterns avancés

#### Module utilitaire
```lua
-- lua/utils/init.lua
local M = {}

--- Check if a plugin is loaded
---@param name string
---@return boolean
function M.has(name)
  return require("lazy.core.config").plugins[name] ~= nil
end

--- Get plugin opts
---@param name string
---@return table
function M.opts(name)
  local plugin = require("lazy.core.config").plugins[name]
  if not plugin then
    return {}
  end
  return require("lazy.core.plugin").values(plugin, "opts", false)
end

--- Safe require
---@param module string
---@return any
function M.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Failed to load " .. module, vim.log.levels.WARN)
    return nil
  end
  return result
end

--- Create keymap with default options
---@param mode string|table
---@param lhs string
---@param rhs string|function
---@param opts? table
function M.map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

return M
```

#### Plugin avec configuration utilisateur
```lua
-- lua/plugins/custom-plugin.lua
return {
  dir = vim.fn.stdpath("config") .. "/lua/custom/my-plugin",
  name = "my-plugin",
  event = "VeryLazy",
  opts = {
    enabled = true,
    style = "default",
  },
  config = function(_, opts)
    require("custom.my-plugin").setup(opts)
  end,
}

-- lua/custom/my-plugin/init.lua
local M = {}

M.config = {
  enabled = true,
  style = "default",
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  if not M.config.enabled then
    return
  end

  -- Setup logic here
end

function M.toggle()
  M.config.enabled = not M.config.enabled
  vim.notify("My plugin: " .. (M.config.enabled and "enabled" or "disabled"))
end

return M
```

### 5. Tests avec plenary

```lua
-- tests/my_plugin_spec.lua
describe("my-plugin", function()
  local plugin = require("custom.my-plugin")

  before_each(function()
    plugin.setup({ enabled = true })
  end)

  it("should be enabled by default", function()
    assert.is_true(plugin.config.enabled)
  end)

  it("should toggle state", function()
    plugin.toggle()
    assert.is_false(plugin.config.enabled)
    plugin.toggle()
    assert.is_true(plugin.config.enabled)
  end)

  it("should merge custom options", function()
    plugin.setup({ style = "custom" })
    assert.equals("custom", plugin.config.style)
  end)
end)
```

### 6. Checklist qualité

- [ ] Plugin avec lazy loading approprié (event, cmd, ft, keys)
- [ ] Keymaps avec descriptions (`desc = "..."`)
- [ ] Autocommands dans des augroups (éviter doublons)
- [ ] Pas de variables globales (utiliser `local`)
- [ ] `vim.keymap.set` au lieu de `vim.api.nvim_set_keymap`
- [ ] `vim.opt` au lieu de `vim.o/vim.bo/vim.wo`
- [ ] Gestion d'erreurs avec `pcall` si nécessaire
- [ ] Tests si logique complexe

## Output attendu

### Fichiers générés

Pour un plugin:
- `lua/plugins/[category].lua` - Spec du plugin

Pour une feature complète:
- `lua/plugins/[name].lua` - Spec du plugin
- `lua/config/[name].lua` - Configuration additionnelle
- `tests/[name]_spec.lua` - Tests

### Documentation inline
```lua
--- Description de la fonction
---@param arg1 string Description de l'argument
---@param arg2? number Argument optionnel
---@return boolean success
function M.my_function(arg1, arg2)
  -- ...
end
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa-neovim` | Auditer la config (perf, keymaps) |
| `/dev-debug` | Déboguer un problème |
| `/work-explore` | Comprendre une config existante |
| `/dev-test` | Écrire plus de tests |

---

IMPORTANT: Toujours utiliser le lazy loading pour optimiser le temps de démarrage.

YOU MUST ajouter `desc` à tous les keymaps pour which-key.

NEVER utiliser de variables globales - toujours `local`.

Think hard sur les dépendances avant d'ajouter un plugin.
