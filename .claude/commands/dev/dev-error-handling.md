# Agent ERROR-HANDLING

Implémente une stratégie de gestion d'erreurs robuste et cohérente.

## Cible
$ARGUMENTS

## Objectif

Mettre en place une gestion d'erreurs professionnelle qui améliore la fiabilité,
facilite le débogage et offre une meilleure expérience utilisateur.

## Stratégie de gestion d'erreurs

```
┌─────────────────────────────────────────────────────────────┐
│                    ERROR HANDLING STRATEGY                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. CLASSIFIER    → Catégoriser les types d'erreurs        │
│  ═══════════                                                │
│                                                             │
│  2. STRUCTURER    → Créer hiérarchie d'erreurs custom      │
│  ════════════                                               │
│                                                             │
│  3. IMPLÉMENTER   → Patterns de gestion par contexte       │
│  ═════════════                                              │
│                                                             │
│  4. PROPAGER      → Stratégie de propagation claire        │
│  ══════════                                                 │
│                                                             │
│  5. LOGGER        → Logging structuré et contextuel        │
│  ════════                                                   │
│                                                             │
│  6. RÉCUPÉRER     → Stratégies de recovery/fallback        │
│  ══════════                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Classification des erreurs

### Taxonomie des erreurs

| Catégorie | Description | Exemples | Récupérable |
|-----------|-------------|----------|-------------|
| **Validation** | Entrées invalides | Format email, champ vide | Oui |
| **Business** | Règles métier violées | Solde insuffisant | Oui |
| **Authentication** | Problèmes d'auth | Token expiré, accès refusé | Oui |
| **NotFound** | Ressource absente | User not found | Oui |
| **Conflict** | État conflictuel | Doublon, version obsolète | Oui |
| **External** | Services tiers | API timeout, service down | Partiel |
| **Infrastructure** | Système | DB down, disk full | Non |
| **Programming** | Bugs | Null pointer, type error | Non |

### Matrice erreurs → codes HTTP

```
┌─────────────────────────────────────────────────────────────┐
│                    MAPPING HTTP CODES                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  400 Bad Request     → ValidationError                      │
│  401 Unauthorized    → AuthenticationError                  │
│  403 Forbidden       → AuthorizationError                   │
│  404 Not Found       → NotFoundError                        │
│  409 Conflict        → ConflictError                        │
│  422 Unprocessable   → BusinessRuleError                    │
│  429 Too Many        → RateLimitError                       │
│  500 Server Error    → InternalError                        │
│  502 Bad Gateway     → ExternalServiceError                 │
│  503 Unavailable     → ServiceUnavailableError              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 2 : Hiérarchie d'erreurs custom

### Structure de base

```typescript
// Base error class
export class AppError extends Error {
  public readonly code: string;
  public readonly statusCode: number;
  public readonly isOperational: boolean;
  public readonly context?: Record<string, unknown>;
  public readonly timestamp: Date;

  constructor(
    message: string,
    code: string,
    statusCode: number = 500,
    isOperational: boolean = true,
    context?: Record<string, unknown>
  ) {
    super(message);
    this.name = this.constructor.name;
    this.code = code;
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.context = context;
    this.timestamp = new Date();

    Error.captureStackTrace(this, this.constructor);
  }

  toJSON() {
    return {
      name: this.name,
      code: this.code,
      message: this.message,
      statusCode: this.statusCode,
      timestamp: this.timestamp,
      ...(process.env.NODE_ENV === 'development' && {
        stack: this.stack,
        context: this.context,
      }),
    };
  }
}
```

### Erreurs spécialisées

