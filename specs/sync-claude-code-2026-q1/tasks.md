# Tâches : Synchronisation Claude Code Q1 2026

**Input**: `specs/sync-claude-code-2026-q1/plan.md`, `specs/sync-claude-code-2026-q1/spec.md`
**Prérequis**: Plan validé, branche créée

---

## Format : `[ID] [P?] [US?] Description — fichier`

---

## Phase 1 : Hooks settings.json (US1 + US2 + US5) — BLOQUANT

**Objectif** : Ajouter les nouveaux hooks de cycle de vie, passer les existants en async, renforcer sécurité SessionStart

**Test indépendant** : `jq . .claude/settings.json` + démarrer une session

### Nouveaux hooks (US1)

- [ ] T001 - [US1] Ajouter hook `PostCompact` (logging async) dans `.claude/settings.json`
  - Ajouter après le bloc `PreCompact` existant (ligne ~376)
  - Pattern : `echo "[COMPACT] Post-compaction $(date)" >> /tmp/claude-sessions.log`
  - Propriétés : `async: true`, `onFailure: "ignore"`, `timeout: 5000`

- [ ] T002 - [US1] Ajouter hook `TeammateIdle` (logging async) dans `.claude/settings.json`
  - Nouveau bloc après `SubagentStop`
  - Pattern : `echo "[TEAM] Teammate idle $(date)" >> /tmp/claude-agents.log`
  - Propriétés : `async: true`, `onFailure: "ignore"`, `timeout: 5000`

- [ ] T003 - [US1] Ajouter hook `TaskCompleted` (logging async) dans `.claude/settings.json`
  - Nouveau bloc
  - Pattern : `echo "[TASK] Task completed $(date)" >> /tmp/claude-sessions.log`
  - Propriétés : `async: true`, `onFailure: "ignore"`, `timeout: 5000`

- [ ] T004 - [US1] Ajouter hook `InstructionsLoaded` (logging async) dans `.claude/settings.json`
  - Nouveau bloc
  - Pattern : `echo "[INIT] Instructions loaded $(date)" >> /tmp/claude-sessions.log`
  - Propriétés : `async: true`, `onFailure: "ignore"`, `timeout: 5000`

### Passage en async des hooks existants (US2)

- [ ] T005 - [US2] Ajouter `"async": true` aux hooks de logging existants dans `.claude/settings.json`
  - `SessionEnd` (ligne ~353) : ajouter `"async": true`
  - `PreCompact` (ligne ~365) : ajouter `"async": true`
  - `SubagentStop` (ligne ~341) : ajouter `"async": true`
  - `Notification` — permission_prompt (ligne ~317) : ajouter `"async": true`
  - `Notification` — idle_prompt (ligne ~329) : ajouter `"async": true`
  - NE PAS toucher : PreToolUse (sécurité), PostToolUse (formatage), Setup, SessionStart

### Hooks sécurité SessionStart (US5)

- [ ] T006 - [US5] Ajouter hook SessionStart : vérifier `.env` dans `.gitignore` — `.claude/settings.json`
  - Ajouter dans le tableau `SessionStart` (après les 2 hooks existants)
  - Pattern : `if [ -f .env ] && [ -f .gitignore ]; then if ! grep -qx ".env" .gitignore && ! grep -qx "*.env" .gitignore; then echo "[SECURITY] .env existe mais n est pas dans .gitignore!"; fi; fi`
  - Propriétés : `timeout: 3000`, `onFailure: "ignore"`

- [ ] T007 - [US5] Ajouter hook SessionStart : warning hooks personnalisés — `.claude/settings.json`
  - Ajouter dans le tableau `SessionStart`
  - Pattern : vérifier si `.claude/settings.json` du projet (pas le socle) contient des hooks custom
  - Propriétés : `timeout: 3000`, `onFailure: "ignore"`

**Checkpoint Phase 1** : `jq . .claude/settings.json` valide. Session démarre. Logs dans `/tmp/claude-*.log`.

