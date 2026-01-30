# Tâches : Synchronisation Doc Officielle Claude Code 2026

**Input**: `specs/claude-code-sync-2026/plan.md`
**Date**: 2026-01-30

---

## Phase 1 : LSP Configuration [P]

**Objectif** : Ajouter le support LSP (Language Server Protocol) au socle

- [ ] T001 - [P] Créer `.lsp.json` à la racine du projet
  - Config pour 11 langages: TypeScript, Python, Go, Rust, Java, C/C++, C#, PHP, Kotlin, Ruby, HTML/CSS
  - Chaque entrée: `command`, `args`, `extensionToLanguage`
  - Variable d'activation: `ENABLE_LSP_TOOL=1`

- [ ] T002 - [P] Créer `.claude/rules/lsp.md`
  - Paths: `**/*.ts`, `**/*.py`, `**/*.go`, `**/*.rs`, `**/*.java`, `**/*.cs`, `**/*.rb`, `**/*.php`, `**/*.kt`
  - Contenu: quand préférer LSP vs Grep, bonnes pratiques navigation sémantique

- [ ] T003 - Mettre à jour `.claude/rules/README.md`
  - Ajouter entrée `lsp` dans le tableau des règles

**Checkpoint** : LSP configuré et documenté.

---

## Phase 2 : Hooks Manquants [P]

**Objectif** : Ajouter les hook events manquants dans settings.json

- [ ] T004 - Créer `scripts/hooks/setup-deps.sh`
  - Détecte le type de projet (package.json, pyproject.toml, go.mod, pubspec.yaml, Cargo.toml, Gemfile)
  - Installe les dépendances avec le gestionnaire approprié
  - Timeout-safe, idempotent

- [ ] T005 - Ajouter hook `Setup` dans `.claude/settings.json`
  - Matcher `init` → exécute `scripts/hooks/setup-deps.sh`
  - Matcher `maintenance` → lance audit + update
  - Description claire du rôle

- [ ] T006 - Ajouter hook `Notification` dans `.claude/settings.json`
  - Matcher `idle_prompt` → log quand Claude attend l'utilisateur
  - Matcher `permission_prompt` → log les demandes de permission

- [ ] T007 - Ajouter hook `SubagentStop` dans `.claude/settings.json`
  - Log les résultats des sub-agents pour traçabilité

- [ ] T008 - Ajouter hook `SessionEnd` dans `.claude/settings.json`
  - Log la fin de session pour analytics

- [ ] T009 - Ajouter hook `PreCompact` dans `.claude/settings.json`
  - Log avant compaction pour debugging

- [ ] T010 - Ajouter hook prompt-based `Stop` dans `.claude/settings.json`
  - `type: "prompt"` avec vérification intelligente
  - Vérifie que les tâches sont complètes avant de terminer

**Checkpoint** : Tous les hooks events officiels sont couverts.

---

## Phase 3 : Frontmatter Skills

**Objectif** : Enrichir les 40 skills avec les nouveaux champs frontmatter

- [ ] T011 - Mettre à jour `.claude/skills/writing-skills/SKILL.md`
  - Documenter les nouveaux champs: `disable-model-invocation`, `user-invocable`, `argument-hint`, `model`, `agent`, `hooks`
  - Ajouter exemples pour chaque champ
  - Documenter `$ARGUMENTS[N]`, `$N`, `${CLAUDE_SESSION_ID}`
  - Documenter dynamic context injection `!` backtick command backtick

- [ ] T012 - [P] Ajouter `disable-model-invocation: true` aux skills manuels
  - Skills concernés (10):
    - `.claude/skills/work-commit/SKILL.md`
    - `.claude/skills/work-pr/SKILL.md`
    - `.claude/skills/work-plan/SKILL.md`
    - `.claude/skills/work-explore/SKILL.md`
    - `.claude/skills/ops-docker/SKILL.md`
    - `.claude/skills/ops-ci/SKILL.md`
    - `.claude/skills/ops-database/SKILL.md`
    - `.claude/skills/ops-monitoring/SKILL.md`
    - `.claude/skills/doc-generate/SKILL.md`
    - `.claude/skills/doc-changelog/SKILL.md`

- [ ] T013 - [P] Ajouter `argument-hint` aux skills qui prennent des arguments
  - Skills concernés (10):
    - `dev-tdd` → `argument-hint: "[feature-description]"`
    - `dev-debug` → `argument-hint: "[error-description]"`
    - `dev-api` → `argument-hint: "[endpoint-name]"`
    - `dev-flutter` → `argument-hint: "[widget-or-screen]"`
    - `dev-refactor` → `argument-hint: "[file-or-module]"`
    - `qa-security` → `argument-hint: "[scope-or-module]"`
    - `qa-perf` → `argument-hint: "[page-or-endpoint]"`
    - `ops-infra-code` → `argument-hint: "[module-name]"`
    - `ops-proxmox` → `argument-hint: "[resource-type]"`
    - `ops-opnsense` → `argument-hint: "[component]"`

- [ ] T014 - [P] Ajouter `model` aux skills complexes
  - Skills concernés (4):
    - `qa-security` → `model: sonnet`
    - `dev-tdd` → `model: sonnet`
    - `dev-debug` → `model: sonnet`
    - `qa-perf` → `model: sonnet`

- [ ] T015 - [P] Ajouter `user-invocable: false` aux skills background-only
  - Skills concernés (3):
    - `state-management` → `user-invocable: false`
    - `api-mocking` → `user-invocable: false`
    - `feature-flags` → `user-invocable: false`

