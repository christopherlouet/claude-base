---
name: dev-error-handling
description: Strategie de gestion des erreurs. Declencher quand l'utilisateur veut implementer la gestion d'erreurs, exceptions, ou error boundaries.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# Error Handling

## Principes

1. **Fail fast** - Detecter les erreurs tot
2. **Fail loud** - Logger clairement
3. **Fail gracefully** - UX propre
4. **Recover when possible** - Retry, fallback

## Erreurs personnalisees

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
