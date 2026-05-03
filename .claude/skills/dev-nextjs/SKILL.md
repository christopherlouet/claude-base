---
name: dev-nextjs
description: Next.js development (App Router, Server Components, caching, streaming). Trigger when the user works with Next.js, modifies app/, pages/, next.config, or talks about RSC, Server Actions, Route Handlers, middleware.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

# Next.js App Router

## App Router vs Pages Router

**App Router** (default since Next 13, stable): `app/` folder, Server Components by default, Server Actions, streaming. **Prefer** for any new project.

**Pages Router**: `pages/` folder, getServerSideProps/getStaticProps. **Legacy**, do not add new routes there.

If the project has both, coexist — both can live together, but do not duplicate a route.

## Server Components by default

Any component in `app/` is a **Server Component** by default. It runs on the server, zero client JS.

```tsx
// app/posts/page.tsx — Server Component (default)
export default async function PostsPage() {
  const posts = await db.posts.findMany();  // Direct SQL OK
  return <PostList posts={posts} />;
}
```

### Switch to Client Component with `"use client"`

```tsx
// app/components/SearchBox.tsx
"use client";  // Directive at the top of the file

import { useState } from "react";

export function SearchBox() {
  const [query, setQuery] = useState("");
  return <input value={query} onChange={(e) => setQuery(e.target.value)} />;
}
```

**Rule**: "use client" only if you need hooks (useState, useEffect) or browser events (onClick, onChange). Otherwise, stay Server Component.

### Server/Client composition

Server Components can import Client Components, but **the reverse is not allowed** (except via `children` props).

```tsx
// OK: Server Component uses a Client Component
export default async function Page() {
  const data = await fetch(...);
  return <ClientChart data={data} />;  // ClientChart is "use client"
}

// OK: Client Component receives a Server Component via children
"use client";
export function Layout({ children }: { children: React.ReactNode }) {
  return <div>{children}</div>;  // children can be a RSC
}
```

## Data Fetching

### Native fetch() with Next.js cache

```tsx
// Forced cache (SSG-like, manual revalidation)
const data = await fetch(url, { cache: "force-cache" });

// No cache (SSR on every request)
const data = await fetch(url, { cache: "no-store" });

// Time-based revalidation (ISR)
const data = await fetch(url, { next: { revalidate: 60 } });

// Tag-based revalidation
const data = await fetch(url, { next: { tags: ["posts"] } });
// Then in a Server Action: revalidateTag("posts")
```

IMPORTANT (Next 15+): `fetch` is no longer cached by default. You must explicitly set `force-cache` or `next: { revalidate }`.

### Parallel data fetching

```tsx
// BAD — waterfall
const user = await getUser();
const posts = await getPosts();

// GOOD — parallel
const [user, posts] = await Promise.all([getUser(), getPosts()]);
```

## Server Actions

Functions executed on the server, invoked from the client without a manual API route.

```tsx
// app/actions.ts
"use server";

export async function createPost(formData: FormData) {
  const title = formData.get("title") as string;
  await db.posts.create({ data: { title } });
  revalidatePath("/posts");
}

// app/posts/new/page.tsx
import { createPost } from "../actions";

export default function NewPost() {
  return (
    <form action={createPost}>
      <input name="title" />
      <button type="submit">Create</button>
    </form>
  );
}
```

**Pitfalls**:
- Always validate inputs with Zod (Server Actions receive unvalidated data)
- Always `revalidatePath` or `revalidateTag` after a mutation
- Do NOT expose business logic without auth (check the session inside the action)

## Route Handlers (API)

`app/api/*/route.ts` replaces `pages/api/`.

```tsx
// app/api/posts/route.ts
import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const posts = await db.posts.findMany();
  return NextResponse.json(posts);
}

export async function POST(request: Request) {
  const body = await request.json();
  const post = await db.posts.create({ data: body });
  return NextResponse.json(post, { status: 201 });
}
```

## Streaming and Suspense

Show the page shell immediately, stream the slow content:

