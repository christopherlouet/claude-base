---
sidebar_position: 8
title: "07 - Refactoring Legacy"
description: Refactorez un projet legacy en utilisant TDD et une approche méthodique
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Refactoring d'un projet Legacy

<DifficultyBadge level="advanced" /> **Durée estimée : 60 minutes**

Ce tutoriel vous montre comment refactorer méthodiquement un projet legacy en utilisant le TDD et les outils claude-socle.

## Objectifs

À la fin de ce tutoriel, vous saurez :
- Utiliser `/work:work-explore` pour cartographier un legacy
- Utiliser `/qa:qa-tech-debt` pour prioriser le refactoring
- Utiliser `/dev:dev-tdd` pour refactorer en sécurité
- Appliquer les patterns de refactoring progressif

## Prérequis

- Un projet "legacy" à refactorer
- Expérience en développement
- Patience et méthode

## Contexte

Le refactoring d'un legacy est risqué. Sans tests, chaque modification peut introduire des bugs. La stratégie :

1. **Comprendre** avant de toucher
2. **Tester** le comportement existant
3. **Refactorer** petit à petit
4. **Valider** après chaque changement

## Étape 1 : Cartographier le projet

```bash
/work:work-explore "Analyser ce projet legacy : architecture, dépendances, points de douleur"
```

Claude va identifier :
- La structure du projet
- Les technologies utilisées
- Les fichiers les plus modifiés (hotspots)
- Les dépendances entre modules
- Les patterns utilisés (ou leur absence)

**Exemple de sortie :**

```markdown
## Analyse du projet legacy

### Structure
```
src/
├── controllers/     # 15 fichiers, logique métier mélangée
├── models/          # 8 fichiers, validation dans les contrôleurs
├── routes/          # 3 fichiers, tout dans index.js
├── utils/           # 12 fichiers, beaucoup de duplication
└── index.js         # Point d'entrée, 500 lignes
```

### Technologies
- Node.js 12 (EOL)
- Express 4.16 (ancien)
- MySQL avec requêtes SQL brutes
- Pas de TypeScript
- Pas de tests

### Hotspots (fichiers problématiques)
1. `src/controllers/orderController.js` (800 lignes)
2. `src/utils/helpers.js` (400 lignes, fonctions variées)
3. `src/routes/index.js` (toutes les routes en un fichier)

### Dépendances critiques
- lodash utilisé partout (4.17.4, vulnérable)
- moment.js (deprecated)
- mysql (pas de pool de connexions)

### Dette technique estimée
- 🔴 Critique : Injection SQL, Node EOL
- 🟠 Élevée : Pas de tests, couplage fort
- 🟡 Moyenne : Duplication, nommage incohérent
```

## Étape 2 : Prioriser la dette technique

```bash
/qa:qa-tech-debt
```

Claude va prioriser les éléments à traiter :

```markdown
## Priorisation de la dette technique

### 🔴 Priorité 1 - Sécurité (Sprint 1)
| Item | Risque | Effort | Action |
|------|--------|--------|--------|
| SQL Injection | Critique | Moyen | Migrer vers requêtes préparées |
| Node 12 EOL | Élevé | Faible | Upgrade vers Node 20 |
| lodash vulnérable | Élevé | Faible | npm audit fix |

### 🟠 Priorité 2 - Testabilité (Sprint 2)
| Item | Risque | Effort | Action |
|------|--------|--------|--------|
| orderController.js | Élevé | Élevé | Extraire services, ajouter tests |
| Pas de tests | Élevé | Moyen | Ajouter tests sur chemins critiques |

### 🟡 Priorité 3 - Maintenabilité (Sprint 3+)
| Item | Risque | Effort | Action |
|------|--------|--------|--------|
| TypeScript | Moyen | Élevé | Migration progressive |
| moment.js | Faible | Moyen | Migrer vers date-fns |
| Duplication | Moyen | Moyen | Extraire fonctions communes |
```

## Étape 3 : Sécuriser d'abord

Avant tout refactoring, corrigeons les problèmes de sécurité.

### Mettre à jour Node.js

```bash
# Vérifier la compatibilité
nvm install 20
nvm use 20
npm test  # S'il y a des tests
npm start # Vérifier que ça fonctionne
```

### Corriger les dépendances

```bash
/ops:ops-deps
```

```bash
npm audit fix
npm update lodash
```

### Corriger l'injection SQL

**Avant (vulnérable) :**
```javascript
// src/controllers/orderController.js
const getOrder = async (req, res) => {
  const sql = `SELECT * FROM orders WHERE id = ${req.params.id}`;
  const [rows] = await db.query(sql);
  res.json(rows[0]);
};
```

**Après (sécurisé) :**
```javascript
const getOrder = async (req, res) => {
  const sql = 'SELECT * FROM orders WHERE id = ?';
  const [rows] = await db.query(sql, [req.params.id]);
  res.json(rows[0]);
};
```

## Étape 4 : Ajouter des tests sur le comportement existant

Avant de refactorer, on capture le comportement actuel avec des tests.

```bash
/dev:dev-tdd "Ajouter des tests de caractérisation pour orderController"
```

