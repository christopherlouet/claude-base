---
sidebar_position: 40
title: "qa-review"
description: "Effectuer une revue de code approfondie. Utiliser quand l'utilisateur demande une review, veut vérifier la qualité du code, ou avant de merger une PR."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-review

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Effectuer une revue de code approfondie. Utiliser quand l'utilisateur demande une review, veut vérifier la qualité du code, ou avant de merger une PR.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Glob`, `Grep` |
| **Mots-cles** | `review` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux review..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple de revue de code

# Exemple de revue de code

## PR analysée
**Titre**: feat(auth): Ajouter authentification OAuth Google
**Fichiers modifiés**: 8 fichiers, +245 lignes, -12 lignes

## Résumé de la review

- **Fichiers modifiés**: 8
- **Lignes ajoutées**: +245
- **Lignes supprimées**: -12
- **Verdict**: Request Changes

## Points positifs

- Bonne séparation des responsabilités (service/controller)
- Types TypeScript bien définis
- Tests unitaires présents pour le service
- Gestion des erreurs cohérente

## Problèmes identifiés

### Critiques (bloquants)

**[CRITICAL] `src/services/auth.ts:45`**
```typescript
// ❌ Problème: Secret exposé dans le code
const GOOGLE_CLIENT_SECRET = "GOCSPX-xxxxx";

// ✅ Solution: Utiliser variable d'environnement
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
```
> Les secrets ne doivent jamais être hardcodés. Utiliser les variables d'environnement.

---

**[CRITICAL] `src/controllers/auth.ts:23`**
```typescript
// ❌ Problème: Pas de validation de l'input
const { code } = req.body;
const tokens = await googleAuth.getTokens(code);

// ✅ Solution: Valider avec Zod
const schema = z.object({ code: z.string().min(1) });
const { code } = schema.parse(req.body);
```
> Toujours valider les entrées utilisateur pour éviter les injections.

### Importants (à corriger)

**[IMPORTANT] `src/services/auth.ts:67`**
```typescript
// ❌ Problème: Pas de gestion du cas d'erreur
const user = await db.user.findUnique({ where: { email } });
return user.id; // Crash si user est null

// ✅ Solution: Gérer le cas null
const user = await db.user.findUnique({ where: { email } });
if (!user) {
  throw new NotFoundError(`User not found: ${email}`);
}
return user.id;
```

---

**[IMPORTANT] `src/middleware/auth.ts:15`**
```typescript
// ❌ Problème: Token stocké en localStorage (XSS vulnérable)
localStorage.setItem('token', accessToken);

// ✅ Solution: Utiliser httpOnly cookie
res.cookie('token', accessToken, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict'
});
```

### Suggestions (optionnelles)

**[SUGGESTION] `src/services/auth.ts:89`**
```typescript
// Actuel: Logs verbeux
console.log('User authenticated:', user);
console.log('Tokens:', tokens);

// Suggestion: Logger structuré
logger.info('User authenticated', { userId: user.id });
```

---

**[NITPICK] `src/types/auth.ts:5`**
```typescript
// Préférer interface pour les objets extensibles
type AuthUser = { ... }  // ❌
interface AuthUser { ... }  // ✅
```

## Checklist finale

- [ ] Code lisible et maintenable
- [x] Tests suffisants
- [ ] **Pas de problème de sécurité** ← 2 critiques
- [x] Performance acceptable

## Résumé pour l'auteur

Bonne implémentation globale, mais **2 problèmes de sécurité critiques** à corriger avant merge:

1. Secret hardcodé → utiliser env var
2. Pas de validation input → ajouter Zod

Une fois corrigés, approuvé pour merge.



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
