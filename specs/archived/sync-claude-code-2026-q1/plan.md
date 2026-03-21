# Plan d'implémentation : Synchronisation Claude Code Q1 2026

**Branche**: `feature/sync-claude-code-2026-q1`
**Date**: 2026-03-14
**Spec**: `specs/sync-claude-code-2026-q1/spec.md`
**Statut**: Draft

---

## Résumé

Ajouter les nouveaux hooks Claude Code CLI (PostCompact, TeammateIdle, TaskCompleted, InstructionsLoaded, Elicitation), passer les hooks de logging en mode async, ajouter un template HTTP hook générique, renforcer la sécurité (vérification .env/.gitignore, warning hooks tiers), documenter worktree.sparsePaths, Claude Code Security et MCP Elicitation, et mettre à jour tous les compteurs.

---

## Contexte Technique

| Aspect | Choix | Notes |
|--------|-------|-------|
| **Format principal** | JSON (settings.json) + Markdown (docs/skills) | |
| **Shell** | Bash (scripts, hooks) | POSIX-compatible |
| **Tests** | bats (258 tests existants) | `scripts/test.sh` |
| **Validation** | `scripts/validate-counts.sh` | Compteurs auto |
| **CLI minimum** | Claude Code >= 2.1.70 | Hooks async/HTTP |

### Contraintes

- Les hooks non reconnus par d'anciennes CLI sont ignorés silencieusement (rétrocompat assurée)
- Le JSON de settings.json doit rester valide (pas de commentaires possibles)
- Les hooks HTTP templates doivent être dans la documentation uniquement (pas dans settings.json car impossible de les désactiver en JSON)
- Chaque hook async doit garder `onFailure: "ignore"`

---

## Fichiers Impactés

### À modifier

| Fichier | Modification | US |
|---------|-------------|-----|
| `.claude/settings.json` | Ajouter 5 nouveaux hooks (PostCompact, TeammateIdle, TaskCompleted, InstructionsLoaded, Elicitation) + passer hooks logging en async + ajouter hooks sécurité SessionStart | US1, US2, US5 |
| `docs/reference/hooks-reference.md` | Ajouter lignes dans les 3 tables (events, types, configurés) + section async + section HTTP | US1, US2, US3, US8 |
| `docs/reference/advanced-features.md` | Ajouter sections : Async Hooks, HTTP Hooks, MCP Elicitation, worktree.sparsePaths, Claude Code Security | US3, US4, US6, US7, US8 |
| `.claude/skills/git-worktrees/SKILL.md` | Ajouter section sparsePaths avec exemples monorepo | US4 |
| `.claude/skills/agent-teams/patterns.md` | Ajouter mention Claude Code Security dans pattern Audit | US6 |
| `.claude/rules/security.md` | Ajouter section sur risques hooks/MCP de dépôts tiers | US5 |
| `scripts/validate-counts.sh` | Vérifier que les compteurs hooks sont validés | US8 |

### Tests à vérifier

| Fichier | Couverture |
|---------|------------|
| `tests/` (bats existants) | Vérifier que les tests existants passent toujours |
| `scripts/validate-counts.sh` | Exécuter après modifications pour valider compteurs |

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│  settings.json (coeur)                                           │
│  ├── SessionStart ──── [+] Vérif .env/.gitignore (US5)          │
│  │                     [+] Warning hooks tiers (US5)             │
│  ├── PostCompact ───── [NOUVEAU] Logging async (US1)             │
│  ├── TeammateIdle ──── [NOUVEAU] Logging async (US1)             │
│  ├── TaskCompleted ─── [NOUVEAU] Logging async (US1)             │
│  ├── InstructionsLoaded [NOUVEAU] Logging async (US1)            │
│  ├── Elicitation ───── [NOUVEAU] Logging async (US7)             │
│  ├── ElicitationResult [NOUVEAU] Logging async (US7)             │
│  ├── SessionEnd ────── [MOD] +async: true (US2)                  │
│  ├── PreCompact ────── [MOD] +async: true (US2)                  │
│  ├── SubagentStop ──── [MOD] +async: true (US2)                  │
│  └── Notification ──── [MOD] +async: true (US2)                  │
│                                                                  │
│  Documentation                                                   │
│  ├── hooks-reference.md ── Tables mises à jour (US8)             │
│  ├── advanced-features.md  Nouvelles sections (US3,4,6,7)        │
│  ├── security.md ───────── Section dépôts tiers (US5)            │
│  ├── git-worktrees/SKILL.md Section sparsePaths (US4)            │
│  └── agent-teams/patterns.md Mention Security (US6)              │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Justification

Approche incrémentale : modifier les fichiers existants sans restructurer. Les nouveaux hooks suivent le même pattern que les hooks existants (logging dans `/tmp/claude-*.log`). Le passage en async est un changement minimal (`"async": true` dans le JSON).

### Alternatives considérées

| Alternative | Pourquoi rejetée |
|-------------|------------------|
| Refonte complète du système de hooks | Hors scope, risque de régression élevé |
| HTTP hooks dans settings.json | Impossible de les désactiver proprement en JSON, mieux en doc |
| Scan actif bloquant des dépôts tiers | Risque de faux positifs (décision clarification Q3) |

---

## Phases d'Implémentation

### Phase 1 : Hooks settings.json (US1 + US2 + US5)

**Objectif**: Ajouter les nouveaux hooks et passer les existants en async