```typescript
// Validation errors
export class ValidationError extends AppError {
  public readonly fields: Record<string, string[]>;

  constructor(
    message: string,
    fields: Record<string, string[]>,
    context?: Record<string, unknown>
  ) {
    super(message, 'VALIDATION_ERROR', 400, true, context);
    this.fields = fields;
  }
}

// Business logic errors
export class BusinessError extends AppError {
  constructor(
    message: string,
    code: string = 'BUSINESS_ERROR',
    context?: Record<string, unknown>
  ) {
    super(message, code, 422, true, context);
  }
}

// Not found errors
export class NotFoundError extends AppError {
  public readonly resource: string;
  public readonly identifier: string;

  constructor(resource: string, identifier: string) {
    super(
      `${resource} not found: ${identifier}`,
      'NOT_FOUND',
      404,
      true,
      { resource, identifier }
    );
    this.resource = resource;
    this.identifier = identifier;
  }
}

// Authentication errors
export class AuthenticationError extends AppError {
  constructor(message: string = 'Authentication required') {
    super(message, 'AUTHENTICATION_ERROR', 401, true);
  }
}

// Authorization errors
export class AuthorizationError extends AppError {
  constructor(
    message: string = 'Permission denied',
    context?: Record<string, unknown>
  ) {
    super(message, 'AUTHORIZATION_ERROR', 403, true, context);
  }
}

// External service errors
export class ExternalServiceError extends AppError {
  public readonly service: string;
  public readonly originalError?: Error;

  constructor(
    service: string,
    message: string,
    originalError?: Error
  ) {
    super(
      `External service error [${service}]: ${message}`,
      'EXTERNAL_SERVICE_ERROR',
      502,
      true,
      { service, originalMessage: originalError?.message }
    );
    this.service = service;
    this.originalError = originalError;
  }
}

// Rate limit errors
export class RateLimitError extends AppError {
  public readonly retryAfter: number;

  constructor(retryAfter: number = 60) {
    super(
      `Rate limit exceeded. Retry after ${retryAfter} seconds`,
      'RATE_LIMIT_ERROR',
      429,
      true,
      { retryAfter }
    );
    this.retryAfter = retryAfter;
  }
}
```

## Étape 3 : Patterns de gestion

### Middleware Express global

```typescript
import { Request, Response, NextFunction } from 'express';
import { AppError } from './errors';
import { logger } from './logger';

// Async handler wrapper
export const asyncHandler = (
  fn: (req: Request, res: Response, next: NextFunction) => Promise<void>
) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

// Global error handler
export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Default values
  let statusCode = 500;
  let response: Record<string, unknown> = {
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
    },
  };

  // Handle known errors
  if (err instanceof AppError) {
    statusCode = err.statusCode;
    response.error = err.toJSON();

    // Log operational errors as warnings
    if (err.isOperational) {
      logger.warn('Operational error', {
        error: err.toJSON(),
        request: {
          method: req.method,
          path: req.path,
          query: req.query,
          userId: req.user?.id,
        },
      });
    }
  }

  // Handle unknown errors (programming errors)
  if (!(err instanceof AppError) || !err.isOperational) {
    logger.error('Unexpected error', {
      error: {
        name: err.name,
        message: err.message,
        stack: err.stack,
      },
      request: {
        method: req.method,
        path: req.path,
        body: req.body,
        userId: req.user?.id,
      },
    });

    // In production, don't leak error details
    if (process.env.NODE_ENV === 'production') {
      response.error = {
        code: 'INTERNAL_ERROR',
        message: 'An unexpected error occurred',
      };
    } else {
      response.error = {
        code: 'INTERNAL_ERROR',
        message: err.message,
        stack: err.stack,
      };
    }
  }

  res.status(statusCode).json(response);
};

// 404 handler
export const notFoundHandler = (req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    error: {
      code: 'ROUTE_NOT_FOUND',
      message: `Cannot ${req.method} ${req.path}`,
    },
  });
};
```

### Try-catch structuré

```typescript
// ❌ Mauvais: catch générique
async function getUser(id: string) {
  try {
    return await db.users.findById(id);
  } catch (error) {
    console.log(error); // Perd le contexte
    throw error;
  }
}

// ✅ Bon: gestion contextuelle
async function getUser(id: string): Promise<User> {
  try {
    const user = await db.users.findById(id);

    if (!user) {
      throw new NotFoundError('User', id);
    }

    return user;
  } catch (error) {
    if (error instanceof NotFoundError) {
      throw error; // Re-throw known errors
    }

    // Wrap unknown errors with context
    throw new ExternalServiceError(
      'Database',
      'Failed to fetch user',
      error instanceof Error ? error : new Error(String(error))
    );
  }
}
```

### Result Pattern (Alternative aux exceptions)

```typescript
// Result type
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

// Helper functions
const ok = <T>(data: T): Result<T, never> => ({
  success: true,
  data,
});

const fail = <E>(error: E): Result<never, E> => ({
  success: false,
  error,
});

// Usage
async function validateEmail(email: string): Promise<Result<string, ValidationError>> {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  if (!email) {
    return fail(new ValidationError('Email is required', { email: ['required'] }));
  }

  if (!emailRegex.test(email)) {
    return fail(new ValidationError('Invalid email format', { email: ['invalid_format'] }));
  }

  return ok(email.toLowerCase());
}

// Consumer
const result = await validateEmail(input);
if (!result.success) {
  // Handle error
  console.log(result.error.fields);
} else {
  // Use data
  console.log(result.data);
}
```

