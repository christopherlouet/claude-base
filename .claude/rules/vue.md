---
paths:
  - "**/*.vue"
  - "**/composables/**"
  - "**/stores/**"
  - "**/nuxt.config.*"
---

# Vue 3 / Nuxt Rules

## Composition API (obligatoire)

- `<script setup>` par defaut (plus concis, meilleure inference TS)
- `ref()` pour primitives, `reactive()` pour objets complexes (un seul par composable)
- `computed()` pour valeurs derivees (pas de `watch` + `ref`)
- `watch()` / `watchEffect()` pour side effects

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'

const count = ref(0)
const double = computed(() => count.value * 2)
</script>
```

## Composables

- Prefixe `use` obligatoire : `useAuth`, `useCart`
- Un composable par fichier, dans `composables/`
- Retourner des objets pour destructuring nommé

```ts
// composables/useCounter.ts
export function useCounter(initial = 0) {
  const count = ref(initial)
  const increment = () => count.value++
  return { count, increment }
}
```

## Props et emits

- Toujours typer les props : `defineProps<{ title: string; count?: number }>()`
- Emits avec validation : `defineEmits<{ (e: 'update', value: number): void }>()`
- `withDefaults()` pour defaults sur props typees
- NE PAS muter les props (utiliser v-model ou emit)

## Nuxt 3+

| Feature | Usage |
|---------|-------|
| `useFetch()` | Data fetching SSR-friendly, dedup auto |
| `useAsyncData()` | Fetch custom avec key |
| `useState()` | Global reactive state (remplace Vuex pour cas simples) |
| `navigateTo()` | Redirection programmatique (jamais `router.push` direct en SSR) |
| `defineNuxtRouteMiddleware()` | Middleware route-level |
| `server/api/*.ts` | API routes (Nitro) |

## Anti-patterns

| A eviter | Preferer |
|----------|----------|
| Options API (`data()`, `methods`) | Composition API (`<script setup>`) |
| `ref()` pour tout | `ref` pour primitives, `reactive` pour objets stables |
| Vuex | Pinia (officiel pour Vue 3) |
| `watch()` pour derivations | `computed()` |
| Props mutees | v-model + emit |
| Globals mutables | `useState()` (Nuxt) ou stores Pinia |

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

- `v-memo` pour memoiser des sous-arbres
- `defineAsyncComponent()` pour code splitting de composants
- `shallowRef()` / `shallowReactive()` pour grandes structures immutables
- `<Suspense>` pour async components avec fallback

## Regles

IMPORTANT: Utiliser `<script setup>` systematiquement (pas Options API).
IMPORTANT: Nommage PascalCase pour composants, kebab-case dans templates.
YOU MUST typer toutes les props via `defineProps<>()`.
NEVER muter une prop directement (v-model + emit).
NEVER utiliser Vuex sur un nouveau projet (Pinia).
