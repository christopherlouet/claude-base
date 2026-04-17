---
paths:
  - "**/*.svelte"
  - "**/*.svelte.ts"
  - "**/*.svelte.js"
  - "**/svelte.config.*"
---

# Svelte 5 / SvelteKit Rules

## Runes (Svelte 5)

Svelte 5+ utilise les **runes** : `$state`, `$derived`, `$effect`, `$props`. Ne plus utiliser la syntaxe reactive `$:` ni `let` reactif implicite.

```svelte
<script lang="ts">
  let count = $state(0)
  let double = $derived(count * 2)

  $effect(() => {
    console.log('count changed:', count)
  })

  let { title, onIncrement }: { title: string; onIncrement?: () => void } = $props()
</script>
```

### Migration Svelte 4 → 5

| Svelte 4 | Svelte 5 |
|----------|----------|
| `let count = 0` (reactive) | `let count = $state(0)` |
| `$: double = count * 2` | `let double = $derived(count * 2)` |
| `export let title` | `let { title } = $props()` |
| `$: { console.log(count) }` | `$effect(() => { console.log(count) })` |
| `<slot />` | `{@render children?.()}` |

## Props et events

- `$props()` avec destructuring typé
- Events via **callbacks props** (pas `createEventDispatcher`)

```svelte
<script lang="ts">
  let { onSubmit }: { onSubmit: (data: FormData) => void } = $props()
</script>

<button onclick={() => onSubmit(data)}>Submit</button>
```

## Stores (Svelte 5)

Utiliser les **runes classes** plutôt que `writable()` quand possible :

```ts
// lib/cart.svelte.ts
class Cart {
  items = $state<CartItem[]>([])
  total = $derived(this.items.reduce((sum, i) => sum + i.price, 0))

  add(item: CartItem) {
    this.items.push(item)
  }
}

export const cart = new Cart()
```

Pour compatibilité : `writable()` / `readable()` restent valides mais préférer les runes.

## SvelteKit

| Feature | Usage |
|---------|-------|
| `+page.svelte` | Composant de page |
| `+page.server.ts` | Load function server-only (DB, secrets) |
| `+page.ts` | Load function universelle (client + server) |
| `+layout.svelte` | Layout parent |
| `+server.ts` | API route / endpoint |
| `hooks.server.ts` | Middleware serveur (auth, CORS) |
| `form actions` | Mutations progressive enhancement |

### Load functions

```ts
// +page.server.ts
export async function load({ params, cookies }) {
  const user = await getUserFromSession(cookies.get('session'))
  return { user }
}
```

### Form actions

```ts
// +page.server.ts
export const actions = {
  default: async ({ request }) => {
    const data = await request.formData()
    const title = data.get('title')
    await db.posts.create({ title })
    return { success: true }
  },
}
```

```svelte
<!-- +page.svelte -->
<form method="POST" use:enhance>
  <input name="title" />
  <button>Create</button>
</form>
```

## Anti-patterns

| A eviter | Preferer |
|----------|----------|
| `let count = 0` reactif (Svelte 5) | `let count = $state(0)` |
| `$: double = count * 2` (Svelte 5) | `$derived()` |
| `createEventDispatcher` | Callback props |
| `<slot />` (Svelte 5) | `{@render children?.()}` |
| Données sensibles dans `+page.ts` | Utiliser `+page.server.ts` |
| `fetch` direct dans le composant | `load` function avec SvelteKit's fetch |

## Performance

- SSR par défaut dans SvelteKit
- `export const prerender = true` pour pages statiques
- `export const ssr = false` pour CSR-only (dashboards privés)
- Compilation AOT → bundles minuscules, pas de virtual DOM

## Regles

IMPORTANT: Svelte 5 : utiliser les runes ($state, $derived, $effect, $props).
IMPORTANT: Données sensibles (secrets, DB queries) : uniquement dans `+page.server.ts`.
YOU MUST typer les props via `$props()` avec TypeScript.
NEVER utiliser `createEventDispatcher` (legacy, utiliser callback props).
NEVER exposer `DATABASE_URL` ou secrets dans `+page.ts` (universel = leak client).
