# React/Next.js Project

## Essential Commands
- `npm install` - Install dependencies
- `npm run dev` - Development server (http://localhost:3000)
- `npm test` - Run Jest tests
- `npm run lint` - Check ESLint
- `npm run build` - Production build
- `npm run storybook` - Run Storybook (if configured)

## Project Structure
- `/src/app` or `/pages` - Routes and pages
- `/src/components` - Reusable React components
- `/src/hooks` - Custom hooks
- `/src/context` - Context providers
- `/src/services` - API calls and business logic
- `/src/utils` - Utility functions
- `/src/types` - TypeScript types
- `/public` - Static assets

## React Conventions
- IMPORTANT: Functional components only (no classes)
- IMPORTANT: One component per file
- YOU MUST use TypeScript strict
- Naming: PascalCase for components, camelCase for hooks (useXxx)

## Patterns to follow
- Composition over inheritance
- Limited props drilling (max 2 levels, otherwise Context)
- Custom hooks for reusable logic
- Memoization (useMemo, useCallback) only when necessary

## Performance
- IMPORTANT: Avoid unnecessary re-renders
- Use React.memo() for expensive pure components
- Lazy loading for routes with React.lazy()
- Optimized images with next/image (Next.js)

## Tests
- Jest + React Testing Library
- Test behavior, not implementation
- YOU MUST avoid mocking React hooks

### Test structure
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { UserCard } from './UserCard';

describe('UserCard', () => {
  it('should display user name', () => {
    render(<UserCard user={{ name: 'John' }} />);
    expect(screen.getByText('John')).toBeInTheDocument();
  });

  it('should call onDelete when delete button clicked', async () => {
    const onDelete = jest.fn();
    render(<UserCard user={{ id: 1 }} onDelete={onDelete} />);

    fireEvent.click(screen.getByRole('button', { name: /delete/i }));

    expect(onDelete).toHaveBeenCalledWith(1);
  });
});
```

## State Management

### Context API (small app)
```typescript
// contexts/AuthContext.tsx
const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  return (
    <AuthContext.Provider value={{ user, setUser }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};
```

### Zustand (medium/large app)
```typescript
// stores/useStore.ts
import { create } from 'zustand';

interface Store {
  count: number;
  increment: () => void;
}

export const useStore = create<Store>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));
```

## Error handling

```typescript
// components/ErrorBoundary.tsx
class ErrorBoundary extends Component<Props, State> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('Error:', error, info);
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback onRetry={() => this.setState({ hasError: false })} />;
    }
    return this.props.children;
  }
}
```

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, style, refactor, test, chore
- Scope: component name or feature name

## Claude Code 2.1+ Hooks

The following hooks are configured in `.claude/settings.json`:

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Blocks modifications on main/master |
| Auto-format | PostToolUse | Prettier on modified TS/JS files |
| Type check | PostToolUse | TypeScript verification after edit |
| ESLint check | PostToolUse | ESLint validation after edit |
| Test before commit | PreToolUse | Runs `npm test` before each commit |
| Secrets detection | PreToolUse | Blocks hardcoded secrets |

## Available Skills

| Skill | Trigger | Usage |
|-------|---------|-------|
| `exploring-codebase` | "explore", "understand" | Analyze an existing codebase |
| `planning-implementation` | "plan", "architecture" | Define a plan before coding |
| `test-driven-development` | "TDD", "test first" | Red-Green-Refactor cycle |
| `qa-review` | "review", "verify" | In-depth code review |
| `debugging-issues` | "debug", "bug", "error" | Methodical diagnosis |
| `generating-commit-messages` | "commit", "message" | Conventional Commits |
| `creating-pull-requests` | "PR", "pull request" | Complete and documented PR |
