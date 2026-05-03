---
sidebar_position: 5
title: Rules
description: Understanding Claude Code rules
---

# Rules

> Conventions applied automatically based on file paths

## What is a Rule?

A **rule** is a set of conventions and best practices applied automatically when you work on certain types of files.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  User: "Modify src/components/Button.tsx"                      │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ Path detection                         │                    │
│  │                                        │                    │
│  │ "**/*.tsx" → TypeScript Rule active    │                    │
│  │ "**/components/**" → React Rule active │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ Conventions injected                   │                    │
│  │                                        │                    │
│  │ - TypeScript strict mode               │                    │
│  │ - No `any`                             │                    │
│  │ - Functional components                │                    │
│  │ - Hooks for logic                      │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼                                                 │
│  Claude applies the conventions automatically                  │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## File structure

Rules live in `.claude/rules/`:

```
.claude/rules/
├── typescript.md      # TypeScript conventions
├── react.md           # React conventions
├── flutter.md         # Flutter/Dart conventions
├── python.md          # Python conventions
├── go.md              # Go conventions
├── testing.md         # Testing conventions
├── security.md        # Security rules
├── api.md             # API conventions
├── git.md             # Git conventions
├── workflow.md        # Mandatory workflow
├── accessibility.md   # Accessibility rules
└── performance.md     # Performance rules
```

## Anatomy of a rule

### With frontmatter (path-specific)

```markdown
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Rules

## Strict mode

IMPORTANT: Strict mode enabled (`"strict": true`)

## Types

IMPORTANT: No `any` except documented exceptional cases

YOU MUST define interfaces for complex objects

## Naming

| Type | Convention | Example |
|------|------------|---------|
| Variables | camelCase | `getUserById` |
| Interfaces | PascalCase | `UserService` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY` |
```

### Without frontmatter (global)

```markdown
# Git Rules

## Conventional Commits

\`\`\`
type(scope): short description
\`\`\`

### Allowed types

| Type | Usage |
|------|-------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| refactor | Refactoring |
```

## Frontmatter

### `paths` field

Defines when the rule applies:

```yaml
---
paths:
  - "**/*.ts"           # All .ts files
  - "**/*.tsx"          # All .tsx files
  - "**/components/**"  # components directory
  - "**/api/**"         # api directory
---
```

### Supported patterns

| Pattern | Description | Example |
|---------|-------------|---------|
| `*` | One segment | `*.ts` |
| `**` | Zero or more segments | `**/*.ts` |
| `?` | One character | `file?.ts` |

## Rule categories

### By language

| Rule | Paths | Content |
|------|-------|---------|
| `typescript.md` | `**/*.ts`, `**/*.tsx` | Strict mode, types, conventions |
| `react.md` | `**/*.tsx`, `**/components/**` | Components, hooks, performance |
| `flutter.md` | `**/*.dart`, `**/lib/**` | Clean Architecture, BLoC |
| `python.md` | `**/*.py` | Type hints, PEP 8 |
| `go.md` | `**/*.go` | Error handling, interfaces |

### Cross-cutting

| Rule | Paths | Content |
|------|-------|---------|
| `testing.md` | `**/*.test.ts`, `**/__tests__/**` | Coverage, mocks |
| `security.md` | `**/auth/**`, `**/api/**` | Validation, XSS, injection |
| `api.md` | `**/api/**`, `**/routes/**` | REST, status codes |
| `git.md` | - | Conventional commits |
| `workflow.md` | - | Explore → Specify → Plan → TDD → Audit → Commit |

## Rule examples

### TypeScript Rule

```markdown
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Rules

## Configuration

IMPORTANT: Strict mode enabled

\`\`\`json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true
  }
}
\`\`\`

## Types

IMPORTANT: No `any` except documented cases

YOU MUST define interfaces:

\`\`\`typescript
// Good
interface User {
  id: string;
  name: string;
}

// Bad
const user: any = { ... };
\`\`\`

## Naming

| Type | Convention |
|------|------------|
| Variables/Functions | camelCase |
| Interfaces/Classes | PascalCase |
| Constants | SCREAMING_SNAKE |
```

### React Rule

```markdown
---
paths:
  - "**/*.tsx"
  - "**/components/**"
---

# React Rules

## Components

YOU MUST use functional components:

\`\`\`tsx
// Good
function Button({ label }: ButtonProps) {
  return <button>{label}</button>;
}

// Avoid
class Button extends Component { ... }
\`\`\`

## Hooks

IMPORTANT: Extract logic into custom hooks:

\`\`\`tsx
// Good
function useUser(id: string) {
  const [user, setUser] = useState<User | null>(null);
  // ...
  return { user, loading, error };
}

// Usage
function UserProfile({ id }: Props) {
  const { user, loading } = useUser(id);
  // ...
}
\`\`\`

## Performance

- Use `memo()` for pure components
- Use `useMemo()` for expensive computations
- Use `useCallback()` for callbacks passed as props
```

### Security Rule

```markdown
---
paths:
  - "**/auth/**"
  - "**/api/**"
  - "**/routes/**"
---

# Security Rules

## Input validation

IMPORTANT: Validate ALL user inputs

\`\`\`typescript
// With Zod
const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});
\`\`\`

## XSS prevention

NEVER insert unescaped HTML:

\`\`\`tsx
// Dangerous
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// Safe
<div>{sanitize(userInput)}</div>
\`\`\`

## SQL queries

IMPORTANT: Use parameterized queries:

\`\`\`typescript
// Dangerous
const query = \`SELECT * FROM users WHERE id = \${userId}\`;

// Safe
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);
\`\`\`
```

## Create a new rule

### 1. Create the file

```bash
touch .claude/rules/my-rule.md
```

### 2. Define the frontmatter (optional)

```yaml
---
paths:
  - "**/*.extension"
  - "**/folder/**"
---
```

### 3. Write the conventions

```markdown
# My Rule

## Convention 1

IMPORTANT: Description of the rule.

## Convention 2

YOU MUST follow this practice.

NEVER do this.

## Examples

\`\`\`typescript
// Good
...

// Bad
...
\`\`\`
```

## Rule priority

When multiple rules apply to the same file:

1. Specific rules (more precise path) > General rules
2. Rules defined later in the file > Rules defined earlier
3. Rules don't replace each other, they accumulate

## Best practices

1. **Precise paths**: Target exactly the relevant files
2. **Clear conventions**: Use IMPORTANT, YOU MUST, NEVER
3. **Concrete examples**: Show the good and the bad
4. **No duplication**: One convention in a single place
5. **Maintainability**: Update as standards evolve

---

## See also

- [Commands](./commands) - Manual instructions
- [Skills](./skills) - Automatic behaviors
- [Hooks](./hooks) - Pre/post tool actions
