# Agent QA-NEOVIM

Audit qualité et performance d'une configuration Neovim.

## Cible
$ARGUMENTS

## Méthodologie

### 1. Performance de démarrage

#### Mesurer le temps de démarrage
```bash
# Temps de démarrage détaillé
nvim --startuptime /tmp/startup.log +qa && cat /tmp/startup.log | tail -20

# Temps total seulement
nvim --startuptime /tmp/startup.log +qa && tail -1 /tmp/startup.log

# Avec hyperfine (plus précis)
hyperfine "nvim --headless +qa" --warmup 3
```

#### Objectifs de performance
| Métrique | Bon | Acceptable | Lent |
|----------|-----|------------|------|
| Temps total | < 50ms | 50-100ms | > 100ms |
| Plugins chargés au démarrage | < 10 | 10-20 | > 20 |
| Temps avant UI | < 30ms | 30-50ms | > 50ms |

#### Checklist performance
- [ ] Lazy loading configuré (event, cmd, ft, keys)
- [ ] Plugins lourds différés (VeryLazy, LspAttach)
- [ ] Pas de `require()` au top-level inutiles
- [ ] Utilisation de `vim.loader.enable()` (Neovim 0.9+)
- [ ] Cache Treesitter activé

### 2. Audit des plugins

#### Plugins chargés vs configurés
```lua
-- Vérifier les plugins lazy.nvim
:Lazy

-- Voir le profil de chargement
:Lazy profile

-- Plugins non utilisés (aucun chargement récent)
:Lazy health
```

#### Checklist plugins
- [ ] Tous les plugins ont un lazy loading approprié
- [ ] Pas de plugins dupliqués (fonctionnalités similaires)
- [ ] Dépendances correctement déclarées
- [ ] Plugins maintenus (dernière mise à jour < 6 mois)
- [ ] Pas de plugins abandonnés
- [ ] `lazy-lock.json` committé et à jour

#### Plugins à auditer
| Catégorie | Questions |
|-----------|-----------|
| LSP | Serveurs installés vs utilisés ? Mason à jour ? |
| Completion | Sources configurées ? Performance ? |
| Treesitter | Parsers installés vs utilisés ? |
| UI | Thèmes multiples ? Statusline optimisée ? |
| Git | Signes performants ? Blame lazy ? |

### 3. Audit des keymaps

#### Détecter les conflits
```lua
-- Lister tous les keymaps
:verbose map

-- Keymaps d'un mode spécifique
:verbose nmap <leader>

-- Vérifier un keymap spécifique
:verbose nmap <leader>ff
```

#### Checklist keymaps
- [ ] Tous les keymaps ont une description (`desc = "..."`)
- [ ] Pas de conflits entre plugins
- [ ] Keymaps LSP buffer-local (pas globaux)
- [ ] Leader key cohérent
- [ ] Pas de keymaps sur des touches importantes écrasées
- [ ] Which-key configuré pour discovery

#### Keymaps standards à vérifier
| Keymap | Attendu | Conflit possible |
|--------|---------|------------------|
| `gd` | LSP definition | Vim default (declaration) |
| `gr` | LSP references | Vim default (replace char) |
| `K` | LSP hover | Vim default (man page) |
| `<C-k>` | Signature help | Window navigation |
| `[d` / `]d` | Diagnostic nav | Libre |

### 4. Health checks

#### Exécuter les health checks
```vim
:checkhealth

" Vérifications spécifiques
:checkhealth nvim
:checkhealth lazy
:checkhealth mason
:checkhealth nvim-treesitter
```

#### Checklist santé
- [ ] Toutes les dépendances système présentes (git, node, etc.)
- [ ] Clipboard configuré correctement
- [ ] Python/Node providers fonctionnels (si utilisés)
- [ ] Pas d'erreurs dans les logs (`:messages`)
- [ ] Treesitter parsers compilés
- [ ] LSP serveurs accessibles

### 5. Conventions et qualité du code

