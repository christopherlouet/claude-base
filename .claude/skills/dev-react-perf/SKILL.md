---
name: dev-react-perf
description: React/Next.js performance optimization. Points to Vercel's react-best-practices (70 rules by impact - waterfalls, bundle, re-renders) and adds what it leaves out - list virtualization, state colocation, profiling tools, Core Web Vitals targets. Trigger when the user wants to optimize rendering, reduce re-renders, or improve Core Web Vitals.
---

# React Performance (pointer + gaps)

**If the `vercel-react-best-practices` skill is installed, invoke it now** (Skill tool) and apply its rules first. Either way, check the top of its ranking before anything else:

1. **Request waterfalls (CRITICAL)** — independent requests awaited one after another: start them together (`Promise.all`), await late, stream with Suspense.
2. **Bundle size (CRITICAL)** — whole-library or barrel imports (`import { x } from 'lodash'`): import the path; load rarely used heavy UI (modals, charts, editors) with `lazy()` / `next/dynamic`.
3. **Derived state** — never copy props into state through `useEffect` + `setState`: compute during render, `useMemo` if expensive.
4. **Memo that cannot work** — a `memo` child receiving inline arrows or inline objects re-renders anyway: pass stable callbacks and hoisted constants.
5. **Context values** — a provider `value={{ ... }}` built on every render re-renders every consumer: memoize it or split the context.

(Condensed from Vercel's ranking, MIT; the vendor skill holds the reasoning and the other 65 rules.)

Vercel Engineering publishes the canonical rule set at [`vercel-labs/agent-skills/skills/react-best-practices`](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices) (MIT): 70 rules in 8 categories ranked by impact, starting with the two CRITICAL ones — eliminating request waterfalls and bundle size — then server/client data fetching, re-renders, rendering and JS micro-optimizations. Its companion [`composition-patterns`](https://github.com/vercel-labs/agent-skills/tree/main/skills/composition-patterns) covers compound components and boolean-prop explosion.

Why a pointer: the vendor maintains its rules with each React and Next.js release, while this skill's former 211-line version had gone stale (it still cited FID, retired in 2024, and a react-window API removed in v2). A blind outcome comparison on 2026-10-03 (12 planted defects) found no measurable difference between the two skills: 11/12 for both, and for no skill at all, on Opus 5.5; on Haiku 4.5 the run-to-run spread (5 to 9 out of 12) was larger than any gap between arms.

## Delegate to the vendor skill

```bash
git clone --depth 1 https://github.com/vercel-labs/agent-skills ~/dev/vendor-skills/vercel
ln -s ~/dev/vendor-skills/vercel/skills/react-best-practices ./.claude/skills/react-best-practices
ln -s ~/dev/vendor-skills/vercel/skills/composition-patterns ./.claude/skills/composition-patterns
```

Recipe entry: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Vercel — `vercel-labs/agent-skills`".

## What the vendor skill leaves out

Virtualization, state colocation and the profiling tools below appear in none of its 72 files. In the 2026-10-03 run on Opus, every arm — vendor skill included — left the 5,000-row table fully mounted.

### Long lists: virtualize

Mounting thousands of rows costs more than any memoization saves. Render only the visible window:

```tsx
import { useRef } from 'react';
import { useVirtualizer } from '@tanstack/react-virtual';

export function VirtualList({ items }: { items: { id: number; name: string }[] }) {
  const parentRef = useRef<HTMLDivElement>(null);
  const rows = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 48,
  });
  return (
    <div ref={parentRef} style={{ height: 400, overflow: 'auto' }}>
      <div style={{ height: rows.getTotalSize(), position: 'relative' }}>
        {rows.getVirtualItems().map((row) => (
          <div
            key={items[row.index].id}
            style={{ position: 'absolute', top: 0, width: '100%', height: row.size, transform: `translateY(${row.start}px)` }}
          >
            {items[row.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

Rows need a stable key (an id, never the index) and a known or estimated height. Under a few hundred rows, pagination or `content-visibility: auto` is often enough.

## State colocation (push state down)

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

Typical case: a clock, a timer or a search input whose state sits at the app root re-renders the whole tree on every tick or keystroke. Move that state into the small component that displays it.

## Core Web Vitals targets

| Metric | Good | Needs work | Poor |
|--------|------|------------|------|
| LCP | < 2.5s | 2.5–4s | > 4s |
| INP | < 200ms | 200–500ms | > 500ms |
| CLS | < 0.1 | 0.1–0.25 | > 0.25 |

Measure before and after a change; the `qa-perf` skill holds the measurement workflow.

## Profiling tools

```bash
npx lighthouse https://example.com --view     # lab LCP / INP proxy (TBT) / CLS
npm run build -- --analyze                     # bundle composition (Next.js: @next/bundle-analyzer)
```

- **React DevTools Profiler** — which components rendered, why, and for how long.
- **`why-did-you-render`** (`@welldone-software/why-did-you-render`) — logs avoidable re-renders in development.
