# Plan d'implémentation : [NOM DE LA FEATURE]

**Branche**: `feature/[nom-court]`
**Date**: [DATE]
**Spec**: [lien vers spec.md]
**Statut**: Draft | Validé | En cours

---

## Résumé

[Extraire de la spec: exigence principale + approche technique choisie]

---

## Contexte Technique

<!--
  ACTION REQUISE: Remplacer avec les détails techniques du projet.
-->

| Aspect | Choix | Notes |
|--------|-------|-------|
| **Langage/Version** | [ex: TypeScript 5.x, Python 3.11] | |
| **Framework** | [ex: Next.js 14, FastAPI] | |
| **Dépendances principales** | [ex: Prisma, React Query] | |
| **Base de données** | [ex: PostgreSQL, MongoDB] | Si applicable |
| **Tests** | [ex: Jest, Vitest, pytest] | |
| **Plateforme cible** | [ex: Web, Mobile, API] | |

### Contraintes

- [Contrainte 1: ex: "Doit fonctionner offline"]
- [Contrainte 2: ex: "Compatibilité IE11 non requise"]

### Performance attendue

| Métrique | Cible |
|----------|-------|
| Temps de réponse | < [X]ms |
| Utilisateurs simultanés | [N] |
| Disponibilité | [X]% |

---

## Vérification Constitution/Conventions

*GATE: Doit être validé avant de commencer l'implémentation.*

- [ ] Respecte les conventions du projet (voir CLAUDE.md)
- [ ] Cohérent avec l'architecture existante
- [ ] Pas d'over-engineering
- [ ] Tests planifiés

---

## Structure du Projet

### Documentation (cette feature)

```
specs/[feature]/
├── spec.md           # Spécification fonctionnelle
├── plan.md           # Ce fichier
├── tasks.md          # Découpage en tâches (généré par /work:work-plan)
├── clarifications.md # Historique des clarifications (si applicable)
└── research.md       # Notes de recherche technique (si applicable)
```

### Code Source

<!--
  ACTION REQUISE: Adapter selon la structure du projet.
-->

```
src/
├── [module]/
│   ├── components/     # Composants UI (si applicable)
│   ├── services/       # Logique métier
│   ├── types/          # Types/Interfaces
│   └── utils/          # Utilitaires
└── tests/
    ├── unit/           # Tests unitaires
    └── integration/    # Tests d'intégration
```

---

## Fichiers Impactés

### À créer

| Fichier | Responsabilité |
|---------|----------------|
| `src/services/[feature].ts` | [Description du service] |
| `src/types/[feature].ts` | [Types et interfaces] |
| `src/components/[Feature].tsx` | [Composant principal] |

### À modifier

| Fichier | Modification |
|---------|--------------|
| `src/routes/index.ts` | [Ajout de route] |
| `src/config/index.ts` | [Nouvelle configuration] |

### Tests à ajouter

| Fichier | Couverture |
|---------|------------|
| `tests/unit/[feature].test.ts` | [Cas testés] |
| `tests/integration/[feature].test.ts` | [Flux testés] |

---

## Approche Choisie

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   [Composant/Module A]                                          │
│          │                                                      │
│          ▼                                                      │
│   [Composant/Module B] ─────────▶ [Composant/Module C]          │
│          │                              │                       │
│          ▼                              ▼                       │
│   [Service/Repository]           [Service externe]              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Justification

[Expliquer pourquoi cette approche a été choisie plutôt qu'une autre]

### Alternatives considérées

| Alternative | Pourquoi rejetée |
|-------------|------------------|
| [Alternative 1] | [Raison] |
| [Alternative 2] | [Raison] |

---

## Phases d'Implémentation

### Phase 1 : Fondation (bloquant)

**Objectif**: Infrastructure de base nécessaire à toutes les user stories

- [ ] T001 - Créer la structure des fichiers
- [ ] T002 - Définir les types/interfaces
- [ ] T003 - Configurer les dépendances

**Checkpoint**: Structure prête, les user stories peuvent commencer.

### Phase 2 : User Story 1 (P1 - MVP) 🎯

**Objectif**: [Reprendre l'objectif de US1 depuis la spec]

#### Tests (si TDD)
- [ ] T004 - [P] Test unitaire [composant]
- [ ] T005 - [P] Test intégration [flux]

#### Implémentation
- [ ] T006 - [P] Implémenter [modèle/entité]
- [ ] T007 - Implémenter [service] (dépend de T006)
- [ ] T008 - Implémenter [endpoint/composant] (dépend de T007)

**Checkpoint**: US1 fonctionnelle et testable indépendamment.

### Phase 3 : User Story 2 (P2)

**Objectif**: [Reprendre l'objectif de US2 depuis la spec]

- [ ] T009 - [P] Implémenter [composant]
- [ ] T010 - Intégrer avec Phase 2 (si nécessaire)

**Checkpoint**: US2 fonctionnelle.

### Phase 4 : User Story 3 (P3)

**Objectif**: [Reprendre l'objectif de US3 depuis la spec]

- [ ] T011 - [P] Implémenter [composant]
- [ ] T012 - Tests complémentaires

**Checkpoint**: Toutes les user stories fonctionnelles.

### Phase 5 : Polish & Qualité

- [ ] T013 - [P] Documentation
- [ ] T014 - [P] Tests additionnels
- [ ] T015 - Refactoring si nécessaire
- [ ] T016 - Code review

---

## Risques et Mitigations

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| [Risque 1] | Élevé | Moyenne | [Action préventive] |
| [Risque 2] | Moyen | Faible | [Plan de secours] |
| [Risque 3] | Faible | Élevée | [Accepté / Surveillé] |

---

## Dépendances et Ordre d'Exécution

### Dépendances entre phases

```
Phase 1 (Fondation) ──┬──▶ Phase 2 (US1 - MVP)
                      │
                      ├──▶ Phase 3 (US2) [peut démarrer après Phase 1]
                      │
                      └──▶ Phase 4 (US3) [peut démarrer après Phase 1]

Phases 2, 3, 4 ──────────▶ Phase 5 (Polish)
```

### Tâches parallélisables

- **[P]** indique qu'une tâche peut être exécutée en parallèle
- Les tâches sans [P] ont des dépendances et doivent être séquentielles

---

## Critères de Validation

### Avant de commencer (Gate 1)
- [ ] Spec approuvée
- [ ] Plan reviewé
- [ ] Environnement de dev prêt

### Avant chaque merge (Gate 2)
- [ ] Tests passent
- [ ] Linting/formatting OK
- [ ] Code review approuvée

### Avant déploiement (Gate 3)
- [ ] Tous les critères de succès de la spec vérifiés
- [ ] Documentation à jour
- [ ] Tests d'intégration passent

---

## Notes

<!--
  Notes additionnelles, décisions prises pendant la planification,
  liens vers des ressources, etc.
-->

---

**Version**: 1.0 | **Créé**: [DATE] | **Dernière modification**: [DATE]
