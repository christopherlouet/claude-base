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