## Étape 4 : Stratégie de propagation

### Règles de propagation

```
┌─────────────────────────────────────────────────────────────┐
│                    ERROR PROPAGATION RULES                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  COUCHE          │ ACTION                                  │
│  ════════════════│═══════════════════════════════════════  │
│                  │                                          │
│  Repository      │ Wrap DB errors → ExternalServiceError   │
│                  │                                          │
│  Service         │ Throw business errors                    │
│                  │ Re-throw known errors                    │
│                  │ Wrap unknown → InternalError             │
│                  │                                          │
│  Controller      │ Let errors propagate                     │
│                  │ Middleware handles all                   │
│                  │                                          │
│  Middleware      │ Format response                          │
│                  │ Log appropriately                        │
│                  │                                          │
└─────────────────────────────────────────────────────────────┘
```

### Exemple multi-couches

```typescript
// Repository layer
class UserRepository {
  async findById(id: string): Promise<User | null> {
    try {
      return await this.db.users.findUnique({ where: { id } });
    } catch (error) {
      throw new ExternalServiceError(
        'Database',
        `Failed to find user ${id}`,
        error instanceof Error ? error : undefined
      );
    }
  }
}

// Service layer
class UserService {
  constructor(private repo: UserRepository) {}

  async getUser(id: string): Promise<User> {
    // Validation
    if (!id || typeof id !== 'string') {
      throw new ValidationError('Invalid user ID', { id: ['required'] });
    }

    // Business logic
    const user = await this.repo.findById(id);

    if (!user) {
      throw new NotFoundError('User', id);
    }

    if (user.deletedAt) {
      throw new BusinessError('User account has been deactivated', 'USER_DEACTIVATED');
    }

    return user;
  }
}

// Controller layer
class UserController {
  constructor(private service: UserService) {}

  getUser = asyncHandler(async (req: Request, res: Response) => {
    const user = await this.service.getUser(req.params.id);
    res.json({ success: true, data: user });
  });
}
```

## Étape 5 : Logging structuré

### Configuration du logger

```typescript
import winston from 'winston';

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: {
    service: process.env.SERVICE_NAME || 'app',
    environment: process.env.NODE_ENV,
  },
  transports: [
    new winston.transports.Console({
      format: process.env.NODE_ENV === 'development'
        ? winston.format.combine(
            winston.format.colorize(),
            winston.format.simple()
          )
        : winston.format.json(),
    }),
  ],
});

// Add file transport in production
if (process.env.NODE_ENV === 'production') {
  logger.add(new winston.transports.File({
    filename: 'logs/error.log',
    level: 'error',
  }));
  logger.add(new winston.transports.File({
    filename: 'logs/combined.log',
  }));
}

export { logger };
```

### Patterns de logging

```typescript
// ❌ Mauvais logging
try {
  await processOrder(order);
} catch (error) {
  console.log('Error:', error); // Perd contexte
}

// ✅ Bon logging
try {
  logger.info('Processing order', {
    orderId: order.id,
    userId: order.userId,
    amount: order.total,
  });

  await processOrder(order);

  logger.info('Order processed successfully', {
    orderId: order.id,
    processingTime: Date.now() - startTime,
  });
} catch (error) {
  logger.error('Failed to process order', {
    orderId: order.id,
    userId: order.userId,
    error: {
      name: error.name,
      message: error.message,
      code: error instanceof AppError ? error.code : undefined,
      stack: error.stack,
    },
  });
  throw error;
}
```

## Étape 6 : Stratégies de recovery

### Retry avec backoff exponentiel

```typescript
interface RetryConfig {
  maxRetries: number;
  baseDelay: number;
  maxDelay: number;
  retryableErrors?: string[];
}

async function withRetry<T>(
  fn: () => Promise<T>,
  config: RetryConfig = {
    maxRetries: 3,
    baseDelay: 1000,
    maxDelay: 10000,
  }
): Promise<T> {
  let lastError: Error;

  for (let attempt = 0; attempt <= config.maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      // Check if error is retryable
      const isRetryable =
        error instanceof ExternalServiceError ||
        (config.retryableErrors?.includes((error as AppError).code));

      if (!isRetryable || attempt === config.maxRetries) {
        throw lastError;
      }

      // Calculate delay with exponential backoff
      const delay = Math.min(
        config.baseDelay * Math.pow(2, attempt),
        config.maxDelay
      );

      logger.warn('Retrying operation', {
        attempt: attempt + 1,
        maxRetries: config.maxRetries,
        delay,
        error: lastError.message,
      });

      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }

  throw lastError!;
}

// Usage
const data = await withRetry(
  () => externalApi.fetchData(),
  { maxRetries: 3, baseDelay: 1000, maxDelay: 5000 }
);
```

