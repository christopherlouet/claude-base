---
sidebar_position: 31
title: "vue"
description: "const count = ref(0) const double = computed(() = count.value * 2) /script ```"
tags:
  - "rule"
  - "vue"
---

# Rules: vue

> const count = ref(0) const double = computed(() => count.value * 2) &lt;/script> ```

## Affected files

These rules apply to files matching the following patterns:

- `**/*.vue`
- `**/composables/**`
- `**/stores/**`
- `**/nuxt.config.*`

## Detailed rules

# Vue 3 / Nuxt Rules

## Composition API (mandatory)

- `<script setup>` by default (more concise, better TS inference)
- `ref()` for primitives, `reactive()` for complex objects (only one per composable)
- `computed()` for derived values (no `watch` + `ref`)
- `watch()` / `watchEffect()` for side effects

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

const count = ref(0)
const double = computed(() => count.value * 2)
</script>
```

## Composables

- `use` prefix mandatory: `useAuth`, `useCart`
- One composable per file, in `composables/`
- Return objects for named destructuring

```ts
// composables/useCounter.ts
export function useCounter(initial = 0) {
  const count = ref(initial)
  const increment = () => count.value++
  return { count, increment }
}
```

## Props and emits

- Always type props: `defineProps<{ title: string; count?: number }>()`
- Emits with validation: `defineEmits<{ (e: 'update', value: number): void }>()`
- `withDefaults()` for defaults on typed props
- DO NOT mutate props (use v-model or emit)

## Nuxt 3+

| Feature | Usage |
|---------|-------|
| `useFetch()` | SSR-friendly data fetching, auto dedup |
| `useAsyncData()` | Custom fetch with key |
| `useState()` | Global reactive state (replaces Vuex for simple cases) |
| `navigateTo()` | Programmatic redirect (never `router.push` directly in SSR) |
| `defineNuxtRouteMiddleware()` | Route-level middleware |
| `server/api/*.ts` | API routes (Nitro) |

## Anti-patterns

| Avoid | Prefer |
|----------|----------|
| Options API (`data()`, `methods`) | Composition API (`<script setup>`) |
| `ref()` for everything | `ref` for primitives, `reactive` for stable objects |
| Vuex | Pinia (official for Vue 3) |
| `watch()` for derivations | `computed()` |
| Mutated props | v-model + emit |
| Mutable globals | `useState()` (Nuxt) or Pinia stores |

## Pinia (state management)

```ts
// stores/counter.ts
import { defineStore } from 'pinia'

export const useCounterStore = defineStore('counter', () => {
  const count = ref(0)
  const double = computed(() => count.value * 2)
  function increment() { count.value++ }
  return { count, double, increment }
})
```

## Performance

- `v-memo` to memoize subtrees
- `defineAsyncComponent()` for component code splitting
- `shallowRef()` / `shallowReactive()` for large immutable structures
- `<Suspense>` for async components with fallback

## Rules

IMPORTANT: Use `<script setup>` systematically (not Options API).
IMPORTANT: PascalCase naming for components, kebab-case in templates.
YOU MUST type all props via `defineProps<>()`.
NEVER mutate a prop directly (v-model + emit).
NEVER use Vuex on a new project (Pinia).

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)
