---
sidebar_position: 4
title: "astro"
description: "Astro renders **zero JS by default**. Components are static HTML unless explicitly \"hydrated\" via `client:*` directives. Use Astro for content-heavy s"
tags:
  - "rule"
  - "astro"
---

# Rules: astro

> Astro renders **zero JS by default**. Components are static HTML unless explicitly "hydrated" via `client:*` directives. Use Astro for content-heavy sites (blogs, docs, marketing) and not for interact

## Affected files

These rules apply to files matching the following patterns:

- `**/*.astro`
- `**/astro.config.*`
- `**/content/**/*.md`
- `**/content/**/*.mdx`

## Detailed rules

# Astro Rules

## Philosophy: Islands Architecture

Astro renders **zero JS by default**. Components are static HTML unless explicitly "hydrated" via `client:*` directives. Use Astro for content-heavy sites (blogs, docs, marketing) and not for interactive full-SPA dashboards.

## `.astro` components

```astro
---
// Frontmatter: TypeScript, runs at build time
import Layout from '../layouts/Layout.astro'
import Card from '../components/Card.astro'

interface Props {
  title: string
}
const { title } = Astro.props
const posts = await getPosts()  // Fetched at build, not at runtime
---

<Layout>
  <h1>{title}</h1>
  {posts.map(post => <Card {...post} />)}
</Layout>

<style>
  h1 { color: var(--accent); }  /* Automatically scoped */
</style>
```

## Client directives (hydration)

| Directive | Usage |
|-----------|-------|
| `client:load` | Immediate hydration (avoid except for critical cases) |
| `client:idle` | Hydration when the browser is idle |
| `client:visible` | Hydration when the component enters the viewport (recommended default) |
| `client:media="(max-width: 768px)"` | Hydration based on media query |
| `client:only="react"` | 100% client rendering (no SSR, loading fallback) |

```astro
---
import Counter from '../components/Counter.tsx'
---

<!-- Static HTML -->
<Counter client:visible />
```

**Rule**: `client:visible` by default. `client:load` only if above-the-fold and immediate interactivity is required.

## Framework integrations

Astro supports React, Vue, Svelte, Solid, Preact at the same time:

```js
// astro.config.mjs
import { defineConfig } from 'astro/config'
import react from '@astrojs/react'
import svelte from '@astrojs/svelte'

export default defineConfig({
  integrations: [react(), svelte()],
})
```

Use framework components for interactive **islands** only. For static content, **prefer `.astro` components** (lighter).

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

Type-safe, Zod validation at build time, files in `src/content/blog/*.md`.

## Rendering modes

| Mode | Config | Usage |
|------|--------|-------|
| **Static** | default | Blogs, docs, marketing (prerendered) |
| **Hybrid** | `output: 'hybrid'` | Static by default, `export const prerender = false` per page to opt out |
| **Server** | `output: 'server'` | SSR by default, `export const prerender = true` per page to opt in |

Choose **hybrid** for most cases: the best of both worlds.

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

Enables transition animations between pages, SPA feel without a framework.

## Anti-patterns

| Avoid | Prefer |
|-------|--------|
| React component everywhere | `.astro` for static, framework for islands |
| `client:load` by default | `client:visible` |
| Fetch inside the `.astro` component at runtime | `getStaticPaths()` or Content Collections at build time |
| `document.querySelector` inside `&lt;script&gt;` without event listener | Properly scoped scripts with `is:inline` if needed |
| Astro for full-SPA dashboard | Next.js / SvelteKit are better suited |

## Performance

- Zero JS by default → typical Lighthouse 100
- Native image optimization: `&lt;Image src=\{img\} alt="" /&gt;` from `astro:assets`
- CSS scoped to the component (no collisions)
- Automatic prefetching of internal links (opt-in config)

## Rules

IMPORTANT: Astro = content sites (blog, docs, marketing), NOT SPA dashboards.
IMPORTANT: `client:visible` by default for islands (not `client:load`).
YOU MUST use Content Collections for structured content (type-safe Zod validation).
YOU MUST prefer `.astro` components over framework components when there is no interactivity.
NEVER use `client:load` everywhere — it cancels Astro's zero-JS benefit.

## Automatic application

These rules are automatically applied by Claude during:
- Reading the matching files
- Modifying code
- Suggestions and fixes

---

## See also

- [Back to rules](/docs/rules)
- [Architecture](/docs/intro/architecture)
