---
sidebar_position: 3
title: "02 - Feature React"
description: Créez un composant et un hook React complets avec tests et documentation
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Créer une feature React complète

<DifficultyBadge level="beginner" /> **Durée estimée : 30 minutes**

Ce tutoriel vous montre comment créer un composant React complet avec son hook, ses tests et sa documentation.

## Objectifs

À la fin de ce tutoriel, vous saurez :
- Utiliser `/dev:dev-component` pour créer un composant
- Utiliser `/dev:dev-hook` pour créer un hook personnalisé
- Utiliser `/qa:qa-review` pour vérifier la qualité
- Structurer une feature React de manière professionnelle

## Prérequis

- [Tutoriel 01](/docs/tutorials/premier-projet) complété
- Un projet React/Next.js existant
- Connaissances de base en React

## Contexte

Nous allons créer une feature de **carte utilisateur** comprenant :
- Un composant `UserCard` avec avatar, nom et statut
- Un hook `useUser` pour récupérer les données utilisateur
- Les tests associés

## Étape 1 : Explorer le projet

Commençons par comprendre la structure existante.

```bash
/work:work-explore "Comprendre la structure des composants React existants"
```

Claude va identifier :
- Le dossier des composants (`src/components/`)
- Les conventions de nommage
- Les patterns utilisés (CSS Modules, Tailwind, styled-components...)

## Étape 2 : Créer le hook useUser

Commençons par le hook qui gère les données.

### Lancez la création du hook

```bash
/dev:dev-hook "useUser - Hook pour récupérer et gérer les données d'un utilisateur par son ID"
```

### Résultat attendu

Claude va créer :

**`src/hooks/useUser.ts`**
```typescript
import { useState, useEffect } from 'react';

interface User {
  id: string;
  name: string;
  email: string;
  avatar: string;
  status: 'online' | 'offline' | 'away';
}

interface UseUserOptions {
  enabled?: boolean;
}

interface UseUserResult {
  user: User | null;
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
}

export function useUser(userId: string, options: UseUserOptions = {}): UseUserResult {
  const { enabled = true } = options;
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const fetchUser = async () => {
    if (!userId || !enabled) return;

    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch(`/api/users/${userId}`);
      if (!response.ok) throw new Error('Failed to fetch user');
      const data = await response.json();
      setUser(data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchUser();
  }, [userId, enabled]);

  return { user, isLoading, error, refetch: fetchUser };
}
```

**`src/hooks/__tests__/useUser.test.ts`**
```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { useUser } from '../useUser';

// Mock fetch
global.fetch = jest.fn();

describe('useUser', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should fetch user data', async () => {
    const mockUser = { id: '1', name: 'John', email: 'john@example.com' };
    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve(mockUser),
    });

    const { result } = renderHook(() => useUser('1'));

    expect(result.current.isLoading).toBe(true);

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
    });

    expect(result.current.user).toEqual(mockUser);
  });

  it('should handle errors', async () => {
    (fetch as jest.Mock).mockResolvedValueOnce({ ok: false });

    const { result } = renderHook(() => useUser('1'));

    await waitFor(() => {
      expect(result.current.error).toBeTruthy();
    });
  });
});
```

## Étape 3 : Créer le composant UserCard

Maintenant, créons le composant qui utilise ce hook.

### Lancez la création du composant

```bash
/dev:dev-component "UserCard - Carte affichant les informations d'un utilisateur avec avatar, nom, email et indicateur de statut"
```

### Résultat attendu

Claude va créer :

**`src/components/UserCard/UserCard.tsx`**
```tsx
import { useUser } from '@/hooks/useUser';

interface UserCardProps {
  userId: string;
  showEmail?: boolean;
  className?: string;
}

const statusColors = {
  online: 'bg-green-500',
  offline: 'bg-gray-400',
  away: 'bg-yellow-500',
};

export function UserCard({ userId, showEmail = true, className = '' }: UserCardProps) {
  const { user, isLoading, error } = useUser(userId);

  if (isLoading) {
    return (
      <div className={`animate-pulse rounded-lg bg-gray-200 p-4 ${className}`}>
        <div className="flex items-center gap-3">
          <div className="h-12 w-12 rounded-full bg-gray-300" />
          <div className="space-y-2">
            <div className="h-4 w-24 rounded bg-gray-300" />
            <div className="h-3 w-32 rounded bg-gray-300" />
          </div>
        </div>
      </div>
    );
  }

  if (error || !user) {
    return (
      <div className={`rounded-lg border border-red-200 bg-red-50 p-4 ${className}`}>
        <p className="text-sm text-red-600">Impossible de charger l'utilisateur</p>
      </div>
    );
  }

  return (
    <div className={`rounded-lg border bg-white p-4 shadow-sm ${className}`}>
      <div className="flex items-center gap-3">
        <div className="relative">
          <img
            src={user.avatar}
            alt={user.name}
            className="h-12 w-12 rounded-full object-cover"
          />
          <span
            className={`absolute bottom-0 right-0 h-3 w-3 rounded-full border-2 border-white ${statusColors[user.status]}`}
            title={user.status}
          />
        </div>
        <div>
          <h3 className="font-medium text-gray-900">{user.name}</h3>
          {showEmail && (
            <p className="text-sm text-gray-500">{user.email}</p>
          )}
        </div>
      </div>
    </div>
  );
}
```

