# Agent COVERAGE

Analyse et améliore la couverture de tests du code.

## Cible
$ARGUMENTS

## Objectif

Évaluer la couverture de tests actuelle, identifier les zones non couvertes
et proposer une stratégie pour atteindre les seuils de qualité.

## Stratégie d'analyse de couverture

```
┌─────────────────────────────────────────────────────────────┐
│                    COVERAGE ANALYSIS                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. MESURER       → Collecter métriques actuelles          │
│  ══════════                                                 │
│                                                             │
│  2. ANALYSER      → Identifier gaps et zones critiques     │
│  ══════════                                                 │
│                                                             │
│  3. PRIORISER     → Classer par impact business            │
│  ═══════════                                                │
│                                                             │
│  4. PLANIFIER     → Définir roadmap d'amélioration         │
│  ═══════════                                                │
│                                                             │
│  5. IMPLÉMENTER   → Ajouter tests manquants                │
│  ═════════════                                              │
│                                                             │
│  6. MONITORER     → Suivre évolution dans le temps         │
│  ═══════════                                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Mesurer la couverture

### Commandes de mesure

```bash
# Jest avec couverture
npm test -- --coverage

# Avec rapport détaillé
npm test -- --coverage --coverageReporters="text" "html" "lcov"

# Pour fichiers spécifiques
npm test -- --coverage --collectCoverageFrom='src/services/**/*.ts'

# Vitest
npx vitest --coverage

# NYC (Istanbul) pour Node
npx nyc npm test
```

### Types de métriques

| Métrique | Description | Importance |
|----------|-------------|------------|
| **Statements** | % instructions exécutées | Haute |
| **Branches** | % branches conditionnelles | Très haute |
| **Functions** | % fonctions appelées | Moyenne |
| **Lines** | % lignes exécutées | Haute |

### Lecture du rapport

```
┌─────────────────────────────────────────────────────────────┐
│                    COVERAGE REPORT                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  File              │ Stmts │ Branch │ Funcs │ Lines │       │
│  ══════════════════│═══════│════════│═══════│═══════│       │
│  src/services/     │       │        │       │       │       │
│    user.ts         │ 85.7% │ 70.0%  │ 100%  │ 85.7% │       │
│    order.ts        │ 45.2% │ 30.0%  │ 60%   │ 45.2% │ ⚠️    │
│    payment.ts      │ 92.3% │ 88.9%  │ 100%  │ 92.3% │ ✅    │
│  ══════════════════│═══════│════════│═══════│═══════│       │
│  All files         │ 72.4% │ 62.3%  │ 86.7% │ 72.4% │       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 2 : Analyser les gaps

### Identifier les zones non couvertes

```typescript
// Dans le rapport HTML, les lignes sont colorées:
// 🟢 Vert = Couverte
// 🔴 Rouge = Non couverte
// 🟡 Jaune = Partiellement couverte (branches)

// Exemple de code avec couverture partielle
function processPayment(amount: number, method: string) {
  if (amount <= 0) {           // ← Branch non testée si toujours > 0
    throw new Error('Invalid amount');
  }

  if (method === 'card') {     // ← Testé
    return processCard(amount);
  } else if (method === 'crypto') {  // ← Non testé
    return processCrypto(amount);
  }

  return processDefault(amount);  // ← Non testé
}
```

### Catégorisation des gaps

```markdown
## Analyse des Gaps de Couverture

### 🔴 Critique (Code métier non testé)
| Fichier | Fonction | Lignes | Impact |
|---------|----------|--------|--------|
| order.ts | calculateTotal | 45-67 | Calcul prix |
| payment.ts | refund | 120-145 | Remboursements |

### 🟠 Important (Branches non couvertes)
| Fichier | Condition | Ligne | Cas manquant |
|---------|-----------|-------|--------------|
| user.ts | if (!user) | 34 | User null |
| order.ts | switch(status) | 78 | Status 'pending' |

### 🟡 Mineur (Edge cases)
| Fichier | Cas | Impact |
|---------|-----|--------|
| utils.ts | String vide | Faible |
| helpers.ts | Array vide | Faible |
```

