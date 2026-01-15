# Agent DEV-API-VERSIONING

Mettre en place une stratégie de versioning d'API robuste.

## Contexte
$ARGUMENTS

## Objectif

Définir et implémenter une stratégie de versioning d'API qui permet l'évolution
tout en maintenant la compatibilité avec les clients existants.

## Stratégies de versioning

### Comparatif

| Stratégie | Format | Avantages | Inconvénients |
|-----------|--------|-----------|---------------|
| **URL Path** | `/api/v1/users` | Simple, visible, cacheable | URL change à chaque version |
| **Query Param** | `/api/users?version=1` | Flexible | Moins standard |
| **Header** | `Accept: application/vnd.api.v1+json` | Clean URLs | Moins visible |
| **Content Negotiation** | `Accept: application/vnd.api+json;version=1` | RESTful | Complexe |

### Recommandation

**URL Path versioning** est recommandé pour la plupart des cas :
- Simple à comprendre et utiliser
- Visible dans les logs et documentation
- Facile à router
- Compatible avec tous les clients

## Architecture de versioning

### Structure recommandée

```
src/
├── api/
│   ├── v1/
│   │   ├── routes/
│   │   │   ├── users.ts
│   │   │   └── products.ts
│   │   ├── controllers/
│   │   ├── schemas/
│   │   └── index.ts
│   ├── v2/
│   │   ├── routes/
│   │   ├── controllers/
│   │   ├── schemas/
│   │   └── index.ts
│   └── shared/
│       ├── middleware/
│       ├── utils/
│       └── types/
├── services/          # Business logic (non versionnée)
└── models/            # Data models (non versionnés)
```

### Principes clés

```
┌─────────────────────────────────────────────────────────────┐
│                    COUCHE API (versionnée)                  │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                     │
│  │  v1 API │  │  v2 API │  │  v3 API │                     │
│  └────┬────┘  └────┬────┘  └────┬────┘                     │
└───────┼────────────┼────────────┼───────────────────────────┘
        │            │            │
        └────────────┴────────────┘
                     │
┌────────────────────┴────────────────────────────────────────┐
│              COUCHE SERVICE (non versionnée)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ UserService  │  │ProductService│  │ OrderService │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Implémentation

### Express.js

```typescript
// src/api/v1/index.ts
import { Router } from 'express';
import userRoutes from './routes/users';
import productRoutes from './routes/products';

const v1Router = Router();

v1Router.use('/users', userRoutes);
v1Router.use('/products', productRoutes);

export default v1Router;

// src/api/v2/index.ts
import { Router } from 'express';
import userRoutes from './routes/users';
import productRoutes from './routes/products';

const v2Router = Router();

v2Router.use('/users', userRoutes);
v2Router.use('/products', productRoutes);

export default v2Router;

// src/app.ts
import express from 'express';
import v1Router from './api/v1';
import v2Router from './api/v2';

const app = express();

app.use('/api/v1', v1Router);
app.use('/api/v2', v2Router);

// Redirection de /api vers la dernière version stable
app.use('/api', (req, res, next) => {
  res.redirect(301, `/api/v2${req.path}`);
});
```

### Fastify

```typescript
// src/api/v1/index.ts
import { FastifyPluginAsync } from 'fastify';

const v1Routes: FastifyPluginAsync = async (fastify) => {
  fastify.register(import('./routes/users'), { prefix: '/users' });
  fastify.register(import('./routes/products'), { prefix: '/products' });
};

export default v1Routes;

// src/app.ts
import fastify from 'fastify';
import v1Routes from './api/v1';
import v2Routes from './api/v2';

const app = fastify();

app.register(v1Routes, { prefix: '/api/v1' });
app.register(v2Routes, { prefix: '/api/v2' });
```

## Gestion des changements

### Types de changements

| Type | Impact | Versioning requis |
|------|--------|-------------------|
| **Additive** | Nouveau champ optionnel | Non |
| **Additive** | Nouveau endpoint | Non |
| **Breaking** | Suppression de champ | Oui |
| **Breaking** | Changement de type | Oui |
| **Breaking** | Changement de comportement | Oui |

### Changements non-breaking (safe)

```typescript
// v1 - Original
interface User {
  id: string;
  name: string;
  email: string;
}

// v1 - Après ajout (non-breaking)
interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;  // ✅ Nouveau champ optionnel
}
```

### Changements breaking

```typescript
// v1
interface User {
  id: string;
  name: string;      // ❌ Va être supprimé
  email: string;
}