---

## Phase 2 : Hooks Elicitation (US7)

**Objectif** : Ajouter les hooks MCP Elicitation

- [ ] T008 - [US7] Ajouter hooks `Elicitation` et `ElicitationResult` (logging async) dans `.claude/settings.json`
  - Deux nouveaux blocs
  - Pattern Elicitation : `echo "[MCP] Elicitation request $(date)" >> /tmp/claude-mcp.log`
  - Pattern ElicitationResult : `echo "[MCP] Elicitation result $(date)" >> /tmp/claude-mcp.log`
  - Propriétés : `async: true`, `onFailure: "ignore"`, `timeout: 5000`

**Checkpoint Phase 2** : JSON valide. 2 nouveaux blocs ajoutés.

---

## Phase 3 : Documentation hooks (US1 + US2 + US3 + US8)

**Objectif** : Mettre à jour la documentation des hooks existants et nouveaux

- [ ] T009 - [P] [US8] Ajouter nouveaux events dans table hooks-reference.md — `docs/reference/hooks-reference.md`
  - Ajouter dans la table "Hook events disponibles" :
    - `PostCompact` : Se déclenche après la compaction du contexte
    - `TeammateIdle` : Se déclenche quand un agent teammate devient inactif
    - `TaskCompleted` : Se déclenche quand une tâche est marquée terminée
    - `InstructionsLoaded` : Se déclenche quand CLAUDE.md et rules sont chargés
    - `Elicitation` : Se déclenche quand un serveur MCP demande un input structuré
    - `ElicitationResult` : Se déclenche quand l'utilisateur répond à une Elicitation

- [ ] T010 - [P] [US8] Ajouter hooks configurés dans table hooks-reference.md — `docs/reference/hooks-reference.md`
  - Ajouter dans la table "Hooks configurés" les 6 nouveaux hooks avec description
  - Ajouter colonne ou note "async" pour les hooks passés en mode asynchrone

- [ ] T011 - [P] [US3] Ajouter section HTTP Hooks dans advanced-features.md — `docs/reference/advanced-features.md`
  - Nouvelle section après MCP Configuration
  - Contenu : description `"type": "http"`, exemple webhook générique (URL, headers, body)
  - Mentionner : async recommandé, onFailure: "ignore", timeout

- [ ] T012 - [P] [US2] Ajouter section Async Hooks dans advanced-features.md — `docs/reference/advanced-features.md`
  - Nouvelle section
  - Contenu : propriété `"async": true`, quand l'utiliser, quand ne pas l'utiliser
  - Table : hooks sync (sécurité) vs hooks async (logging/notification)

**Checkpoint Phase 3** : Documentation hooks complète. Cohérente avec settings.json.

---

## Phase 4 : Documentation features (US4 + US6 + US7) — PARALLÉLISABLE

**Objectif** : Documenter sparsePaths, Claude Code Security, MCP Elicitation

- [ ] T013 - [P] [US4] Ajouter section sparsePaths dans git-worktrees SKILL — `.claude/skills/git-worktrees/SKILL.md`
  - Ajouter après la section "Best Practices" (~ligne 191)
  - Contenu : description `worktree.sparsePaths`, configuration dans settings
  - Exemples : monorepo frontend/backend/shared, packages sélectifs
  - Format : tableau + bloc de config JSON

- [ ] T014 - [P] [US6] Ajouter section Claude Code Security dans advanced-features.md — `docs/reference/advanced-features.md`
  - Nouvelle section
  - Contenu : description, prérequis (Enterprise/Team), comment activer
  - Lien avec `/qa:qa-security` comme complément

- [ ] T015 - [P] [US7] Ajouter section MCP Elicitation dans advanced-features.md — `docs/reference/advanced-features.md`
  - Ajouter dans la section MCP Configuration existante
  - Contenu : description Elicitation, hooks associés, cas d'usage

