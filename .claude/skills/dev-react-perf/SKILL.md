---
name: dev-react-perf
description: React/Next.js performance optimization. Trigger when the user wants to optimize rendering, reduce re-renders, or improve Core Web Vitals.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
background: false
---

# React Performance Optimization

## Avoid unnecessary re-renders

### useMemo - Memoize expensive computations

```tsx
const expensiveValue = useMemo(() => {
  return computeExpensiveValue(items);
}, [items]);
```

### useCallback - Memoize functions

```tsx
const handleClick = useCallback(() => {
  onSubmit(formData);
}, [formData, onSubmit]);
```

### React.memo - Memoize components

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

## Virtualization

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

| Metric | Target | Optimization |
|--------|--------|--------------|
| LCP | < 2.5s | Preload hero image, SSR |
| FID | < 100ms | Code splitting, defer JS |
| CLS | < 0.1 | Explicit dimensions |

## Composition Patterns

### Avoid excessive boolean props

```tsx
// BAD: boolean props explosion
<Button primary large rounded disabled loading />

// GOOD: composition with variants
<Button variant="primary" size="large" shape="rounded" state="loading" />

// BETTER: compound components
<Button.Primary size="large">
  <Button.Spinner /> Loading...
</Button.Primary>
```

### Compound Components

```tsx
// Compound component pattern
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

### State Colocation (push state down)

```tsx
// BAD: state in the parent (re-renders everything)
function Page() {
  const [search, setSearch] = useState('');
  return (
    <div>
      <SearchBar value={search} onChange={setSearch} />
      <ExpensiveList /> {/* Unnecessary re-render! */}
      <Footer />       {/* Unnecessary re-render! */}
    </div>
  );
}

// GOOD: state in the component that uses it
function Page() {
  return (
    <div>
      <SearchSection />     {/* Internal state */}
      <ExpensiveList />     {/* Not affected */}
      <Footer />            {/* Not affected */}
    </div>
  );
}
```

### Children as Props (avoid re-renders)

```tsx
// GOOD: children do not re-render when the parent changes
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
      {children} {/* Does NOT re-render when scrollY changes */}
    </div>
  );
}
```

### Render Props vs Hooks

```tsx
// PREFER hooks over render props
// BAD: render prop (verbose, nested)
<WindowSize render={({ width }) => (
  <div>{width > 768 ? <Desktop />: <Mobile />}</div>
)} />

// GOOD: custom hook (simple, composable)
function ResponsiveLayout() {
  const { width } = useWindowSize();
  return width > 768 ? <Desktop />: <Mobile />;
}
```

## Tools

```bash
# Analyze the bundle
npm run build -- --analyze

# Lighthouse
npx lighthouse https://example.com

# React DevTools Profiler
# Why did you render? (debug re-renders)
npm install @welldone-software/why-did-you-render
```
