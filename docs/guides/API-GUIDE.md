# Guide Developpement API

> Workflow complet pour APIs REST et GraphQL

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Runtime | Node.js, Deno, Bun |
| Frameworks | Express, Fastify, Hono, tRPC |
| GraphQL | Apollo Server, GraphQL Yoga |
| Database | PostgreSQL, MongoDB, Redis |
| ORM | Prisma, Drizzle, TypeORM |
| Auth | JWT, OAuth2, API Keys |
| Docs | OpenAPI/Swagger, GraphQL Playground |

## Architecture Recommandee

```
src/
├── api/                  # Routes et controllers
│   ├── routes/
│   ├── controllers/
│   └── middlewares/
├── services/             # Business logic
├── repositories/         # Data access
├── models/               # Types et schemas
├── validators/           # Input validation
├── utils/                # Helpers
└── config/               # Configuration
```

## Workflow Recommande

```
/work:work-explore → /work:work-plan → /dev:dev-api → /dev:dev-tdd → /qa:qa-security → /work:work-pr
```

## Phase 1: Exploration

### Comprendre l'API existante

```bash
/work:work-explore
```

### Questions a clarifier

- REST ou GraphQL?
- Authentification (JWT, API keys, OAuth)?
- Versionning (URL, header)?
- Rate limiting?

## Phase 2: Planification

### Planifier un endpoint

```bash
/work:work-plan "API de gestion des commandes e-commerce"
```

### Structure de plan type

```markdown
## API: Gestion des commandes

### Endpoints REST
- POST   /api/v1/orders          # Creer commande
- GET    /api/v1/orders          # Lister commandes
- GET    /api/v1/orders/:id      # Detail commande
- PATCH  /api/v1/orders/:id      # Modifier commande
- DELETE /api/v1/orders/:id      # Annuler commande
- POST   /api/v1/orders/:id/pay  # Payer commande

### Schemas
- OrderCreateInput
- OrderUpdateInput
- OrderResponse
- PaginatedOrdersResponse

### Validations
- items non vide
- total > 0
- shippingAddress valide

### Securite
- Auth JWT obligatoire
- Rate limit: 100 req/min
- RLS sur user_id
```

## Phase 3: Developpement

### Creer un endpoint REST

```bash
/dev:dev-api "endpoint CRUD pour les produits avec pagination et filtres"
```

### Creer une API GraphQL

```bash
/dev:dev-graphql "schema et resolvers pour gestion des utilisateurs"
```

### Structure endpoint generee

```typescript
// routes/products.ts
router.get('/', validate(listProductsSchema), listProducts);
router.get('/:id', validate(getProductSchema), getProduct);
router.post('/', auth, validate(createProductSchema), createProduct);
router.patch('/:id', auth, validate(updateProductSchema), updateProduct);
router.delete('/:id', auth, deleteProduct);

// controllers/products.ts
export const listProducts = async (req: Request, res: Response) => {
  const { page = 1, limit = 10, category, search } = req.query;

  const products = await productService.list({
    page: Number(page),
    limit: Number(limit),
    filters: { category, search }
  });

  res.json({
    data: products.items,
    meta: {
      page: products.page,
      limit: products.limit,
      total: products.total,
      totalPages: products.totalPages
    }
  });
};
```

### Versioning API

```bash
/dev:dev-api-versioning
```

Strategies:
| Methode | URL | Avantages |
|---------|-----|-----------|
| URL Path | /api/v1/users | Simple, explicite |
| Header | Accept-Version: v1 | URL propre |
| Query | /api/users?version=1 | Facile a tester |

## Phase 4: Tests

### TDD pour services

```bash
/dev:dev-tdd "service de calcul de prix avec taxes et reductions"
```

### Tests d'integration API

```bash
/dev:dev-test "tester les endpoints CRUD produits"
```

### Types de tests

| Type | Scope | Exemple |
|------|-------|---------|
| Unit | Service/Repository | `productService.create()` |
| Integration | API endpoint | `POST /api/products` |
| E2E | Workflow complet | Creer + Modifier + Supprimer |

### Couverture de tests

```bash
/qa:qa-coverage
```

Cibles recommandees:
| Metrique | Cible |
|----------|-------|
| Couverture lignes | > 80% |
| Couverture branches | > 70% |
| Services critiques | 100% |
| Endpoints publics | 100% |

