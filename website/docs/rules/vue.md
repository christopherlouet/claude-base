---
sidebar_position: 30
title: "vue"
description: "const count = ref(0) const double = computed(() = count.value * 2) /script ```"
tags:
  - "rule"
  - "vue"
---

# Regles: vue

> const count = ref(0) const double = computed(() =&gt; count.value * 2) &lt;/script&gt; ```

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

- `**/*.vue`
- `**/composables/**`
- `**/stores/**`
- `**/nuxt.config.*`

## Regles detaillees

# Vue 3 / Nuxt Rules

## Composition API (obligatoire)

- `&lt;script setup&gt;` par defaut (plus concis, meilleure inference TS)
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

- Toujours typer les props : `defineProps&lt;\{ title: string; count?: number \}&gt;()`
- Emits avec validation : `defineEmits&lt;\{ (e: 'update', value: number): void \}&gt;()`
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
| Options API (`data()`, `methods`) | Composition API (`&lt;script setup&gt;`) |
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
- `&lt;Suspense&gt;` pour async components avec fallback

## Regles

IMPORTANT: Utiliser `&lt;script setup&gt;` systematiquement (pas Options API).
IMPORTANT: Nommage PascalCase pour composants, kebab-case dans templates.
YOU MUST typer toutes les props via `defineProps&lt;&gt;()`.
NEVER muter une prop directement (v-model + emit).
NEVER utiliser Vuex sur un nouveau projet (Pinia).

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
