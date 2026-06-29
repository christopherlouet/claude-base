---
sidebar_position: 3
title: Next.js API
description: Next.js API route example with validation and error handling
---

# Next.js API Route

This example shows how to create a professional Next.js API route with Zod validation and error handling.

## Command used

```bash
/dev:dev-api "Create a CRUD endpoint for users with validation"
```

## Generated structure

```
src/app/api/users/
├── route.ts           # GET (list), POST (create)
├── [id]/
│   └── route.ts       # GET, PUT, DELETE (by id)
├── schema.ts          # Zod validation schemas
└── route.test.ts      # Integration tests
```

## API code

### `schema.ts`

```typescript
import { z } from 'zod';

// Base user schema
export const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email('Invalid email'),
  name: z.string().min(2, 'Name too short').max(100),
  role: z.enum(['admin', 'user', 'guest']).default('user'),
  createdAt: z.coerce.date(),
  updatedAt: z.coerce.date(),
});

// Schema for creation (no id or dates)
export const createUserSchema = userSchema.omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

// Schema for update (everything optional except id)
export const updateUserSchema = createUserSchema.partial();

// Schema for list query params
export const listUsersQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().optional(),
  role: z.enum(['admin', 'user', 'guest']).optional(),
  sortBy: z.enum(['name', 'email', 'createdAt']).default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

// Inferred types
export type User = z.infer<typeof userSchema>;
export type CreateUserInput = z.infer<typeof createUserSchema>;
export type UpdateUserInput = z.infer<typeof updateUserSchema>;
export type ListUsersQuery = z.infer<typeof listUsersQuerySchema>;
```

### `route.ts` (list and create)

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createUserSchema, listUsersQuerySchema } from './schema';
import { prisma } from '@/lib/prisma';
import { ApiError, handleApiError } from '@/lib/api-error';

/**
 * GET /api/users
 * List users with pagination and filters
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const query = listUsersQuerySchema.parse(
      Object.fromEntries(searchParams)
    );

    const { page, limit, search, role, sortBy, sortOrder } = query;
    const skip = (page - 1) * limit;

    // Build the filter
    const where = {
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
        ],
      }),
      ...(role && { role }),
    };

    // Parallel queries for data and count
    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { [sortBy]: sortOrder },
        select: {
          id: true,
          email: true,
          name: true,
          role: true,
          createdAt: true,
        },
      }),
      prisma.user.count({ where }),
    ]);

    return NextResponse.json({
      data: users,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasMore: skip + users.length < total,
      },
    });
  } catch (error) {
    return handleApiError(error);
  }
}

/**
 * POST /api/users
 * Create a new user
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const data = createUserSchema.parse(body);

    // Check whether the email already exists
    const existing = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existing) {
      throw new ApiError(409, 'A user with this email already exists');
    }

    const user = await prisma.user.create({
      data,
      select: {
        id: true,
        email: true,
        name: true,
        role: true,
        createdAt: true,
      },
    });

    return NextResponse.json(user, { status: 201 });
  } catch (error) {
    return handleApiError(error);
  }
}
```

### `[id]/route.ts` (operations by ID)

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { updateUserSchema } from '../schema';
import { prisma } from '@/lib/prisma';
import { ApiError, handleApiError } from '@/lib/api-error';

interface RouteContext {
  params: { id: string };
}

/**
 * GET /api/users/:id
 * Get a user by ID
 */
export async function GET(
  request: NextRequest,
  { params }: RouteContext
) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: params.id },
    });

    if (!user) {
      throw new ApiError(404, 'User not found');
    }

    return NextResponse.json(user);
  } catch (error) {
    return handleApiError(error);
  }
}

/**
 * PUT /api/users/:id
 * Update a user
 */
export async function PUT(
  request: NextRequest,
  { params }: RouteContext
) {
  try {
    const body = await request.json();
    const data = updateUserSchema.parse(body);

    // Check that the user exists
    const existing = await prisma.user.findUnique({
      where: { id: params.id },
    });

    if (!existing) {
      throw new ApiError(404, 'User not found');
    }

    // Check email uniqueness if modified
    if (data.email && data.email !== existing.email) {
      const emailExists = await prisma.user.findUnique({
        where: { email: data.email },
      });

      if (emailExists) {
        throw new ApiError(409, 'This email is already in use');
      }
    }

    const user = await prisma.user.update({
      where: { id: params.id },
      data,
    });

    return NextResponse.json(user);
  } catch (error) {
    return handleApiError(error);
  }
}

/**
 * DELETE /api/users/:id
 * Delete a user
 */
