---
paths:
  - "**/*.svelte"
  - "**/*.svelte.ts"
  - "**/*.svelte.js"
  - "**/svelte.config.*"
---

# Svelte 5 / SvelteKit Rules

## Runes (Svelte 5)

Svelte 5+ uses **runes**: `$state`, `$derived`, `$effect`, `$props`. Do not use the `$:` reactive syntax or implicit reactive `let` anymore.

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

## Props and events

- `$props()` with typed destructuring
- Events via **callback props** (not `createEventDispatcher`)

```svelte
<script lang="ts">
  let { onSubmit }: { onSubmit: (data: FormData) => void } = $props()
</script>

<button onclick={() => onSubmit(data)}>Submit</button>
```

## Stores (Svelte 5)

Use **rune classes** rather than `writable()` when possible:

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

For compatibility: `writable()` / `readable()` remain valid but prefer runes.

## SvelteKit

| Feature | Usage |
|---------|-------|
| `+page.svelte` | Page component |
| `+page.server.ts` | Server-only load function (DB, secrets) |
| `+page.ts` | Universal load function (client + server) |
| `+layout.svelte` | Parent layout |
| `+server.ts` | API route / endpoint |
| `hooks.server.ts` | Server middleware (auth, CORS) |
| `form actions` | Progressive enhancement mutations |

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

| Avoid | Prefer |
|----------|----------|
| `let count = 0` reactive (Svelte 5) | `let count = $state(0)` |
| `$: double = count * 2` (Svelte 5) | `$derived()` |
| `createEventDispatcher` | Callback props |
| `<slot />` (Svelte 5) | `{@render children?.()}` |
| Sensitive data in `+page.ts` | Use `+page.server.ts` |
| `fetch` directly in the component | `load` function with SvelteKit's fetch |

## Performance

- SSR by default in SvelteKit
- `export const prerender = true` for static pages
- `export const ssr = false` for CSR-only (private dashboards)
- AOT compilation → tiny bundles, no virtual DOM

## Rules

IMPORTANT: Svelte 5: use runes ($state, $derived, $effect, $props).
IMPORTANT: Sensitive data (secrets, DB queries): only in `+page.server.ts`.
YOU MUST type props via `$props()` with TypeScript.
NEVER use `createEventDispatcher` (legacy, use callback props).
NEVER expose `DATABASE_URL` or secrets in `+page.ts` (universal = client leak).
