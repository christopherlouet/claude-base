---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
---

# TypeScript Rules

## Strict Mode

- IMPORTANT: Strict mode enabled (`"strict": true`)
- Do not disable TypeScript checks
- Fix type errors, do not ignore them

## Type Safety

- IMPORTANT: No `any` except documented exceptional cases
- YOU MUST define interfaces for complex objects
- Prefer `unknown` over `any` when the type is unknown
- Use type guards for narrowing

## Types vs Interfaces

- Prefer `type` for unions and intersections
- Prefer `interface` for extensible objects
- Use `interface` for public APIs

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variables/Functions | camelCase | `getUserById` |
| Classes/Interfaces | PascalCase | `UserService` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Generic types | T, K, V or descriptive | `TData`, `TError` |
| Enums | PascalCase (name and values) | `UserRole.Admin` |

## File Naming

| Type | Convention | Example |
|------|------------|---------|
| React components | PascalCase | `UserCard.tsx` |
| Services/Utils | kebab-case | `user-service.ts` |
| Types/Interfaces | kebab-case or PascalCase | `user-types.ts` |
| Tests | same name + .test | `user-service.test.ts` |

## Best Practices

- Pure functions when possible
- Data immutability
- Single Responsibility Principle
- DRY but not at the expense of readability
- Avoid side effects in functions
