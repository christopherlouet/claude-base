---
name: state-management
description: State management patterns and implementation. Trigger when the user wants to manage global state, use Redux, Zustand, or other solutions.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
user-invocable: false
---

# State Management

## Triggers

- "state management"
- "global state"
- "Redux"
- "Zustand"
- "store"
- "context"

## Solution Choice

### Decision Tree

```
Need global state?
├── No → local useState/useReducer
└── Yes →
    ├── Simple (< 5 stores) → Zustand
    ├── Complex (> 5 stores) → Redux Toolkit
    ├── Server state → React Query/SWR
    └── Forms → React Hook Form
```

### Comparison

| Solution | Bundle | Devtools | Learning | Use Case |
|----------|--------|----------|----------|----------|
| Zustand | 1.2kb | Yes | Easy | General |
| Redux TK | 10kb | Excellent | Medium | Enterprise |
| Jotai | 2kb | Yes | Easy | Atoms |
| React Query | 12kb | Excellent | Medium | Server state |
| Context | 0kb | Limited | Easy | Theme, Auth |

## Zustand (Recommended)

### Installation

```bash
npm install zustand
```

### Simple Store

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

### Async Store

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
// Specific selector (minimal re-render)
const count = useCounterStore((state) => state.count);

// Multiple values with shallow
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

### Typed Hooks

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

### Client/Server State Separation

```typescript
// Server state → React Query
const { data: users } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });

// Client state → Zustand
const { filters, setFilters } = useFilterStore();
```

### Computed Values

```typescript
// Zustand with computed
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
| State in props drilling | Context or global store |
| Everything in one store | Separate by domain |
| Server state in Redux | Use React Query |
| Excessive re-renders | Granular selectors |
