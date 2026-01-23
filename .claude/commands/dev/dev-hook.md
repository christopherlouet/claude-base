# Agent DEV-HOOK

Créer un custom hook React/Vue avec tests et documentation.

## Contexte
$ARGUMENTS

## Pre-requis TDD

IMPORTANT: Cette commande suit l'approche TDD. Les tests seront ecrits AVANT le code du hook.

**Ordre de creation obligatoire:**
1. Definir les types (Options, Return)
2. Ecrire les tests du hook avec `renderHook` (RED)
3. Implementer le hook (GREEN)
4. Refactorer si necessaire (REFACTOR)

Si vous souhaitez proceder autrement, utilisez `/dev-hook --skip-tdd` (non recommande).

---

## Processus de création

### 1. Définir le hook

#### Questions clés
- Quel problème résout ce hook ?
- Quels paramètres accepte-t-il ?
- Que retourne-t-il ?
- Quels effets de bord a-t-il ?
- Doit-il être réutilisable globalement ?

### 2. Structure à générer

```
src/hooks/
├── use[HookName].ts        # Hook principal
├── use[HookName].test.ts   # Tests
└── index.ts                # Export
```

### 3. Template hook React

```typescript
// use[HookName].ts
import { useState, useEffect, useCallback, useMemo } from 'react';

interface Use[HookName]Options {
  /** Option 1 */
  option1?: string;
  /** Option 2 */
  option2?: boolean;
}

interface Use[HookName]Return {
  /** Données retournées */
  data: DataType | null;
  /** État de chargement */
  isLoading: boolean;
  /** Erreur éventuelle */
  error: Error | null;
  /** Action disponible */
  refetch: () => Promise<void>;
}

/**
 * Hook pour [description]
 *
 * @example
 * ```tsx
 * const { data, isLoading, error } = use[HookName]({ option1: 'value' });
 * ```
 */
export function use[HookName](options: Use[HookName]Options = {}): Use[HookName]Return {
  const { option1, option2 = false } = options;

  const [data, setData] = useState<DataType | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const refetch = useCallback(async () => {
    setIsLoading(true);
    setError(null);

    try {
      // Logique du hook
      const result = await fetchData(option1);
      setData(result);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
    } finally {
      setIsLoading(false);
    }
  }, [option1]);

  useEffect(() => {
    refetch();
  }, [refetch]);

  // Mémoisation si calcul coûteux
  const processedData = useMemo(() => {
    if (!data) return null;
    return processData(data);
  }, [data]);

  return {
    data: processedData,
    isLoading,
    error,
    refetch,
  };
}
```

### 4. Patterns courants

#### Hook de fetch
```typescript
export function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    fetch(url, { signal: controller.signal })
      .then(res => res.json())
      .then(setData)
      .catch(err => {
        if (err.name !== 'AbortError') setError(err);
      })
      .finally(() => setIsLoading(false));

    return () => controller.abort();
  }, [url]);

  return { data, isLoading, error };
}
```

#### Hook de localStorage
```typescript
export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = useCallback((value: T | ((val: T) => T)) => {
    setStoredValue(prev => {
      const valueToStore = value instanceof Function ? value(prev) : value;
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
      return valueToStore;
    });
  }, [key]);

  return [storedValue, setValue] as const;
}
```

#### Hook de debounce
```typescript
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
```

#### Hook de media query
```typescript
export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(
    () => window.matchMedia(query).matches
  );

  useEffect(() => {
    const mediaQuery = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);

    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, [query]);

  return matches;
}
```

### 5. Template tests

```typescript
// use[HookName].test.ts
import { renderHook, act, waitFor } from '@testing-library/react';
import { use[HookName] } from './use[HookName]';

describe('use[HookName]', () => {
  it('returns initial state', () => {
    const { result } = renderHook(() => use[HookName]());

    expect(result.current.data).toBeNull();
    expect(result.current.isLoading).toBe(true);
    expect(result.current.error).toBeNull();
  });

  it('fetches data successfully', async () => {
    const { result } = renderHook(() => use[HookName]({ option1: 'test' }));

    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
    });

    expect(result.current.data).toBeDefined();
    expect(result.current.error).toBeNull();
  });

  it('handles errors', async () => {
    // Mock error
    jest.spyOn(global, 'fetch').mockRejectedValueOnce(new Error('Failed'));

    const { result } = renderHook(() => use[HookName]());

    await waitFor(() => {
      expect(result.current.error).toBeDefined();
    });

    expect(result.current.data).toBeNull();
  });

  it('refetches on demand', async () => {
    const { result } = renderHook(() => use[HookName]());

    await waitFor(() => expect(result.current.isLoading).toBe(false));

    act(() => {
      result.current.refetch();
    });

    expect(result.current.isLoading).toBe(true);
  });

  it('updates when options change', async () => {
    const { result, rerender } = renderHook(
      ({ option1 }) => use[HookName]({ option1 }),
      { initialProps: { option1: 'initial' } }
    );

    await waitFor(() => expect(result.current.isLoading).toBe(false));

    rerender({ option1: 'updated' });

    expect(result.current.isLoading).toBe(true);
  });
});
```

### 6. Checklist qualité

- [ ] Types explicites pour options et retour
- [ ] JSDoc avec @example
- [ ] Cleanup des effets (return dans useEffect)
- [ ] Gestion des erreurs
- [ ] Mémoisation si nécessaire
- [ ] Tests complets
- [ ] Pas de memory leaks

## Output attendu

### Fichiers générés
- `use[HookName].ts`
- `use[HookName].test.ts`
- Export dans `index.ts`

### Documentation
```markdown
## use[HookName]

### Usage
\`\`\`tsx
const { data, isLoading, error, refetch } = use[HookName]({
  option1: 'value',
});
\`\`\`

### Options
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| option1 | string | - | Description |

### Return
| Value | Type | Description |
|-------|------|-------------|
| data | T \| null | Données |
| isLoading | boolean | État de chargement |
| error | Error \| null | Erreur |
| refetch | () => Promise<void> | Recharger |
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/component` | Composant utilisant le hook |
| `/test` | Tests complémentaires |
| `/doc` | Documenter le hook |
| `/perf` | Optimiser les performances |

---

IMPORTANT: Toujours nettoyer les effets de bord (AbortController, clearTimeout, removeEventListener).

YOU MUST typer les options et le retour explicitement.

NEVER oublier la gestion des erreurs et des états de chargement.

Think hard sur les dépendances des useEffect et useCallback.
