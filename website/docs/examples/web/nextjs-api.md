---
sidebar_position: 3
title: API Next.js
description: Exemple de route API Next.js avec validation et gestion d'erreurs
---

# Route API Next.js

Cet exemple montre comment créer une route API Next.js professionnelle avec validation Zod et gestion d'erreurs.

## Commande utilisée

```bash
/dev:dev-api "Créer un endpoint CRUD pour les utilisateurs avec validation"
```

## Structure générée

```
src/app/api/users/
├── route.ts           # GET (list), POST (create)
├── [id]/
│   └── route.ts       # GET, PUT, DELETE (by id)
├── schema.ts          # Schémas de validation Zod
└── route.test.ts      # Tests d'intégration
```

## Code de l'API

### `schema.ts`

```typescript
import { z } from 'zod';

// Schéma de base utilisateur
export const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email('Email invalide'),
  name: z.string().min(2, 'Nom trop court').max(100),
  role: z.enum(['admin', 'user', 'guest']).default('user'),
  createdAt: z.coerce.date(),
  updatedAt: z.coerce.date(),
});

// Schéma pour la création (sans id ni dates)
export const createUserSchema = userSchema.omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

// Schéma pour la mise à jour (tout optionnel sauf id)
export const updateUserSchema = createUserSchema.partial();

// Schéma pour les query params de liste
export const listUsersQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().optional(),
  role: z.enum(['admin', 'user', 'guest']).optional(),
  sortBy: z.enum(['name', 'email', 'createdAt']).default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

// Types inférés
export type User = z.infer<typeof userSchema>;
export type CreateUserInput = z.infer<typeof createUserSchema>;
export type UpdateUserInput = z.infer<typeof updateUserSchema>;
export type ListUsersQuery = z.infer<typeof listUsersQuerySchema>;
```

### `route.ts` (liste et création)

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createUserSchema, listUsersQuerySchema } from './schema';
import { prisma } from '@/lib/prisma';
import { ApiError, handleApiError } from '@/lib/api-error';

/**
 * GET /api/users
 * Liste les utilisateurs avec pagination et filtres
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const query = listUsersQuerySchema.parse(
      Object.fromEntries(searchParams)
    );

    const { page, limit, search, role, sortBy, sortOrder } = query;
    const skip = (page - 1) * limit;

    // Construction du filtre
    const where = {
      ...(search && {
        OR: [
          { name: { contains: search, mode: 'insensitive' } },
          { email: { contains: search, mode: 'insensitive' } },
        ],
      }),
      ...(role && { role }),
    };

    // Requêtes parallèles pour data et count
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
 * Crée un nouvel utilisateur
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const data = createUserSchema.parse(body);

    // Vérifier si l'email existe déjà
    const existing = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existing) {
      throw new ApiError(409, 'Un utilisateur avec cet email existe déjà');
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

### `[id]/route.ts` (opérations par ID)

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
 * Récupère un utilisateur par son ID
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
      throw new ApiError(404, 'Utilisateur non trouvé');
    }

    return NextResponse.json(user);
  } catch (error) {
    return handleApiError(error);
  }
}

/**
 * PUT /api/users/:id
 * Met à jour un utilisateur
 */
export async function PUT(
  request: NextRequest,
  { params }: RouteContext
) {
  try {
    const body = await request.json();
    const data = updateUserSchema.parse(body);

    // Vérifier que l'utilisateur existe
    const existing = await prisma.user.findUnique({
      where: { id: params.id },
    });

    if (!existing) {
      throw new ApiError(404, 'Utilisateur non trouvé');
    }

    // Vérifier unicité email si modifié
    if (data.email && data.email !== existing.email) {
      const emailExists = await prisma.user.findUnique({
        where: { email: data.email },
      });

      if (emailExists) {
        throw new ApiError(409, 'Cet email est déjà utilisé');
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
 * Supprime un utilisateur
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
      throw new ApiError(404, 'Utilisateur non trouvé');
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

  // Erreur de validation Zod
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

  // Erreur API personnalisée
  if (error instanceof ApiError) {
    return NextResponse.json(
      {
        error: error.message,
        code: error.code,
      },
      { status: error.statusCode }
    );
  }

  // Erreur Prisma (contrainte unique, etc.)
  if (error && typeof error === 'object' && 'code' in error) {
    const prismaError = error as { code: string };
    if (prismaError.code === 'P2002') {
      return NextResponse.json(
        {
          error: 'Une ressource avec ces données existe déjà',
          code: 'DUPLICATE_ENTRY',
        },
        { status: 409 }
      );
    }
  }

  // Erreur générique
  return NextResponse.json(
    {
      error: 'Une erreur interne est survenue',
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
        name: 'T', // Trop court
      }),
    });

    const response = await POST(request);
    const data = await response.json();

    expect(response.status).toBe(400);
    expect(data.code).toBe('VALIDATION_ERROR');
  });
});
```

## Points clés

| Aspect | Implémentation |
|--------|----------------|
| **Validation** | Zod avec messages d'erreur personnalisés |
| **Pagination** | Curseur-based avec metadata |
| **Erreurs** | Classe ApiError + handler centralisé |
| **TypeScript** | Types inférés depuis les schémas Zod |
| **Tests** | Mocks Prisma, couverture des cas d'erreur |

## Commandes associées

- `/dev:dev-test` - Générer plus de tests
- `/qa:qa-security` - Audit sécurité de l'API
- `/doc:doc-api-spec` - Générer OpenAPI spec

---

:::tip Route Handler vs API Routes
Next.js 13+ utilise les Route Handlers (`app/api/`) plutôt que les API Routes (`pages/api/`). Les Route Handlers supportent les méthodes HTTP nommées (`GET`, `POST`, etc.).
:::
