---
sidebar_position: 3
title: tRPC Procedure
description: Example of a type-safe tRPC procedure with validation
---

# Type-Safe tRPC Procedure

This example shows how to create professional tRPC procedures with Zod validation and end-to-end type inference.

## Command used

```bash
/dev:dev-trpc "Create a router for tasks with CRUD and filters"
```

## Generated structure

```
src/
├── server/
│   ├── trpc.ts           # tRPC configuration
│   ├── context.ts        # Request context
│   └── routers/
│       ├── index.ts      # Main router
│       ├── task.ts       # Tasks router
│       └── user.ts       # Users router
├── utils/
│   └── trpc.ts           # tRPC client (React)
└── pages/api/
    └── trpc/
        └── [trpc].ts     # Next.js handler
```

## Router Code

### `server/trpc.ts`

```typescript
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
          error.cause instanceof ZodError ? error.cause.flatten(): null,
      },
    };
  },
});

// Logging middleware
const loggerMiddleware = t.middleware(async ({ path, type, next }) => {
  const start = Date.now();
  const result = await next();
  const duration = Date.now() - start;

  console.log(`[${type}] ${path} - ${duration}ms`);

  return result;
});

// Authentication middleware
const isAuthed = t.middleware(async ({ ctx, next }) => {
  if (!ctx.session?.user) {
    throw new TRPCError({
      code: 'UNAUTHORIZED',
      message: 'You must be logged in',
    });
  }

  return next({
    ctx: {
      ...ctx,
      session: ctx.session,
      user: ctx.session.user,
    },
  });
});

// Admin middleware
const isAdmin = t.middleware(async ({ ctx, next }) => {
  if (!ctx.session?.user || ctx.session.user.role !== 'admin') {
    throw new TRPCError({
      code: 'FORBIDDEN',
      message: 'Access restricted to administrators',
    });
  }

  return next({
    ctx: {
      ...ctx,
      session: ctx.session,
      user: ctx.session.user,
    },
  });
});

export const router = t.router;
export const publicProcedure = t.procedure.use(loggerMiddleware);
export const protectedProcedure = t.procedure.use(loggerMiddleware).use(isAuthed);
export const adminProcedure = t.procedure.use(loggerMiddleware).use(isAdmin);
```

### `server/context.ts`

```typescript
import type { CreateNextContextOptions } from '@trpc/server/adapters/next';
import { getServerSession } from 'next-auth';
import { authOptions } from '../pages/api/auth/[...nextauth]';
import { prisma } from '../lib/prisma';

export async function createContext({ req, res }: CreateNextContextOptions) {
  const session = await getServerSession(req, res, authOptions);

  return {
    session,
    prisma,
    req,
    res,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

### `server/routers/task.ts`

```typescript
import { z } from 'zod';
import { TRPCError } from '@trpc/server';
import { router, publicProcedure, protectedProcedure } from '../trpc';

