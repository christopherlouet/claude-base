# Projet React/Next.js

## Commandes Essentielles
- `npm install` - Installer les dépendances
- `npm run dev` - Serveur de développement (http://localhost:3000)
- `npm test` - Lancer les tests Jest
- `npm run lint` - Vérifier ESLint
- `npm run build` - Build de production
- `npm run storybook` - Lancer Storybook (si configuré)

## Structure du Projet
- `/src/app` ou `/pages` - Routes et pages
- `/src/components` - Composants React réutilisables
- `/src/hooks` - Custom hooks
- `/src/context` - Context providers
- `/src/services` - Appels API et logique métier
- `/src/utils` - Fonctions utilitaires
- `/src/types` - Types TypeScript
- `/public` - Assets statiques

## Conventions React
- IMPORTANT: Composants fonctionnels uniquement (pas de classes)
- IMPORTANT: Un composant par fichier
- YOU MUST utiliser TypeScript strict
- Nommage: PascalCase pour composants, camelCase pour hooks (useXxx)

## Patterns à suivre
- Composition over inheritance
- Props drilling limité (max 2 niveaux, sinon Context)
- Custom hooks pour logique réutilisable
- Memoization (useMemo, useCallback) uniquement si nécessaire

## Performance
- IMPORTANT: Éviter les re-renders inutiles
- Utiliser React.memo() pour composants purs coûteux
- Lazy loading pour routes avec React.lazy()
- Images optimisées avec next/image (Next.js)

## Tests
- Jest + React Testing Library
- Tester le comportement, pas l'implémentation
- YOU MUST éviter les mocks de hooks React

### Structure des tests
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

### Context API (petite app)
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

### Zustand (app moyenne/grande)
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

## Gestion des erreurs

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
- Scope: component name ou feature name

## Hooks Claude Code 2.1+

Les hooks suivants sont configurés dans `.claude/settings.json` :

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Bloque les modifications sur main/master |
| Auto-format | PostToolUse | Prettier sur les fichiers TS/JS modifiés |
| Type check | PostToolUse | Vérification TypeScript après édition |
| ESLint check | PostToolUse | Validation ESLint après édition |
| Test avant commit | PreToolUse | Exécute `npm test` avant chaque commit |
| Détection secrets | PreToolUse | Bloque les secrets hardcodés |

## Skills disponibles

| Skill | Déclenchement | Usage |
|-------|---------------|-------|
| `exploring-codebase` | "explorer", "comprendre" | Analyser un codebase existant |
| `planning-implementation` | "planifier", "architecture" | Définir un plan avant de coder |
| `test-driven-development` | "TDD", "test first" | Cycle Red-Green-Refactor |
| `reviewing-code` | "review", "vérifier" | Revue de code approfondie |
| `debugging-issues` | "debug", "bug", "erreur" | Diagnostic méthodique |
| `generating-commit-messages` | "commit", "message" | Conventional Commits |
| `creating-pull-requests` | "PR", "pull request" | PR complète et documentée |