### Script d'analyse automatique

```typescript
// scripts/analyze-coverage.ts
import * as fs from 'fs';

interface CoverageData {
  [file: string]: {
    statements: { covered: number; total: number };
    branches: { covered: number; total: number };
    functions: { covered: number; total: number };
    lines: { covered: number; total: number };
  };
}

function analyzeCoverage(threshold: number = 80) {
  const coverage: CoverageData = JSON.parse(
    fs.readFileSync('coverage/coverage-summary.json', 'utf-8')
  );

  const issues: Array<{
    file: string;
    metric: string;
    value: number;
    severity: 'critical' | 'warning' | 'info';
  }> = [];

  for (const [file, data] of Object.entries(coverage)) {
    if (file === 'total') continue;

    const metrics = [
      { name: 'statements', value: (data.statements.covered / data.statements.total) * 100 },
      { name: 'branches', value: (data.branches.covered / data.branches.total) * 100 },
      { name: 'functions', value: (data.functions.covered / data.functions.total) * 100 },
    ];

    for (const metric of metrics) {
      if (isNaN(metric.value)) continue;

      if (metric.value < 50) {
        issues.push({
          file,
          metric: metric.name,
          value: metric.value,
          severity: 'critical',
        });
      } else if (metric.value < threshold) {
        issues.push({
          file,
          metric: metric.name,
          value: metric.value,
          severity: 'warning',
        });
      }
    }
  }

  return issues.sort((a, b) => a.value - b.value);
}
```

## Étape 3 : Prioriser les améliorations

### Matrice de priorisation

```
┌─────────────────────────────────────────────────────────────┐
│                    PRIORITIZATION MATRIX                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  IMPACT BUSINESS                                            │
│       ↑                                                     │
│  HAUT │  ┌─────────────┐  ┌─────────────┐                  │
│       │  │   URGENT    │  │  PRIORITÉ   │                  │
│       │  │  (P1)       │  │  HAUTE (P2) │                  │
│       │  └─────────────┘  └─────────────┘                  │
│       │                                                     │
│  BAS  │  ┌─────────────┐  ┌─────────────┐                  │
│       │  │  OPPORTUN   │  │   BACKLOG   │                  │
│       │  │  (P3)       │  │  (P4)       │                  │
│       │  └─────────────┘  └─────────────┘                  │
│       └────────────────────────────────────→ EFFORT        │
│              FAIBLE              ÉLEVÉ                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Critères de priorisation

| Critère | Poids | Description |
|---------|-------|-------------|
| **Impact financier** | 5 | Code de paiement, facturation |
| **Données sensibles** | 5 | Auth, données personnelles |
| **Fréquence d'usage** | 4 | Features core utilisées souvent |
| **Complexité** | 3 | Code avec beaucoup de branches |
| **Historique bugs** | 4 | Code qui a déjà eu des bugs |
| **Changements fréquents** | 3 | Code souvent modifié |

### Template de priorisation

```markdown
## Plan de Couverture Priorisé

### P1 - Urgent (Cette semaine)
| Fichier | Couverture actuelle | Cible | Tests à ajouter |
|---------|---------------------|-------|-----------------|
| payment.ts | 45% | 90% | 12 tests |
| auth.ts | 52% | 95% | 15 tests |

### P2 - Haute priorité (Ce sprint)
| Fichier | Couverture actuelle | Cible | Tests à ajouter |
|---------|---------------------|-------|-----------------|
| order.ts | 60% | 85% | 8 tests |
| user.ts | 65% | 85% | 6 tests |

### P3 - Opportuniste (Prochain sprint)
| Fichier | Couverture actuelle | Cible | Tests à ajouter |
|---------|---------------------|-------|-----------------|
| utils.ts | 70% | 80% | 4 tests |
| helpers.ts | 72% | 80% | 3 tests |