**Tests de caractérisation :**

```javascript
// tests/orderController.test.js
const request = require('supertest');
const app = require('../src/app');

describe('OrderController - Comportement existant', () => {
  // Ces tests documentent le comportement ACTUEL
  // même s'il est incorrect

  describe('GET /orders/:id', () => {
    it('should return order with products', async () => {
      const response = await request(app)
        .get('/orders/1')
        .expect(200);

      // Documenter la structure actuelle
      expect(response.body).toHaveProperty('id');
      expect(response.body).toHaveProperty('customer_id');
      expect(response.body).toHaveProperty('products');
    });

    it('should return 500 for invalid id (current bug)', async () => {
      // Documenter le bug actuel
      // Devrait être 404 mais renvoie 500
      const response = await request(app)
        .get('/orders/invalid')
        .expect(500);
    });
  });

  describe('POST /orders', () => {
    it('should create order with current validation', async () => {
      const response = await request(app)
        .post('/orders')
        .send({
          customer_id: 1,
          products: [{ id: 1, quantity: 2 }]
        })
        .expect(201);

      expect(response.body.id).toBeDefined();
    });
  });
});
```

:::tip Tests de caractérisation
Les tests de caractérisation capturent le comportement actuel, **bugs inclus**. Ils servent de filet de sécurité pendant le refactoring.
:::

## Étape 5 : Refactorer avec le pattern "Strangler Fig"

Le pattern Strangler Fig permet de remplacer progressivement le legacy.

### Créer la nouvelle structure

```bash
mkdir -p src/features/orders/{domain,application,infrastructure}
```

### Extraire le domaine

```bash
/dev:dev-refactor "Extraire la logique métier de orderController vers un service dédié"
```

**Nouveau service :**

```typescript
// src/features/orders/application/OrderService.ts
import { Order, OrderItem } from '../domain/Order';
import { OrderRepository } from '../domain/OrderRepository';

export class OrderService {
  constructor(private readonly orderRepository: OrderRepository) {}

  async getOrder(id: string): Promise<Order | null> {
    return this.orderRepository.findById(id);
  }

  async createOrder(customerId: string, items: OrderItem[]): Promise<Order> {
    const order = Order.create(customerId, items);
    await this.orderRepository.save(order);
    return order;
  }

  async calculateTotal(orderId: string): Promise<number> {
    const order = await this.orderRepository.findById(orderId);
    if (!order) throw new Error('Order not found');
    return order.calculateTotal();
  }
}
```

### Remplacer progressivement

```javascript
// src/controllers/orderController.js (migration progressive)
const { OrderService } = require('../features/orders/application/OrderService');
const { MySQLOrderRepository } = require('../features/orders/infrastructure/MySQLOrderRepository');

// Nouveau code
const orderService = new OrderService(new MySQLOrderRepository(db));

// Anciennes routes pointent vers le nouveau service
const getOrder = async (req, res) => {
  try {
    const order = await orderService.getOrder(req.params.id);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
```

## Étape 6 : Migrer vers TypeScript progressivement

```bash
/ops:ops-migrate "Migrer progressivement vers TypeScript"
```

### Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "allowJs": true,           // Permet le JS existant
    "checkJs": false,          // Ne vérifie pas le JS
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

### Migration fichier par fichier

1. Renommer `.js` en `.ts`
2. Ajouter les types
3. Lancer les tests
4. Passer au fichier suivant

## Étape 7 : Valider le refactoring

```bash
# Lancer tous les tests
npm test

# Vérifier la couverture
npm run test:coverage

# Audit de sécurité final
/qa:qa-security
```

## Étape 8 : Commiter par étapes

Chaque étape de refactoring doit être un commit séparé :

```bash
# Commit 1 - Sécurité
git add -A && git commit -m "fix(security): parameterize SQL queries"

# Commit 2 - Tests
git add -A && git commit -m "test: add characterization tests for orders"

# Commit 3 - Extraction service
git add -A && git commit -m "refactor(orders): extract OrderService"

# Commit 4 - TypeScript
git add -A && git commit -m "refactor: migrate orders to TypeScript"
```

## Stratégies de refactoring

| Pattern | Quand l'utiliser |
|---------|------------------|
| **Strangler Fig** | Remplacement progressif d'un système |
| **Branch by Abstraction** | Changer une implémentation sans casser l'API |
| **Extract Method/Class** | Réduire la complexité d'une fonction/classe |
| **Characterization Tests** | Capturer le comportement avant de modifier |

## Checklist refactoring

- [ ] Tests de caractérisation en place
- [ ] Aucune régression après chaque changement
- [ ] Commits atomiques et descriptifs
- [ ] Code review pour chaque PR
- [ ] Documentation mise à jour

## Prochaines étapes

- [Tutoriel 08 : Infrastructure Proxmox](/docs/tutorials/proxmox-infra)
- [Agent qa-tech-debt](/docs/agents/qa-tech-debt)
- [Commande /dev:dev-refactor](/docs/commands/dev/dev-refactor)

---

:::warning Règle d'or
**Ne jamais refactorer sans tests.** Si le code n'a pas de tests, ajoutez-en d'abord.
:::