```tsx
import { Suspense } from "react";

export default function Page() {
  return (
    <div>
      <Header />  {/* Render immediately */}
      <Suspense fallback={<PostsSkeleton />}>
        <SlowPosts />  {/* Stream when ready */}
      </Suspense>
    </div>
  );
}
```

### loading.tsx

```tsx
// app/posts/loading.tsx — Automatic loading UI
export default function Loading() {
  return <PostsSkeleton />;
}
```

## Middleware

```tsx
// middleware.ts (at the root)
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  const token = request.cookies.get("token");
  if (!token && request.nextUrl.pathname.startsWith("/dashboard")) {
    return NextResponse.redirect(new URL("/login", request.url));
  }
}

export const config = {
  matcher: ["/dashboard/:path*", "/api/protected/:path*"],
};
```

**Pitfall**: middleware runs on the Edge Runtime. No Node APIs (fs, crypto.createHash...) without a polyfill.

## Metadata API

Replaces manual `<head>`.

```tsx
// Static metadata
export const metadata: Metadata = {
  title: "My App",
  description: "...",
};

// Dynamic metadata (async)
export async function generateMetadata({ params }): Promise<Metadata> {
  const post = await getPost(params.id);
  return { title: post.title };
}
```

## Images and Fonts

```tsx
import Image from "next/image";
import { Geist } from "next/font/google";

const geist = Geist({ subsets: ["latin"] });

<Image src="/hero.jpg" alt="" width={1200} height={600} priority />
```

Next loads and hosts fonts locally (no Google request), avoiding FOIT/FOUT.

## Configuration

```ts
// next.config.ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  experimental: {
    reactCompiler: true,       // Auto-memoization optimization
    ppr: "incremental",        // Partial Prerendering
    dynamicIO: true,           // Next 15+ granular cache
  },
  images: {
    remotePatterns: [{ protocol: "https", hostname: "cdn.example.com" }],
  },
};

export default nextConfig;
```

## Vercel deployment

- `vercel` — preview deploy
- `vercel --prod` — production deploy
- Build settings auto-detected (npm, pnpm, bun)
- Env variables in the dashboard

Alternative: self-host with `next build && next start` (Node 18+).

## Common pitfalls

| Problem | Solution |
|---------|----------|
| "use client" everywhere | Only add it to components that use hooks/events |
| Unwanted data refetch | Check `cache` and `next.revalidate` on the fetch |
| Build errors ERR_DYNAMIC | Mark the page `export const dynamic = "force-dynamic"` or fix dynamic calls |
| Slow middleware | Reduce the matcher, avoid fetches inside middleware |
| Hydration mismatch | No random/Date.now() in SSR without suppressHydrationWarning |

## Verification

```bash
npm run build              # Verify the build + bundle size
npm run build -- --debug   # Detailed log
npx @next/bundle-analyzer  # Visualize the chunks
```

## Complements with the foundation

- Rule `.claude/rules/nextjs.md`: path-specific rules (auto-activation on `app/**`)
- Rule `.claude/rules/performance.md`: Core Web Vitals
- Skill `dev-react-perf`: memoization, React lazy loading
- Skill `qa-chrome`: visual audit of Next pages

## Expected output

1. **App Router** by default (not Pages Router unless partial migration)
2. **Server Components** by default, "use client" only if necessary
3. **Explicit caching** on every fetch (force-cache, no-store, or revalidate)
4. **Zod validation** on Server Actions and Route Handlers
5. **Metadata API** for SEO (never manual `<head>` in App Router)

## Rules

IMPORTANT: "use client" is the exception, not the rule. By default, everything is a Server Component.

IMPORTANT: Next 15+: fetch is no longer cached by default. Always specify the cache behavior.

IMPORTANT: Validate Server Action inputs with Zod before mutation.

YOU MUST use `revalidatePath` or `revalidateTag` after every mutation to invalidate the cache.

NEVER fetch inside middleware (Edge, slow).

NEVER expose business logic in a Route Handler without checking auth.
