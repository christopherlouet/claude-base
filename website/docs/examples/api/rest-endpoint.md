---
sidebar_position: 1
title: Endpoint REST
description: Exemple d'endpoint REST complet avec Express et validation
---

# Endpoint REST avec Express

Cet exemple montre comment créer un endpoint REST professionnel avec Express, validation Zod et tests.

## Commande utilisée

```bash
/dev:dev-api "Créer un endpoint CRUD pour les articles avec pagination"
```

## Structure générée

```
src/
├── routes/
│   └── articles.ts        # Routes Express
├── controllers/
│   └── articleController.ts
├── services/
│   └── articleService.ts
├── schemas/
│   └── articleSchema.ts   # Validation Zod
├── middleware/
│   └── validate.ts        # Middleware validation
└── tests/
    └── articles.test.ts
```

## Code de l'endpoint

### `schemas/articleSchema.ts`

```typescript
import { z } from 'zod';

export const articleSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(3).max(200),
  slug: z.string().regex(/^[a-z0-9-]+$/),
  content: z.string().min(10),
  excerpt: z.string().max(300).optional(),
  authorId: z.string().uuid(),
  status: z.enum(['draft', 'published', 'archived']),
  tags: z.array(z.string()).default([]),
  publishedAt: z.coerce.date().nullable(),
  createdAt: z.coerce.date(),
  updatedAt: z.coerce.date(),
});

export const createArticleSchema = articleSchema.omit({
  id: true,
  slug: true,
  createdAt: true,
  updatedAt: true,
  publishedAt: true,
});

export const updateArticleSchema = createArticleSchema.partial();

export const listArticlesQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  status: z.enum(['draft', 'published', 'archived']).optional(),
  authorId: z.string().uuid().optional(),
  tag: z.string().optional(),
  search: z.string().optional(),
  sortBy: z.enum(['createdAt', 'publishedAt', 'title']).default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

export type Article = z.infer<typeof articleSchema>;
export type CreateArticleInput = z.infer<typeof createArticleSchema>;
export type UpdateArticleInput = z.infer<typeof updateArticleSchema>;
export type ListArticlesQuery = z.infer<typeof listArticlesQuerySchema>;
```

### `middleware/validate.ts`

```typescript
import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';

export const validate = (schema: AnyZodObject, source: 'body' | 'query' | 'params' = 'body') =>
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = await schema.parseAsync(req[source]);
      req[source] = data; // Remplace par les données validées/transformées
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          error: 'Validation Error',
          code: 'VALIDATION_ERROR',
          details: error.errors.map((e) => ({
            field: e.path.join('.'),
            message: e.message,
          })),
        });
      }
      next(error);
    }
  };
```

### `routes/articles.ts`

```typescript
import { Router } from 'express';
import { articleController } from '../controllers/articleController';
import { validate } from '../middleware/validate';
import { authenticate } from '../middleware/authenticate';
import { authorize } from '../middleware/authorize';
import {
  createArticleSchema,
  updateArticleSchema,
  listArticlesQuerySchema,
} from '../schemas/articleSchema';

const router = Router();

/**
 * @route   GET /api/articles
 * @desc    Liste les articles avec pagination et filtres
 * @access  Public
 */
router.get(
  '/',
  validate(listArticlesQuerySchema, 'query'),
  articleController.list
);

/**
 * @route   GET /api/articles/:id
 * @desc    Récupère un article par ID ou slug
 * @access  Public
 */
router.get('/:id', articleController.getById);

/**
 * @route   POST /api/articles
 * @desc    Crée un nouvel article
 * @access  Private (auteur)
 */
router.post(
  '/',
  authenticate,
  authorize('author', 'admin'),
  validate(createArticleSchema),
  articleController.create
);

/**
 * @route   PUT /api/articles/:id
 * @desc    Met à jour un article
 * @access  Private (propriétaire ou admin)
 */
router.put(
  '/:id',
  authenticate,
  validate(updateArticleSchema),
  articleController.update
);

/**
 * @route   DELETE /api/articles/:id
 * @desc    Supprime un article
 * @access  Private (propriétaire ou admin)
 */
router.delete(
  '/:id',
  authenticate,
  authorize('admin'),
  articleController.remove
);

/**
 * @route   POST /api/articles/:id/publish
 * @desc    Publie un article
 * @access  Private (propriétaire ou admin)
 */
router.post(
  '/:id/publish',
  authenticate,
  articleController.publish
);

export default router;
```

### `controllers/articleController.ts`