// Validation schemas
const taskSchema = z.object({
  id: z.string().cuid(),
  title: z.string().min(1).max(200),
  description: z.string().max(2000).nullable(),
  status: z.enum(['todo', 'in_progress', 'done', 'cancelled']),
  priority: z.enum(['low', 'medium', 'high', 'urgent']),
  dueDate: z.date().nullable(),
  assigneeId: z.string().cuid().nullable(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

const createTaskSchema = taskSchema.omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

const updateTaskSchema = createTaskSchema.partial();

const listTasksSchema = z.object({
  status: z.enum(['todo', 'in_progress', 'done', 'cancelled']).optional(),
  priority: z.enum(['low', 'medium', 'high', 'urgent']).optional(),
  assigneeId: z.string().cuid().optional(),
  search: z.string().optional(),
  cursor: z.string().cuid().optional(),
  limit: z.number().int().min(1).max(100).default(20),
  sortBy: z.enum(['createdAt', 'dueDate', 'priority']).default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

export const taskRouter = router({
  /**
   * List tasks with cursor-based pagination
   */
  list: protectedProcedure
    .input(listTasksSchema)
    .query(async ({ ctx, input }) => {
      const { cursor, limit, status, priority, assigneeId, search, sortBy, sortOrder } = input;

      const where = {
        // Filter by the user's project/team
        project: {
          members: {
            some: { userId: ctx.user.id },
          },
        },
        ...(status && { status }),
        ...(priority && { priority }),
        ...(assigneeId && { assigneeId }),
        ...(search && {
          OR: [
            { title: { contains: search, mode: 'insensitive' as const } },
            { description: { contains: search, mode: 'insensitive' as const } },
          ],
        }),
      };

      const tasks = await ctx.prisma.task.findMany({
        where,
        take: limit + 1,
        cursor: cursor ? { id: cursor }: undefined,
        orderBy: { [sortBy]: sortOrder },
        include: {
          assignee: {
            select: { id: true, name: true, image: true },
          },
        },
      });

      let nextCursor: string | undefined;
      if (tasks.length > limit) {
        const nextItem = tasks.pop();
        nextCursor = nextItem?.id;
      }

      return {
        tasks,
        nextCursor,
      };
    }),

  /**
   * Get a task by ID
   */
  byId: protectedProcedure
    .input(z.object({ id: z.string().cuid() }))
    .query(async ({ ctx, input }) => {
      const task = await ctx.prisma.task.findUnique({
        where: { id: input.id },
        include: {
          assignee: {
            select: { id: true, name: true, image: true },
          },
          comments: {
            orderBy: { createdAt: 'desc' },
            include: {
              author: {
                select: { id: true, name: true, image: true },
              },
            },
          },
        },
      });

      if (!task) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'Task not found',
        });
      }

      return task;
    }),

  /**
   * Create a new task
   */
  create: protectedProcedure
    .input(createTaskSchema.extend({
      projectId: z.string().cuid(),
    }))
    .mutation(async ({ ctx, input }) => {
      const { projectId, ...data } = input;

      // Check that the user has access to the project
      const project = await ctx.prisma.project.findFirst({
        where: {
          id: projectId,
          members: {
            some: { userId: ctx.user.id },
          },
        },
      });

      if (!project) {
        throw new TRPCError({
          code: 'FORBIDDEN',
          message: 'Access to project denied',
        });
      }

      return ctx.prisma.task.create({
        data: {
          ...data,
          projectId,
          creatorId: ctx.user.id,
        },
        include: {
          assignee: {
            select: { id: true, name: true, image: true },
          },
        },
      });
    }),

  /**
   * Update a task
   */
  update: protectedProcedure
    .input(z.object({
      id: z.string().cuid(),
      data: updateTaskSchema,
    }))
    .mutation(async ({ ctx, input }) => {
      const { id, data } = input;

      // Check that the task exists and that the user has access to it
      const existing = await ctx.prisma.task.findFirst({
        where: {
          id,
          project: {
            members: {
              some: { userId: ctx.user.id },
            },
          },
        },
      });

      if (!existing) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'Task not found or access denied',
        });
      }

      return ctx.prisma.task.update({
        where: { id },
        data,
        include: {
          assignee: {
            select: { id: true, name: true, image: true },
          },
        },
      });
    }),

  /**
   * Change a task's status (shortcut)
   */
  updateStatus: protectedProcedure
    .input(z.object({
      id: z.string().cuid(),
      status: z.enum(['todo', 'in_progress', 'done', 'cancelled']),
    }))
    .mutation(async ({ ctx, input }) => {
      const { id, status } = input;

      return ctx.prisma.task.update({
        where: { id },
        data: { status },
      });
    }),

  /**
   * Delete a task
   */
  delete: protectedProcedure
    .input(z.object({ id: z.string().cuid() }))
    .mutation(async ({ ctx, input }) => {
      const { id } = input;

      // Check permissions (creator or project admin)
      const task = await ctx.prisma.task.findFirst({
        where: {
          id,
          OR: [
            { creatorId: ctx.user.id },
            {
              project: {
                members: {
                  some: {
                    userId: ctx.user.id,
                    role: 'admin',
                  },
                },
              },
            },
          ],
        },
      });

      if (!task) {
        throw new TRPCError({
          code: 'FORBIDDEN',
          message: 'Not authorized to delete this task',
        });
      }

      await ctx.prisma.task.delete({ where: { id } });

      return { success: true };
    }),

  /**
   * Task statistics
   */
  stats: protectedProcedure
    .input(z.object({ projectId: z.string().cuid().optional() }))
    .query(async ({ ctx, input }) => {
      const where = {
        project: {
          members: {
            some: { userId: ctx.user.id },
          },
        },
        ...(input.projectId && { projectId: input.projectId }),
      };

      const [total, byStatus, byPriority, overdue] = await Promise.all([
        ctx.prisma.task.count({ where }),
        ctx.prisma.task.groupBy({
          by: ['status'],
          where,
          _count: true,
        }),
        ctx.prisma.task.groupBy({
          by: ['priority'],
          where,
          _count: true,
        }),
        ctx.prisma.task.count({
          where: {
            ...where,
            status: { not: 'done' },
            dueDate: { lt: new Date() },
          },
        }),
      ]);

      return {
        total,
        byStatus: Object.fromEntries(
          byStatus.map((s) => [s.status, s._count])
        ),
        byPriority: Object.fromEntries(
          byPriority.map((p) => [p.priority, p._count])
        ),
        overdue,
      };
    }),
});
```

### `server/routers/index.ts`

```typescript
import { router } from '../trpc';
import { taskRouter } from './task';
import { userRouter } from './user';

