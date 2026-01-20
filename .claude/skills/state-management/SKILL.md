---
name: state-management
description: Patterns et implementation de state management. Declencher quand l'utilisateur veut gerer l'etat global, utiliser Redux, Zustand, ou d'autres solutions.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# State Management

## Declencheurs

- "state management"
- "etat global"
- "Redux"
- "Zustand"
- "store"
- "context"

## Choix de Solution

### Arbre de Decision

```
Besoin de state global?
├── Non → useState/useReducer local
└── Oui →
    ├── Simple (< 5 stores) → Zustand
    ├── Complexe (> 5 stores) → Redux Toolkit
    ├── Server state → React Query/SWR
    └── Formulaires → React Hook Form
```

### Comparatif

| Solution | Bundle | Devtools | Learning | Use Case |
|----------|--------|----------|----------|----------|
| Zustand | 1.2kb | Oui | Facile | General |
| Redux TK | 10kb | Excellent | Moyen | Enterprise |
| Jotai | 2kb | Oui | Facile | Atoms |
| React Query | 12kb | Excellent | Moyen | Server state |
| Context | 0kb | Limited | Facile | Theme, Auth |

## Zustand (Recommande)

### Installation

```bash
npm install zustand
```

### Store Simple

```typescript
// stores/useCounterStore.ts
import { create } from 'zustand';

interface CounterState {
  count: number;
  increment: () => void;
  decrement: () => void;
  reset: () => void;
}

export const useCounterStore = create<CounterState>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  reset: () => set({ count: 0 }),
}));
```

### Store avec Async

```typescript
// stores/useUserStore.ts
import { create } from 'zustand';

interface User {
  id: string;
  name: string;
  email: string;
}

interface UserState {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  fetchUser: (id: string) => Promise<void>;
  logout: () => void;
}

export const useUserStore = create<UserState>((set) => ({
  user: null,
  isLoading: false,
  error: null,

  fetchUser: async (id: string) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`/api/users/${id}`);
      const user = await response.json();
      set({ user, isLoading: false });
    } catch (error) {
      set({ error: 'Failed to fetch user', isLoading: false });
    }
  },

  logout: () => set({ user: null }),
}));
```

### Persistence

```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useSettingsStore = create(
  persist<SettingsState>(
    (set) => ({
      theme: 'light',
      setTheme: (theme) => set({ theme }),
    }),
    {
      name: 'settings-storage',
    }
  )
);
```

### Selectors (Performance)

```typescript
// Selecteur specifique (re-render minimal)
const count = useCounterStore((state) => state.count);

// Multiple valeurs avec shallow
import { shallow } from 'zustand/shallow';

const { user, isLoading } = useUserStore(
  (state) => ({ user: state.user, isLoading: state.isLoading }),
  shallow
);
```

## Redux Toolkit

### Installation

```bash
npm install @reduxjs/toolkit react-redux
```

### Slice

```typescript
// features/counter/counterSlice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface CounterState {
  value: number;
}

const initialState: CounterState = {
  value: 0,
};

export const counterSlice = createSlice({
  name: 'counter',
  initialState,
  reducers: {
    increment: (state) => {
      state.value += 1;
    },
    decrement: (state) => {
      state.value -= 1;
    },
    incrementByAmount: (state, action: PayloadAction<number>) => {
      state.value += action.payload;
    },
  },
});

export const { increment, decrement, incrementByAmount } = counterSlice.actions;
export default counterSlice.reducer;
```

### Store

```typescript
// store/index.ts
import { configureStore } from '@reduxjs/toolkit';
import counterReducer from '../features/counter/counterSlice';

export const store = configureStore({
  reducer: {
    counter: counterReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

### Hooks Types

```typescript
// store/hooks.ts
import { useDispatch, useSelector, TypedUseSelectorHook } from 'react-redux';
import type { RootState, AppDispatch } from './index';

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
```

## React Query (Server State)

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Fetch
const { data, isLoading, error } = useQuery({
  queryKey: ['users', userId],
  queryFn: () => fetchUser(userId),
});

// Mutation
const queryClient = useQueryClient();

const mutation = useMutation({
  mutationFn: createUser,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] });
  },
});
```

## Patterns

### Separation Client/Server State

```typescript
// Server state → React Query
const { data: users } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });

// Client state → Zustand
const { filters, setFilters } = useFilterStore();
```

### Computed Values

```typescript
// Zustand avec computed
export const useCartStore = create<CartState>((set, get) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),

  // Computed
  get total() {
    return get().items.reduce((sum, item) => sum + item.price, 0);
  },
}));
```

## Anti-Patterns

| Anti-Pattern | Solution |
|--------------|----------|
| State dans props drilling | Context ou store global |
| Tout dans un store | Separer par domaine |
| Server state dans Redux | Utiliser React Query |
| Re-renders excessifs | Selectors granulaires |
