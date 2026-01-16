# Agent TEST

Génère des tests complets et de qualité pour du code existant.

## Cible
$ARGUMENTS

## Objectif

Créer une suite de tests exhaustive qui couvre les cas nominaux,
les edge cases et les cas d'erreur pour garantir la fiabilité du code.

## Stratégie de test

```
┌─────────────────────────────────────────────────────────────┐
│                    STRATÉGIE DE TEST                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. ANALYSER     → Identifier fonctions et branches        │
│  ══════════                                                 │
│                                                             │
│  2. IDENTIFIER   → Lister tous les cas à tester            │
│  ═══════════                                                │
│                                                             │
│  3. GÉNÉRER      → Écrire les tests (AAA pattern)          │
│  ══════════                                                 │
│                                                             │
│  4. VÉRIFIER     → Exécuter et valider couverture          │
│  ══════════                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Analyse du code

### Questions à se poser

- Quelles sont les fonctions/méthodes publiques à tester ?
- Quelles sont les dépendances et effets de bord ?
- Quelles sont les branches conditionnelles ?
- Quels sont les edge cases potentiels ?
- Quelles erreurs peuvent survenir ?

### Matrice d'analyse

```markdown
| Fonction | Inputs | Outputs | Dépendances | Effets de bord |
|----------|--------|---------|-------------|----------------|
| func1    | [types]| [type]  | [deps]      | [effets]       |
| func2    | [types]| [type]  | [deps]      | [effets]       |
```

## Étape 2 : Identification des cas de test

### Catégories de tests

```
┌─────────────────────────────────────────────────────────────┐
│                    CATÉGORIES DE TESTS                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  NOMINAL (Happy Path)                                       │
│  └── Comportement attendu avec entrées valides              │
│                                                             │
│  EDGE CASES (Limites)                                       │
│  ├── Valeurs vides: null, undefined, "", [], {}             │
│  ├── Valeurs limites: 0, -1, MAX_INT, MIN_INT               │
│  ├── Longueurs: string vide, très long, exact limite        │
│  └── Types: conversions, coercions                          │
│                                                             │
│  ERROR CASES (Erreurs)                                      │
│  ├── Entrées invalides                                      │
│  ├── Exceptions attendues                                   │
│  └── États impossibles                                      │
│                                                             │
│  BOUNDARY (Frontières)                                      │
│  ├── Off-by-one: index 0, dernier élément                   │
│  ├── Seuils: juste avant, exactement, juste après           │
│  └── Transitions d'état                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Template de cas de test

```markdown
## Cas de test pour [fonction]

### Nominal
- [ ] Input valide standard → Output attendu
- [ ] Input valide variante → Output attendu

### Edge Cases
- [ ] Input null → [comportement]
- [ ] Input undefined → [comportement]
- [ ] Input vide ("", [], {}) → [comportement]
- [ ] Input à la limite → [comportement]

### Erreurs
- [ ] Input invalide type → [erreur attendue]
- [ ] Input hors plage → [erreur attendue]

### Boundary
- [ ] Premier élément → [comportement]
- [ ] Dernier élément → [comportement]
- [ ] Seuil exact → [comportement]
```

## Étape 3 : Génération des tests

### Structure AAA (Arrange-Act-Assert)

```typescript
describe('ModuleName', () => {
  describe('functionName', () => {
    // Test nominal
    it('should [expected behavior] when [condition]', () => {
      // Arrange - Préparer les données
      const input = { /* données de test */ };
      const expected = { /* résultat attendu */ };

      // Act - Exécuter la fonction
      const result = functionName(input);

      // Assert - Vérifier le résultat
      expect(result).toEqual(expected);
    });

    // Test edge case
    it('should handle empty input gracefully', () => {
      // Arrange
      const input = null;

      // Act & Assert
      expect(() => functionName(input)).toThrow('Input required');
    });

    // Test async
    it('should fetch user data successfully', async () => {
      // Arrange
      const userId = '123';
      const expectedUser = { id: '123', name: 'John' };

      // Act
      const result = await fetchUser(userId);

      // Assert
      expect(result).toEqual(expectedUser);
    });
  });
});
```

### Patterns de test courants

#### Test de fonction pure

```typescript
describe('calculateDiscount', () => {
  it('should apply 10% discount for orders over $100', () => {
    expect(calculateDiscount(150)).toBe(135);
  });

  it('should not apply discount for orders under $100', () => {
    expect(calculateDiscount(50)).toBe(50);
  });

  it('should handle zero amount', () => {
    expect(calculateDiscount(0)).toBe(0);
  });

  it('should throw for negative amount', () => {
    expect(() => calculateDiscount(-10)).toThrow('Amount must be positive');
  });
});
```

#### Test avec mocks (dépendances externes)

