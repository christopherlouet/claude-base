# Tâches : Intégration Agent Teams Natif et Documentation Swarm

**Input**: `specs/agent-teams/spec.md`, `specs/agent-teams/plan.md`
**Prérequis**: Plan validé

---

## Format des tâches : `[ID] [P?] [US?] Description`

- **[P]** : Peut être exécutée en parallèle (fichiers différents, pas de dépendances)
- **[US1-US7]** : User story associée (pour traçabilité)
- Chemins de fichiers exacts inclus

---

## Phase 1 : Activation et Configuration (bloquant)

**Objectif** : Permettre l'activation d'Agent Teams et fournir les instructions de base

**⚠️ CRITIQUE** : Les phases suivantes dépendent de la création du SKILL.md

- [ ] T001 - [US1] Créer le skill principal dans `.claude/skills/agent-teams/SKILL.md`
  - Frontmatter: name, description, allowed-tools, context: fork
  - Mots-clés déclencheurs: "agent team", "équipe d'agents", "swarm", "parallèle agents"
  - Section activation: variable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`
  - Section prérequis: Claude Code >= 2.1.19, tmux optionnel
  - Section quand utiliser vs ne pas utiliser (tableau comparatif sub-agents vs Agent Teams)
  - Cycle de vie: créer équipe → spawn teammates → coordonner → shutdown → cleanup
  - Raccourcis clavier: Shift+Up/Down (navigation), Shift+Tab (delegate mode), Ctrl+T (task list)
  - Bonnes pratiques: 2-5 teammates, 5-6 tâches par agent, isolation fichiers
  - Limitations connues (pas de resume, un team par session, pas d'imbrication)
  - Référence vers `@patterns.md` pour les patterns pré-configurés

- [ ] T002 - [US1] Documenter l'activation dans `docs/reference/advanced-features.md`
  - Remplacer les 3 lignes existantes (section "Agent Teams") par une section complète
  - Contenu: activation, modes d'affichage, comparaison sub-agents vs Agent Teams
  - Configuration settings.json et variables d'environnement

**Checkpoint** : Le skill est créé, l'activation est documentée.

---

## Phase 2 : Patterns pré-configurés

**Objectif** : Fournir 4 patterns prêts à l'emploi (audit, feature, debug, review)

- [ ] T003 - [P] [US5] Créer les patterns dans `.claude/skills/agent-teams/patterns.md`
  - **Pattern Audit** (3-4 teammates): security + perf + a11y (+ design optionnel)
  - **Pattern Feature** (2-3 teammates): frontend + backend + tests
  - **Pattern Debug** (3-5 teammates): hypothèses concurrentes, adversarial
  - **Pattern Review** (3 teammates): security + perf + coverage
  - Pour chaque pattern: nom, description, rôles, prompt de spawn recommandé, cas d'usage, limitations

- [ ] T004 - [P] [US2] Enrichir le SKILL.md avec l'exemple audit parallèle
  - Scénario complet: lancement, coordination, rapport consolidé
  - Prompt de spawn recommandé pour chaque auditeur
  - Gestion de l'échec d'un auditeur

- [ ] T005 - [P] [US3] Enrichir le SKILL.md avec l'exemple feature en équipe
  - Scénario complet: répartition par couche, coordination, merge
  - Gestion des dépendances entre tâches
  - Plan approval workflow pour les teammates

**Checkpoint** : Les 4 patterns sont documentés avec exemples concrets.

---

## Phase 3 : Commande et intégration

**Objectif** : Créer la commande `/work:work-team` et le pattern debug

- [ ] T006 - [US1] Créer la commande dans `.claude/commands/work/work-team.md`
  - Argument `$ARGUMENTS` pour description de la tâche
  - Détection du type de tâche (audit, feature, debug, review, custom)
  - Vérification prérequis (Agent Teams activé ?)
  - Guidage: choix du pattern ou création custom
  - Instructions pour le lead: spawn, coordinate, synthesize, cleanup
  - Suggestion mode delegate pour les équipes > 3 teammates
  - Lien vers la doc et les patterns

- [ ] T007 - [US4] Ajouter le pattern debug dans le SKILL.md
  - Scénario: hypothèses concurrentes adversariales
  - Prompt de spawn recommandé pour les enquêteurs
  - Communication entre agents (partage de preuves)
  - Synthèse: consensus sur la cause racine

**Checkpoint** : `/work:work-team` est fonctionnel avec tous les patterns.

---

## Phase 4 : Documentation et mise à jour du socle

**Objectif** : Cohérence de toute la documentation

- [ ] T008 - [P] [US6] Section Agent Teams complète dans `docs/reference/advanced-features.md`
  - Activation et configuration
  - Modes d'affichage (in-process, tmux, auto)
  - Tableau comparatif: sub-agents vs Agent Teams vs sessions parallèles manuelles
  - Variables d'environnement (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`, `CLAUDE_CODE_TASK_LIST_ID`)
  - Raccourcis clavier (Shift+Up/Down, Shift+Tab, Ctrl+T)
  - Limitations et dépannage
  - Exemples d'usage avec patterns du socle

