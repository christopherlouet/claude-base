# Tâches : [NOM DE LA FEATURE]

**Input**: Documents de conception depuis `specs/[feature]/`
**Prérequis**: plan.md (requis), spec.md (requis pour user stories)

---

## Format des tâches : `[ID] [P?] [US?] Description`

- **[P]** : Peut être exécutée en parallèle (fichiers différents, pas de dépendances)
- **[US1/US2/US3]** : User story associée (pour traçabilité)
- Inclure les chemins de fichiers exacts dans les descriptions

---

## Conventions de chemins

- **Projet simple** : `src/`, `tests/` à la racine
- **Web app** : `backend/src/`, `frontend/src/`
- **Mobile** : `api/src/`, `ios/src/` ou `android/src/`

Adapter selon la structure définie dans plan.md.

---

## Phase 1 : Setup (Infrastructure partagée)

**Objectif** : Initialisation du projet et structure de base

- [ ] T001 - Créer la structure de fichiers selon le plan
- [ ] T002 - Initialiser les dépendances
- [ ] T003 - [P] Configurer linting et formatting

---

## Phase 2 : Fondation (Prérequis bloquants)

**Objectif** : Infrastructure de base qui DOIT être complète AVANT toute user story

**⚠️ CRITIQUE** : Aucune user story ne peut commencer avant la fin de cette phase

- [ ] T004 - Setup base de données et migrations (si applicable)
- [ ] T005 - [P] Configurer l'authentification (si applicable)
- [ ] T006 - [P] Setup routing et middleware
- [ ] T007 - Créer les modèles/entités de base partagés
- [ ] T008 - Configurer gestion des erreurs et logging

**Checkpoint** : Fondation prête - les user stories peuvent commencer.

---

## Phase 3 : User Story 1 - [Titre] (P1) 🎯 MVP

**Objectif** : [Description courte de ce que cette story livre]

**Test indépendant** : [Comment vérifier que cette story fonctionne seule]

### Tests pour US1 (optionnel - si TDD demandé) ⚠️

> **NOTE : Écrire ces tests EN PREMIER, s'assurer qu'ils ÉCHOUENT avant l'implémentation**

- [ ] T009 - [P] [US1] Test unitaire pour [composant] dans `tests/unit/[name].test.ts`
- [ ] T010 - [P] [US1] Test intégration pour [flux] dans `tests/integration/[name].test.ts`

### Implémentation US1

- [ ] T011 - [P] [US1] Créer [Entité1] dans `src/models/[entity1].ts`
- [ ] T012 - [P] [US1] Créer [Entité2] dans `src/models/[entity2].ts`
- [ ] T013 - [US1] Implémenter [Service] dans `src/services/[service].ts` (dépend T011, T012)
- [ ] T014 - [US1] Implémenter [endpoint/feature] dans `src/[location]/[file].ts`
- [ ] T015 - [US1] Ajouter validation et gestion d'erreurs
- [ ] T016 - [US1] Ajouter logging pour les opérations US1

**Checkpoint** : US1 est fonctionnelle et testable indépendamment.

---

## Phase 4 : User Story 2 - [Titre] (P2)

**Objectif** : [Description courte]

**Test indépendant** : [Comment vérifier que cette story fonctionne seule]

### Tests pour US2 (optionnel)

- [ ] T017 - [P] [US2] Test unitaire dans `tests/unit/[name].test.ts`
- [ ] T018 - [P] [US2] Test intégration dans `tests/integration/[name].test.ts`

### Implémentation US2

- [ ] T019 - [P] [US2] Créer [Entité] dans `src/models/[entity].ts`
- [ ] T020 - [US2] Implémenter [Service] dans `src/services/[service].ts`
- [ ] T021 - [US2] Implémenter [endpoint/feature] dans `src/[location]/[file].ts`
- [ ] T022 - [US2] Intégrer avec composants US1 (si nécessaire)

**Checkpoint** : US1 ET US2 fonctionnent indépendamment.

---

## Phase 5 : User Story 3 - [Titre] (P3)

**Objectif** : [Description courte]

**Test indépendant** : [Comment vérifier que cette story fonctionne seule]

### Tests pour US3 (optionnel)

- [ ] T023 - [P] [US3] Test unitaire dans `tests/unit/[name].test.ts`
- [ ] T024 - [P] [US3] Test intégration dans `tests/integration/[name].test.ts`

### Implémentation US3

