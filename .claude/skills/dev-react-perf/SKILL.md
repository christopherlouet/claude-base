---
name: dev-react-perf
description: Optimisation des performances React/Next.js. Declencher quand l'utilisateur veut optimiser le rendu, reduire les re-renders, ou ameliorer les Core Web Vitals.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# React Performance Optimization

## Eviter les re-renders inutiles

### useMemo - Memoiser les calculs couteux

```tsx
const expensiveValue = useMemo(() => {
  return computeExpensiveValue(items);
}, [items]);
```

### useCallback - Memoiser les fonctions

```tsx
const handleClick = useCallback(() => {
  onSubmit(formData);
}, [formData, onSubmit]);
```

### React.memo - Memoiser les composants

```tsx
const UserCard = memo(({ user }: Props) => {
  return <div>{user.name}</div>;
});
```

## Lazy Loading

```tsx
// Components
const HeavyComponent = lazy(() => import('./HeavyComponent'));

<Suspense fallback={<Loading />}>
  <HeavyComponent />
</Suspense>

// Routes (Next.js)
const DynamicComponent = dynamic(() => import('./Component'), {
  loading: () => <Skeleton />,
  ssr: false,
});
```

## Virtualisation

```tsx
import { FixedSizeList } from 'react-window';

<FixedSizeList
  height={400}
  itemCount={items.length}
  itemSize={50}
>
  {({ index, style }) => (
    <div style={style}>{items[index].name}</div>
  )}
</FixedSizeList>
```

## Images (Next.js)

```tsx
import Image from 'next/image';

<Image
  src="/photo.jpg"
  alt="Description"
  width={800}
  height={600}
  priority={isAboveFold}
  placeholder="blur"
/>
```

## Core Web Vitals

| Metrique | Cible | Optimisation |
|----------|-------|--------------|
| LCP | < 2.5s | Preload hero image, SSR |
| FID | < 100ms | Code splitting, defer JS |
| CLS | < 0.1 | Explicit dimensions |

## Composition Patterns

### Eviter les boolean props excessifs

```tsx
// MAUVAIS : boolean props explosion
<Button primary large rounded disabled loading />

// BON : composition avec variants
<Button variant="primary" size="large" shape="rounded" state="loading" />

// MIEUX : composants composes
<Button.Primary size="large">
  <Button.Spinner /> Loading...
</Button.Primary>
```

### Compound Components

```tsx
// Pattern compound component
function Tabs({ children }: { children: React.ReactNode }) {
  const [active, setActive] = useState(0);
  return (
    <TabsContext.Provider value={{ active, setActive }}>
      {children}
    </TabsContext.Provider>
  );
}

Tabs.List = function TabList({ children }) { /* ... */ };
Tabs.Tab = function Tab({ index, children }) { /* ... */ };
Tabs.Panel = function TabPanel({ index, children }) { /* ... */ };

// Usage
<Tabs>
  <Tabs.List>
    <Tabs.Tab index={0}>Tab 1</Tabs.Tab>
    <Tabs.Tab index={1}>Tab 2</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel index={0}>Content 1</Tabs.Panel>
  <Tabs.Panel index={1}>Content 2</Tabs.Panel>
</Tabs>
```

### State Colocation (pousser l'etat vers le bas)

```tsx
// MAUVAIS : etat dans le parent (re-render tout)
function Page() {
  const [search, setSearch] = useState('');
  return (
    <div>
      <SearchBar value={search} onChange={setSearch} />
      <ExpensiveList /> {/* Re-render inutile ! */}
      <Footer />       {/* Re-render inutile ! */}
    </div>
  );
}

// BON : etat dans le composant qui l'utilise
function Page() {
  return (
    <div>
      <SearchSection />     {/* Etat interne */}
      <ExpensiveList />     {/* Pas affecte */}
      <Footer />            {/* Pas affecte */}
    </div>
  );
}
```

### Children as Props (eviter les re-renders)

```tsx
// BON : children ne re-rendent pas quand le parent change
function ScrollTracker({ children }: { children: React.ReactNode }) {
  const [scrollY, setScrollY] = useState(0);
  useEffect(() => {
    const handler = () => setScrollY(window.scrollY);
    window.addEventListener('scroll', handler);
    return () => window.removeEventListener('scroll', handler);
  }, []);

  return (
    <div>
      <ScrollIndicator position={scrollY} />
      {children} {/* Ne re-rend PAS quand scrollY change */}
    </div>
  );
}
```

### Render Props vs Hooks

```tsx
// PREFERER les hooks aux render props
// MAUVAIS : render prop (verbose, nested)
<WindowSize render={({ width }) => (
  <div>{width > 768 ? <Desktop /> : <Mobile />}</div>
)} />

// BON : custom hook (simple, composable)
function ResponsiveLayout() {
  const { width } = useWindowSize();
  return width > 768 ? <Desktop /> : <Mobile />;
}
```

## Outils

```bash
# Analyser le bundle
npm run build -- --analyze

# Lighthouse
npx lighthouse https://example.com

# React DevTools Profiler
# Why did you render? (debug re-renders)
npm install @welldone-software/why-did-you-render
```
