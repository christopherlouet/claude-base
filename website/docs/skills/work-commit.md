---
sidebar_position: 39
title: "work-commit"
description: "Génère des messages de commit clairs suivant Conventional Commits. Utiliser quand l'utilisateur veut commiter, demande un message de commit, ou après avoir terminé une modification."
tags:
  - "skill"
  - "fork"
---

# Skill: work-commit

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Génère des messages de commit clairs suivant Conventional Commits. Utiliser quand l'utilisateur veut commiter, demande un message de commit, ou après avoir terminé une modification.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Bash`, `Read`, `Grep` |
| **Mots-cles** | `work`, `commit`, `quoi`, `pourquoi`, `add`, `added`, `adds` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux work..."_
- _"Je veux commit..."_
- _"Je veux quoi..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemples de Messages de Commit

# Exemples de Messages de Commit

## Nouvelle fonctionnalité

**Changement**: Ajout d'un bouton de déconnexion dans le header

```bash
git diff --staged
# src/components/Header.tsx | 15 ++++++
# src/services/auth.ts      |  8 +++
```

**Message**:
```
feat(auth): add logout button to header

- Add LogoutButton component
- Implement logout service method
- Clear session on logout

Refs: #234
```

---

## Correction de bug

**Changement**: Fix d'un crash quand l'email est null

```bash
git diff --staged
# src/utils/validation.ts | 3 ++-
```

**Message**:
```
fix(validation): handle null email in validateUser

Previously crashed when email was null.
Now returns false for null/undefined inputs.

Fixes: #456
```

---

## Refactoring

**Changement**: Extraction de la logique de prix dans un module séparé

```bash
git diff --staged
# src/services/order.ts       | 45 --------
# src/utils/pricing.ts        | 50 +++++++++
# src/utils/pricing.test.ts   | 30 ++++++
```

**Message**:
```
refactor(pricing): extract price calculation to dedicated module

- Move calculateTotal from order service
- Add unit tests for edge cases
- No functional changes
```

---

## Tests

**Changement**: Ajout de tests pour le composant Button

```bash
git diff --staged
# src/components/Button.test.tsx | 45 +++++++++
```

**Message**:
```
test(ui): add unit tests for Button component

- Test all variants (primary, secondary, outline)
- Test disabled state
- Test click handler
```

---

## Documentation

**Changement**: Mise à jour du README avec nouvelles instructions

```bash
git diff --staged
# README.md | 25 +++++-----
```

**Message**:
```
docs(readme): update installation and usage instructions

- Add Docker setup instructions
- Update environment variables section
- Fix outdated npm commands
```

---

## Breaking Change

**Changement**: Changement de l'API d'authentification

```bash
git diff --staged
# src/services/auth.ts | 50 ++++++------
# src/types/auth.ts    | 20 ++---
```

**Message**:
```
feat(auth)!: change authentication to use JWT tokens

BREAKING CHANGE: The login response format has changed.

Before: { token: string, user: User }
After:  { accessToken: string, refreshToken: string, user: User }

Migration: Update all login handlers to destructure new response format.

Refs: #789
```



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
