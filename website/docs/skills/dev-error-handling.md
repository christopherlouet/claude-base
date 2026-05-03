---
sidebar_position: 9
title: "dev-error-handling"
description: "Error handling strategy. Trigger when the user wants to implement error handling, exceptions, or error boundaries."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-error-handling

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Error handling strategy. Trigger when the user wants to implement error handling, exceptions, or error boundaries.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| **Keywords** | `dev`, `error`, `handling` |

## Detailed description

# Error Handling

## Principles

1. **Fail fast** - Detect errors early
2. **Fail loud** - Log clearly
3. **Fail gracefully** - Clean UX
4. **Recover when possible** - Retry, fallback

## Custom errors

```typescript
// Base error
class AppError extends Error {
  constructor(
    message: string,
    public code: string,
    public statusCode: number = 500
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

// Specific errors
class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} not found: ${id}`, 'NOT_FOUND', 404);
  }
}

class ValidationError extends AppError {
  constructor(public errors: Record<string, string>) {
    super('Validation failed', 'VALIDATION_ERROR', 400);
  }
}
```

## API Error Response

```typescript
// Error handler middleware
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
      }
    });
  }

  // Log unexpected errors
  logger.error({ err, requestId: req.id }, 'Unexpected error');

  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'Something went wrong',
    }
  });
});
```

## React Error Boundary

```tsx
class ErrorBoundary extends Component<Props, State> {
  state = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    logger.error({ error, info }, 'React error boundary');
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback error={this.state.error} />;
    }
    return this.props.children;
  }
}
```

## Retry Pattern

```typescript
async function withRetry<T>(
  fn: () => Promise<T>,
  retries = 3,
  delay = 1000
): Promise<T> {
  try {
    return await fn();
  } catch (error) {
    if (retries === 0) throw error;
    await sleep(delay);
    return withRetry(fn, retries - 1, delay * 2);
  }
}
```

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to dev..."_
- _"I want to error..."_
- _"I want to handling..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Example: Error Handling Patterns

# Example: Error Handling Patterns

## Scenario
A Node.js API needs structured error handling: custom error classes, middleware, and client-friendly responses.

## Custom Error Hierarchy

```typescript
// src/errors/base.ts
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number,
    public readonly details?: Record<string, unknown>,
  ) {
    super(message);
    this.name = this.constructor.name;
  }
}

export class ValidationError extends AppError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(message, 'VALIDATION_ERROR', 400, details);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} with id ${id} not found`, 'NOT_FOUND', 404);
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(message, 'CONFLICT', 409);
  }
}
```

## Error Middleware

```typescript
// src/middleware/error-handler.ts
import { logger } from '@/lib/logger';

export function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
  if (err instanceof AppError) {
    // Known errors: log at warn, return structured response
    logger.warn({ err, requestId: req.id }, err.message);
    return res.status(err.statusCode).json({
      success: false,
      error: { code: err.code, message: err.message, details: err.details },
    });
  }

  // Unknown errors: log at error, return generic 500
  logger.error({ err, requestId: req.id }, 'Unhandled error');
  res.status(500).json({
    success: false,
    error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' },
  });
}
```

## Usage in Service

```typescript
// src/services/user.service.ts
export class UserService {
  async getById(id: string): Promise<User> {
    const user = await this.db.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundError('User', id);
    return user;
  }

  async create(input: CreateUserInput): Promise<User> {
    const existing = await this.db.user.findByEmail(input.email);
    if (existing) throw new ConflictError('Email already registered');
    return this.db.user.create({ data: input });
  }
}
```

## React Error Boundary (Frontend)

```tsx
// components/ErrorBoundary.tsx
class ErrorBoundary extends React.Component<Props, { error: Error | null }> {
  state = { error: null };
  static getDerivedStateFromError(error: Error) { return { error }; }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    reportError(error, info.componentStack);  // Send to Sentry/logging
  }

  render() {
    if (this.state.error) return <ErrorFallback error={this.state.error} onRetry={() => this.setState({ error: null })} />;
    return this.props.children;
  }
}
```

## Key Decisions

- **Error hierarchy**: `AppError` base class enables consistent handling via `instanceof`
- **Separate known vs unknown**: Known errors get specific status codes, unknown get 500
- **No stack traces to client**: Internal details logged server-side, never exposed
- **Error codes over messages**: Clients use `code` field for programmatic handling
- **Error boundary on frontend**: Catches render errors, reports to monitoring, shows fallback UI



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