### Tests E2E API

```bash
/qa:qa-e2e "workflow complet de commande: creation, paiement, confirmation"
```

## Phase 5: Documentation

### Generer spec OpenAPI

```bash
/doc:doc-api-spec
```

### Documentation generee

```yaml
openapi: 3.0.0
info:
  title: Products API
  version: 1.0.0
paths:
  /api/v1/products:
    get:
      summary: List products
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 10
            maximum: 100
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PaginatedProducts'
```

## Phase 6: Securite

### Audit securite API

```bash
/qa:qa-security
```

### Checklist OWASP API

- [ ] A1: Broken Object Level Authorization
- [ ] A2: Broken Authentication
- [ ] A3: Excessive Data Exposure
- [ ] A4: Lack of Resources & Rate Limiting
- [ ] A5: Broken Function Level Authorization
- [ ] A6: Mass Assignment
- [ ] A7: Security Misconfiguration
- [ ] A8: Injection
- [ ] A9: Improper Assets Management
- [ ] A10: Insufficient Logging & Monitoring

### Patterns securite

```typescript
// Validation input
const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

// Rate limiting
app.use(rateLimit({
  windowMs: 60 * 1000,
  max: 100,
  message: { error: 'Too many requests' }
}));

// CORS strict
app.use(cors({
  origin: ['https://app.example.com'],
  credentials: true
}));

// Helmet security headers
app.use(helmet());
```

## Phase 7: Performance

### Audit performance

```bash
/qa:qa-perf
```

### Optimisations

| Technique | Commande | Gain |
|-----------|----------|------|
| Caching | `/dev:dev-api` + Redis | -70% latence |
| Pagination | Cursor-based | O(1) vs O(n) |
| N+1 | DataLoader | -90% queries |
| Compression | gzip/brotli | -70% bandwidth |

### Load testing

```bash
/ops:ops-load-testing
```

## Phase 8: Deploy

### Configuration CI/CD

```bash
/ops:ops-ci "GitHub Actions pour API Node.js"
```

### Docker

```bash
/ops:ops-docker "API Node.js avec multi-stage"
```

### Monitoring

```bash
/ops:ops-monitoring
```

## Commandes par Use Case

### Nouvelle API

```bash
1. /work:work-plan          # Architecture API
2. /dev:dev-api            # Creer endpoints
3. /doc:doc-api-spec       # Documentation OpenAPI
4. /qa:qa-security        # Audit securite
5. /ops:ops-ci             # CI/CD
```

### Nouvel endpoint

```bash
1. /work:work-explore       # Comprendre l'existant
2. /dev:dev-api            # Creer l'endpoint
3. /dev:dev-tdd            # Tests
4. /doc:doc-api-spec       # Mettre a jour doc
5. /work:work-pr            # Pull Request
```

### Migration API v1 → v2

```bash
1. /dev:dev-api-versioning # Strategie
2. /work:work-plan          # Plan migration
3. /doc:doc-changelog      # Documenter breaking changes
```

### Debug performance

```bash
1. /qa:qa-perf            # Identifier bottlenecks
2. /ops:ops-monitoring     # Ajouter traces
3. /dev:dev-api            # Optimiser (cache, index)
```

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Cree un endpoint" | dev-api | REST ou GraphQL |
| "Audit securite API" | qa-security | OWASP Top 10 |
| "Documente l'API" | doc-generate | OpenAPI spec |
| "Optimise les requetes" | qa-perf | N+1, cache, index |

## Patterns API

### Response Format

```typescript
// Success
{
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 100
  }
}

// Error
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

### Error Handling

```typescript
class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500,
    public details?: unknown
  ) {
    super(message);
  }
}

// Middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        details: err.details
      }
    });
  }

  logger.error(err);
  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'Something went wrong'
    }
  });
});
```

## Anti-patterns a Eviter

- Validation dans controllers → Middleware/schema
- Business logic dans routes → Services
- SQL brut partout → ORM/Query builder
- Pas de rate limiting → DDoS possible
- Secrets en dur → Variables d'environnement
- Pas de versioning → Breaking changes

## Ressources

- [OpenAPI Spec](https://spec.openapis.org/oas/latest.html)
- [OWASP API Security](https://owasp.org/www-project-api-security/)
- [REST API Design](https://restfulapi.net)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)
