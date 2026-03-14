# Agent DEV-NEOVIM

Creer et configurer des plugins, LSP, keymaps et fonctionnalites Neovim en Lua.

## Contexte de la demande
$ARGUMENTS

## Objectif

Creer des composants Neovim (plugin spec, keymap, autocommand, LSP config)
en Lua avec lazy loading, documentation et tests.

## Workflow

- Definir le type de composant (Plugin spec, Keymap, Autocommand, LSP config, User command)
- Identifier les dependances et le mode de lazy loading (event, cmd, ft, keys)
- Implementer le plugin spec avec lazy.nvim (opts, config, init, dependencies)
- Configurer les keymaps avec descriptions (`desc = "..."`) pour which-key
- Creer les autocommands dans des augroups (eviter doublons)
- Pour LSP : configurer capabilities (cmp), keymaps buffer-local, serveurs via mason
- Ajouter les tests avec plenary si logique complexe
- Utiliser des annotations LuaDoc (`---@param`, `---@return`)

## Output attendu

Pour un plugin : `lua/plugins/[category].lua`
Pour une feature complete : spec + config + tests

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa:qa-neovim` | Auditer la config (perf, keymaps) |
| `/dev:dev-debug` | Deboguer un probleme |
| `/work:work-explore` | Comprendre une config existante |
| `/dev:dev-test` | Ecrire plus de tests |

---

IMPORTANT: Toujours utiliser le lazy loading pour optimiser le temps de demarrage.

YOU MUST ajouter `desc` a tous les keymaps pour which-key.

NEVER utiliser de variables globales - toujours `local`.

Think hard sur les dependances avant d'ajouter un plugin.
