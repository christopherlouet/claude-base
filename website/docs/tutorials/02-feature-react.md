---
sidebar_position: 3
title: "02 - React Feature"
description: Create a complete React component and hook with tests and documentation
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Create a complete React feature

<DifficultyBadge level="beginner" /> **Estimated duration: 30 minutes**

This tutorial shows you how to create a complete React component with its hook, tests, and documentation.

## Goals

By the end of this tutorial, you will know how to:
- Use `/dev:dev-component` to create a component
- Use `/dev:dev-hook` to create a custom hook
- Use `/qa:qa-review` to check quality
- Structure a React feature professionally

## Prerequisites

- [Tutorial 01](/docs/tutorials/premier-projet) completed
- An existing React/Next.js project
- Basic React knowledge

## Context

We will create a **user card** feature including:
- A `UserCard` component with avatar, name, and status
- A `useUser` hook to fetch user data
- The associated tests

## Step 1: Explore the project

Let's start by understanding the existing structure.

```bash
/work:work-explore "Understand the structure of existing React components"
```

Claude will identify:
- The components folder (`src/components/`)
- Naming conventions
- Patterns used (CSS Modules, Tailwind, styled-components...)

## Step 2: Create the useUser hook

Let's start with the hook that manages the data.

### Launch hook creation

```bash
/dev:dev-hook "useUser - Hook to fetch and manage user data by ID"
```

### Expected result

Claude will create:

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
      setError(err instanceof Error ? err: new Error('Unknown error'));
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

## Step 3: Create the UserCard component

Now, let's create the component that uses this hook.

### Launch component creation

```bash
/dev:dev-component "UserCard - Card displaying user information with avatar, name, email, and status indicator"
```

### Expected result

Claude will create:

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

## Step 4: Check quality

Before committing, let's check the code quality.

### Launch a review

```bash
/qa:qa-review
```

### Expected result

Claude will analyze:
- TypeScript code quality
- Test coverage
- React best practices
- Accessibility

**Example feedback:**

```
## Code Review

### ✅ Strengths
- Complete TypeScript types
- Tests covering loading/error/success states
- Accessible component (alt on image)
- Clean hook/component separation

### ⚠️ Suggestions
- Add aria-label on the status indicator
- Consider React Query for data fetching
- Add Storybook stories for visual documentation

### 📊 Estimated coverage
- useUser: 85%
- UserCard: 90%
```

## Step 5: Run the tests

Let's check that everything works.

```bash
npm test
```

All tests should pass.

## Step 6: Commit

Create a clean commit for this feature.

```bash
/work:work-commit
```

**Suggested commit message:**

```
feat(user): add UserCard component with useUser hook

- Add useUser hook for fetching user data
- Add UserCard component with loading/error states
- Add comprehensive tests for both hook and component
- Support online/offline/away status indicators
```

## Recap

You have created a complete React feature:

```
src/
├── hooks/
│   ├── useUser.ts           # Data hook
│   └── __tests__/
│       └── useUser.test.ts  # Hook tests
└── components/
    └── UserCard/
        ├── UserCard.tsx     # Component
        ├── UserCard.test.tsx # Component tests
        └── index.ts         # Export
```

| Command | What it does |
|---------|--------------|
| `/dev:dev-hook` | Creates a hook with types and tests |
| `/dev:dev-component` | Creates a component with tests |
| `/qa:qa-review` | Checks code quality |

## Next steps

- [Tutorial 03: REST API](/docs/tutorials/api-rest-node) - Create a backend
- [Web Guide](/docs/concepts/stack-recipes) - React best practices
- [/dev:dev-design-system command](/docs/commands/dev/dev-design-system) - Create a design system

---

:::tip Tip
Use `/dev:dev-component` even for simple components. Claude adapts the complexity of the generated code to the described need.
:::