- [ ] T009 - [P] [US6] Mettre à jour `docs/reference/agents-catalog.md`
  - Ajouter section "Agent Teams" dans l'introduction
  - Mentionner la coordination native entre agents existants
  - Mettre à jour le nombre de skills (41 → 42)

- [ ] T010 - [P] [US6] Mettre à jour `docs/reference/skills-catalog.md`
  - Ajouter le skill `agent-teams` dans le tableau des skills additionnels
  - Mots-clés: "agent team", "swarm", "équipe", "parallèle agents"

- [ ] T011 - [P] [US7] Mettre à jour `docs/reference/commands.md`
  - Ajouter `--teammate-mode` dans les CLI Flags Avancés
  - Ajouter `/work:work-team` dans les commandes (si section listée)

- [ ] T012 - [P] [US6] Mettre à jour `CLAUDE.md`
  - Ajouter le workflow Agent Teams dans "Workflows Recommandés"
  - Exemple: `/work:work-team "audit complet"` ou `/work:work-team "feature multi-couches"`
  - Mettre à jour les compteurs (skills, commandes) dans l'import `agents-catalog.md`

- [ ] T013 - [US6] Mettre à jour `.claude/skills/parallel-agents/SKILL.md`
  - Ajouter section "Agent Teams natif (recommandé pour équipes > 2 agents)"
  - Tableau comparatif: sub-agents Task parallèles vs Agent Teams
  - Recommandation: utiliser Agent Teams pour orchestration complexe, sub-agents pour tâches focalisées
  - Lien vers le skill `agent-teams`

**Checkpoint** : Toute la documentation est cohérente et les compteurs sont à jour.

---

## Phase 5 : Polish et Validation

**Objectif** : Vérification finale

- [ ] T014 - Relecture croisée de tous les fichiers créés/modifiés
  - Vérifier la cohérence des informations entre fichiers
  - Vérifier que tous les liens internes sont valides
  - S'assurer qu'il n'y a pas de doublons d'information

- [ ] T015 - Vérifier les compteurs du socle
  - Nombre de commandes (120 → 121 avec work-team)
  - Nombre de skills (41 → 42 avec agent-teams)
  - Mettre à jour dans: CLAUDE.md, agents-catalog.md, settings.json (si applicable)

---

## Dépendances et Ordre d'Exécution

### Dépendances entre phases

```
Phase 1 (T001, T002) ──── Activation/SKILL.md de base
     │
     ├──▶ Phase 2 (T003, T004, T005) ──── Patterns (parallélisable)
     │         │
     │         ▼
     ├──▶ Phase 3 (T006, T007) ──── Commande + pattern debug
     │
     └──▶ Phase 4 (T008-T013) ──── Documentation (parallélisable)

Phase 3 + Phase 4 ──▶ Phase 5 (T014, T015) ──── Validation
```

### Dépendances entre user stories

| Story | Peut commencer après | Dépendances |
|-------|---------------------|-------------|
| US1 (Activation) | Immédiat | Aucune |
| US2 (Audit parallèle) | Phase 1 (SKILL.md créé) | US1 |
| US3 (Feature en équipe) | Phase 1 (SKILL.md créé) | US1 |
| US4 (Debug hypothèses) | Phase 1 (SKILL.md créé) | US1 |
| US5 (Patterns) | Phase 1 (SKILL.md créé) | US1 |
| US6 (Documentation) | Phase 1 (activation documentée) | US1 |
| US7 (Mode affichage) | Phase 1 (activation documentée) | US1 |

### Opportunités de parallélisation

- **Phase 2** : T003, T004, T005 sur des fichiers/sections différents → [P]
- **Phase 4** : T008 à T012 sur des fichiers différents → [P]

---

## Stratégie d'Implémentation

### MVP First (Phase 1 + 2)

1. Compléter Phase 1: SKILL.md de base + activation documentée
2. Compléter Phase 2: Patterns pré-configurés
3. **STOP et VALIDER**: Tester le lancement d'un audit parallèle
4. Si OK, continuer avec Phase 3 et 4

### Livraison Incrémentale

1. Phase 1 → Activation fonctionnelle
2. Phase 2 → Patterns utilisables
3. Phase 3 → Commande `/work:work-team` disponible
4. Phase 4 → Documentation complète
5. Phase 5 → Validation et commit

---

## Estimation

| Phase | Complexité | Fichiers | Lignes estimées |
|-------|-----------|----------|-----------------|
| Phase 1 | Moyenne | 2 fichiers (1 créé, 1 modifié) | ~200 lignes |
| Phase 2 | Moyenne | 2 fichiers (1 créé, 1 modifié) | ~250 lignes |
| Phase 3 | Simple | 2 fichiers (1 créé, 1 modifié) | ~150 lignes |
| Phase 4 | Simple | 6 fichiers modifiés | ~150 lignes |
| Phase 5 | Simple | Relecture | ~0 lignes |
| **Total** | **Moyenne** | **3 créés + 8 modifiés** | **~750 lignes** |

---

**Version**: 1.0 | **Créé**: 2026-02-06
