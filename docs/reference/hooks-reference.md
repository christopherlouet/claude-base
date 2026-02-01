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
| `SessionEnd` | command | Fin de session |

## Types de hooks

| Type | Description |
|------|-------------|
| `command` | Exécute un script bash (déterministe, rapide) |
| `prompt` | Évalue via un LLM Haiku (contextuel, intelligent) - pour `Stop`, `SubagentStop`, `PreToolUse` |

## Hooks configurés

| Hook | Déclencheur | Action |
|------|-------------|--------|
| **Protection main** | PreToolUse (Edit/Write) | Bloque modifications sur main/master |
| **Détection secrets** | PreToolUse (Write/Edit) | Gitleaks vérifie les secrets avant écriture |
| **Tests pre-commit** | PreToolUse (Bash git commit) | Exécute les tests avant un commit |
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
| **Notification** | Notification | Log les demandes de permission et idle |
| **SubagentStop** | SubagentStop | Log la fin des sub-agents |
| **SessionEnd** | SessionEnd | Log la fin de session |
| **PreCompact** | PreCompact | Log avant compaction du contexte |

## Variables d'environnement des hooks

| Variable | Usage |
|----------|-------|
| `ALLOW_MAIN_EDIT=1` | Désactiver la protection de branche main |
| `SKIP_PRE_COMMIT_TESTS=1` | Désactiver les tests avant commit |
