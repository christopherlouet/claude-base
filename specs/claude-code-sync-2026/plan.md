# Plan d'implémentation : Synchronisation Doc Officielle Claude Code 2026

**Branche**: `feature/claude-code-sync-2026`
**Date**: 2026-01-30
**Statut**: Draft

---

## Résumé

Mettre à jour le socle claude-socle pour intégrer les nouveautés de la documentation officielle Claude Code (janvier 2026) : configuration LSP, hooks manquants (Setup, SubagentStop, Notification, prompt-based), mise à jour du frontmatter des skills, intégration Chrome, et documentation des nouveaux CLI flags.

---

## Contexte Technique

| Aspect | Choix | Notes |
|--------|-------|-------|
| **Type de projet** | Template/Socle Claude Code | Pas d'app, uniquement config |
| **Fichiers impactés** | Markdown, JSON, scripts bash | Pas de code applicatif |
| **Tests** | Validation manuelle | Pas de tests unitaires (config) |
| **Plateforme** | Claude Code CLI 2.1+ | Minimum v2.1.0 |

### Contraintes

- Rétrocompatibilité : ne pas casser les skills/agents/hooks existants
- Les nouveaux champs frontmatter sont tous optionnels (safe to add)
- Le `.lsp.json` est un nouveau fichier (pas de conflit)
- Les hooks ajoutés ne doivent pas ralentir le démarrage

---

## Fichiers Impactés

### À créer

| Fichier | Responsabilité |
|---------|----------------|
| `.lsp.json` | Configuration LSP par défaut (11 langages) |
| `.claude/skills/qa-chrome/SKILL.md` | Skill tests visuels Chrome |
| `.claude/agents/qa-chrome.md` | Agent audit visuel Chrome |
| `.claude/commands/qa/qa-chrome.md` | Commande `/qa-chrome` |
| `scripts/hooks/setup-deps.sh` | Script hook Setup pour install dépendances |
| `.claude/rules/lsp.md` | Règle pour l'utilisation LSP |

### À modifier

| Fichier | Modification |
|---------|--------------|
| `.claude/settings.json` | Ajouter hooks Setup, Notification, SubagentStop, SessionEnd, PreCompact |
| `CLAUDE.md` | Ajouter sections LSP, CLI flags, Chrome, hooks, bonnes pratiques skills |
| `.claude/rules/README.md` | Ajouter la règle LSP |
| 40× `.claude/skills/*/SKILL.md` | Ajouter frontmatter: `disable-model-invocation`, `argument-hint`, `model` |
| `.claude/skills/writing-skills/SKILL.md` | Mettre à jour avec les nouveaux champs frontmatter |

---

## Approche Choisie

### Architecture des changements

