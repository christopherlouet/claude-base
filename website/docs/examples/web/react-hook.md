---
sidebar_position: 2
title: Hook React Personnalisé
description: Exemple de custom hook avec gestion d'état et effets
---

# Hook React Personnalisé

Cet exemple montre comment créer un custom hook professionnel avec TypeScript et tests.

## Commande utilisée

```bash
/dev-hook "Créer un hook useDebounce pour retarder les mises à jour"
```

## Structure générée

```
src/hooks/
├── useDebounce.ts       # Hook principal
├── useDebounce.test.ts  # Tests unitaires
└── index.ts             # Exports
```

## Code du hook

### `useDebounce.ts`

```typescript
import { useState, useEffect, useRef, useCallback } from 'react';

export interface UseDebounceOptions {
  /** Délai en millisecondes (default: 500) */
  delay?: number;
  /** Exécuter immédiatement au premier appel */
  leading?: boolean;
  /** Exécuter à la fin du délai (default: true) */
  trailing?: boolean;
  /** Valeur maximale d'attente avant exécution forcée */
  maxWait?: number;
}

export interface UseDebounceReturn<T> {
  /** Valeur debouncée */
  debouncedValue: T;
  /** Annuler le debounce en cours */
  cancel: () => void;
  /** Forcer l'exécution immédiate */
  flush: () => void;
  /** Indique si un debounce est en attente */
  isPending: boolean;
}

/**
 * Hook pour retarder la mise à jour d'une valeur.
 *
 * Utile pour les recherches, validations, ou toute opération
 * qui ne doit pas s'exécuter à chaque frappe.
 *
 * @example
 * ```tsx
 * function SearchInput() {
 *   const [query, setQuery] = useState('');
 *   const { debouncedValue, isPending } = useDebounce(query, { delay: 300 });
 *
 *   useEffect(() => {
 *     if (debouncedValue) {
 *       searchAPI(debouncedValue);
 *     }
 *   }, [debouncedValue]);
 *
 *   return (
 *     <input
 *       value={query}
 *       onChange={(e) => setQuery(e.target.value)}
 *       placeholder={isPending ? 'Recherche...' : 'Rechercher'}
 *     />
 *   );
 * }
 * ```
 */
export function useDebounce<T>(
  value: T,
  options: UseDebounceOptions = {}
): UseDebounceReturn<T> {
  const {
    delay = 500,
    leading = false,
    trailing = true,
    maxWait,
  } = options;

  const [debouncedValue, setDebouncedValue] = useState<T>(value);
  const [isPending, setIsPending] = useState(false);

  const timeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const maxTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const lastValueRef = useRef<T>(value);
  const leadingCalledRef = useRef(false);

  const clearTimeouts = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
      timeoutRef.current = null;
    }
    if (maxTimeoutRef.current) {
      clearTimeout(maxTimeoutRef.current);
      maxTimeoutRef.current = null;
    }
  }, []);

  const flush = useCallback(() => {
    clearTimeouts();
    setDebouncedValue(lastValueRef.current);
    setIsPending(false);
    leadingCalledRef.current = false;
  }, [clearTimeouts]);

  const cancel = useCallback(() => {
    clearTimeouts();
    setIsPending(false);
    leadingCalledRef.current = false;
  }, [clearTimeouts]);

  useEffect(() => {
    lastValueRef.current = value;

    // Leading edge
    if (leading && !leadingCalledRef.current) {
      setDebouncedValue(value);
      leadingCalledRef.current = true;
      if (!trailing) {
        return;
      }
    }

    setIsPending(true);

    // Clear existing timeout
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    // Trailing edge
    if (trailing) {
      timeoutRef.current = setTimeout(() => {
        setDebouncedValue(value);
        setIsPending(false);
        leadingCalledRef.current = false;
      }, delay);
    }

    // Max wait
    if (maxWait && !maxTimeoutRef.current) {
      maxTimeoutRef.current = setTimeout(() => {
        setDebouncedValue(lastValueRef.current);
        setIsPending(false);
        leadingCalledRef.current = false;
        clearTimeouts();
      }, maxWait);
    }

    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, [value, delay, leading, trailing, maxWait, clearTimeouts]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      clearTimeouts();
    };
  }, [clearTimeouts]);

  return {
    debouncedValue,
    cancel,
    flush,
    isPending,
  };
}

// Alias simplifié pour les cas courants
export function useDebouncedValue<T>(value: T, delay = 500): T {
  const { debouncedValue } = useDebounce(value, { delay });
  return debouncedValue;
}
```

### `useDebounce.test.ts`

