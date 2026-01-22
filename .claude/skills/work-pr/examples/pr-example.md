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
