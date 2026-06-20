# DEV-ERROR-HANDLING Agent

Implements a robust and consistent error handling strategy.

## Request context
$ARGUMENTS

## Goal

Set up professional error handling that improves reliability,
makes debugging easier and provides a better user experience.

## Workflow

- **Classify** errors (Validation, Business, Auth, NotFound, External, Infrastructure)
- **Structure** a custom error hierarchy with code, statusCode, context and timestamp
- **Implement** handling patterns (global middleware, async handler, Result pattern)
- **Propagate** across layers (Repository wraps, Service throw/re-throw, Controller passes through, Middleware formats)
- **Log** in a structured way with context (no console.log)
- **Recover** with retry (exponential backoff), circuit breaker and graceful fallback

## Expected output

- Custom error classes (AppError base + specialized)
- Global handling middleware
- Retry/circuit breaker utilities
- Structured logging configuration
- Error case tests

## Related agents

| Agent | When to use |
|-------|-------------|
| `/dev:dev-debug` | Diagnose errors |
| `/dev:dev-tdd` | Test error cases |
| `/ops:ops-monitoring` | Alerts on errors |
| `/dev:dev-api` | Document API errors |
| `/qa:qa-review` | Review error handling |

---

IMPORTANT: Every error must be either handled or propagated. Never swallowed.

YOU MUST use typed errors with context.

YOU MUST log errors with structured context.

NEVER use empty catch or console.log for errors.

Think hard about the recovery strategy for each type of error.
