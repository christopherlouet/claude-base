---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.dart"
  - "**/*.py"
  - "**/*.go"
  - "**/*.rs"
  - "**/*.java"
  - "**/*.cs"
  - "**/*.rb"
  - "**/*.php"
---

# TDD Enforcement Rules

## Declenchement Proactif du TDD

IMPORTANT: Quand l'utilisateur demande d'implementer, ajouter, creer, fixer ou corriger du code, Claude DOIT proposer l'approche TDD AVANT de commencer a coder.

### Mots-cles declencheurs

Proposer TDD automatiquement quand l'utilisateur mentionne:
- "implementer", "implement"
- "ajouter", "add"
- "creer", "create"
- "fixer", "fix"
- "corriger", "correct"
- "nouvelle feature", "new feature"
- "bug", "bugfix"
- "fonctionnalite"
- "developper", "develop"
- "coder", "code"

### Comportement attendu

1. **AVANT toute modification de code source**:
   - Proposer: "Je recommande d'utiliser l'approche TDD. Voulez-vous que je commence par ecrire les tests ?"
   - Ou directement utiliser `/dev-tdd` si le contexte est clair

2. **Si l'utilisateur refuse TDD**:
   - Respecter son choix mais rappeler les risques
   - Documenter dans le commit que TDD n'a pas ete utilise

3. **Exceptions au TDD** (pas de proposition):
   - Fichiers de configuration (*.json, *.yaml, *.toml)
   - Documentation (*.md)
   - Scripts de build/deploy
   - Refactoring mineur (renommage, formatage)
   - Corrections de typos

### Rappels systematiques

YOU MUST rappeler le cycle TDD quand vous modifiez du code:

```
Cycle TDD:
1. RED   - Ecrire un test qui echoue
2. GREEN - Ecrire le code minimal pour passer
3. REFACTOR - Ameliorer sans casser les tests
```

### Integration avec les commandes

Quand une commande de developpement est utilisee (`/dev-component`, `/dev-api`, `/dev-hook`, etc.), Claude DOIT:
1. Verifier si des tests existent pour le code concerne
2. Si non, proposer de commencer par les tests
3. Si oui, s'assurer que les tests passent avant modification

### Validation pre-commit

AVANT de proposer un commit:
- Verifier que les tests existent pour le nouveau code
- Verifier que les tests passent
- Couverture minimum 80% sur le nouveau code

### Anti-patterns a bloquer

NEVER:
- Ecrire du code d'implementation avant les tests
- Proposer de "tester plus tard"
- Ignorer les tests pour "aller plus vite"
- Modifier les tests pour les faire passer (au lieu de corriger le code)
