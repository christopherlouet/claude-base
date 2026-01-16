# Agent WORK-FLOW-RELEASE

Workflow complet pour préparer et publier une release.

## Contexte
$ARGUMENTS

## Workflow automatisé

```
┌─────────────────────────────────────────────────────────────┐
│                    WORKFLOW RELEASE                          │
├─────────────────────────────────────────────────────────────┤
│  1. AUDIT      → Vérifier la qualité du code                │
│  2. CHANGELOG  → Mettre à jour le changelog                 │
│  3. VERSION    → Bump de version                            │
│  4. TEST       → Tests complets                             │
│  5. BUILD      → Build de production                        │
│  6. TAG        → Tag et release notes                       │
│  7. DEPLOY     → Déploiement                                │
└─────────────────────────────────────────────────────────────┘
```

---

## ÉTAPE 1/7 : AUDIT QUALITÉ

### Objectif
S'assurer que le code est prêt pour la release.

### Checks à effectuer
```bash
# Tests
npm test

# Lint
npm run lint

# Types
npm run typecheck

# Sécurité
npm audit

# Build
npm run build
```

### Critères de go/no-go

| Critère | Seuil | Status |
|---------|-------|--------|
| Tests | 100% pass | |
| Coverage | > 80% | |
| Lint | 0 errors | |
| Types | 0 errors | |
| Audit | 0 critical | |
| Build | Success | |

### Checklist audit
- [ ] Tous les tests passent
- [ ] Couverture suffisante
- [ ] Pas d'erreur lint
- [ ] Pas d'erreur TypeScript
- [ ] Pas de vulnérabilité critique
- [ ] Build réussi

---

## ÉTAPE 2/7 : CHANGELOG

### Objectif
Documenter tous les changements depuis la dernière release.

### Structure
```markdown
# Changelog

## [X.Y.Z] - YYYY-MM-DD

### Added
- Nouvelle fonctionnalité A
- Nouvelle fonctionnalité B

### Changed
- Modification de X
- Amélioration de Y

### Fixed
- Correction du bug #123
- Fix de la régression #456

### Deprecated
- Feature Z sera retirée en vX.Y.Z

### Removed
- Suppression de la feature obsolète

### Security
- Correction de la faille CVE-XXXX
```

### Commande utile
```bash
# Lister les commits depuis le dernier tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

### Checklist changelog
- [ ] Tous les changements listés
- [ ] Catégorisation correcte
- [ ] Breaking changes signalés
- [ ] Liens vers issues/PRs

---

## ÉTAPE 3/7 : VERSIONING

### Objectif
Déterminer et appliquer le bon numéro de version.

### Semantic Versioning
```
MAJOR.MINOR.PATCH

MAJOR → Breaking changes
MINOR → Nouvelles features (backward compatible)
PATCH → Bug fixes (backward compatible)
```

### Arbre de décision
```
         Y a-t-il des breaking changes ?
                     │
           ┌─────────┴─────────┐
           │                   │
          Oui                 Non
           │                   │
      MAJOR++            Nouvelles features ?
      (X.0.0)                  │
                     ┌─────────┴─────────┐
                     │                   │
                    Oui                 Non
                     │                   │
                 MINOR++             PATCH++
                 (X.Y.0)             (X.Y.Z)
```

### Commandes
```bash
# Patch release (bug fixes)
npm version patch

# Minor release (features)
npm version minor

# Major release (breaking changes)
npm version major

# Pre-release
npm version prerelease --preid=beta
```

### Checklist version
- [ ] Type de release déterminé
- [ ] Version cohérente avec les changements
- [ ] package.json mis à jour
- [ ] Autres fichiers de version mis à jour

---

## ÉTAPE 4/7 : TESTS COMPLETS

### Objectif
Validation complète avant release.

### Niveaux de tests
```
┌─────────────────────────────────┐
│        Tests E2E                │  ← Scénarios utilisateur
├─────────────────────────────────┤
│    Tests d'intégration          │  ← Composants ensemble
├─────────────────────────────────┤
│      Tests unitaires            │  ← Fonctions isolées
└─────────────────────────────────┘
```

### Commandes
```bash
# Tests unitaires
npm test

# Tests d'intégration
npm run test:integration

# Tests E2E
npm run test:e2e