### P4 - Backlog
| Fichier | Couverture actuelle | Note |
|---------|---------------------|------|
| config.ts | 40% | Rarement modifié |
| constants.ts | 0% | Pas de logique |
```

## Étape 4 : Configuration des seuils

### Configuration Jest

```javascript
// jest.config.js
module.exports = {
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.stories.{ts,tsx}',
    '!src/**/index.ts',
    '!src/types/**',
  ],
  coverageThreshold: {
    global: {
      statements: 80,
      branches: 75,
      functions: 80,
      lines: 80,
    },
    // Seuils spécifiques par dossier
    './src/services/': {
      statements: 90,
      branches: 85,
      functions: 90,
      lines: 90,
    },
    './src/utils/': {
      statements: 95,
      branches: 90,
      functions: 95,
      lines: 95,
    },
  },
  coverageReporters: ['text', 'text-summary', 'html', 'lcov'],
};
```

### Seuils recommandés par type de code

| Type de code | Statements | Branches | Functions |
|--------------|------------|----------|-----------|
| **Services métier** | 90% | 85% | 90% |
| **Utils/Helpers** | 95% | 90% | 95% |
| **Controllers** | 80% | 75% | 85% |
| **Components UI** | 70% | 65% | 75% |
| **Config/Constants** | Optionnel | Optionnel | Optionnel |

## Étape 5 : Stratégies d'amélioration

### Tests pour branches manquantes

```typescript
// Code source
function getDiscount(user: User, amount: number): number {
  if (!user) {
    return 0;
  }

  if (user.isPremium) {
    return amount * 0.2;
  }

  if (user.orderCount > 10) {
    return amount * 0.1;
  }

  return 0;
}

// Tests exhaustifs pour 100% branches
describe('getDiscount', () => {
  it('should return 0 when user is null', () => {
    expect(getDiscount(null, 100)).toBe(0);
  });

  it('should return 0 when user is undefined', () => {
    expect(getDiscount(undefined, 100)).toBe(0);
  });

  it('should return 20% for premium users', () => {
    const user = { isPremium: true, orderCount: 0 };
    expect(getDiscount(user, 100)).toBe(20);
  });

  it('should return 10% for users with >10 orders', () => {
    const user = { isPremium: false, orderCount: 15 };
    expect(getDiscount(user, 100)).toBe(10);
  });

  it('should return 0 for regular users with <=10 orders', () => {
    const user = { isPremium: false, orderCount: 5 };
    expect(getDiscount(user, 100)).toBe(0);
  });

  it('should prioritize premium over order count', () => {
    const user = { isPremium: true, orderCount: 15 };
    expect(getDiscount(user, 100)).toBe(20); // Premium discount
  });
});
```

### Tests de boundary conditions

```typescript
describe('boundary conditions', () => {
  // Test exact boundary
  it('should not give discount at exactly 10 orders', () => {
    const user = { isPremium: false, orderCount: 10 };
    expect(getDiscount(user, 100)).toBe(0);
  });

  it('should give discount at 11 orders', () => {
    const user = { isPremium: false, orderCount: 11 };
    expect(getDiscount(user, 100)).toBe(10);
  });

  // Test edge values
  it('should handle zero amount', () => {
    const user = { isPremium: true, orderCount: 0 };
    expect(getDiscount(user, 0)).toBe(0);
  });

  it('should handle negative amount', () => {
    const user = { isPremium: true, orderCount: 0 };
    expect(getDiscount(user, -100)).toBe(-20);
  });
});
```

### Tests de chemins d'erreur

```typescript
// Code avec gestion d'erreurs
async function processOrder(orderId: string): Promise<Order> {
  const order = await orderRepo.findById(orderId);

  if (!order) {
    throw new NotFoundError('Order', orderId);
  }

  if (order.status === 'cancelled') {
    throw new BusinessError('Cannot process cancelled order');
  }

  // ... processing
  return order;
}