- [ ] T016 - [P] [US6] Mention Claude Code Security dans pattern Audit — `.claude/skills/agent-teams/patterns.md`
  - Ajouter dans le Pattern 1 (Audit Parallele, ~ligne 36)
  - Note : "Pour les équipes Enterprise/Team, Claude Code Security peut compléter cet audit"

**Checkpoint Phase 4** : Nouvelles features documentées dans les bons fichiers.

---

## Phase 5 : Sécurité (US5) — PARALLÉLISABLE

**Objectif** : Documenter les risques sécurité hooks/MCP

- [ ] T017 - [US5] Ajouter section risques dépôts tiers dans security.md — `.claude/rules/security.md`
  - Ajouter après la section "Dependencies" (~ligne 52)
  - Contenu : 3 vecteurs d'attaque (hooks malveillants, MCP non-fiables, exfiltration env vars)
  - Bonnes pratiques : vérifier settings.json des dépôts clonés, MCP désactivés par défaut, .env dans .gitignore

**Checkpoint Phase 5** : Rule security couvre les risques hooks/MCP.

---

## Phase 6 : Validation & Compteurs (US8) — GATE FINALE

**Objectif** : Tout valider avant merge

- [ ] T018 - [US8] Exécuter `scripts/validate-counts.sh` et corriger écarts
  - Vérifier compteurs : commands, agents, skills, rules
  - Vérifier documentation : CLAUDE.md, README, website si applicable

- [ ] T019 - [US8] Exécuter tests bats — `scripts/test.sh`
  - 258 tests existants doivent passer
  - Aucune régression acceptée

- [ ] T020 - [US8] Test manuel : démarrer session Claude Code
  - Vérifier : hook SessionStart affiche version + compteurs corrects
  - Vérifier : pas d'erreur au démarrage
  - Vérifier : logs dans `/tmp/claude-sessions.log` pour nouveaux hooks

**Checkpoint Phase 6** : Tout vert. Prêt pour commit/PR.

---

## Dépendances et Ordre d'Exécution

```
Phase 1 (Hooks settings.json)  ◄──── BLOQUE Phase 2 et 3
     │
     ├──▶ Phase 2 (Elicitation)
     │
     └──▶ Phase 3 (Doc hooks)  ──┐
                                  │
Phase 4 (Doc features) [P] ─────┤
                                  │
Phase 5 (Sécurité) [P] ─────────┤
                                  │
                                  ▼
                          Phase 6 (Validation)
```

### Dépendances entre user stories

| Story | Peut commencer après | Dépendances |
|-------|---------------------|-------------|
| US1 (P1) | Immédiatement | Aucune |
| US2 (P1) | Phase 1 T001-T004 | Même fichier que US1 |
| US5 (P1) | Phase 1 T005 | Même fichier settings.json |
| US3 (P2) | Phase 1 | Doc seulement |
| US4 (P2) | Immédiatement | Fichier indépendant |
| US6 (P2) | Immédiatement | Fichiers indépendants |
| US7 (P3) | Phase 1 | Hooks + doc |
| US8 (P1) | Toutes les phases | Gate finale |

### Opportunités de parallélisation

- **T001-T004** : séquentiels (même fichier settings.json)
- **T009-T012** : parallélisables (sections indépendantes)
- **T013-T016** : parallélisables (fichiers différents)
- **Phases 3, 4, 5** : parallélisables entre elles

---

## Stratégie d'Implémentation

### MVP (US1 + US2 + US5 + US8 uniquement)

1. Phase 1 : Hooks settings.json → commit atomique
2. Phase 3 : Doc hooks → commit atomique
3. Phase 5 : Sécurité → commit atomique
4. Phase 6 : Validation → corrections si nécessaire
5. **STOP et VALIDER**

### Livraison complète (toutes US)

6. Phase 2 : Elicitation → commit
7. Phase 4 : Doc features → commit
8. Phase 6 : Validation finale → PR

---

**Version**: 1.0 | **Créé**: 2026-03-14
