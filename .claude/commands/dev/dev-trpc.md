# Agent DEV-TRPC

Creation d'APIs type-safe avec tRPC.

## Contexte
$ARGUMENTS

## Pourquoi tRPC

```
┌─────────────────────────────────────────────────────────────────┐
│                    tRPC vs REST vs GraphQL                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  REST         │  GraphQL      │  tRPC                          │
│  ────         │  ───────      │  ────                          │
│  Manual types │  Schema       │  Auto-inferred types           │
│  fetch/axios  │  Apollo/urql  │  Direct function calls         │
│  OpenAPI spec │  SDL          │  TypeScript = contract         │
│  Any client   │  Any client   │  TypeScript clients only       │
│                                                                 │
│  Best for:    │  Best for:    │  Best for:                     │
│  Public APIs  │  Complex data │  Full-stack TypeScript         │
│  Multi-lang   │  Mobile apps  │  Monorepos                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Setup

### Installation

```bash
# Server
npm install @trpc/server zod

# Client (React)
npm install @trpc/client @trpc/react-query @tanstack/react-query

# Next.js
npm install @trpc/next
```

### Structure

```
src/
├── server/
│   ├── trpc.ts          # Configuration tRPC
│   ├── context.ts       # Context creation
│   └── routers/
│       ├── index.ts     # App router
│       ├── user.ts      # User procedures
│       └── post.ts      # Post procedures
├── utils/
│   └── trpc.ts          # Client hooks
└── pages/api/trpc/
    └── [trpc].ts        # API handler (Next.js)
```

## Server Setup

### Configuration de base

```typescript
// server/trpc.ts
import { initTRPC, TRPCError } from '@trpc/server';
import superjson from 'superjson';
import { ZodError } from 'zod';
import type { Context } from './context';

const t = initTRPC.context<Context>().create({
  transformer: superjson,
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        zodError:
          error.cause instanceof ZodError ? error.cause.flatten() : null,
      },
    };
  },
});

export const router = t.router;
export const publicProcedure = t.procedure;
export const middleware = t.middleware;
```

### Context

```typescript
// server/context.ts
import { prisma } from '@/lib/prisma';
import { getSession } from 'next-auth/react';
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getSession({ req });

  return {
    prisma,
    session,
    user: session?.user,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

### Middleware d'authentification

```typescript
// server/trpc.ts (suite)
const isAuthed = middleware(({ ctx, next }) => {
  if (!ctx.session || !ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  return next({
    ctx: {
      session: ctx.session,
      user: ctx.user,
    },
  });
});

export const protectedProcedure = t.procedure.use(isAuthed);
```

## Routers

### User Router

```typescript
// server/routers/user.ts
import { z } from 'zod';
import { router, publicProcedure, protectedProcedure } from '../trpc';
import { TRPCError } from '@trpc/server';
import { hash } from 'bcrypt';

export const userRouter = router({
  // Query publique
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ ctx, input }) => {
      const user = await ctx.prisma.user.findUnique({
        where: { id: input.id },
        select: {
          id: true,
          name: true,
          email: true,
          createdAt: true,
        },
      });

      if (!user) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'User not found',
        });
      }

      return user;
    }),

  // Query protegee
  me: protectedProcedure.query(async ({ ctx }) => {
    return ctx.prisma.user.findUnique({
      where: { id: ctx.user.id },
      include: { profile: true },
    });
  }),

  // Mutation
  updateProfile: protectedProcedure
    .input(
      z.object({
        name: z.string().min(2).optional(),
        bio: z.string().max(500).optional(),
      })
    )
    .mutation(async ({ ctx, input }) => {
      return ctx.prisma.user.update({
        where: { id: ctx.user.id },
        data: {
          name: input.name,
          profile: {
            upsert: {
              create: { bio: input.bio },
              update: { bio: input.bio },
            },
          },
        },
      });
    }),

  // Liste avec pagination
  list: publicProcedure
    .input(
      z.object({
        limit: z.number().min(1).max(100).default(10),
        cursor: z.string().optional(),
      })
    )
    .query(async ({ ctx, input }) => {
      const { limit, cursor } = input;

      const users = await ctx.prisma.user.findMany({
        take: limit + 1,
        cursor: cursor ? { id: cursor } : undefined,
        orderBy: { createdAt: 'desc' },
      });

      let nextCursor: typeof cursor = undefined;
      if (users.length > limit) {
        const nextItem = users.pop();
        nextCursor = nextItem?.id;
      }

      return {
        users,
        nextCursor,
      };
    }),
});
```

### App Router

```typescript
// server/routers/index.ts
import { router } from '../trpc';
import { userRouter } from './user';
import { postRouter } from './post';

export const appRouter = router({
  user: userRouter,
  post: postRouter,
});

export type AppRouter = typeof appRouter;
```

### API Handler (Next.js)

```typescript
// pages/api/trpc/[trpc].ts
import { createNextApiHandler } from '@trpc/server/adapters/next';
import { appRouter } from '@/server/routers';
import { createContext } from '@/server/context';

export default createNextApiHandler({
  router: appRouter,
  createContext,
  onError:
    process.env.NODE_ENV === 'development'
      ? ({ path, error }) => {
          console.error(`tRPC error on ${path}:`, error);
        }
      : undefined,
});
```

## Client Setup

### Configuration client

```typescript
// utils/trpc.ts
import { httpBatchLink } from '@trpc/client';
import { createTRPCNext } from '@trpc/next';
import type { AppRouter } from '@/server/routers';
import superjson from 'superjson';

function getBaseUrl() {
  if (typeof window !== 'undefined') return '';
  if (process.env.VERCEL_URL) return `https://${process.env.VERCEL_URL}`;
  return `http://localhost:${process.env.PORT ?? 3000}`;
}