# Tous les tests avec couverture
npm run test:coverage
```

### Tests manuels critiques
- [ ] Flow principal fonctionne
- [ ] Authentification OK
- [ ] Paiement (si applicable) OK
- [ ] Responsive/Mobile OK

### Checklist tests
- [ ] Tests unitaires : 100% pass
- [ ] Tests intégration : 100% pass
- [ ] Tests E2E : 100% pass
- [ ] Tests manuels validés
- [ ] Coverage acceptable

---

## ÉTAPE 5/7 : BUILD PRODUCTION

### Objectif
Générer les artifacts de production.

### Process
```bash
# 1. Clean
rm -rf dist/ build/

# 2. Build production
NODE_ENV=production npm run build

# 3. Vérifier la taille du bundle
npm run analyze # si disponible

# 4. Test du build
npm run preview # ou serve
```

### Vérifications
| Check | Attendu | Actuel |
|-------|---------|--------|
| Build success | ✓ | |
| Bundle size | < X MB | |
| No warnings | ✓ | |
| Assets générés | ✓ | |

### Checklist build
- [ ] Build réussi sans erreur
- [ ] Taille de bundle acceptable
- [ ] Assets correctement générés
- [ ] Variables d'env production

---

## ÉTAPE 6/7 : TAG & RELEASE

### Objectif
Créer le tag Git et les release notes.

### Création du tag
```bash
# Tag annoté avec message
git tag -a v1.2.3 -m "Release v1.2.3"

# Push du tag
git push origin v1.2.3
```

### Release Notes (GitHub)
```markdown
# Release v1.2.3

## Highlights
- ✨ Feature majeure 1
- 🚀 Amélioration performance
- 🐛 Fix critique

## What's Changed
[Changelog complet]

## Breaking Changes
⚠️ [Si applicable]

## Migration Guide
[Si breaking changes]

## Contributors
@contributor1, @contributor2

## Full Changelog
https://github.com/org/repo/compare/v1.2.2...v1.2.3
```

### Commande GitHub CLI
```bash
gh release create v1.2.3 \
  --title "Release v1.2.3" \
  --notes-file RELEASE_NOTES.md
```

### Checklist tag
- [ ] Tag créé
- [ ] Tag pushé
- [ ] Release créée sur GitHub
- [ ] Release notes complètes
- [ ] Assets attachés (si applicable)

---

## ÉTAPE 7/7 : DÉPLOIEMENT

### Objectif
Déployer en production.

### Stratégie de déploiement
```
      ┌─────────────┐
      │   Staging   │  ← Validation finale
      └──────┬──────┘
             │
      ┌──────▼──────┐
      │  Canary     │  ← 5% du trafic
      │  (optionnel)│
      └──────┬──────┘
             │
      ┌──────▼──────┐
      │ Production  │  ← 100% du trafic
      └─────────────┘
```

### Checklist pré-déploiement
- [ ] Backup effectué
- [ ] Rollback plan prêt
- [ ] Monitoring alertes configurées
- [ ] Équipe notifiée

### Déploiement
```bash
# Selon votre infra
npm run deploy:production
# ou
git push production main
# ou
kubectl apply -f k8s/
```

### Vérifications post-déploiement
- [ ] Application accessible
- [ ] Health checks OK
- [ ] Pas d'erreurs dans les logs
- [ ] Métriques normales
- [ ] Smoke tests passent

---

## Output final attendu

### Release Summary
```
✅ RELEASE v[X.Y.Z] TERMINÉE

Version: [X.Y.Z]
Date: [YYYY-MM-DD]
Type: [Major/Minor/Patch]

Changements:
- [N] features
- [N] fixes
- [N] improvements

Tests: ✅ All passed
Build: ✅ Success
Deploy: ✅ Production

Release: https://github.com/org/repo/releases/tag/v[X.Y.Z]
```

### Communication
```markdown
🚀 **Release v[X.Y.Z] déployée !**

Nouveautés :
- Feature 1
- Feature 2

Corrections :
- Fix 1
- Fix 2

Documentation : [lien]
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/audit` | Étape 1 - Audit qualité |
| `/changelog` | Étape 2 - Changelog |
| `/test` | Étape 4 - Tests complets |
| `/release` | Alternative simplifiée |
| `/monitoring` | Post-déploiement |

---

IMPORTANT: Ne jamais skip les tests avant une release.

YOU MUST avoir un plan de rollback prêt avant de déployer.

NEVER déployer un vendredi soir (sauf hotfix critique).

Think hard sur l'impact de chaque changement pour les utilisateurs.