- [ ] T001 - [US1] Ajouter hook `PostCompact` dans `.claude/settings.json` (logging async)
- [ ] T002 - [US1] Ajouter hook `TeammateIdle` dans `.claude/settings.json` (logging async)
- [ ] T003 - [US1] Ajouter hook `TaskCompleted` dans `.claude/settings.json` (logging async)
- [ ] T004 - [US1] Ajouter hook `InstructionsLoaded` dans `.claude/settings.json` (logging async)
- [ ] T005 - [US2] Passer hooks existants en async : `SessionEnd`, `PreCompact`, `SubagentStop`, `Notification` (2 hooks)
- [ ] T006 - [US5] Ajouter hook SessionStart : vérification `.env` dans `.gitignore`
- [ ] T007 - [US5] Ajouter hook SessionStart : warning si hooks personnalisés détectés dans le projet

**Checkpoint**: Tous les hooks fonctionnent. JSON valide. Session démarre sans erreur.

### Phase 2 : Hooks Elicitation (US7)

**Objectif**: Ajouter les hooks MCP Elicitation (P3 mais dépend de Phase 1 pour cohérence)

- [ ] T008 - [US7] Ajouter hooks `Elicitation` et `ElicitationResult` dans `.claude/settings.json` (logging async)

**Checkpoint**: Hooks Elicitation présents dans settings.json.

### Phase 3 : Documentation hooks (US1 + US2 + US3 + US8)

**Objectif**: Mettre à jour la documentation des hooks

- [ ] T009 - [P] [US8] Mettre à jour `docs/reference/hooks-reference.md` : ajouter nouveaux events dans la table
- [ ] T010 - [P] [US8] Mettre à jour `docs/reference/hooks-reference.md` : ajouter hooks configurés dans la table
- [ ] T011 - [P] [US3] Ajouter section HTTP Hooks dans `docs/reference/advanced-features.md` avec exemple webhook générique
- [ ] T012 - [P] [US2] Ajouter section Async Hooks dans `docs/reference/advanced-features.md`

**Checkpoint**: Documentation hooks complète et cohérente.

### Phase 4 : Documentation features (US4 + US6 + US7)

**Objectif**: Documenter sparsePaths, Claude Code Security, MCP Elicitation

- [ ] T013 - [P] [US4] Ajouter section `worktree.sparsePaths` dans `.claude/skills/git-worktrees/SKILL.md`
- [ ] T014 - [P] [US6] Ajouter section Claude Code Security dans `docs/reference/advanced-features.md`
- [ ] T015 - [P] [US7] Ajouter section MCP Elicitation dans `docs/reference/advanced-features.md`
- [ ] T016 - [P] [US6] Ajouter mention Claude Code Security dans `.claude/skills/agent-teams/patterns.md` (pattern Audit)

**Checkpoint**: Toutes les nouvelles features documentées.

### Phase 5 : Sécurité (US5)

**Objectif**: Renforcer la documentation sécurité

- [ ] T017 - [US5] Ajouter section risques hooks/MCP dépôts tiers dans `.claude/rules/security.md`

**Checkpoint**: Guide sécurité couvre les 3 vecteurs (hooks, MCP, env vars).

### Phase 6 : Validation & Compteurs (US8)

**Objectif**: S'assurer que tout est cohérent

- [ ] T018 - [US8] Exécuter `scripts/validate-counts.sh` et corriger les écarts
- [ ] T019 - [US8] Exécuter les tests bats existants (`scripts/test.sh`)
- [ ] T020 - [US8] Vérification manuelle : démarrer une session Claude Code avec le socle mis à jour

**Checkpoint**: Tous les compteurs corrects. Tests passent. Session démarre proprement.

---

## Risques et Mitigations

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| JSON invalide dans settings.json | Élevé | Faible | Valider le JSON après chaque modification avec `jq .` |
| Hooks async non supportés par CLI ancienne | Moyen | Faible | Ignorés silencieusement par design CLI |
| Documentation incohérente avec settings.json | Moyen | Moyenne | T018 validate-counts.sh comme gate finale |
| Faux positifs du hook warning hooks tiers | Faible | Moyenne | Warning non-bloquant + message clair |

---

## Dépendances et Ordre d'Exécution

```
Phase 1 (Hooks settings.json) ──┬──▶ Phase 2 (Elicitation)
                                │
                                └──▶ Phase 3 (Doc hooks) ──┐
                                                            │
Phase 4 (Doc features) [P - indépendant] ──────────────────┤
                                                            │
Phase 5 (Sécurité) [P - indépendant] ─────────────────────┤
                                                            │
                                                            ▼
                                                    Phase 6 (Validation)
```

- **Phase 1** doit être terminée avant Phases 2 et 3
- **Phases 3, 4, 5** sont parallélisables entre elles
- **Phase 6** est la gate finale après toutes les autres

---

## Critères de Validation

### Avant de commencer (Gate 1)
- [x] Spec approuvée (clarifications résolues)
- [x] Plan reviewé
- [ ] Branche `feature/sync-claude-code-2026-q1` créée

### Après chaque phase (Gate 2)
- [ ] JSON valide (`jq . .claude/settings.json`)
- [ ] Pas de régression sur les tests existants

### Avant merge (Gate 3)
- [ ] `scripts/validate-counts.sh` passe
- [ ] `scripts/test.sh` passe
- [ ] Session Claude Code démarre sans erreur
- [ ] Nouveaux hooks se déclenchent dans les logs
- [ ] Documentation complète et cohérente

---

**Version**: 1.0 | **Créé**: 2026-03-14