**Checkpoint** : Tous les skills enrichis avec les nouveaux champs.

---

## Phase 4 : Chrome Integration [P] ✅

**Objectif** : Créer le support tests visuels Chrome

- [x] T016 - [P] Créer `.claude/skills/qa-chrome/SKILL.md`
  - Frontmatter: `name: qa-chrome`, `description`, `allowed-tools: Bash, Read, Grep`, `context: fork`, `disable-model-invocation: true`, `argument-hint: "[url-or-page]"`
  - Instructions: tests visuels, debugging console, vérification responsive, capture GIF
  - Prérequis: `--chrome` flag, extension Chrome

- [x] T017 - [P] Créer `.claude/agents/qa-chrome.md`
  - Frontmatter: `name: qa-chrome`, `description`, `tools: Read, Grep, Glob, Bash`, `model: sonnet`, `permissionMode: default`
  - Instructions: audit visuel, debugging DOM/console, tests d'accessibilité visuelle
  - Skills préchargés: `qa-chrome`, `qa-design`

- [x] T018 - [P] Créer `.claude/commands/qa/qa-chrome.md`
  - Commande `/qa-chrome` qui invoque l'agent Chrome
  - Arguments: URL ou page à tester
  - Documentation inline des capacités

**Checkpoint** : ✅ Triplet Chrome (skill/agent/command) créé et validé.

---

## Phase 5 : Documentation CLAUDE.md

**Objectif** : Documenter toutes les nouveautés

- [ ] T019 - Ajouter section "LSP (Language Server Protocol)" dans CLAUDE.md
  - Placement: après la section "MCP Configuration"
  - Contenu: activation, langages supportés, bonnes pratiques LSP vs Grep
  - Référence vers `.lsp.json`

- [ ] T020 - Ajouter section "CLI Flags Avancés" dans CLAUDE.md
  - Placement: après la section "Commandes Essentielles"
  - Flags: `--agent`, `--agents`, `--chrome`, `--teleport`, `--remote`, `--fallback-model`, `--plugin-dir`, `--tools`, `--init`, `--init-only`, `--maintenance`, `--max-budget-usd`, `--fork-session`, `--strict-mcp-config`
  - Tableau avec flag, description, exemple

- [ ] T021 - Ajouter entrée Chrome dans la section "QA- : Qualité"
  - Ajouter `/qa-chrome` dans le tableau des commandes QA
  - Ajouter l'agent `qa-chrome` dans le tableau des agents

- [ ] T022 - Mettre à jour section Hooks dans CLAUDE.md
  - Ajouter les nouveaux events: Setup, Notification, SubagentStop, SubagentStart, SessionEnd, PreCompact, PostToolUseFailure, PermissionRequest
  - Documenter les prompt-based hooks (`type: "prompt"`)
  - Mettre à jour le tableau des hooks existants

- [ ] T023 - Ajouter section "Bonnes Pratiques Skills" dans CLAUDE.md
  - SKILL.md < 500 lignes (déporter dans fichiers de référence)
  - Budget descriptions: 15k chars max (`SLASH_COMMAND_TOOL_CHAR_BUDGET`)
  - Dynamic context injection: `!` backtick command backtick
  - Substitutions: `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, `${CLAUDE_SESSION_ID}`
  - Frontmatter complet: tous les champs disponibles avec exemples
  - Supporting files: `examples/`, `scripts/`, `reference.md`

- [ ] T024 - Mettre à jour les compteurs dans CLAUDE.md
  - Commandes: 118 → 119 (ajout /qa-chrome)
  - Agents: 56 → 57 (ajout qa-chrome)
  - Skills: 40 → 41 (ajout qa-chrome)
  - Rules: 20 → 21 (ajout lsp)

**Checkpoint** : Documentation complète et à jour.

---

## Dépendances et Ordre d'Exécution

```
Phase 1 (LSP) ──────────┐
Phase 2 (Hooks) ─────────┼──▶ Phase 5 (Documentation CLAUDE.md)
Phase 3 (Skills) ────────┤
Phase 4 (Chrome) ────────┘
```

### Opportunités de parallélisation

- **Phases 1, 2, 3, 4** : entièrement parallèles (fichiers différents)
- **Phase 5** : dépend de toutes les autres (doit refléter les changements)
- Au sein de Phase 3 : T012, T013, T014, T015 sont parallèles
- Au sein de Phase 4 : T016, T017, T018 sont parallèles

---

## Stratégie d'Implémentation

### Ordre recommandé (séquentiel)

1. Phase 1 (LSP) - nouveaux fichiers, aucun risque
2. Phase 2 (Hooks) - modification settings.json, attention JSON
3. Phase 3 (Skills) - bulk update 40 fichiers
4. Phase 4 (Chrome) - nouveaux fichiers, aucun risque
5. Phase 5 (Documentation) - reflète tous les changements

### Avec parallélisation

```bash
# Lancer en parallèle:
Agent 1: Phase 1 (LSP) + Phase 4 (Chrome)     # Nouveaux fichiers uniquement
Agent 2: Phase 2 (Hooks)                        # settings.json
Agent 3: Phase 3 (Skills)                       # 40× SKILL.md

# Puis séquentiellement:
Agent principal: Phase 5 (Documentation)        # CLAUDE.md final
```

---

**Version**: 1.0 | **Créé**: 2026-01-30
