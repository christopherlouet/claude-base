---
sidebar_position: 53
title: "work-pr"
description: "Créer une Pull Request complète et bien documentée. Utiliser quand l'utilisateur veut créer une PR, soumettre ses changements, ou préparer une demande de merge."
tags:
  - "skill"
  - "fork"
---

# Skill: work-pr

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Créer une Pull Request complète et bien documentée. Utiliser quand l'utilisateur veut créer une PR, soumettre ses changements, ou préparer une demande de merge.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Bash`, `Grep`, `Glob` |
| **Mots-cles** | `work`, `fix bug` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux work..."_
- _"Je veux fix bug..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple de Pull Request

# Exemple de Pull Request

## Contexte
Ajout d'un système de pagination pour la liste des produits.

## Vérifications pré-PR

```bash
# État
git status
# On branch feature/pagination
# nothing to commit, working tree clean

# Différences
git diff main...HEAD --stat
# src/components/ProductList.tsx  | 45 ++++++++--
# src/hooks/usePagination.ts      | 32 +++++++
# src/services/products.ts        | 15 ++-
# src/types/pagination.ts         |  8 ++
# tests/usePagination.test.ts     | 67 ++++++++++++++
# 5 files changed, 158 insertions(+), 9 deletions(-)

# Tests
npm test
# ✅ All tests passed

# Lint
npm run lint
# ✅ No errors

# Build
npm run build
# ✅ Build successful
```

## PR créée

### Titre
```
feat(products): ajouter pagination à la liste des produits
```

### Corps de la PR

```markdown
## Description

Ajoute un système de pagination côté serveur pour la liste des produits,
permettant de gérer efficacement les catalogues volumineux (+10k produits).

## Type de changement

- [x] New feature (changement non-breaking qui ajoute une fonctionnalité)
- [ ] Bug fix
- [ ] Breaking change
- [ ] Refactoring

## Changements

### Ajouts
- `src/hooks/usePagination.ts` - Hook réutilisable de pagination
- `src/types/pagination.ts` - Types TypeScript pour la pagination
- `tests/usePagination.test.ts` - Tests unitaires du hook

### Modifications
- `src/components/ProductList.tsx` - Intégration de la pagination
- `src/services/products.ts` - Support des paramètres page/limit

## Comment tester

1. Lancer l'application: `npm run dev`
2. Aller sur `/products`
3. Vérifier que:
   - La liste affiche 20 produits par page
   - Les boutons "Précédent/Suivant" fonctionnent
   - L'URL se met à jour avec `?page=X`
   - Le compteur total est affiché

## Tests

- [x] Tests unitaires ajoutés (coverage: 94%)
- [x] Tests manuels effectués
- [ ] Tests E2E (à ajouter dans une PR suivante)

## Checklist

- [x] Mon code suit les conventions du projet
- [x] J'ai fait une self-review de mon code
- [x] Les noms de variables sont explicites
- [x] Pas de `console.log` oubliés
- [x] Les tests passent localement
- [x] Build réussi

## Screenshots

### Avant
![Liste sans pagination](before.png)
*Liste complète chargée d'un coup (lent)*

### Après
![Liste avec pagination](after.png)
*20 produits par page avec navigation*

## Performance

| Métrique | Avant | Après |
|----------|-------|-------|
| Time to First Byte | 2.3s | 0.4s |
| Largest Contentful Paint | 3.1s | 0.8s |
| Données transférées | 2.4MB | 45KB |

## Notes pour les reviewers

- Le hook `usePagination` est générique et pourra être réutilisé
  pour d'autres listes (commandes, utilisateurs, etc.)
- J'ai choisi 20 items par page basé sur les best practices UX
- La pagination est côté serveur pour les performances

Fixes #234
```

### Commande de création

```bash
gh pr create \
  --title "feat(products): ajouter pagination à la liste des produits" \
  --body-file PR_BODY.md \
  --base main \
  --head feature/pagination \
  --reviewer "@team/frontend" \
  --label "feature,frontend,needs-review" \
  --milestone "v2.1.0"
```

## Résultat

```
Creating pull request for feature/pagination into main

https://github.com/example/app/pull/456
```

**PR #456 créée avec succès.**



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
