---
name: qa-review
description: Effectuer une revue de code approfondie. Utiliser quand l'utilisateur demande une review, veut vérifier la qualité du code, ou avant de merger une PR.
allowed-tools:
  - Read
  - Glob
  - Grep
context: fork
---

# Revue de Code

## Objectif

Identifier les problèmes de qualité, sécurité et maintenabilité AVANT le merge.

## Instructions

### 1. Vue d'ensemble

```bash
# Voir les changements
git diff main...HEAD --stat
git log main...HEAD --oneline
```

### 2. Checklist de review

#### Qualité du code
- [ ] Lisibilité (noms clairs, fonctions courtes)
- [ ] DRY (pas de duplication)
- [ ] SOLID (single responsibility)
- [ ] Complexité raisonnable

#### Typage (TypeScript)
- [ ] Pas de `any`
- [ ] Types explicites sur les APIs publiques
- [ ] Interfaces bien définies

#### Tests
- [ ] Tests présents et pertinents
- [ ] Edge cases couverts
- [ ] Mocks limités aux I/O

#### Sécurité
- [ ] Inputs validés
- [ ] Pas de secrets hardcodés
- [ ] Pas d'injection possible

#### Performance
- [ ] Pas de N+1 queries
- [ ] Pas de boucles infinies possibles
- [ ] Mémoire gérée correctement

### 3. Format des commentaires

```
[TYPE] fichier:ligne - commentaire

Types:
- [CRITICAL] - Bloquant, doit être corrigé
- [IMPORTANT] - Devrait être corrigé
- [SUGGESTION] - Amélioration optionnelle
- [QUESTION] - Clarification nécessaire
- [NITPICK] - Détail mineur
```

## Output attendu

```markdown
## Review : [Titre PR]

### Résumé
- **Fichiers modifiés**: X
- **Lignes ajoutées**: +Y
- **Lignes supprimées**: -Z
- **Verdict**: Approve / Request Changes / Comment

### Points positifs
- [Point 1]
- [Point 2]

### Problèmes identifiés

#### Critiques
- [CRITICAL] `fichier.ts:42` - Description

#### Importants
- [IMPORTANT] `fichier.ts:87` - Description

### Suggestions
- [SUGGESTION] `fichier.ts:123` - Description

### Checklist finale
- [ ] Code lisible et maintenable
- [ ] Tests suffisants
- [ ] Pas de problème de sécurité
- [ ] Performance acceptable
```

## Analyse de nommage

### Regles de nommage a verifier

| Element | Convention | Exemples bons | Exemples mauvais |
|---------|-----------|---------------|------------------|
| Variables | Descriptif, camelCase | `userCount`, `isActive` | `x`, `tmp`, `data` |
| Fonctions | Verbe + nom, camelCase | `getUserById`, `validateEmail` | `process`, `handle`, `do` |
| Booleens | Prefixe is/has/can/should | `isValid`, `hasPermission` | `valid`, `permission` |
| Constantes | SCREAMING_SNAKE | `MAX_RETRY_COUNT` | `maxRetry` |
| Classes | PascalCase, nom | `UserService`, `OrderRepository` | `Manager`, `Helper` |
| Interfaces | PascalCase, descriptif | `UserProfile`, `PaymentMethod` | `IUser`, `DataType` |

### Smells de nommage a detecter

| Smell | Probleme | Correction |
|-------|----------|------------|
| **Nom generique** | `data`, `result`, `temp`, `info` | Nommer selon le contenu |
| **Abbreviation** | `usr`, `btn`, `msg`, `idx` | Ecrire en entier |
| **Negation double** | `!isNotValid`, `!disableButton` | `isValid`, `enableButton` |
| **Type dans le nom** | `userArray`, `nameString` | `users`, `name` |
| **Longueur inappropriee** | Variable globale courte, locale longue | Inverse : global long, local court |
| **Nom trompeur** | `getUser` qui modifie | `fetchAndUpdateUser` |

### Patterns a rechercher

```
# Variables a un caractere (sauf i, j dans les boucles)
\b[a-z]\b\s*[=:]

# Noms generiques
\b(data|result|temp|tmp|info|item|obj|val|res)\b\s*[=:]

# Booleens sans prefixe
\b(active|valid|visible|enabled|disabled|open|closed)\b\s*[=:]
```

## Regles

- Etre constructif, pas destructif
- Expliquer le POURQUOI
- Proposer des alternatives
- Distinguer bloquant vs nice-to-have
- Verifier la coherence du nommage dans le code review