```
┌─────────────────────────────────────────────────────────────────┐
│                    MODIFICATIONS PAR AXE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  AXE 2: LSP              AXE 5: Chrome                         │
│  ┌──────────┐            ┌──────────────┐                       │
│  │ .lsp.json│            │ skill        │                       │
│  │ rule     │            │ agent        │                       │
│  │ CLAUDE.md│            │ command      │                       │
│  └──────────┘            │ CLAUDE.md    │                       │
│                          └──────────────┘                       │
│  AXE 3: Hooks                                                   │
│  ┌──────────────────────┐                                       │
│  │ settings.json        │                                       │
│  │ setup-deps.sh        │                                       │
│  │ CLAUDE.md            │                                       │
│  └──────────────────────┘                                       │
│                                                                 │
│  AXE 4: Skills Frontmatter    AXE 6: Doc CLI                   │
│  ┌──────────────────────┐    ┌──────────────┐                   │
│  │ 40× SKILL.md         │    │ CLAUDE.md    │                   │
│  │ writing-skills       │    └──────────────┘                   │
│  └──────────────────────┘                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Justification

- Modifications additives uniquement (pas de breaking changes)
- Chaque axe est indépendant et peut être développé en parallèle
- Les fichiers `.lsp.json` et Chrome sont entièrement nouveaux
- Les modifications de frontmatter sont rétrocompatibles (champs optionnels)

---

## Phases d'Implémentation

### Phase 1 : LSP Configuration (P1) [P]

**Objectif** : Ajouter le support LSP au socle

- [ ] T001 - [P] Créer `.lsp.json` avec config pour 11 langages
- [ ] T002 - [P] Créer `.claude/rules/lsp.md` (règle path-specific)
- [ ] T003 - Mettre à jour `.claude/rules/README.md` (ajouter entrée lsp)

### Phase 2 : Hooks manquants (P1) [P]

**Objectif** : Ajouter les hook events manquants dans settings.json

- [ ] T004 - Créer `scripts/hooks/setup-deps.sh` (hook Setup)
- [ ] T005 - Ajouter hook `Setup` dans `.claude/settings.json`
- [ ] T006 - Ajouter hook `Notification` dans `.claude/settings.json`
- [ ] T007 - Ajouter hook `SubagentStop` dans `.claude/settings.json`
- [ ] T008 - Ajouter hook `SessionEnd` dans `.claude/settings.json`
- [ ] T009 - Ajouter hook `PreCompact` dans `.claude/settings.json`
- [ ] T010 - Ajouter hook prompt-based `Stop` dans `.claude/settings.json`

### Phase 3 : Frontmatter Skills (P1) [P]

**Objectif** : Enrichir les skills avec les nouveaux champs frontmatter

- [ ] T011 - Mettre à jour `writing-skills/SKILL.md` avec la doc des nouveaux champs
- [ ] T012 - [P] Ajouter `disable-model-invocation: true` aux skills manuels (work-commit, work-pr, work-plan, work-explore, ops-docker, ops-ci, ops-database, ops-monitoring, doc-generate, doc-changelog)
- [ ] T013 - [P] Ajouter `argument-hint` aux skills qui prennent des arguments (dev-tdd, dev-debug, dev-api, dev-flutter, dev-refactor, qa-security, qa-perf, ops-infra-code, ops-proxmox, ops-opnsense)
- [ ] T014 - [P] Ajouter `model` aux skills qui bénéficient d'un modèle spécifique (qa-security→sonnet, dev-tdd→sonnet, dev-debug→sonnet, qa-perf→sonnet)
- [ ] T015 - [P] Ajouter `user-invocable: false` aux skills background-only (state-management, api-mocking, feature-flags)

### Phase 4 : Chrome Integration (P2) [P]

**Objectif** : Créer le triplet skill/agent/command pour les tests Chrome

- [ ] T016 - [P] Créer `.claude/skills/qa-chrome/SKILL.md`
- [ ] T017 - [P] Créer `.claude/agents/qa-chrome.md`
- [ ] T018 - [P] Créer `.claude/commands/qa/qa-chrome.md`

### Phase 5 : Documentation CLAUDE.md (P1)

**Objectif** : Documenter toutes les nouveautés dans CLAUDE.md

- [ ] T019 - Ajouter section "LSP (Language Server Protocol)" dans CLAUDE.md
- [ ] T020 - Ajouter section "CLI Flags Avancés" dans CLAUDE.md
- [ ] T021 - Ajouter section "Chrome Integration" dans CLAUDE.md
- [ ] T022 - Mettre à jour la section Hooks avec les nouveaux events
- [ ] T023 - Ajouter section "Bonnes pratiques Skills" dans CLAUDE.md
- [ ] T024 - Mettre à jour les compteurs (commandes, agents, skills)

---

## Risques et Mitigations

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Hook Setup ralentit le démarrage | Moyen | Faible | Timeout 10s, script optimisé, conditionnel |
| Trop de champs frontmatter surchargent les skills | Faible | Moyenne | N'ajouter que les champs pertinents par skill |
| LSP non disponible sur toutes les machines | Faible | Élevée | Config désactivée par défaut, doc d'activation |
| Chrome non installé partout | Faible | Élevée | Flag `--chrome` optionnel, skill conditionnel |

---

## Dépendances et Ordre d'Exécution

### Dépendances entre phases

```
Phase 1 (LSP) ──────────┐
Phase 2 (Hooks) ─────────┼──▶ Phase 5 (Documentation)
Phase 3 (Skills) ────────┤
Phase 4 (Chrome) ────────┘
```

### Tâches parallélisables

- **Phases 1-4 sont entièrement parallèles** entre elles
- Au sein de chaque phase, les tâches marquées [P] sont parallèles
- Phase 5 dépend de toutes les autres (documentation finale)

---

## Critères de Validation

- [ ] `.lsp.json` valide et bien documenté
- [ ] Tous les nouveaux hooks dans settings.json (syntaxe JSON valide)
- [ ] 40 skills mis à jour avec les nouveaux champs frontmatter
- [ ] Triplet Chrome (skill/agent/command) créé
- [ ] CLAUDE.md mis à jour avec toutes les nouveautés
- [ ] Compteurs à jour dans CLAUDE.md
- [ ] Aucun skill/agent existant cassé

---

**Version**: 1.0 | **Créé**: 2026-01-30
