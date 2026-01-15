# Projet Node.js API

## Commandes Essentielles
- `npm install` - Installer les dépendances
- `npm run dev` - Serveur de développement avec hot-reload
- `npm test` - Lancer les tests
- `npm run lint` - Vérifier ESLint
- `npm run build` - Compiler TypeScript
- `npm start` - Démarrer en production
- `npm run db:migrate` - Lancer les migrations

## Structure du Projet
- `/src/routes` ou `/src/controllers` - Endpoints API
- `/src/services` - Logique métier
- `/src/models` - Modèles de données / ORM
- `/src/middleware` - Middlewares Express/Fastify
- `/src/utils` - Fonctions utilitaires
- `/src/types` - Types TypeScript
- `/src/config` - Configuration
- `/tests` - Tests unitaires et d'intégration

## Conventions API
- IMPORTANT: REST ou GraphQL cohérent
- IMPORTANT: Validation des entrées sur TOUS les endpoints
- YOU MUST gérer les erreurs proprement (try/catch, error middleware)
- YOU MUST logger les requêtes et erreurs

## Sécurité
- IMPORTANT: Requêtes SQL paramétrées (jamais de concaténation)
- IMPORTANT: Authentification sur routes protégées
- Rate limiting sur endpoints publics
- Validation avec Joi/Zod/class-validator
- Sanitization des inputs

## Base de données
- Utiliser un ORM (Prisma, TypeORM, Sequelize)
- Migrations versionnées
- Seeds pour données de test
- Transactions pour opérations multiples

## Tests
- Jest ou Vitest
- Tests unitaires pour services
- Tests d'intégration pour endpoints
- Base de données de test séparée

### Exemple de test d'intégration
```typescript
import request from 'supertest';
import { app } from '@/app';

describe('GET /api/users/:id', () => {
  it('should return user when exists', async () => {
    const response = await request(app)
      .get('/api/users/1')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(response.body.success).toBe(true);
    expect(response.body.data.id).toBe(1);
  });

  it('should return 404 when user not found', async () => {
    await request(app)
      .get('/api/users/99999')
      .set('Authorization', `Bearer ${token}`)
      .expect(404);
  });
});
```

## Gestion des erreurs

### Middleware d'erreur centralisé
```typescript
// middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string
  ) {
    super(message);
  }
}

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: {
        code: err.code,
        message: err.message
      }
    });
  }

  // Erreur non gérée
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred'
    }
  });
}
```

## Validation avec Zod

```typescript
// schemas/user.schema.ts
import { z } from 'zod';

export const createUserSchema = z.object({
  body: z.object({
    email: z.string().email(),
    name: z.string().min(2).max(100),
    password: z.string().min(8)
  })
});

// middleware/validate.ts
export const validate = (schema: z.Schema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse({ body: req.body, query: req.query, params: req.params });
      next();
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            details: error.errors
          }
        });
      }
      next(error);
    }
  };
};
```

## Format des réponses API
```json
{
  "success": true,
  "data": { ... },
  "meta": { "page": 1, "total": 100 }
}
```

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Description",
    "details": [...]
  }
}
```

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, refactor, test, chore, docs
- Scope: endpoint ou service name

## Hooks Claude Code 2.1+

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Bloque les modifications sur main/master |
| Auto-format | PostToolUse | Prettier sur les fichiers TS/JS modifiés |
| Type check | PostToolUse | Vérification TypeScript après édition |
| ESLint check | PostToolUse | Validation ESLint après édition |
| Test avant commit | PreToolUse | Exécute `npm test` avant chaque commit |
| Détection secrets | PreToolUse | Bloque les secrets hardcodés |

## Skills disponibles

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyser un codebase existant |
| `planning-implementation` | Définir un plan avant de coder |
| `test-driven-development` | Cycle TDD Red-Green-Refactor |
| `reviewing-code` | Revue de code approfondie |
| `debugging-issues` | Diagnostic méthodique |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | PR complète et documentée |
