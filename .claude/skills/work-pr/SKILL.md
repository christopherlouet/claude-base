---
name: work-pr
description: Créer une Pull Request complète et bien documentée. Utiliser quand l'utilisateur veut créer une PR, soumettre ses changements, ou préparer une demande de merge.
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
context: fork
---

# Créer une Pull Request

## Objectif

Créer une PR complète, bien documentée, prête pour review.

## Instructions

### 1. Vérifier l'état

```bash
# État des changements
git status --short

# Différences avec la branche cible
git diff main...HEAD --stat

# Historique des commits
git log main...HEAD --oneline
```

### 2. Préparer la branche

```bash
# S'assurer d'être à jour
git fetch origin
git rebase origin/main  # ou merge selon convention

# Vérifier les tests
npm test

# Vérifier le lint
npm run lint
```

### 3. Template de PR

```markdown
## Description

[Résumé clair de ce que fait cette PR en 2-3 phrases]

## Type de changement

- [ ] Nouvelle fonctionnalité (feat)
- [ ] Correction de bug (fix)
- [ ] Refactoring (refactor)
- [ ] Documentation (docs)
- [ ] Autre: [préciser]

## Changements

### Ajouts
- [Fichier/fonction ajouté]

### Modifications
- [Fichier/fonction modifié]

### Suppressions
- [Fichier/fonction supprimé]

## Comment tester

1. [Étape de test 1]
2. [Étape de test 2]
3. Vérifier que [résultat attendu]

## Checklist

- [ ] Code auto-reviewé
- [ ] Tests ajoutés/mis à jour
- [ ] Documentation mise à jour
- [ ] Pas de console.log oubliés
- [ ] Lint passe
- [ ] Build passe

## Screenshots (si UI)

[Avant/Après si applicable]

## Issues liées

Fixes #[numéro] (ou Refs #[numéro])
```

### 4. Créer la PR

```bash
# Pousser la branche
git push -u origin $(git branch --show-current)

# Créer la PR avec GitHub CLI
gh pr create \
  --title "type(scope): description" \
  --body "$(cat PR_BODY.md)" \
  --base main
```

## Bonnes pratiques

| Faire | Ne pas faire |
|-------|--------------|
| Titre descriptif | "Fix bug" |
| Description complète | PR vide |
| Petites PRs focalisées | PRs géantes |
| Tests inclus | PR sans tests |
| Screenshots UI | Changements UI non documentés |

## Règles

- UNE PR = UN sujet
- Toujours inclure des tests
- Répondre aux commentaires rapidement
- Squash si historique bruyant