**`src/components/UserCard/UserCard.test.tsx`**
```tsx
import { render, screen } from '@testing-library/react';
import { UserCard } from './UserCard';
import { useUser } from '@/hooks/useUser';

jest.mock('@/hooks/useUser');

const mockUseUser = useUser as jest.MockedFunction<typeof useUser>;

describe('UserCard', () => {
  const mockUser = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    avatar: '/avatar.jpg',
    status: 'online' as const,
  };

  it('renders user information', () => {
    mockUseUser.mockReturnValue({
      user: mockUser,
      isLoading: false,
      error: null,
      refetch: jest.fn(),
    });

    render(<UserCard userId="1" />);

    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });

  it('shows loading state', () => {
    mockUseUser.mockReturnValue({
      user: null,
      isLoading: true,
      error: null,
      refetch: jest.fn(),
    });

    render(<UserCard userId="1" />);

    expect(screen.getByRole('generic')).toHaveClass('animate-pulse');
  });

  it('shows error state', () => {
    mockUseUser.mockReturnValue({
      user: null,
      isLoading: false,
      error: new Error('Failed'),
      refetch: jest.fn(),
    });

    render(<UserCard userId="1" />);

    expect(screen.getByText(/impossible de charger/i)).toBeInTheDocument();
  });
});
```

**`src/components/UserCard/index.ts`**
```typescript
export { UserCard } from './UserCard';
export type { UserCardProps } from './UserCard';
```

## Étape 4 : Vérifier la qualité

Avant de commiter, vérifions la qualité du code.

### Lancez une review

```bash
/qa:qa-review
```

### Résultat attendu

Claude va analyser :
- La qualité du code TypeScript
- La couverture de tests
- Les bonnes pratiques React
- L'accessibilité

**Exemple de feedback :**

```
## Code Review

### ✅ Points positifs
- Types TypeScript complets
- Tests couvrant les états loading/error/success
- Composant accessible (alt sur image)
- Séparation hook/composant propre

### ⚠️ Suggestions
- Ajouter aria-label sur l'indicateur de statut
- Considérer React Query pour le data fetching
- Ajouter Storybook stories pour la documentation visuelle

### 📊 Couverture estimée
- useUser: 85%
- UserCard: 90%
```

## Étape 5 : Lancer les tests

Vérifions que tout fonctionne.

```bash
npm test
```

Tous les tests devraient passer.

## Étape 6 : Commiter

Créez un commit propre pour cette feature.

```bash
/work:work-commit
```

**Message de commit suggéré :**

```
feat(user): add UserCard component with useUser hook

- Add useUser hook for fetching user data
- Add UserCard component with loading/error states
- Add comprehensive tests for both hook and component
- Support online/offline/away status indicators
```

## Récapitulatif

Vous avez créé une feature React complète :

```
src/
├── hooks/
│   ├── useUser.ts           # Hook de données
│   └── __tests__/
│       └── useUser.test.ts  # Tests du hook
└── components/
    └── UserCard/
        ├── UserCard.tsx     # Composant
        ├── UserCard.test.tsx # Tests du composant
        └── index.ts         # Export
```

| Commande | Ce qu'elle fait |
|----------|-----------------|
| `/dev:dev-hook` | Crée un hook avec types et tests |
| `/dev:dev-component` | Crée un composant avec tests |
| `/qa:qa-review` | Vérifie la qualité du code |

## Prochaines étapes

- [Tutoriel 03 : API REST](/docs/tutorials/api-rest-node) - Créer un backend
- [Guide Web](/docs/guides/web-guide) - Bonnes pratiques React
- [Commande /dev:dev-design-system](/docs/commands/dev/dev-design-system) - Créer un design system

---

:::tip Astuce
Utilisez `/dev:dev-component` même pour des composants simples. Claude adapte la complexité du code généré au besoin décrit.
:::