### Circuit Breaker

```typescript
enum CircuitState {
  CLOSED = 'CLOSED',
  OPEN = 'OPEN',
  HALF_OPEN = 'HALF_OPEN',
}

class CircuitBreaker {
  private state: CircuitState = CircuitState.CLOSED;
  private failures: number = 0;
  private lastFailureTime?: Date;
  private successCount: number = 0;

  constructor(
    private readonly threshold: number = 5,
    private readonly timeout: number = 30000,
    private readonly halfOpenRequests: number = 3
  ) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === CircuitState.OPEN) {
      if (Date.now() - this.lastFailureTime!.getTime() > this.timeout) {
        this.state = CircuitState.HALF_OPEN;
        this.successCount = 0;
      } else {
        throw new ExternalServiceError(
          'CircuitBreaker',
          'Circuit is OPEN - service unavailable'
        );
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private onSuccess(): void {
    if (this.state === CircuitState.HALF_OPEN) {
      this.successCount++;
      if (this.successCount >= this.halfOpenRequests) {
        this.state = CircuitState.CLOSED;
        this.failures = 0;
      }
    } else {
      this.failures = 0;
    }
  }

  private onFailure(): void {
    this.failures++;
    this.lastFailureTime = new Date();

    if (this.failures >= this.threshold) {
      this.state = CircuitState.OPEN;
      logger.warn('Circuit breaker opened', {
        failures: this.failures,
        threshold: this.threshold,
      });
    }
  }
}
```

### Fallback gracieux

```typescript
async function getUserWithFallback(id: string): Promise<User> {
  try {
    // Try primary source
    return await userService.getUser(id);
  } catch (error) {
    if (error instanceof ExternalServiceError) {
      logger.warn('Primary source failed, trying cache', { userId: id });

      // Try cache
      const cached = await cache.get(`user:${id}`);
      if (cached) {
        return JSON.parse(cached);
      }

      // Return minimal user object
      logger.warn('Cache miss, returning minimal user', { userId: id });
      return {
        id,
        name: 'Unknown',
        email: '',
        _partial: true,
      };
    }
    throw error;
  }
}
```

## Bonnes pratiques

### À faire

| Pratique | Raison |
|----------|--------|
| **Erreurs custom typées** | Meilleure gestion et typage |
| **Contexte dans les erreurs** | Facilite le débogage |
| **Logging structuré** | Analysable par outils |
| **Fail fast** | Détection précoce des problèmes |
| **Recovery gracieux** | Meilleure UX |

### À éviter

| Anti-pattern | Problème | Solution |
|--------------|----------|----------|
| `catch {}` vide | Avale les erreurs | Au minimum logger |
| `throw "error"` | Pas de stack trace | Utiliser Error ou custom |
| Catch puis ignore | Perd l'information | Re-throw ou handle |
| Log et throw | Double logging | L'un ou l'autre |
| Générique `Error` | Pas de contexte | Erreurs typées |

## Output attendu

### Fichiers générés

```markdown
## Error Handling Implementation

**Fichiers créés:**
- `src/errors/index.ts` - Classes d'erreurs custom
- `src/middleware/errorHandler.ts` - Middleware global
- `src/utils/retry.ts` - Utilitaires retry/circuit breaker
- `src/config/logger.ts` - Configuration logging

**Classes d'erreurs:**
- AppError (base)
- ValidationError
- BusinessError
- NotFoundError
- AuthenticationError
- AuthorizationError
- ExternalServiceError
- RateLimitError
```

## Checklist

- [ ] Classes d'erreurs custom créées
- [ ] Middleware global configuré
- [ ] Logging structuré en place
- [ ] Stratégie de propagation définie
- [ ] Retry/Circuit breaker implémentés
- [ ] Fallbacks configurés pour services critiques
- [ ] Tests des cas d'erreur

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/debug` | Diagnostiquer des erreurs |
| `/test` | Tester les cas d'erreur |
| `/monitoring` | Alertes sur erreurs |
| `/api` | Documenter les erreurs API |
| `/review` | Review gestion d'erreurs |

---

IMPORTANT: Toute erreur doit être soit gérée, soit propagée. Jamais avalée.

YOU MUST utiliser des erreurs typées avec contexte.

YOU MUST logger les erreurs avec contexte structuré.

NEVER utiliser catch vide ou console.log pour les erreurs.

Think hard sur la stratégie de recovery pour chaque type d'erreur.