export const appRouter = router({
  task: taskRouter,
  user: userRouter,
});

export type AppRouter = typeof appRouter;
```

### `utils/trpc.ts` (React Client)

```typescript
import { httpBatchLink, loggerLink } from '@trpc/client';
import { createTRPCNext } from '@trpc/next';
import superjson from 'superjson';
import type { AppRouter } from '../server/routers';

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
        loggerLink({
          enabled: (opts) =>
            process.env.NODE_ENV === 'development' ||
            (opts.direction === 'down' && opts.result instanceof Error),
        }),
        httpBatchLink({
          url: `${getBaseUrl()}/api/trpc`,
        }),
      ],
    };
  },
  ssr: false,
});
```

## Client-side usage

```tsx
import { trpc } from '../utils/trpc';

function TaskList() {
  // Query with filters
  const { data, fetchNextPage, hasNextPage, isLoading } = trpc.task.list.useInfiniteQuery(
    { limit: 20, status: 'todo' },
    {
      getNextPageParam: (lastPage) => lastPage.nextCursor,
    }
  );

  // Mutation with optimistic update
  const utils = trpc.useUtils();
  const updateStatus = trpc.task.updateStatus.useMutation({
    onMutate: async ({ id, status }) => {
      await utils.task.list.cancel();
      const previous = utils.task.list.getData();

      utils.task.list.setData({ limit: 20 }, (old) => ({
        ...old!,
        tasks: old!.tasks.map((t) =>
          t.id === id ? { ...t, status }: t
        ),
      }));

      return { previous };
    },
    onError: (err, vars, context) => {
      if (context?.previous) {
        utils.task.list.setData({ limit: 20 }, context.previous);
      }
    },
    onSettled: () => {
      utils.task.list.invalidate();
    },
  });

  if (isLoading) return <Spinner />;

  return (
    <ul>
      {data?.pages.flatMap((page) =>
        page.tasks.map((task) => (
          <li key={task.id}>
            {task.title}
            <button
              onClick={() =>
                updateStatus.mutate({ id: task.id, status: 'done' })
              }
            >
              Complete
            </button>
          </li>
        ))
      )}
      {hasNextPage && (
        <button onClick={() => fetchNextPage()}>Load more</button>
      )}
    </ul>
  );
}
```

## Key points

| Aspect | Implementation |
|--------|----------------|
| **Type-safety** | End-to-end inferred types |
| **Validation** | Zod with formatted errors |
| **Auth** | Reusable middlewares |
| **Pagination** | Cursor-based with `useInfiniteQuery` |
| **Optimistic UI** | Mutation with rollback |

## Related commands

- `/dev:dev-test` - Generate procedure tests
- `/dev:dev-prisma` - Associated Prisma schema
- `/qa:qa-security` - Security audit

---

:::tip React Query DevTools
Enable the DevTools to debug queries:
```tsx
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

<ReactQueryDevtools initialIsOpen={false} />
```
:::