export const trpc = createTRPCNext<AppRouter>({
  config() {
    return {
      transformer: superjson,
      links: [
        httpBatchLink({
          url: `${getBaseUrl()}/api/trpc`,
        }),
      ],
    };
  },
  ssr: false,
});
```

### Provider

```typescript
// pages/_app.tsx
import { trpc } from '@/utils/trpc';
import type { AppProps } from 'next/app';

function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />;
}

export default trpc.withTRPC(App);
```

## Utilisation Client

### Queries

```typescript
// components/UserProfile.tsx
import { trpc } from '@/utils/trpc';

export function UserProfile({ userId }: { userId: string }) {
  // Query simple
  const { data: user, isLoading, error } = trpc.user.getById.useQuery(
    { id: userId },
    { enabled: !!userId }
  );

  // Query avec refetch
  const utils = trpc.useUtils();
  const handleRefresh = () => {
    utils.user.getById.invalidate({ id: userId });
  };

  if (isLoading) return <Spinner />;
  if (error) return <Error message={error.message} />;

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      <button onClick={handleRefresh}>Refresh</button>
    </div>
  );
}
```

### Mutations

```typescript
// components/UpdateProfileForm.tsx
import { trpc } from '@/utils/trpc';
import { useState } from 'react';

export function UpdateProfileForm() {
  const [name, setName] = useState('');
  const utils = trpc.useUtils();

  const updateProfile = trpc.user.updateProfile.useMutation({
    onSuccess: () => {
      utils.user.me.invalidate();
    },
    onError: (error) => {
      toast.error(error.message);
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    updateProfile.mutate({ name });
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={name}
        onChange={(e) => setName(e.target.value)}
        disabled={updateProfile.isLoading}
      />
      <button type="submit" disabled={updateProfile.isLoading}>
        {updateProfile.isLoading ? 'Saving...' : 'Save'}
      </button>
    </form>
  );
}
```

### Infinite Query

```typescript
// components/UserList.tsx
import { trpc } from '@/utils/trpc';

export function UserList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = trpc.user.list.useInfiniteQuery(
    { limit: 10 },
    {
      getNextPageParam: (lastPage) => lastPage.nextCursor,
    }
  );

  return (
    <div>
      {data?.pages.map((page) =>
        page.users.map((user) => (
          <UserCard key={user.id} user={user} />
        ))
      )}

      {hasNextPage && (
        <button
          onClick={() => fetchNextPage()}
          disabled={isFetchingNextPage}
        >
          {isFetchingNextPage ? 'Loading...' : 'Load More'}
        </button>
      )}
    </div>
  );
}
```

## Output attendu

### Architecture proposee

```markdown
## Architecture tRPC

### Routers
- `user` - Gestion utilisateurs
- `post` - Gestion posts
- `auth` - Authentification

### Procedures
| Router | Procedure | Type | Auth |
|--------|-----------|------|------|
| user | getById | query | public |
| user | me | query | protected |
| user | update | mutation | protected |

### Validation (Zod)
[Schemas de validation]
```

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev-prisma` | Base de donnees |
| `/dev-api` | Documentation API |
| `/qa-security` | Securite |

---

IMPORTANT: tRPC est ideal pour monorepos TypeScript full-stack.

IMPORTANT: Toujours valider les inputs avec Zod.

YOU MUST utiliser protectedProcedure pour les operations authentifiees.

NEVER exposer de donnees sensibles dans les queries publiques.
