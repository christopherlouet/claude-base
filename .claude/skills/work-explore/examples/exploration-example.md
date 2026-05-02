# Codebase exploration example

## Context
New developer on a Next.js e-commerce project.

## Exploration performed

### 1. Overview
```bash
# Project structure
tree -L 2 -d src/
```

**Result:**
```
src/
├── app/           # Next.js 13+ routes (App Router)
├── components/    # React components
├── hooks/         # Custom hooks
├── lib/           # Utilities and configuration
├── services/      # API calls
└── types/         # TypeScript types
```

### 2. Entry points identified
- `src/app/layout.tsx` - Main layout
- `src/app/page.tsx` - Home page
- `src/lib/db.ts` - Database connection
- `src/services/api.ts` - API client

### 3. Patterns discovered

| Pattern | Location | Usage |
|---------|----------|-------|
| Server Components | `app/**/*.tsx` | Server-side rendering |
| Client Components | `components/**/*.tsx` | Interactivity |
| Custom Hooks | `hooks/use*.ts` | Reusable logic |
| Zod Validation | `lib/schemas/*.ts` | Data validation |

### 4. Key dependencies
```json
{
  "next": "14.x",
  "react": "18.x",
  "prisma": "5.x",
  "zod": "3.x",
  "tailwindcss": "3.x"
}
```

### 5. Conventions detected
- Naming: PascalCase for components, camelCase for hooks
- Tests: `__tests__/` next to files
- Styles: Tailwind CSS, no CSS modules

## Final output

```markdown
## Exploration summary

**Project type**: Next.js 14 e-commerce
**Architecture**: App Router + Server Components
**Database**: PostgreSQL via Prisma
**Styling**: Tailwind CSS

### Key files to know
1. `src/app/layout.tsx` - Entry point
2. `src/lib/db.ts` - Prisma configuration
3. `src/services/api.ts` - Backend calls

### Recommended next steps
- Read `src/app/api/` to understand the endpoints
- Explore `src/components/` for the UI components
```