export async function DELETE(
  request: NextRequest,
  { params }: RouteContext
) {
  try {
    const existing = await prisma.user.findUnique({
      where: { id: params.id },
    });

    if (!existing) {
      throw new ApiError(404, 'User not found');
    }

    await prisma.user.delete({
      where: { id: params.id },
    });

    return new NextResponse(null, { status: 204 });
  } catch (error) {
    return handleApiError(error);
  }
}
```

### `@/lib/api-error.ts`

```typescript
import { NextResponse } from 'next/server';
import { ZodError } from 'zod';

export class ApiError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public code?: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export function handleApiError(error: unknown): NextResponse {
  console.error('API Error:', error);

  // Zod validation error
  if (error instanceof ZodError) {
    return NextResponse.json(
      {
        error: 'Validation Error',
        code: 'VALIDATION_ERROR',
        details: error.errors.map((e) => ({
          field: e.path.join('.'),
          message: e.message,
        })),
      },
      { status: 400 }
    );
  }

  // Custom API error
  if (error instanceof ApiError) {
    return NextResponse.json(
      {
        error: error.message,
        code: error.code,
      },
      { status: error.statusCode }
    );
  }

  // Prisma error (unique constraint, etc.)
  if (error && typeof error === 'object' && 'code' in error) {
    const prismaError = error as { code: string };
    if (prismaError.code === 'P2002') {
      return NextResponse.json(
        {
          error: 'A resource with this data already exists',
          code: 'DUPLICATE_ENTRY',
        },
        { status: 409 }
      );
    }
  }

  // Generic error
  return NextResponse.json(
    {
      error: 'An internal error occurred',
      code: 'INTERNAL_ERROR',
    },
    { status: 500 }
  );
}
```

### `route.test.ts`

```typescript
import { GET, POST } from './route';
import { prisma } from '@/lib/prisma';
import { NextRequest } from 'next/server';

// Mock Prisma
jest.mock('@/lib/prisma', () => ({
  prisma: {
    user: {
      findMany: jest.fn(),
      count: jest.fn(),
      findUnique: jest.fn(),
      create: jest.fn(),
    },
  },
}));

describe('GET /api/users', () => {
  it('returns paginated users', async () => {
    const mockUsers = [
      { id: '1', email: 'test@example.com', name: 'Test', role: 'user' },
    ];

    (prisma.user.findMany as jest.Mock).mockResolvedValue(mockUsers);
    (prisma.user.count as jest.Mock).mockResolvedValue(1);

    const request = new NextRequest('http://localhost/api/users?page=1&limit=10');
    const response = await GET(request);
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data.data).toEqual(mockUsers);
    expect(data.pagination.total).toBe(1);
  });

  it('filters by search query', async () => {
    const request = new NextRequest('http://localhost/api/users?search=test');
    await GET(request);

    expect(prisma.user.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          OR: expect.arrayContaining([
            { name: expect.any(Object) },
            { email: expect.any(Object) },
          ]),
        }),
      })
    );
  });
});

describe('POST /api/users', () => {
  it('creates a new user', async () => {
    const newUser = {
      email: 'new@example.com',
      name: 'New User',
      role: 'user',
    };

    (prisma.user.findUnique as jest.Mock).mockResolvedValue(null);
    (prisma.user.create as jest.Mock).mockResolvedValue({
      id: 'new-id',
      ...newUser,
      createdAt: new Date(),
    });

    const request = new NextRequest('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify(newUser),
    });

    const response = await POST(request);

    expect(response.status).toBe(201);
  });

  it('returns 409 for duplicate email', async () => {
    (prisma.user.findUnique as jest.Mock).mockResolvedValue({ id: 'existing' });

    const request = new NextRequest('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({
        email: 'existing@example.com',
        name: 'Test',
      }),
    });

    const response = await POST(request);

    expect(response.status).toBe(409);
  });

  it('returns 400 for invalid data', async () => {
    const request = new NextRequest('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({
        email: 'invalid-email',
        name: 'T', // Too short
      }),
    });

    const response = await POST(request);
    const data = await response.json();

    expect(response.status).toBe(400);
    expect(data.code).toBe('VALIDATION_ERROR');
  });
});
```

## Key points

| Aspect | Implementation |
|--------|----------------|
| **Validation** | Zod with custom error messages |
| **Pagination** | Cursor-based with metadata |
| **Errors** | ApiError class + centralized handler |
| **TypeScript** | Types inferred from Zod schemas |
| **Tests** | Prisma mocks, error case coverage |

## Related commands

- `/dev:dev-tdd` - Generate more tests
- `/qa:qa-security` - API security audit
- `/doc:doc-api-spec` - Generate OpenAPI spec

---

:::tip Route Handler vs API Routes
Next.js 13+ uses Route Handlers (`app/api/`) rather than API Routes (`pages/api/`). Route Handlers support named HTTP methods (`GET`, `POST`, etc.).
:::