#### Linting Lua
```bash
# Luacheck
luacheck lua/ --no-color

# Avec configuration
luacheck lua/ --config .luacheckrc
```

#### Checklist code Lua
- [ ] Toutes les variables sont `local`
- [ ] Pas de `vim.cmd` quand Lua possible
- [ ] `vim.keymap.set` au lieu de `nvim_set_keymap`
- [ ] `vim.opt` au lieu de `vim.o/bo/wo`
- [ ] Autocommands dans des augroups
- [ ] Pas de `vim.g.mapleader` après les keymaps
- [ ] Modules correctement structurés (return M)

#### Anti-patterns à détecter
```lua
-- MAUVAIS: Variable globale
myvar = "value"

-- MAUVAIS: vim.cmd pour ce qui peut être Lua
vim.cmd("set number")

-- MAUVAIS: Ancien style keymap
vim.api.nvim_set_keymap("n", "<leader>x", ":cmd<CR>", {})

-- MAUVAIS: Autocommand sans groupe
vim.api.nvim_create_autocmd("BufRead", { callback = function() end })

-- MAUVAIS: Leader défini après keymaps
vim.keymap.set("n", "<leader>w", ...)
vim.g.mapleader = " "  -- Trop tard!
```

### 6. Sécurité

#### Checklist sécurité
- [ ] Pas de secrets dans la config (API keys, tokens)
- [ ] `exrc` désactivé ou sécurisé
- [ ] Plugins de sources fiables (GitHub stars, mainteneur connu)
- [ ] Pas d'exécution automatique de code non fiable
- [ ] Modelines sécurisées ou désactivées

### 7. Structure et organisation

#### Structure recommandée
```
nvim/
├── init.lua              # Bootstrap uniquement
├── lua/
│   ├── config/           # Options, keymaps, autocmds
│   ├── plugins/          # Specs lazy.nvim (1 fichier = 1 catégorie)
│   └── utils/            # Helpers réutilisables
├── after/ftplugin/       # Settings par filetype
└── snippets/             # Snippets custom
```

#### Checklist organisation
- [ ] `init.lua` minimal (bootstrap seulement)
- [ ] Séparation config/plugins/utils
- [ ] Nommage cohérent des fichiers
- [ ] Pas de fichiers de 500+ lignes
- [ ] README ou documentation interne

## Output attendu

### Rapport d'audit

```markdown
## Audit Neovim Config - [Date]

### Performance
- Temps de démarrage: [X ms]
- Plugins au démarrage: [N]
- Score: [Bon/Acceptable/À améliorer]

### Plugins ([N] total)
- Bien configurés: [N]
- Sans lazy loading: [liste]
- Potentiellement inutilisés: [liste]

### Keymaps
- Total: [N]
- Sans description: [N] [liste]
- Conflits détectés: [liste]

### Health
- Erreurs: [N]
- Warnings: [N]
- Points d'attention: [liste]

### Code quality
- Fichiers Lua: [N]
- Issues luacheck: [N]
- Anti-patterns: [liste]

### Recommandations prioritaires
1. [Recommandation 1]
2. [Recommandation 2]
3. [Recommandation 3]
```

### Score global

| Catégorie | Score | Max |
|-----------|-------|-----|
| Performance | /20 |
| Plugins | /20 |
| Keymaps | /15 |
| Health | /15 |
| Code quality | /15 |
| Organisation | /15 |
| **Total** | **/100** |

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev-neovim` | Implémenter les corrections |
| `/dev-refactor` | Restructurer la config |
| `/work-explore` | Comprendre la config actuelle |
| `/dev-debug` | Investiguer un problème spécifique |

---

IMPORTANT: Mesurer le temps de démarrage AVANT et APRÈS chaque optimisation.

YOU MUST vérifier les keymaps avec `desc` pour which-key.

NEVER désactiver les health checks - ils révèlent les vrais problèmes.

Think hard sur le ratio bénéfice/complexité des plugins.