```typescript
import { Request, Response, NextFunction } from 'express';
import { articleService } from '../services/articleService';
import { ApiError } from '../utils/ApiError';
import type { ListArticlesQuery, CreateArticleInput, UpdateArticleInput } from '../schemas/articleSchema';

export const articleController = {
  /**
   * Liste les articles
   */
  async list(req: Request, res: Response, next: NextFunction) {
    try {
      const query = req.query as ListArticlesQuery;
      const result = await articleService.findAll(query);

      res.json({
        data: result.articles,
        pagination: {
          page: query.page,
          limit: query.limit,
          total: result.total,
          totalPages: Math.ceil(result.total / query.limit),
          hasMore: query.page * query.limit < result.total,
        },
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Récupère un article par ID ou slug
   */
  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const article = await articleService.findByIdOrSlug(id);

      if (!article) {
        throw new ApiError(404, 'Article non trouvé');
      }

      // Incrémenter les vues si article publié
      if (article.status === 'published') {
        await articleService.incrementViews(article.id);
      }

      res.json(article);
    } catch (error) {
      next(error);
    }
  },

  /**
   * Crée un nouvel article
   */
  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const data = req.body as CreateArticleInput;
      const authorId = req.user!.id;

      const article = await articleService.create({
        ...data,
        authorId,
      });

      res.status(201).json(article);
    } catch (error) {
      next(error);
    }
  },

  /**
   * Met à jour un article
   */
  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const data = req.body as UpdateArticleInput;
      const userId = req.user!.id;
      const userRole = req.user!.role;

      const existing = await articleService.findById(id);

      if (!existing) {
        throw new ApiError(404, 'Article non trouvé');
      }

      // Vérifier les permissions
      if (existing.authorId !== userId && userRole !== 'admin') {
        throw new ApiError(403, 'Non autorisé à modifier cet article');
      }

      const article = await articleService.update(id, data);
      res.json(article);
    } catch (error) {
      next(error);
    }
  },

  /**
   * Supprime un article
   */
  async remove(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;

      const existing = await articleService.findById(id);

      if (!existing) {
        throw new ApiError(404, 'Article non trouvé');
      }

      await articleService.delete(id);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  },

  /**
   * Publie un article
   */
  async publish(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const userId = req.user!.id;
      const userRole = req.user!.role;

      const existing = await articleService.findById(id);

      if (!existing) {
        throw new ApiError(404, 'Article non trouvé');
      }

      if (existing.authorId !== userId && userRole !== 'admin') {
        throw new ApiError(403, 'Non autorisé à publier cet article');
      }

      if (existing.status === 'published') {
        throw new ApiError(400, 'Article déjà publié');
      }

      const article = await articleService.publish(id);
      res.json(article);
    } catch (error) {
      next(error);
    }
  },
};
```

### `services/articleService.ts`

```typescript
import { prisma } from '../lib/prisma';
import { slugify } from '../utils/slugify';
import type { CreateArticleInput, UpdateArticleInput, ListArticlesQuery } from '../schemas/articleSchema';

export const articleService = {
  async findAll(query: ListArticlesQuery) {
    const { page, limit, status, authorId, tag, search, sortBy, sortOrder } = query;
    const skip = (page - 1) * limit;

    const where = {
      ...(status && { status }),
      ...(authorId && { authorId }),
      ...(tag && { tags: { has: tag } }),
      ...(search && {
        OR: [
          { title: { contains: search, mode: 'insensitive' as const } },
          { content: { contains: search, mode: 'insensitive' as const } },
        ],
      }),
    };

    const [articles, total] = await Promise.all([
      prisma.article.findMany({
        where,
        skip,
        take: limit,
        orderBy: { [sortBy]: sortOrder },
        include: {
          author: {
            select: { id: true, name: true, avatarUrl: true },
          },
        },
      }),
      prisma.article.count({ where }),
    ]);

    return { articles, total };
  },

  async findById(id: string) {
    return prisma.article.findUnique({
      where: { id },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true },
        },
      },
    });
  },

  async findByIdOrSlug(idOrSlug: string) {
    return prisma.article.findFirst({
      where: {
        OR: [{ id: idOrSlug }, { slug: idOrSlug }],
      },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true },
        },
      },
    });
  },

  async create(data: CreateArticleInput & { authorId: string }) {
    const slug = slugify(data.title);

    // Vérifier unicité du slug
    const existingSlug = await prisma.article.findUnique({
      where: { slug },
    });

    const finalSlug = existingSlug
      ? `${slug}-${Date.now()}`
      : slug;

    return prisma.article.create({
      data: {
        ...data,
        slug: finalSlug,
        excerpt: data.excerpt || data.content.substring(0, 200) + '...',
      },
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true },
        },
      },
    });
  },

  async update(id: string, data: UpdateArticleInput) {
    const updateData: any = { ...data };

    // Regénérer le slug si le titre change
    if (data.title) {
      updateData.slug = slugify(data.title);
    }

    return prisma.article.update({
      where: { id },
      data: updateData,
      include: {
        author: {
          select: { id: true, name: true, avatarUrl: true },
        },
      },
    });
  },

  async delete(id: string) {
    return prisma.article.delete({ where: { id } });
  },

  async publish(id: string) {
    return prisma.article.update({
      where: { id },
      data: {
        status: 'published',
        publishedAt: new Date(),
      },
    });
  },

  async incrementViews(id: string) {
    return prisma.article.update({
      where: { id },
      data: {
        views: { increment: 1 },
      },
    });
  },
};
```

