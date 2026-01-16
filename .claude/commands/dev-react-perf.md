# Agent DEV-REACT-PERF

Optimisation performance React/Next.js basée sur 45 règles priorisées par impact.

## Cible
$ARGUMENTS

## Niveaux de priorité

| Niveau | Impact | Focus |
|--------|--------|-------|
| **CRITICAL** | Très élevé | Waterfalls, Bundle size |
| **HIGH** | Élevé | Server performance, Client fetching |
| **MEDIUM** | Moyen | Re-renders, Rendering |
| **LOW** | Faible | JS micro-optimizations, Advanced patterns |

## Règles par catégorie

### 1. CRITICAL - Élimination des Waterfalls

Les waterfalls sont la cause #1 des performances dégradées.

- [ ] **async-parallel** : Paralléliser les fetches indépendants
  ```typescript
  // Avant (waterfall)
  const user = await getUser();
  const posts = await getPosts();

  // Après (parallel)
  const [user, posts] = await Promise.all([getUser(), getPosts()]);
  ```

- [ ] **async-defer-await** : Démarrer le fetch avant d'awaiter
  ```typescript
  // Avant
  const data = await fetch('/api/data');

  // Après
  const dataPromise = fetch('/api/data');
  // ... autre code ...
  const data = await dataPromise;
  ```

- [ ] **async-dependencies** : Éviter les dépendances de données séquentielles
- [ ] **async-api-routes** : Paralléliser dans les API routes
- [ ] **async-suspense-boundaries** : Placer les Suspense boundaries stratégiquement

### 2. CRITICAL - Optimisation Bundle Size

- [ ] **bundle-barrel-imports** : Éviter les barrel imports (index.ts)
  ```typescript
  // Avant (importe tout le barrel)
  import { Button } from '@/components';

  // Après (import direct)
  import { Button } from '@/components/Button';
  ```

- [ ] **bundle-dynamic-imports** : Utiliser `next/dynamic` pour les gros composants
  ```typescript
  const HeavyChart = dynamic(() => import('./HeavyChart'), {
    loading: () => <Skeleton />,
    ssr: false
  });
  ```

- [ ] **bundle-defer-third-party** : Différer les scripts third-party
- [ ] **bundle-conditional** : Imports conditionnels pour features optionnelles
- [ ] **bundle-preload** : Preload des ressources critiques

### 3. HIGH - Performance Serveur

- [ ] **server-cache-react** : Utiliser le cache React pour les fetches
  ```typescript
  import { cache } from 'react';

  export const getUser = cache(async (id: string) => {
    return await db.user.findUnique({ where: { id } });
  });
  ```

- [ ] **server-cache-lru** : Cache LRU pour données fréquentes
- [ ] **server-serialization** : Minimiser la sérialisation RSC
- [ ] **server-parallel-fetching** : Fetches parallèles côté serveur
- [ ] **server-after-nonblocking** : Utiliser `after()` pour tâches non-bloquantes

### 4. HIGH - Récupération Données Client

- [ ] **client-swr-dedup** : SWR/React Query pour déduplication et cache
  ```typescript
  // Déduplication automatique des requêtes identiques
  const { data } = useSWR('/api/user', fetcher, {
    dedupingInterval: 2000
  });
  ```

- [ ] **client-event-listeners** : Cleanup des event listeners

### 5. MEDIUM - Optimisation Re-renders

- [ ] **rerender-defer-reads** : Différer les lectures de state
- [ ] **rerender-memo** : `React.memo()` pour composants purs coûteux
  ```typescript
  const ExpensiveList = memo(({ items }: Props) => {
    return items.map(item => <Item key={item.id} {...item} />);
  });
  ```

- [ ] **rerender-dependencies** : Stabiliser les dépendances de hooks
  ```typescript
  // Avant (nouvelle référence à chaque render)
  useEffect(() => {}, [{ id: 1 }]);

  // Après (référence stable)
  const config = useMemo(() => ({ id: 1 }), []);
  useEffect(() => {}, [config]);
  ```

- [ ] **rerender-derived-state** : Calculer au render vs stocker en state
- [ ] **rerender-functional-setstate** : Updater fonctionnel pour state basé sur précédent
- [ ] **rerender-lazy-state-init** : Initialisation lazy du state
- [ ] **rerender-transitions** : `useTransition` pour updates non-urgentes

### 6. MEDIUM - Performance Rendu