- [ ] T025 - [P] [US3] Créer [Entité] dans `src/models/[entity].ts`
- [ ] T026 - [US3] Implémenter [Service] dans `src/services/[service].ts`
- [ ] T027 - [US3] Implémenter [endpoint/feature] dans `src/[location]/[file].ts`

**Checkpoint** : Toutes les user stories fonctionnent indépendamment.

---

## Phase N : Polish & Préoccupations transversales

**Objectif** : Améliorations qui touchent plusieurs user stories

- [ ] TXXX - [P] Mise à jour de la documentation dans `docs/`
- [ ] TXXX - Nettoyage et refactoring du code
- [ ] TXXX - Optimisation de performance
- [ ] TXXX - [P] Tests unitaires additionnels
- [ ] TXXX - Revue de sécurité
- [ ] TXXX - Validation finale

---

## Dépendances et Ordre d'Exécution

### Dépendances entre phases

```
Phase 1 (Setup)
     │
     ▼
Phase 2 (Fondation)  ◄──── BLOQUE toutes les user stories
     │
     ├──▶ Phase 3 (US1 - MVP)
     │
     ├──▶ Phase 4 (US2) [peut démarrer après Phase 2]
     │
     └──▶ Phase 5 (US3) [peut démarrer après Phase 2]

Toutes les phases ──▶ Phase N (Polish)
```

### Dépendances entre user stories

| Story | Peut commencer après | Dépendances |
|-------|---------------------|-------------|
| US1 (P1) | Phase 2 (Fondation) | Aucune autre story |
| US2 (P2) | Phase 2 (Fondation) | Peut intégrer avec US1 mais testable seule |
| US3 (P3) | Phase 2 (Fondation) | Peut intégrer avec US1/US2 mais testable seule |

### Au sein de chaque User Story

1. Tests (si TDD) DOIVENT être écrits et ÉCHOUER avant l'implémentation
2. Modèles avant services
3. Services avant endpoints
4. Implémentation core avant intégration
5. Story complète avant de passer à la suivante

### Opportunités de parallélisation

- Toutes les tâches marquées [P] peuvent être exécutées en parallèle
- Une fois la Phase 2 terminée, toutes les user stories peuvent démarrer en parallèle
- Les tests d'une story marqués [P] peuvent tourner en parallèle
- Les modèles marqués [P] peuvent être créés en parallèle

---

## Exemple de parallélisation : User Story 1

```bash
# Lancer tous les tests US1 ensemble (si TDD):
Task: "Test unitaire pour [composant] dans tests/unit/[name].test.ts"
Task: "Test intégration pour [flux] dans tests/integration/[name].test.ts"

# Lancer tous les modèles US1 ensemble:
Task: "Créer [Entité1] dans src/models/[entity1].ts"
Task: "Créer [Entité2] dans src/models/[entity2].ts"
```

---

## Stratégie d'Implémentation

### MVP First (US1 uniquement)

1. Compléter Phase 1: Setup
2. Compléter Phase 2: Fondation (CRITIQUE - bloque tout)
3. Compléter Phase 3: US1
4. **STOP et VALIDER**: Tester US1 indépendamment
5. Déployer/démontrer si prêt

### Livraison Incrémentale

1. Setup + Fondation → Base prête
2. Ajouter US1 → Tester → Déployer (MVP!)
3. Ajouter US2 → Tester → Déployer
4. Ajouter US3 → Tester → Déployer
5. Chaque story ajoute de la valeur sans casser les précédentes

### Stratégie Équipe (parallélisation)

Avec plusieurs développeurs:

1. L'équipe complète Setup + Fondation ensemble
2. Une fois Fondation terminée:
   - Dev A: User Story 1
   - Dev B: User Story 2
   - Dev C: User Story 3
3. Les stories se complètent et s'intègrent indépendamment

---

## Notes

- **[P]** tâches = fichiers différents, pas de dépendances
- **[US?]** label = traçabilité vers la user story
- Chaque user story doit être complétable et testable indépendamment
- Vérifier que les tests échouent avant d'implémenter (TDD)
- Commit après chaque tâche ou groupe logique
- S'arrêter à chaque checkpoint pour valider la story indépendamment

**À éviter**:
- Tâches vagues sans chemin de fichier
- Conflits sur le même fichier
- Dépendances cross-story qui cassent l'indépendance

---

**Version**: 1.0 | **Créé**: [DATE]