### `tests/articles.test.ts`

```typescript
import request from 'supertest';
import { app } from '../app';
import { prisma } from '../lib/prisma';
import { generateToken } from '../utils/jwt';

describe('Articles API', () => {
  let authToken: string;
  let testUserId: string;

  beforeAll(async () => {
    // Créer un utilisateur de test
    const user = await prisma.user.create({
      data: {
        email: 'test@example.com',
        name: 'Test User',
        role: 'author',
      },
    });
    testUserId = user.id;
    authToken = generateToken(user);
  });

  afterAll(async () => {
    await prisma.article.deleteMany();
    await prisma.user.deleteMany();
  });

  describe('GET /api/articles', () => {
    it('returns paginated articles', async () => {
      const response = await request(app)
        .get('/api/articles')
        .query({ page: 1, limit: 10 })
        .expect(200);

      expect(response.body).toHaveProperty('data');
      expect(response.body).toHaveProperty('pagination');
      expect(Array.isArray(response.body.data)).toBe(true);
    });

    it('filters by status', async () => {
      await request(app)
        .get('/api/articles')
        .query({ status: 'published' })
        .expect(200);
    });

    it('searches in title and content', async () => {
      await request(app)
        .get('/api/articles')
        .query({ search: 'test' })
        .expect(200);
    });
  });

  describe('POST /api/articles', () => {
    it('creates article with valid data', async () => {
      const response = await request(app)
        .post('/api/articles')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'Test Article',
          content: 'This is the content of the test article.',
          status: 'draft',
        })
        .expect(201);

      expect(response.body.title).toBe('Test Article');
      expect(response.body.slug).toBe('test-article');
      expect(response.body.authorId).toBe(testUserId);
    });

    it('returns 401 without authentication', async () => {
      await request(app)
        .post('/api/articles')
        .send({
          title: 'Test',
          content: 'Content',
          status: 'draft',
        })
        .expect(401);
    });

    it('returns 400 with invalid data', async () => {
      const response = await request(app)
        .post('/api/articles')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          title: 'AB', // Trop court
          content: 'Short', // Trop court
        })
        .expect(400);

      expect(response.body.code).toBe('VALIDATION_ERROR');
    });
  });

  describe('PUT /api/articles/:id', () => {
    let articleId: string;

    beforeEach(async () => {
      const article = await prisma.article.create({
        data: {
          title: 'Original Title',
          slug: 'original-title',
          content: 'Original content here.',
          status: 'draft',
          authorId: testUserId,
        },
      });
      articleId = article.id;
    });

    it('updates article', async () => {
      const response = await request(app)
        .put(`/api/articles/${articleId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({ title: 'Updated Title' })
        .expect(200);

      expect(response.body.title).toBe('Updated Title');
    });

    it('returns 404 for non-existent article', async () => {
      await request(app)
        .put('/api/articles/non-existent-id')
        .set('Authorization', `Bearer ${authToken}`)
        .send({ title: 'Test' })
        .expect(404);
    });
  });

  describe('POST /api/articles/:id/publish', () => {
    it('publishes draft article', async () => {
      const article = await prisma.article.create({
        data: {
          title: 'Draft Article',
          slug: 'draft-article',
          content: 'Content to publish.',
          status: 'draft',
          authorId: testUserId,
        },
      });

      const response = await request(app)
        .post(`/api/articles/${article.id}/publish`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(response.body.status).toBe('published');
      expect(response.body.publishedAt).toBeDefined();
    });
  });
});
```

## Points clés

| Aspect | Implémentation |
|--------|----------------|
| **Validation** | Zod avec middleware réutilisable |
| **Architecture** | Routes → Controllers → Services |
| **Permissions** | Middleware `authenticate` + `authorize` |
| **Pagination** | Curseur avec metadata complètes |
| **Tests** | Supertest + setup/teardown propre |

## Commandes associées

- `/qa:qa-security` - Audit sécurité de l'API
- `/doc:doc-api-spec` - Générer OpenAPI spec
- `/dev:dev-test` - Ajouter plus de tests

---

:::tip Rate Limiting
Ajoutez du rate limiting pour protéger votre API :
```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requêtes par fenêtre
});

app.use('/api/', limiter);
```
:::