- [ ] **rendering-content-visibility** : `content-visibility: auto` pour listes longues
  ```css
  .list-item {
    content-visibility: auto;
    contain-intrinsic-size: 0 100px;
  }
  ```

- [ ] **rendering-hoist-jsx** : Extraire le JSX statique hors du render
- [ ] **rendering-hydration-no-flicker** : Éviter le flicker d'hydration
- [ ] **rendering-activity** : `<Activity>` pour cacher sans démonter (React 19+)
- [ ] **rendering-conditional-render** : Éviter les renders conditionnels coûteux
- [ ] **rendering-animate-svg-wrapper** : Wrapper pour animer les SVG
- [ ] **rendering-svg-precision** : Réduire la précision des paths SVG

### 7. LOW - Performance JavaScript

- [ ] **js-batch-dom-css** : Batcher les modifications DOM/CSS
- [ ] **js-index-maps** : Utiliser Map pour lookups O(1)
  ```typescript
  // Avant O(n)
  const item = items.find(i => i.id === id);

  // Après O(1)
  const itemsMap = new Map(items.map(i => [i.id, i]));
  const item = itemsMap.get(id);
  ```

- [ ] **js-cache-property-access** : Cacher les accès répétés aux propriétés
- [ ] **js-cache-function-results** : Memoization des fonctions pures
- [ ] **js-cache-storage** : Cache localStorage/sessionStorage
- [ ] **js-combine-iterations** : Combiner les itérations multiples
- [ ] **js-length-check-first** : Vérifier la longueur avant d'itérer
- [ ] **js-early-exit** : Early return pour éviter les calculs inutiles
- [ ] **js-hoist-regexp** : Hoister les RegExp hors des boucles
- [ ] **js-min-max-loop** : `Math.min/max` avec spread pour petits arrays
- [ ] **js-set-map-lookups** : Set pour vérifications d'appartenance
- [ ] **js-tosorted-immutable** : `toSorted()` pour tri immutable (ES2023)

### 8. LOW - Patterns Avancés

- [ ] **advanced-event-handler-refs** : Refs pour event handlers stables
  ```typescript
  const onClickRef = useRef(onClick);
  onClickRef.current = onClick;

  const stableOnClick = useCallback(() => {
    onClickRef.current?.();
  }, []);
  ```

- [ ] **advanced-use-latest** : Hook `useLatest` pour valeurs toujours fraîches

## Outils de diagnostic

### Bundle Analyzer
```bash
# Next.js
ANALYZE=true npm run build

# Vite
npx vite-bundle-visualizer
```

### React DevTools Profiler
1. Ouvrir React DevTools > Profiler
2. Record pendant interaction
3. Identifier les composants lents (>16ms)

### Lighthouse
```bash
npx lighthouse https://example.com --only-categories=performance
```

## Output attendu

### Rapport d'optimisation

```markdown
## Audit Performance React : [Composant/Page]

### Score actuel
- LCP: [X]s (objectif: <2.5s)
- Bundle size: [X]kb (objectif: <200kb initial)
- Re-renders inutiles: [X] identifiés

### Violations par priorité

#### CRITICAL (à corriger immédiatement)
| Règle | Fichier | Impact estimé |
|-------|---------|---------------|
| async-parallel | api/route.ts:23 | -500ms |
| bundle-barrel-imports | components/index.ts | -50kb |

#### HIGH
| Règle | Fichier | Impact estimé |
|-------|---------|---------------|

#### MEDIUM
| Règle | Fichier | Impact estimé |
|-------|---------|---------------|

### Corrections proposées
1. [Correction 1 avec code]
2. [Correction 2 avec code]

### Gains estimés
- LCP: [avant] → [après]
- Bundle: [avant] → [après]
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/qa-perf` | Audit performance générique (pas spécifique React) |
| `/refactor` | Après identification des optimisations |
| `/component` | Créer des composants optimisés dès le départ |
| `/review` | Review incluant la performance |

---

IMPORTANT: Mesurer AVANT et APRÈS chaque optimisation pour valider l'impact réel.

YOU MUST prioriser CRITICAL > HIGH > MEDIUM > LOW. Ne pas optimiser les LOW avant d'avoir traité les CRITICAL.

NEVER optimiser prématurément - profiler d'abord, optimiser ensuite.

Think hard sur le ratio effort/gain de chaque optimisation.
