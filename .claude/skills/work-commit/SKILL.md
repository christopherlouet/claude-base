---
name: work-commit
description: Génère des messages de commit clairs suivant Conventional Commits. Utiliser quand l'utilisateur veut commiter, demande un message de commit, ou après avoir terminé une modification.
allowed-tools:
  - Bash
  - Read
  - Grep
context: fork
---

# Génération de Messages de Commit

## Format Conventional Commits

```
type(scope): description courte (< 50 caractères)

[corps optionnel - détails sur le "quoi" et "pourquoi"]

[footer optionnel - références issues, breaking changes]
```

## Instructions

### 1. Analyser les changements

```bash
# Voir les fichiers modifiés
git status --short

# Voir le diff détaillé
git diff --staged

# Si rien n'est staged, voir les changements non-staged
git diff
```

### 2. Déterminer le type

| Type | Utilisation |
|------|-------------|
| `feat` | Nouvelle fonctionnalité |
| `fix` | Correction de bug |
| `refactor` | Refactoring sans changement fonctionnel |
| `test` | Ajout ou modification de tests |
| `docs` | Documentation uniquement |
| `style` | Formatage, pas de changement de code |
| `chore` | Maintenance, dépendances |
| `perf` | Amélioration de performance |

### 3. Identifier le scope

Le scope indique la partie du code affectée:
- Nom du module: `auth`, `api`, `ui`
- Nom du composant: `button`, `modal`
- Fonctionnalité: `login`, `checkout`

### 4. Rédiger la description

- **Impératif présent**: "add" pas "added" ou "adds"
- **Minuscule**: pas de majuscule au début
- **Pas de point final**
- **< 50 caractères**

### 5. Commiter

```bash
git add [fichiers]
git commit -m "type(scope): description"
```

Ou avec corps:
```bash
git commit -m "type(scope): description

- Détail 1
- Détail 2

Refs: #123"
```

## Règles

- UN commit = UN changement logique
- Message clair pour quelqu'un qui ne connaît pas le contexte
- Expliquer le POURQUOI, pas le COMMENT (le code montre le comment)
- Référencer les issues si applicable

## Exemples

### Bons messages
```
feat(auth): add OAuth2 login support
fix(api): handle null response from external service
refactor(utils): extract date formatting to separate module
test(cart): add unit tests for price calculation
docs(readme): update installation instructions
```

### Mauvais messages
```
❌ "fix bug"                    → Trop vague
❌ "Update code"                → Non informatif
❌ "WIP"                        → Ne pas commiter du WIP
❌ "feat: Add new feature..."   → Redondant
```
