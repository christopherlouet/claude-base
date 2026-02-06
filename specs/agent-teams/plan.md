# Plan d'implémentation : Intégration Agent Teams Natif et Documentation Swarm

**Branche**: `feature/agent-teams`
**Date**: 2026-02-06
**Spec**: [specs/agent-teams/spec.md](spec.md)
**Statut**: Draft

---

## Résumé

Intégrer la fonctionnalité native Agent Teams (TeammateTool) de Claude Code dans le socle via :
1. Un skill `agent-teams` avec patterns pré-configurés (fichier de référence `patterns.md`)
2. Une commande `/work:work-team` pour l'usage direct
3. L'enrichissement de `/assistant` pour détecter quand une équipe est bénéfique
4. La mise à jour de la documentation et du CLAUDE.md
5. La mise à jour du skill `parallel-agents` pour référencer Agent Teams

---

## Contexte Technique

| Aspect | Choix | Notes |
|--------|-------|-------|
| **Type de projet** | Socle Claude Code (configuration) | Fichiers .md, .json |
| **Langage** | Markdown + YAML frontmatter | Pas de code applicatif |
| **Fonctionnalité cible** | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Feature flag Claude Code |
| **Prérequis** | Claude Code >= 2.1.19 | Agent Teams experimental |
| **Tests** | Manuels (lancement d'équipe) | Pas de tests unitaires pour du .md |

### Contraintes

- Pas de code applicatif : uniquement des fichiers de configuration (.md, .json)
- Doit s'intégrer sans casser les 120 commandes, 57 agents et 41 skills existants
- Les 57 agents existants ne sont PAS modifiés
- Le skill `parallel-agents` est enrichi (pas remplacé) pour garder la compatibilité

### Performance attendue

| Métrique | Cible |
|----------|-------|
| Lancement d'une équipe 3 agents | < 30 secondes |
| Gain audit parallèle vs séquentiel | > 40% |

---

## Vérification Conventions

- [x] Respecte les conventions du projet (CLAUDE.md)
- [x] Cohérent avec l'architecture existante (commands/, skills/, agents/)
- [x] Pas d'over-engineering (on utilise le natif, pas de framework custom)
- [ ] Tests planifiés (manuels - vérification de lancement)

---

## Structure du Projet

### Documentation (cette feature)

```
specs/agent-teams/
├── spec.md           # Spécification fonctionnelle (existant)
├── plan.md           # Ce fichier
└── tasks.md          # Découpage en tâches
```

### Fichiers du socle

```
.claude/
├── skills/
│   ├── agent-teams/         # NOUVEAU - Skill Agent Teams
│   │   ├── SKILL.md         # Instructions du skill
│   │   └── patterns.md      # Patterns pré-configurés
│   └── parallel-agents/
│       └── SKILL.md         # MODIFIÉ - Référence vers Agent Teams
├── commands/
│   └── work/
│       └── work-team.md     # NOUVEAU - Commande /work:work-team
└── settings.local.json      # MODIFIÉ - Variable d'env Agent Teams

docs/
└── reference/
    └── advanced-features.md  # MODIFIÉ - Section Agent Teams enrichie

CLAUDE.md                     # MODIFIÉ - Workflow Agent Teams ajouté
```

---

## Fichiers Impactés

### À créer

| Fichier | Responsabilité | US |
|---------|----------------|----|
| `.claude/skills/agent-teams/SKILL.md` | Skill principal avec instructions d'orchestration | US1, US2, US3 |
| `.claude/skills/agent-teams/patterns.md` | 4 patterns pré-configurés (audit, feature, debug, review) | US5 |
| `.claude/commands/work/work-team.md` | Commande `/work:work-team` pour lancement direct | US1, US6 |

### À modifier

| Fichier | Modification | US |
|---------|-------------|-----|
| `.claude/skills/parallel-agents/SKILL.md` | Ajouter section "Agent Teams natif" avec lien et comparaison | US6 |
| `docs/reference/advanced-features.md` | Enrichir la section Agent Teams (3 lignes → section complète) | US6, US7 |
| `docs/reference/agents-catalog.md` | Ajouter Agent Teams dans les fonctionnalités | US6 |
| `docs/reference/commands.md` | Ajouter les CLI flags Agent Teams | US7 |
| `docs/reference/skills-catalog.md` | Ajouter le skill `agent-teams` | US6 |
| `CLAUDE.md` | Ajouter workflow Agent Teams dans les workflows recommandés | US6 |

---

## Approche Choisie

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   Utilisateur                                                   │
│       │                                                         │
│       ├──→ /work:work-team "audit complet"                      │
│       │         │                                               │
│       │         ▼                                               │
│       │    Skill agent-teams/SKILL.md                           │
│       │         │                                               │
│       │         ├──→ patterns.md (choix du pattern)             │
│       │         │                                               │
│       │         ▼                                               │
│       │    TeammateTool natif (Claude Code)                     │
│       │         │                                               │
│       │         ├──→ Teammate 1 (qa-security)                   │
│       │         ├──→ Teammate 2 (qa-perf)                       │
│       │         └──→ Teammate 3 (qa-a11y)                       │
│       │                                                         │
│       └──→ /assistant "tâche complexe"                          │
│                 │                                               │
│                 ▼                                               │
│            Détecte besoin d'équipe → suggère /work:work-team    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Justification

On utilise le **TeammateTool natif** de Claude Code plutôt qu'un système custom car :
- Gestion du cycle de vie intégrée (spawn, messages, shutdown, cleanup)
- tmux/iTerm2 natif (split panes automatiques)
- Shared task list avec file locking
- Pas de maintenance côté socle

### Alternatives considérées

| Alternative | Pourquoi rejetée |
|-------------|------------------|
| Outil custom type claude-flow | Over-engineering, maintenance lourde, le natif fait le travail |
| Script bash d'orchestration tmux | Fragile, pas de messaging inter-agents, réinvente la roue |
| Enrichir uniquement `parallel-agents` | Le skill actuel utilise les sub-agents Task, pas Agent Teams |

---

## Phases d'Implémentation

### Phase 1 : Activation et Configuration (bloquant) [US1]

**Objectif**: Permettre l'activation d'Agent Teams dans le socle

- [ ] T001 - [US1] Créer `.claude/skills/agent-teams/SKILL.md` avec instructions de base
- [ ] T002 - [US1] Documenter l'activation dans `docs/reference/advanced-features.md`

**Checkpoint**: Un utilisateur peut activer Agent Teams et lancer une équipe basique.

### Phase 2 : Patterns pré-configurés (P1 MVP) [US2, US3, US5]

**Objectif**: Fournir des patterns prêts à l'emploi pour les cas d'usage principaux

- [ ] T003 - [P] [US5] Créer `.claude/skills/agent-teams/patterns.md` avec les 4 patterns
- [ ] T004 - [P] [US2] Enrichir le SKILL.md avec le pattern audit parallèle
- [ ] T005 - [P] [US3] Enrichir le SKILL.md avec le pattern feature en équipe

**Checkpoint**: Les patterns audit, feature, debug et review sont utilisables.

### Phase 3 : Commande et intégration [US1, US4]

**Objectif**: Créer la commande dédiée et intégrer avec l'orchestrateur

- [ ] T006 - [US1] Créer `.claude/commands/work/work-team.md`
- [ ] T007 - [US4] Ajouter le pattern debug dans le SKILL.md

**Checkpoint**: `/work:work-team` fonctionne avec tous les patterns.

### Phase 4 : Documentation et mise à jour du socle [US6, US7]

**Objectif**: Documentation complète et mise à jour de tous les fichiers de référence

- [ ] T008 - [P] [US6] Enrichir `docs/reference/advanced-features.md` section Agent Teams
- [ ] T009 - [P] [US6] Mettre à jour `docs/reference/agents-catalog.md`
- [ ] T010 - [P] [US6] Mettre à jour `docs/reference/skills-catalog.md`
- [ ] T011 - [P] [US7] Mettre à jour `docs/reference/commands.md` avec les CLI flags
- [ ] T012 - [P] [US6] Mettre à jour `CLAUDE.md` avec le workflow Agent Teams
- [ ] T013 - [US6] Mettre à jour `.claude/skills/parallel-agents/SKILL.md`

**Checkpoint**: Toute la documentation est cohérente et à jour.

### Phase 5 : Polish et Validation

**Objectif**: Vérification finale de la cohérence

- [ ] T014 - Relecture croisée de tous les fichiers créés/modifiés
- [ ] T015 - Vérifier la cohérence des compteurs (nombre de skills, commandes)

---

## Risques et Mitigations

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Agent Teams encore experimental, API peut changer | Élevé | Moyenne | Documenter la dépendance, mentionner le flag experimental |
| tmux non disponible sur certains environnements | Faible | Moyenne | Documenter le mode in-process comme fallback |
| Confusion entre sub-agents existants et Agent Teams | Moyen | Élevée | Tableau comparatif clair dans la doc et le SKILL.md |
| Compteurs du socle deviennent incorrects (120 commandes, 41 skills...) | Faible | Élevée | Mettre à jour les compteurs dans CLAUDE.md et agents-catalog.md |

---

## Dépendances et Ordre d'Exécution

### Dépendances entre phases

```
Phase 1 (Activation) ──┬──▶ Phase 2 (Patterns) ──▶ Phase 3 (Commande)
                        │
                        └──▶ Phase 4 (Documentation) [peut démarrer après Phase 1]

Phase 3 + Phase 4 ──────────▶ Phase 5 (Polish)
```

### Tâches parallélisables

- **Phase 2** : T003, T004, T005 sont indépendants (fichiers différents)
- **Phase 4** : T008 à T012 sont indépendants (fichiers différents)

---

## Critères de Validation

### Avant de commencer (Gate 1)
- [x] Spec approuvée (v1.1 avec clarifications résolues)
- [ ] Plan reviewé par l'utilisateur

### Avant chaque merge (Gate 2)
- [ ] Fichiers créés correspondent au plan
- [ ] Documentation cohérente entre fichiers
- [ ] Compteurs mis à jour (skills, commandes)

### Avant déploiement (Gate 3)
- [ ] Tous les critères de succès de la spec vérifiés (CS-001 à CS-006)
- [ ] Un utilisateur peut lancer `/work:work-team "audit complet"` avec succès
- [ ] Documentation complète et liens valides

---

## Notes

- Ce plan ne contient pas de code applicatif : tous les fichiers sont des .md ou .json
- Le TDD classique ne s'applique pas ici car il n'y a pas de code à tester unitairement
- La validation se fait par relecture et test manuel de lancement d'équipe
- Les 57 agents existants ne sont PAS modifiés, seuls les fichiers de référence changent

---

**Version**: 1.0 | **Créé**: 2026-02-06 | **Dernière modification**: 2026-02-06
