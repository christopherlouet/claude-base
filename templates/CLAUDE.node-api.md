# Node.js API Project

## Essential Commands
- `npm install` - Install dependencies
- `npm run dev` - Development server with hot-reload
- `npm test` - Run tests
- `npm run lint` - Check ESLint
- `npm run build` - Compile TypeScript
- `npm start` - Start in production
- `npm run db:migrate` - Run migrations

## Project Structure
- `/src/routes` or `/src/controllers` - API endpoints
- `/src/services` - Business logic
- `/src/models` - Data models / ORM
- `/src/middleware` - Express/Fastify middleware
- `/src/utils` - Utility functions
- `/src/types` - TypeScript types
- `/src/config` - Configuration
- `/tests` - Unit and integration tests

## API Conventions
- IMPORTANT: Consistent REST or GraphQL
- IMPORTANT: Input validation on ALL endpoints
- YOU MUST handle errors cleanly (try/catch, error middleware)
- YOU MUST log requests and errors

## Security
- IMPORTANT: Parameterized SQL queries (never concatenation)
- IMPORTANT: Authentication on protected routes
- Rate limiting on public endpoints
- Validation with Joi/Zod/class-validator
- Input sanitization

## Database
- Use an ORM (Prisma, TypeORM, Sequelize)
- Versioned migrations
- Seeds for test data
- Transactions for multi-step operations

## Tests
- Jest or Vitest
- Unit tests for services
- Integration tests for endpoints
- Separate test database

### Integration test example
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

## Error handling

### Centralized error middleware
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

  // Unhandled error
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

## Validation with Zod

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

## API response format
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
- Scope: endpoint or service name

## Claude Code 2.1+ Hooks

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Blocks modifications on main/master |
| Auto-format | PostToolUse | Prettier on modified TS/JS files |
| Type check | PostToolUse | TypeScript check after edit |
| ESLint check | PostToolUse | ESLint validation after edit |
| Test before commit | PreToolUse | Runs `npm test` before each commit |
| Secret detection | PreToolUse | Blocks hardcoded secrets |

## Available skills

| Skill | Usage |
|-------|-------|
| `exploring-codebase` | Analyze an existing codebase |
| `planning-implementation` | Define a plan before coding |
| `test-driven-development` | Red-Green-Refactor TDD cycle |
| `reviewing-code` | In-depth code review |
| `debugging-issues` | Methodical diagnosis |
| `generating-commit-messages` | Conventional Commits |
| `creating-pull-requests` | Complete and documented PR |
