---
sidebar_position: 7
title: TDD
description: Developpement guide par les tests (obligatoire)
---

# Workflow : TDD (Test-Driven Development)

Developpement guide par les tests avec le cycle Red-Green-Refactor.

:::tip TDD est obligatoire et proactif
Depuis la version 1.11, **TDD est obligatoire** dans le workflow principal.
Le cycle Explore → Plan → **TDD** → Commit impose d'ecrire les tests AVANT le code.

**Nouveau (v1.12+)** : La [rule `tdd-enforcement`](/docs/rules/tdd-enforcement) declenche automatiquement TDD quand vous demandez d'implementer, ajouter, creer ou corriger du code.
:::

## Commande

```bash
/dev:dev-tdd "Description de la fonctionnalite"
```

## Le cycle Red-Green-Refactor

```
┌─────────────────────────────────────┐
│                                     │
│    ┌─────┐                          │
│    │ RED │ Ecrire un test qui       │
│    └──┬──┘ echoue                   │
│       │                             │
│       ▼                             │
│   ┌───────┐                         │
│   │ GREEN │ Ecrire le code          │
│   └───┬───┘ minimal pour passer     │
│       │                             │
│       ▼                             │
│  ┌──────────┐                       │
│  │ REFACTOR │ Ameliorer le code     │
│  └────┬─────┘ sans casser les tests │
│       │                             │
│       └─────────────────────────────┘
│                                     │
└─────────────────────────────────────┘
```

## Etapes detaillees

### 1. RED - Ecrire le test

```typescript
// test/user.service.spec.ts
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with valid email', async () => {
      const user = await userService.createUser({
        email: 'test@example.com',
        name: 'Test User',
      });

      expect(user.id).toBeDefined();
      expect(user.email).toBe('test@example.com');
    });
  });
});
```

Le test doit echouer car `createUser` n'existe pas encore.

### 2. GREEN - Implementer le minimum

```typescript
// src/user.service.ts
export class UserService {
  async createUser(data: CreateUserDto): Promise<User> {
    return {
      id: generateId(),
      email: data.email,
      name: data.name,
    };
  }
}
```

Ecrire le code minimal pour faire passer le test.

### 3. REFACTOR - Ameliorer

```typescript
// Ajouter la validation, le repository, etc.
export class UserService {
  constructor(private readonly userRepository: UserRepository) {}

  async createUser(data: CreateUserDto): Promise<User> {
    this.validateEmail(data.email);
    return this.userRepository.create(data);
  }

  private validateEmail(email: string): void {
    if (!email.includes('@')) {
      throw new InvalidEmailError(email);
    }
  }
}
```

Ameliorer le code sans casser les tests.

## Exemple avec Claude

```bash
> /dev:dev-tdd "Creer un service de validation d'email"

# Claude :
# 1. Propose les cas de test
#    - Email valide
#    - Email invalide (sans @)
#    - Email vide
#    - Email null
#
# 2. Ecrit les tests
#
# 3. Implemente le service
#
# 4. Refactore si necessaire
```

## Bonnes pratiques

### DO
- ✅ Un test a la fois
- ✅ Tests independants
- ✅ Noms de tests descriptifs
- ✅ Tester les edge cases

### DON'T
- ❌ Ecrire le code avant les tests
- ❌ Tests dependants les uns des autres
- ❌ Ignorer les cas limites
- ❌ Mocks excessifs

## Structure de test recommandee

```typescript
describe('NomDuModule', () => {
  describe('nomDeLaFonction', () => {
    it('should [comportement attendu] when [condition]', () => {
      // Arrange - Preparer les donnees
      const input = { ... };

      // Act - Executer l'action
      const result = fonction(input);

      // Assert - Verifier le resultat
      expect(result).toEqual(expected);
    });
  });
});
```

## Edge cases a tester

| Type | Exemples |
|------|----------|
| Valeurs limites | 0, -1, MAX_INT |
| Null/Undefined | null, undefined |
| Chaines vides | '', ' ' |
| Collections vides | [], {} |
| Erreurs | Exceptions, timeouts |

---

## Voir aussi

- [Rule tdd-enforcement](/docs/rules/tdd-enforcement) - Declenchement proactif du TDD
- [Skill dev-tdd](/docs/skills/dev-tdd) - Skill auto-declenche
- [Tests](/docs/commands/dev/dev-test)
- [Testing Setup](/docs/commands/dev/dev-testing-setup)
- [Coverage](/docs/commands/qa/qa-coverage)
