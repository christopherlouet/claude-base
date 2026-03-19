# Workflow Rules

## Cycle Obligatoire: Explore -> Plan -> TDD -> Commit

### 0. CI BASELINE (recommande)

Avant de commencer a travailler sur un projet existant :

- Lancer lint, type-check et tests pour connaitre l'etat CI actuel
- Noter les erreurs PRE-EXISTANTES pour ne pas les confondre avec les nouvelles
- Si CI est deja en echec, le signaler a l'utilisateur avant de commencer

### 1. EXPLORE (obligatoire)

- Lire et comprendre le code existant AVANT de modifier
- Identifier les patterns et conventions en place
- NE JAMAIS coder sans avoir explore
- Utiliser `/work:work-explore` ou l'agent `work-explore`

### 2. PLAN (obligatoire pour features complexes)

- Proposer une architecture AVANT d'implementer
- Lister les fichiers a creer/modifier
- Identifier les risques potentiels
- Attendre validation avant de coder
- Utiliser `/work:work-plan`

### 3. TDD (obligatoire)

- IMPORTANT: Toujours ecrire les tests AVANT le code
- Cycle Red-Green-Refactor obligatoire:
  1. RED: Ecrire un test qui echoue
  2. GREEN: Ecrire le code minimal pour passer le test
  3. REFACTOR: Ameliorer le code sans casser les tests
- Utiliser `/dev:dev-tdd` pour le cycle complet
- Commits atomiques et frequents
- Respecter les conventions du projet
- Couverture minimum 80% sur nouveau code

### 4. COMMIT

- Message de commit descriptif (Conventional Commits)
- Referencer les issues si applicable
- PR avec description complete
- Utiliser `/work:work-commit` ou `/work:work-pr`

## Gestion du scope

Les sessions avec un scope trop large (15+ taches) generent systematiquement des regressions. Preferer des sessions focalisees :

| Scope | Approche recommandee |
|-------|---------------------|
| 1-5 taches | Session unique, workflow standard |
| 6-10 taches | Decouper en 2-3 commits logiques |
| 10-15 taches | Decouper en sessions separees par domaine |
| 15+ taches | STOP — decouper en features independantes, une PR par feature |

Signaux d'alerte :
- Plus de 10 fichiers modifies sans commit intermediaire → commiter maintenant
- Un fix introduit une regression → revert, commiter ce qui marche, traiter le reste separement
- Le scope grossit pendant le travail → s'arreter, commiter l'etat stable, replanifier

## Anti-patterns a Eviter

- Coder sans comprendre l'existant
- Implementer sans plan valide
- Coder AVANT d'ecrire les tests (violer TDD)
- Commits geants multi-fonctionnalites
- Tests avec trop de mocks
- `any` partout en TypeScript
- Copier-coller sans adapter
- Optimiser prematurement
- Ignorer les warnings de lint/types
- Sessions trop ambitieuses (15+ taches dans une session)
- Confondre erreurs CI pre-existantes et nouvelles erreurs

## Workflows Recommandes

### Nouvelle feature
```
/work:work-flow-feature "description"
# ou manuellement (TDD obligatoire):
/work:work-explore -> /work:work-plan -> /dev:dev-tdd -> /work:work-pr
```

### Correction de bug
```
/work:work-flow-bugfix "description du bug"
```

### Nouvelle release
```
/work:work-flow-release "v2.0.0"
```

### Audit complet
```
/qa:qa-audit  # Securite + RGPD + A11y + Perf (lecture seule)
```

### Audit + fix en boucle
```
/qa:qa-loop                  # Audit + fix P0/P1 jusqu'a score 85+
/qa:qa-loop "score 90"       # Score cible personnalise
```

### Deploiement securise
```
/ops:ops-deploy              # Checklist pre-deploy + deploy + post-deploy
```
