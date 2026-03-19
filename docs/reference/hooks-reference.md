# Hooks (Claude Code 2.1+)

Le projet inclut des hooks automatiques dans `.claude/settings.json`:

## Hook Events disponibles

| Event | Type | Description |
|-------|------|-------------|
| `SessionStart` | command | Déclenché au démarrage d'une session (matchers: `startup`, `resume`, `clear`, `compact`) |
| `UserPromptSubmit` | command | Quand l'utilisateur soumet un prompt (validation, contexte additionnel) |
| `PreToolUse` | command/prompt | Avant l'exécution d'un outil (matcher: `Edit\|Write`, `Bash`) |
| `PermissionRequest` | command/prompt | Quand un dialog de permission est affiché |
| `PostToolUse` | command | Après l'exécution réussie d'un outil |
| `PostToolUseFailure` | command | Après l'échec d'un outil |
| `SubagentStart` | command | Démarrage d'un sub-agent |
| `SubagentStop` | command/prompt | Fin d'exécution d'un sub-agent |
| `Stop` | command/prompt | Quand Claude finit de répondre |
| `Setup` | command | Initialisation (`init`) et maintenance (`maintenance`) du projet |
| `Notification` | command | Notifications (`permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`) |
| `PreCompact` | command | Avant compaction du contexte (matchers: `manual`, `auto`) |
| `PostCompact` | command | Apres compaction du contexte |
| `SessionEnd` | command | Fin de session |
| `TeammateIdle` | command | Quand un agent teammate devient inactif (Agent Teams) |
| `TaskCompleted` | command | Quand une tache est marquee terminee |
| `InstructionsLoaded` | command | Quand CLAUDE.md et rules sont charges |
| `Elicitation` | command | Quand un serveur MCP demande un input structure |
| `ElicitationResult` | command | Quand l'utilisateur repond a une Elicitation MCP |

## Types de hooks

| Type | Description |
|------|-------------|
| `command` | Execute un script bash (deterministe, rapide) |
| `prompt` | Evalue via un LLM Haiku (contextuel, intelligent) - pour `Stop`, `SubagentStop`, `PreToolUse` |
| `http` | Envoie un POST JSON vers une URL (webhook externe) - CLI 2.1.70+ |

## Proprietes des hooks

| Propriete | Description |
|-----------|-------------|
| `async` | `true` pour executer en arriere-plan sans bloquer (CLI 2.1.70+) |
| `onFailure` | `"block"` pour bloquer, `"ignore"` pour continuer |
| `timeout` | Timeout en millisecondes |

## Hooks configurés

| Hook | Déclencheur | Action |
|------|-------------|--------|
| **Session info** | SessionStart (startup) | Affiche les informations du projet au démarrage |
| **Check node_modules** | SessionStart (startup) | Vérifie que node_modules existe si package.json présent |
| **Protection main** | PreToolUse (Edit/Write) | Bloque modifications sur main/master |
| **Détection secrets** | PreToolUse (Write/Edit) | Gitleaks vérifie les secrets avant écriture |
| **Tests pre-commit** | PreToolUse (Bash git commit) | Exécute les tests avant un commit. Detecte et repare Husky si necessaire |
| **CI locale pre-push** | PreToolUse (Bash git push) | Lint + type-check + tests avant push. Desactivable avec `SKIP_PRE_PUSH_CI=1` |
| **Destructive ops guard** | PreToolUse (Bash) | Bloque les DELETE/DROP/TRUNCATE/rm destructifs sans confirmation |
| **RTK token optimizer** | PreToolUse (Bash) | Reecrit les commandes via RTK pour reduire les tokens (-60-90%). Desactive par defaut, activer avec `ENABLE_RTK=1` |
| **Auto-format TS/JS** | PostToolUse (Edit/Write) | Prettier sur fichiers TS/JS |
| **Auto-format Python** | PostToolUse (Edit/Write) | Ruff/Black sur fichiers .py |
| **Auto-format Go** | PostToolUse (Edit/Write) | gofmt sur fichiers .go |
| **Auto-format Rust** | PostToolUse (Edit/Write) | rustfmt sur fichiers .rs |
| **Auto-format Dart** | PostToolUse (Edit/Write) | dart format sur fichiers .dart |
| **Auto-format Lua** | PostToolUse (Edit/Write) | stylua sur fichiers .lua |
| **Type-check** | PostToolUse (Edit/Write) | Vérifie les types TypeScript |
| **ESLint** | PostToolUse (Edit/Write) | Lint JS/TS après modification |
| **Auto-install** | PostToolUse (Edit package.json) | npm/yarn/pnpm/bun install |
| **Auto-sync Python** | PostToolUse (Edit pyproject.toml) | uv sync ou pip install |
| **Auto pub get** | PostToolUse (Edit pubspec.yaml) | flutter/dart pub get |
| **Auto go mod tidy** | PostToolUse (Edit go.mod) | go mod tidy |
| **Auto cargo check** | PostToolUse (Edit Cargo.toml) | cargo check |
| **Coverage check** | PostToolUse (Edit test files) | Vérifie la couverture de tests |
| **Setup init** | Setup (init) | Installe les dépendances au premier lancement |
| **Setup maintenance** | Setup (maintenance) | Audit et mise à jour périodique |
| **Notification permission** | Notification (permission_prompt) | Log les demandes de permission |
| **Notification idle** | Notification (idle_prompt) | Log quand Claude attend l'utilisateur |
| **SubagentStop** | SubagentStop | Log la fin des sub-agents |
| **SessionEnd** | SessionEnd | Log la fin de session |
| **PreCompact** | PreCompact | Log avant compaction du contexte |
| **PostCompact** | PostCompact | Log apres compaction du contexte (async) |
| **TeammateIdle** | TeammateIdle | Log quand un teammate devient inactif (async) |
| **TaskCompleted** | TaskCompleted | Log quand une tache est terminee (async) |
| **InstructionsLoaded** | InstructionsLoaded | Log le chargement des instructions (async) |
| **Elicitation** | Elicitation | Log les demandes MCP Elicitation (async) |
| **ElicitationResult** | ElicitationResult | Log les reponses MCP Elicitation (async) |
| **Check .env** | SessionStart | Verifie que .env est dans .gitignore |
| **Warning hooks tiers** | SessionStart | Avertit si des hooks personnalises sont detectes |

## Variables d'environnement des hooks

| Variable | Usage |
|----------|-------|
| `ALLOW_MAIN_EDIT=1` | Désactiver la protection de branche main |
| `SKIP_PRE_COMMIT_TESTS=1` | Désactiver les tests avant commit |

## Fichiers de logs

Les hooks de logging ecrivent dans `/tmp/` (mode append, nettoyes au redemarrage):

| Fichier | Contenu |
|---------|---------|
| `/tmp/claude-sessions.log` | Demarrage, fin de session, compaction, taches |
| `/tmp/claude-agents.log` | Activite des sub-agents et teammates |
| `/tmp/claude-notifications.log` | Permissions et attentes utilisateur |
| `/tmp/claude-mcp.log` | Evenements MCP Elicitation |