```typescript
import { renderHook, act, waitFor } from '@testing-library/react';
import { useDebounce, useDebouncedValue } from './useDebounce';

describe('useDebounce', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('returns initial value immediately', () => {
    const { result } = renderHook(() => useDebounce('initial'));

    expect(result.current.debouncedValue).toBe('initial');
  });

  it('debounces value updates', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, { delay: 500 }),
      { initialProps: { value: 'initial' } }
    );

    rerender({ value: 'updated' });

    // Valeur pas encore mise à jour
    expect(result.current.debouncedValue).toBe('initial');
    expect(result.current.isPending).toBe(true);

    // Avancer le temps
    act(() => {
      jest.advanceTimersByTime(500);
    });

    expect(result.current.debouncedValue).toBe('updated');
    expect(result.current.isPending).toBe(false);
  });

  it('cancels pending updates on cancel()', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, { delay: 500 }),
      { initialProps: { value: 'initial' } }
    );

    rerender({ value: 'updated' });

    act(() => {
      result.current.cancel();
    });

    act(() => {
      jest.advanceTimersByTime(500);
    });

    // Valeur reste à l'ancienne
    expect(result.current.debouncedValue).toBe('initial');
  });

  it('immediately updates on flush()', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, { delay: 500 }),
      { initialProps: { value: 'initial' } }
    );

    rerender({ value: 'updated' });

    act(() => {
      result.current.flush();
    });

    expect(result.current.debouncedValue).toBe('updated');
    expect(result.current.isPending).toBe(false);
  });

  it('supports leading edge execution', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, { delay: 500, leading: true }),
      { initialProps: { value: 'initial' } }
    );

    rerender({ value: 'updated' });

    // Mise à jour immédiate sur leading edge
    expect(result.current.debouncedValue).toBe('updated');
  });

  it('respects maxWait option', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, { delay: 500, maxWait: 1000 }),
      { initialProps: { value: 'initial' } }
    );

    // Simuler des mises à jour rapides
    for (let i = 0; i < 5; i++) {
      rerender({ value: `update-${i}` });
      act(() => {
        jest.advanceTimersByTime(300);
      });
    }

    // Après 1000ms (maxWait), la valeur doit être mise à jour
    expect(result.current.debouncedValue).not.toBe('initial');
  });
});

describe('useDebouncedValue', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('provides simplified API', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebouncedValue(value, 300),
      { initialProps: { value: 'test' } }
    );

    rerender({ value: 'updated' });

    expect(result.current).toBe('test');

    act(() => {
      jest.advanceTimersByTime(300);
    });

    expect(result.current).toBe('updated');
  });
});
```

### `index.ts`

```typescript
export { useDebounce, useDebouncedValue } from './useDebounce';
export type { UseDebounceOptions, UseDebounceReturn } from './useDebounce';
```

## Exemple d'utilisation

### Recherche en temps réel

```tsx
import { useState, useEffect } from 'react';
import { useDebounce } from '@/hooks';

function SearchUsers() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [isLoading, setIsLoading] = useState(false);

  const { debouncedValue, isPending } = useDebounce(query, {
    delay: 300,
    leading: false,
  });

  useEffect(() => {
    if (!debouncedValue.trim()) {
      setResults([]);
      return;
    }

    const searchUsers = async () => {
      setIsLoading(true);
      try {
        const response = await fetch(`/api/users?q=${debouncedValue}`);
        const data = await response.json();
        setResults(data);
      } finally {
        setIsLoading(false);
      }
    };

    searchUsers();
  }, [debouncedValue]);

  return (
    <div>
      <input
        type="search"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Rechercher un utilisateur..."
      />

      {(isPending || isLoading) && <Spinner />}

      <ul>
        {results.map((user) => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  );
}
```

### Validation de formulaire

```tsx
import { useDebounce } from '@/hooks';

function EmailInput({ onValidate }) {
  const [email, setEmail] = useState('');
  const [error, setError] = useState('');

  const { debouncedValue } = useDebounce(email, { delay: 500 });

  useEffect(() => {
    if (!debouncedValue) {
      setError('');
      return;
    }

    // Validation asynchrone
    checkEmailAvailability(debouncedValue)
      .then((available) => {
        setError(available ? '' : 'Email déjà utilisé');
        onValidate(available);
      });
  }, [debouncedValue, onValidate]);

  return (
    <div>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      {error && <span className="error">{error}</span>}
    </div>
  );
}
```

## Points clés

| Aspect | Implémentation |
|--------|----------------|
| **Options flexibles** | `leading`, `trailing`, `maxWait` |
| **Contrôle** | `cancel()` et `flush()` exposés |
| **État** | `isPending` pour feedback UI |
| **Cleanup** | Nettoyage des timeouts au démontage |
| **TypeScript** | Types génériques pour la valeur |

## Commandes associées

- `/dev-test` - Ajouter plus de tests
- `/dev-component` - Créer un composant utilisant ce hook
- `/doc-explain` - Comprendre le fonctionnement

---

:::tip Bibliothèques alternatives
Pour des cas plus avancés, considérez :
- `use-debounce` - Bibliothèque populaire
- `lodash.debounce` - Avec `useCallback`
- `ahooks` - Collection complète de hooks
:::
