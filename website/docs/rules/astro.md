---
sidebar_position: 4
title: "astro"
description: "Astro rend **zero JS par défaut**. Les composants sont HTML statique sauf si explicitement \"hydratés\" via les `client:*` directives. Utiliser Astro po"
tags:
  - "rule"
  - "astro"
---

# Regles: astro

> Astro rend **zero JS par défaut**. Les composants sont HTML statique sauf si explicitement "hydratés" via les `client:*` directives. Utiliser Astro pour sites à fort contenu (blogs, docs, marketing) e

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

- `**/*.astro`
- `**/astro.config.*`
- `**/content/**/*.md`
- `**/content/**/*.mdx`

## Regles detaillees

# Astro Rules

## Philosophie : Islands Architecture

Astro rend **zero JS par défaut**. Les composants sont HTML statique sauf si explicitement "hydratés" via les `client:*` directives. Utiliser Astro pour sites à fort contenu (blogs, docs, marketing) et pas pour dashboards interactifs full-SPA.

## Composants `.astro`

```astro
---
// Frontmatter : TypeScript, s'execute au build
import Layout from '../layouts/Layout.astro'
import Card from '../components/Card.astro'

interface Props {
  title: string
}
const { title } = Astro.props
const posts = await getPosts()  // Fetch au build, pas au runtime
---

<Layout>
  <h1>{title}</h1>
  {posts.map(post => <Card {...post} />)}
</Layout>

<style>
  h1 { color: var(--accent); }  /* Scoped automatiquement */
</style>
```

## Client directives (hydration)

| Directive | Usage |
|-----------|-------|
| `client:load` | Hydratation immédiate (éviter sauf cas critique) |
| `client:idle` | Hydratation quand le browser est idle |
| `client:visible` | Hydratation quand le composant entre dans le viewport (défaut recommandé) |
| `client:media="(max-width: 768px)"` | Hydratation selon media query |
| `client:only="react"` | Rendu 100% client (pas de SSR, fallback loading) |

```astro
---
import Counter from '../components/Counter.tsx'
---

<!-- HTML statique -->
<Counter client:visible />
```

**Règle** : `client:visible` par défaut. `client:load` uniquement si above-the-fold et interactif immédiatement nécessaire.

## Intégrations framework

Astro supporte React, Vue, Svelte, Solid, Preact en même temps :

```js
// astro.config.mjs
import { defineConfig } from 'astro/config'
import react from '@astrojs/react'
import svelte from '@astrojs/svelte'

export default defineConfig({
  integrations: [react(), svelte()],
})
```

Utiliser les composants framework pour les **islands** interactifs uniquement. Pour le contenu statique, **préférer les composants `.astro`** (plus légers).

## Content Collections

```ts
// src/content/config.ts
import { defineCollection, z } from 'astro:content'

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.date(),
    draft: z.boolean().default(false),
    tags: z.array(z.string()),
  }),
})

export const collections = { blog }
```

```astro
---
import { getCollection } from 'astro:content'

const posts = await getCollection('blog', ({ data }) => !data.draft)
---
```

Type-safe, validation Zod au build, fichiers dans `src/content/blog/*.md`.

## Rendering modes

| Mode | Config | Usage |
|------|--------|-------|
| **Static** | défaut | Blogs, docs, marketing (prerendered) |
| **Hybrid** | `output: 'hybrid'` | Static par défaut, `export const prerender = false` par page pour opt-out |
| **Server** | `output: 'server'` | SSR par défaut, `export const prerender = true` par page pour opt-in |

Choisir **hybrid** pour la plupart des cas : le mieux des deux mondes.

## View Transitions (Astro 3+)

```astro
---
import { ViewTransitions } from 'astro:transitions'
---

<html>
  <head>
    <ViewTransitions />
  </head>
</html>
```

Active les animations de transition entre pages, effet SPA sans framework.

## Anti-patterns

| A eviter | Preferer |
|----------|----------|
| Composant React partout | `.astro` pour static, framework pour islands |
| `client:load` par défaut | `client:visible` |
| Fetch dans le composant `.astro` au runtime | `getStaticPaths()` ou Content Collections au build |
| `document.querySelector` dans `&lt;script&gt;` sans event listener | Scripts bien délimités avec `is:inline` si besoin |
| Astro pour dashboard full-SPA | Next.js / SvelteKit plus adaptés |

## Performance

- Zero JS par défaut → Lighthouse 100 typique
- Image optimization native : `&lt;Image src=\{img\} alt="" /&gt;` depuis `astro:assets`
- CSS scoped au composant (pas de collision)
- Prefetch automatique des liens internes (opt-in config)

## Regles

IMPORTANT: Astro = sites à contenu (blog, docs, marketing), PAS dashboards SPA.
IMPORTANT: `client:visible` par défaut pour les islands (pas `client:load`).
YOU MUST utiliser Content Collections pour le contenu structuré (validation Zod type-safe).
YOU MUST préférer les composants `.astro` aux composants framework quand pas d'interactivité.
NEVER mettre `client:load` partout — annule le bénéfice zero-JS d'Astro.

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