// Tests des chemins d'erreur
describe('processOrder error paths', () => {
  it('should throw NotFoundError for non-existent order', async () => {
    orderRepo.findById.mockResolvedValue(null);

    await expect(processOrder('unknown-id'))
      .rejects
      .toThrow(NotFoundError);
  });

  it('should throw BusinessError for cancelled order', async () => {
    orderRepo.findById.mockResolvedValue({ status: 'cancelled' });

    await expect(processOrder('order-123'))
      .rejects
      .toThrow('Cannot process cancelled order');
  });
});
```

## Étape 6 : Monitoring continu

### Intégration CI/CD

```yaml
# .github/workflows/test.yml
name: Tests with Coverage

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run tests with coverage
        run: npm test -- --coverage --coverageReporters="json-summary" "text"

      - name: Check coverage thresholds
        run: |
          COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
          echo "Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage is below 80%"
            exit 1
          fi

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          fail_ci_if_error: true
```

### Badge de couverture

```markdown
<!-- Dans README.md -->
[![Coverage](https://codecov.io/gh/user/repo/branch/main/graph/badge.svg)](https://codecov.io/gh/user/repo)
```

### Rapport d'évolution

```markdown
## Coverage Trend Report

### Évolution sur 4 semaines
| Semaine | Statements | Branches | Trend |
|---------|------------|----------|-------|
| S-3 | 68.2% | 55.1% | - |
| S-2 | 72.5% | 60.3% | ↑ +4.3% |
| S-1 | 78.1% | 68.7% | ↑ +5.6% |
| S0 | 82.4% | 75.2% | ↑ +4.3% |

### Fichiers améliorés cette semaine
| Fichier | Avant | Après | Delta |
|---------|-------|-------|-------|
| payment.ts | 45% | 92% | +47% |
| auth.ts | 52% | 88% | +36% |
| order.ts | 60% | 85% | +25% |
```

## Output attendu

### Rapport d'analyse

```markdown
## Coverage Analysis Report

**Date:** [date]
**Couverture globale:** [X%]

### Métriques actuelles
| Métrique | Valeur | Seuil | Status |
|----------|--------|-------|--------|
| Statements | 78.4% | 80% | ⚠️ |
| Branches | 65.2% | 75% | ❌ |
| Functions | 85.7% | 80% | ✅ |
| Lines | 78.4% | 80% | ⚠️ |

### Top 5 fichiers à améliorer
| Fichier | Couverture | Gap | Priorité |
|---------|------------|-----|----------|
| payment.ts | 45% | -35% | P1 |
| order.ts | 52% | -28% | P1 |
| user.ts | 65% | -15% | P2 |
| cart.ts | 70% | -10% | P3 |
| utils.ts | 75% | -5% | P4 |

### Plan d'action
1. [ ] Ajouter 12 tests pour payment.ts (P1)
2. [ ] Ajouter 8 tests pour order.ts (P1)
3. [ ] Ajouter 6 tests pour user.ts (P2)
```

## Checklist

- [ ] Rapport de couverture généré
- [ ] Gaps identifiés et catégorisés
- [ ] Priorisation effectuée
- [ ] Seuils configurés dans Jest
- [ ] Tests ajoutés pour fichiers critiques
- [ ] CI/CD vérifie la couverture
- [ ] Documentation mise à jour

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-test` | Générer les tests manquants |
| `/dev:dev-tdd` | Développer avec TDD |
| `/qa:qa-review` | Review des tests |
| `/ops:ops-ci` | Configurer CI avec coverage |
| `/qa:qa-audit` | Audit qualité global |

---

IMPORTANT: La couverture n'est pas une fin en soi. 100% couverture ≠ 100% qualité.

YOU MUST prioriser le code métier critique.

YOU MUST tester les branches ET les edge cases.

NEVER sacrifier la qualité des tests pour atteindre un pourcentage.

Think hard sur ce qui mérite vraiment d'être testé en priorité.
