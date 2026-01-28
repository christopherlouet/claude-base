---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.dart"
  - "**/*.rs"
---

# Verification Before Completion

## Principe

Toute implementation doit etre verifiee AVANT d'etre consideree comme terminee.
Ne jamais presumer qu'un fix fonctionne sans le prouver.

## Checklist de verification obligatoire

### Apres un fix de bug

```
[ ] Le bug original est reproduit
[ ] Le fix corrige effectivement le probleme
[ ] Les tests existants passent toujours
[ ] Un test de non-regression est ajoute
[ ] Pas d'effets de bord detectes
```

### Apres une nouvelle feature

```
[ ] La feature fonctionne comme specifie
[ ] Les edge cases sont geres (null, vide, limites)
[ ] Les tests couvrent le happy path ET les erreurs
[ ] Le code compile/lint sans warning
[ ] La feature n'a pas degrade les performances
```

### Apres un refactoring

```
[ ] Le comportement est identique avant/apres
[ ] Les tests passent sans modification
[ ] Pas de regression fonctionnelle
[ ] Le code est effectivement plus simple/lisible
```

## Methode de verification

### 1. Verification automatisee

```bash
# Lancer les tests
npm test           # ou pytest, go test, flutter test

# Verifier les types
npm run typecheck  # ou mypy, go vet

# Lancer le linter
npm run lint       # ou ruff, golangci-lint
```

### 2. Verification manuelle

- Relire le diff complet (`git diff`)
- Verifier que chaque changement est intentionnel
- S'assurer qu'aucun debug/TODO n'est reste
- Confirmer que les imports inutiles sont supprimes

### 3. Defense en profondeur

- Ajouter des assertions sur les invariants critiques
- Valider les preconditions en entree de fonction
- Logger les etats inattendus sans crasher

## Regles

IMPORTANT: Ne JAMAIS dire "c'est corrige" sans avoir lance les tests.

IMPORTANT: Toujours verifier le diff complet avant de commiter.

NEVER presumer qu'un changement est safe. Le prouver.
