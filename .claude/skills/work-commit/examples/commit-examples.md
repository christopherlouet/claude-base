# Commit Message Examples

## New feature

**Change**: Add a logout button in the header

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

## Bug fix

**Change**: Fix a crash when email is null

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

**Change**: Extract pricing logic into a separate module

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

**Change**: Add tests for the Button component

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

**Change**: Update the README with new instructions

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

**Change**: Change the authentication API

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