// v2 - Breaking change
interface User {
  id: string;
  firstName: string; // ❌ Renommé
  lastName: string;  // ❌ Nouveau requis
  email: string;
}
```

## Stratégie de dépréciation

### Timeline recommandée

```
┌─────────────────────────────────────────────────────────────┐
│  v1 ACTIVE    │  v1 DEPRECATED  │  v1 SUNSET  │  v1 OFF   │
│               │                  │             │           │
│  0           6 mois           12 mois        18 mois      │
└─────────────────────────────────────────────────────────────┘
```

### Headers de dépréciation

```typescript
// Middleware de dépréciation
function deprecationMiddleware(version: string, sunsetDate: Date) {
  return (req, res, next) => {
    res.setHeader('Deprecation', 'true');
    res.setHeader('Sunset', sunsetDate.toUTCString());
    res.setHeader('Link', '</api/v2>; rel="successor-version"');

    // Log pour monitoring
    logger.warn(`Deprecated API ${version} called`, {
      path: req.path,
      client: req.headers['user-agent'],
    });

    next();
  };
}

// Utilisation
app.use('/api/v1', deprecationMiddleware('v1', new Date('2025-06-01')));
```

### Communication aux clients

```markdown
## API v1 Deprecation Notice

**Status**: Deprecated
**Sunset Date**: June 1, 2025

### Migration Guide

| v1 Endpoint | v2 Endpoint | Changes |
|-------------|-------------|---------|
| GET /api/v1/users | GET /api/v2/users | Response format changed |
| POST /api/v1/users | POST /api/v2/users | New required field: `lastName` |

### Breaking Changes in v2

1. `User.name` split into `firstName` and `lastName`
2. Pagination changed from offset to cursor-based
3. Error format standardized to RFC 7807

### Support

- Documentation: https://api.example.com/docs/v2
- Migration guide: https://api.example.com/docs/migration-v1-v2
- Support: api-support@example.com
```

## Documentation OpenAPI

### Versioning dans OpenAPI

```yaml
# openapi-v1.yaml
openapi: 3.0.3
info:
  title: My API
  version: '1.0.0'
  description: |
    ## Deprecation Notice
    This version is deprecated. Please migrate to v2.
    Sunset date: 2025-06-01
  x-api-status: deprecated

servers:
  - url: https://api.example.com/v1

# openapi-v2.yaml
openapi: 3.0.3
info:
  title: My API
  version: '2.0.0'
  description: Current stable version

servers:
  - url: https://api.example.com/v2
```

## Monitoring et métriques

### Métriques à suivre

```typescript
// Middleware de métriques
function apiMetrics(version: string) {
  return (req, res, next) => {
    const start = Date.now();

    res.on('finish', () => {
      metrics.increment('api.requests', {
        version,
        method: req.method,
        path: req.route?.path || 'unknown',
        status: res.statusCode,
      });

      metrics.histogram('api.latency', Date.now() - start, {
        version,
        path: req.route?.path || 'unknown',
      });
    });

    next();
  };
}
```

### Dashboard recommandé

| Métrique | Description |
|----------|-------------|
| Requests par version | Trafic sur chaque version |
| Clients par version | Nombre de clients uniques |
| Erreurs par version | Taux d'erreur |
| Latence par version | P50, P95, P99 |

## Checklist de nouvelle version

### Avant de créer v(n+1)

- [ ] Breaking changes documentés
- [ ] Migration guide rédigé
- [ ] Timeline de dépréciation définie
- [ ] Tests de compatibilité prêts

### Au lancement de v(n+1)

- [ ] Documentation mise à jour
- [ ] Changelog publié
- [ ] Clients notifiés
- [ ] Monitoring en place

### À la dépréciation de v(n)

- [ ] Headers Deprecation ajoutés
- [ ] Sunset date communiquée
- [ ] Logs de monitoring activés

### Au sunset de v(n)

- [ ] Vérifier qu'aucun client critique n'utilise v(n)
- [ ] Retourner 410 Gone
- [ ] Retirer le code après période de grâce

## Agents liés

| Agent | Usage |
|-------|-------|
| `/dev-api` | Créer des endpoints |
| `/doc-api-spec` | Documenter l'API |
| `/doc-changelog` | Changelog des versions |

---

IMPORTANT: Ne jamais supprimer une version sans période de dépréciation.

YOU MUST documenter tous les breaking changes.

YOU MUST fournir un guide de migration pour chaque nouvelle version majeure.

NEVER faire de breaking changes dans une version mineure.

Think hard sur l'impact des changements avant de créer une nouvelle version.
