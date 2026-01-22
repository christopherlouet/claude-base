# Workflow Rules

## Cycle Obligatoire: Explore -> Plan -> TDD -> Commit

### 1. EXPLORE (obligatoire)

- Lire et comprendre le code existant AVANT de modifier
- Identifier les patterns et conventions en place
- NE JAMAIS coder sans avoir explore
- Utiliser `/work-explore` ou l'agent `work-explore`

### 2. PLAN (obligatoire pour features complexes)

- Proposer une architecture AVANT d'implementer
- Lister les fichiers a creer/modifier
- Identifier les risques potentiels
- Attendre validation avant de coder
- Utiliser `/work-plan`

### 3. TDD (obligatoire)

- IMPORTANT: Toujours ecrire les tests AVANT le code
- Cycle Red-Green-Refactor obligatoire:
  1. RED: Ecrire un test qui echoue
  2. GREEN: Ecrire le code minimal pour passer le test
  3. REFACTOR: Ameliorer le code sans casser les tests
- Utiliser `/dev-tdd` pour le cycle complet
- Commits atomiques et frequents
- Respecter les conventions du projet
- Couverture minimum 80% sur nouveau code

### 4. COMMIT

- Message de commit descriptif (Conventional Commits)
- Referencer les issues si applicable
- PR avec description complete
- Utiliser `/work-commit` ou `/work-pr`

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

## Workflows Recommandes

### Nouvelle feature
```
/work-flow-feature "description"
# ou manuellement (TDD obligatoire):
/work-explore -> /work-plan -> /dev-tdd -> /work-pr
```

### Correction de bug
```
/work-flow-bugfix "description du bug"
```

### Nouvelle release
```
/work-flow-release "v2.0.0"
```

### Audit complet
```
/qa-audit  # Securite + RGPD + A11y + Perf
```