```typescript
describe('UserService', () => {
  let userService: UserService;
  let mockDatabase: jest.Mocked<Database>;

  beforeEach(() => {
    mockDatabase = {
      findById: jest.fn(),
      save: jest.fn(),
    };
    userService = new UserService(mockDatabase);
  });

  it('should return user when found', async () => {
    // Arrange
    const expectedUser = { id: '1', name: 'John' };
    mockDatabase.findById.mockResolvedValue(expectedUser);

    // Act
    const result = await userService.getUser('1');

    // Assert
    expect(result).toEqual(expectedUser);
    expect(mockDatabase.findById).toHaveBeenCalledWith('1');
  });

  it('should throw when user not found', async () => {
    // Arrange
    mockDatabase.findById.mockResolvedValue(null);

    // Act & Assert
    await expect(userService.getUser('999'))
      .rejects
      .toThrow('User not found');
  });
});
```

#### Test de composant React

```typescript
import { render, screen, fireEvent } from '@testing-library/react';

describe('LoginForm', () => {
  it('should render email and password fields', () => {
    render(<LoginForm onSubmit={jest.fn()} />);

    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
  });

  it('should call onSubmit with credentials', async () => {
    const mockSubmit = jest.fn();
    render(<LoginForm onSubmit={mockSubmit} />);

    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'test@example.com' },
    });
    fireEvent.change(screen.getByLabelText(/password/i), {
      target: { value: 'password123' },
    });
    fireEvent.click(screen.getByRole('button', { name: /submit/i }));

    expect(mockSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123',
    });
  });

  it('should show error for invalid email', async () => {
    render(<LoginForm onSubmit={jest.fn()} />);

    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'invalid' },
    });
    fireEvent.blur(screen.getByLabelText(/email/i));

    expect(await screen.findByText(/invalid email/i)).toBeInTheDocument();
  });
});
```

#### Test d'API

```typescript
import request from 'supertest';
import { app } from '../app';

describe('POST /api/users', () => {
  it('should create user with valid data', async () => {
    const userData = {
      email: 'new@example.com',
      name: 'New User',
    };

    const response = await request(app)
      .post('/api/users')
      .send(userData)
      .expect(201);

    expect(response.body).toMatchObject({
      email: 'new@example.com',
      name: 'New User',
    });
    expect(response.body.id).toBeDefined();
  });

  it('should return 400 for missing email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'No Email' })
      .expect(400);

    expect(response.body.error).toContain('email');
  });
});
```

## Étape 4 : Vérification

### Commandes de vérification

```bash
# Lancer les tests
npm test

# Avec couverture
npm run test:coverage

# Tests spécifiques
npm test -- --grep "UserService"

# Mode watch
npm run test:watch
```

### Seuils de couverture recommandés

| Type de code | Couverture min |
|--------------|----------------|
| Logique métier critique | 90%+ |
| Services et utils | 80%+ |
| Composants UI | 70%+ |
| Code généré/config | Optionnel |

## Bonnes pratiques

### À faire ✅

| Pratique | Exemple |
|----------|---------|
| **Noms descriptifs** | `should return user when found` |
| **Tests indépendants** | Chaque test peut s'exécuter seul |
| **Données explicites** | Pas de magic numbers |
| **Un concept par test** | Une assertion principale |
| **Setup/Teardown** | beforeEach/afterEach pour isolation |

### À éviter ❌

| Anti-pattern | Problème | Solution |
|--------------|----------|----------|
| Tests interdépendants | Fragiles, ordre important | Isolation complète |
| Mocks excessifs | Testent le mock, pas le code | Mocks pour I/O uniquement |
| Tests lents | CI lente | Optimiser, paralléliser |
| Tests flaky | Confiance réduite | Éliminer l'aléatoire |
| Assertions multiples | Difficile à debugger | Un concept par test |

## Output attendu

### Tests générés

```markdown
## Tests Générés

**Fichier(s) créé(s):**
- `src/services/__tests__/user.service.test.ts`

**Statistiques:**
- Nombre de tests: [X]
- Couverture estimée: [X%]
- Temps d'exécution: [Xs]

### Cas couverts

| Fonction | Nominal | Edge Cases | Erreurs | Total |
|----------|---------|------------|---------|-------|
| getUser  | 2       | 3          | 2       | 7     |
| saveUser | 3       | 2          | 3       | 8     |
```

### Commande pour lancer

```bash
# Lancer tous les tests générés
npm test -- src/services/__tests__/user.service.test.ts

# Avec couverture
npm test -- --coverage --collectCoverageFrom='src/services/**/*.ts'
```

## Checklist de génération de tests

- [ ] Fonctions publiques identifiées
- [ ] Cas nominaux couverts
- [ ] Edge cases listés et testés
- [ ] Cas d'erreur testés
- [ ] Mocks utilisés uniquement pour I/O externe
- [ ] Noms de tests descriptifs
- [ ] Structure AAA respectée
- [ ] Tests indépendants

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/explore` | Comprendre le code à tester |
| `/tdd` | Développer en TDD |
| `/testing-setup` | Configurer l'infrastructure de tests |
| `/review` | Review des tests |
| `/coverage` | Analyser la couverture |

---

IMPORTANT: Pas de mocks sauf pour les dépendances externes (API, DB, filesystem).

IMPORTANT: Tests indépendants les uns des autres.

YOU MUST viser une couverture > 80% sur le code ciblé.

YOU MUST tester les edge cases (null, undefined, empty, limites).

NEVER écrire des tests qui dépendent de l'ordre d'exécution.

Think hard sur les cas limites avant de coder les tests.
