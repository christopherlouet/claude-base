---
sidebar_position: 2
title: Resolver GraphQL
description: Exemple de resolver GraphQL avec Apollo Server et validation
---

# Resolver GraphQL avec Apollo Server

Cet exemple montre comment créer des resolvers GraphQL professionnels avec Apollo Server, TypeScript et validation.

## Commande utilisée

```bash
/dev:dev-graphql "Créer des queries et mutations pour les utilisateurs"
```

## Structure générée

```
src/graphql/
├── schema/
│   ├── typeDefs.ts        # Schema GraphQL
│   └── index.ts
├── resolvers/
│   ├── userResolver.ts    # Resolvers utilisateur
│   ├── index.ts
│   └── scalars.ts         # Scalars personnalisés
├── dataloaders/
│   └── userLoader.ts      # DataLoader pour N+1
├── context.ts             # Contexte GraphQL
└── server.ts              # Configuration Apollo
```

## Code du Resolver

### `schema/typeDefs.ts`

```typescript
import { gql } from 'graphql-tag';

export const typeDefs = gql`
  scalar DateTime

  enum Role {
    ADMIN
    USER
    GUEST
  }

  enum SortOrder {
    ASC
    DESC
  }

  type User {
    id: ID!
    email: String!
    name: String
    avatarUrl: String
    role: Role!
    posts: [Post!]!
    postsCount: Int!
    createdAt: DateTime!
    updatedAt: DateTime!
  }

  type Post {
    id: ID!
    title: String!
    content: String!
    author: User!
    published: Boolean!
    createdAt: DateTime!
  }

  type PageInfo {
    hasNextPage: Boolean!
    hasPreviousPage: Boolean!
    startCursor: String
    endCursor: String
  }

  type UserEdge {
    node: User!
    cursor: String!
  }

  type UserConnection {
    edges: [UserEdge!]!
    pageInfo: PageInfo!
    totalCount: Int!
  }

  input CreateUserInput {
    email: String!
    name: String
    role: Role
  }

  input UpdateUserInput {
    email: String
    name: String
    role: Role
  }

  input UsersFilterInput {
    search: String
    role: Role
  }

  input UsersSortInput {
    field: UserSortField!
    order: SortOrder!
  }

  enum UserSortField {
    NAME
    EMAIL
    CREATED_AT
  }

  type Query {
    # Récupère un utilisateur par ID
    user(id: ID!): User

    # Récupère l'utilisateur connecté
    me: User

    # Liste les utilisateurs avec pagination cursor-based
    users(
      first: Int
      after: String
      last: Int
      before: String
      filter: UsersFilterInput
      sort: UsersSortInput
    ): UserConnection!
  }

  type Mutation {
    # Crée un nouvel utilisateur
    createUser(input: CreateUserInput!): User!

    # Met à jour un utilisateur
    updateUser(id: ID!, input: UpdateUserInput!): User!

    # Supprime un utilisateur
    deleteUser(id: ID!): Boolean!

    # Change le rôle d'un utilisateur (admin only)
    changeUserRole(id: ID!, role: Role!): User!
  }
`;
```

### `resolvers/userResolver.ts`

```typescript
import { GraphQLError } from 'graphql';
import { z } from 'zod';
import type { Context } from '../context';
import { prisma } from '../../lib/prisma';
import { encodeCursor, decodeCursor } from '../../utils/cursor';

// Schémas de validation
const createUserSchema = z.object({
  email: z.string().email('Email invalide'),
  name: z.string().min(2).max(100).optional(),
  role: z.enum(['ADMIN', 'USER', 'GUEST']).default('USER'),
});

const updateUserSchema = z.object({
  email: z.string().email('Email invalide').optional(),
  name: z.string().min(2).max(100).optional(),
  role: z.enum(['ADMIN', 'USER', 'GUEST']).optional(),
});

export const userResolver = {
  Query: {
    user: async (_: unknown, { id }: { id: string }) => {
      return prisma.user.findUnique({ where: { id } });
    },

    me: async (_: unknown, __: unknown, { user }: Context) => {
      if (!user) {
        throw new GraphQLError('Non authentifié', {
          extensions: { code: 'UNAUTHENTICATED' },
        });
      }
      return prisma.user.findUnique({ where: { id: user.id } });
    },

    users: async (
      _: unknown,
      args: {
        first?: number;
        after?: string;
        last?: number;
        before?: string;
        filter?: { search?: string; role?: string };
        sort?: { field: string; order: 'ASC' | 'DESC' };
      }
    ) => {
      const { first = 10, after, last, before, filter, sort } = args;
      const take = first || last || 10;
      const cursor = after ? decodeCursor(after) : before ? decodeCursor(before) : undefined;

      // Construction du filtre
      const where = {
        ...(filter?.search && {
          OR: [
            { name: { contains: filter.search, mode: 'insensitive' as const } },
            { email: { contains: filter.search, mode: 'insensitive' as const } },
          ],
        }),
        ...(filter?.role && { role: filter.role }),
      };

      // Ordre de tri
      const orderBy = sort
        ? { [sort.field.toLowerCase()]: sort.order.toLowerCase() }
        : { createdAt: 'desc' as const };

      // Requêtes
      const [users, totalCount] = await Promise.all([
        prisma.user.findMany({
          where,
          take: take + 1, // +1 pour savoir s'il y a une page suivante
          skip: cursor ? 1 : 0,
          cursor: cursor ? { id: cursor } : undefined,
          orderBy,
        }),
        prisma.user.count({ where }),
      ]);

      const hasMore = users.length > take;
      const nodes = hasMore ? users.slice(0, -1) : users;

      return {
        edges: nodes.map((user) => ({
          node: user,
          cursor: encodeCursor(user.id),
        })),
        pageInfo: {
          hasNextPage: hasMore,
          hasPreviousPage: !!cursor,
          startCursor: nodes[0] ? encodeCursor(nodes[0].id) : null,
          endCursor: nodes[nodes.length - 1]
            ? encodeCursor(nodes[nodes.length - 1].id)
            : null,
        },
        totalCount,
      };
    },
  },

  Mutation: {
    createUser: async (
      _: unknown,
      { input }: { input: z.infer<typeof createUserSchema> },
      { user }: Context
    ) => {
      // Validation
      const data = createUserSchema.parse(input);

      // Vérifier que l'email n'existe pas
      const existing = await prisma.user.findUnique({
        where: { email: data.email },
      });

      if (existing) {
        throw new GraphQLError('Un utilisateur avec cet email existe déjà', {
          extensions: { code: 'BAD_USER_INPUT', field: 'email' },
        });
      }

      return prisma.user.create({ data });
    },

    updateUser: async (
      _: unknown,
      { id, input }: { id: string; input: z.infer<typeof updateUserSchema> },
      { user }: Context
    ) => {
      if (!user) {
        throw new GraphQLError('Non authentifié', {
          extensions: { code: 'UNAUTHENTICATED' },
        });
      }

      // Validation
      const data = updateUserSchema.parse(input);

      // Vérifier que l'utilisateur existe
      const existing = await prisma.user.findUnique({ where: { id } });

      if (!existing) {
        throw new GraphQLError('Utilisateur non trouvé', {
          extensions: { code: 'NOT_FOUND' },
        });
      }

      // Vérifier les permissions (soi-même ou admin)
      if (existing.id !== user.id && user.role !== 'ADMIN') {
        throw new GraphQLError('Non autorisé', {
          extensions: { code: 'FORBIDDEN' },
        });
      }

      // Vérifier unicité email si modifié
      if (data.email && data.email !== existing.email) {
        const emailExists = await prisma.user.findUnique({
          where: { email: data.email },
        });
        if (emailExists) {
          throw new GraphQLError('Cet email est déjà utilisé', {
            extensions: { code: 'BAD_USER_INPUT', field: 'email' },
          });
        }
      }

      return prisma.user.update({ where: { id }, data });
    },

    deleteUser: async (
      _: unknown,
      { id }: { id: string },
      { user }: Context
    ) => {
      if (!user || user.role !== 'ADMIN') {
        throw new GraphQLError('Non autorisé', {
          extensions: { code: 'FORBIDDEN' },
        });
      }

      await prisma.user.delete({ where: { id } });
      return true;
    },

    changeUserRole: async (
      _: unknown,
      { id, role }: { id: string; role: string },
      { user }: Context
    ) => {
      if (!user || user.role !== 'ADMIN') {
        throw new GraphQLError('Seuls les admins peuvent changer les rôles', {
          extensions: { code: 'FORBIDDEN' },
        });
      }

      return prisma.user.update({
        where: { id },
        data: { role },
      });
    },
  },

  // Field resolvers
  User: {
    posts: async (parent: { id: string }, _: unknown, { loaders }: Context) => {
      // Utiliser DataLoader pour éviter N+1
      return loaders.postsByAuthorId.load(parent.id);
    },

    postsCount: async (parent: { id: string }) => {
      return prisma.post.count({ where: { authorId: parent.id } });
    },
  },
};
```

### `dataloaders/userLoader.ts`

```typescript
import DataLoader from 'dataloader';
import { prisma } from '../../lib/prisma';

export const createLoaders = () => ({
  // Charge les utilisateurs par ID (pour éviter N+1 sur author)
  userById: new DataLoader<string, any>(async (ids) => {
    const users = await prisma.user.findMany({
      where: { id: { in: [...ids] } },
    });

    const userMap = new Map(users.map((u) => [u.id, u]));
    return ids.map((id) => userMap.get(id) || null);
  }),

  // Charge les posts par authorId (pour le field resolver posts)
  postsByAuthorId: new DataLoader<string, any[]>(async (authorIds) => {
    const posts = await prisma.post.findMany({
      where: { authorId: { in: [...authorIds] } },
    });

    const postsByAuthor = new Map<string, any[]>();
    posts.forEach((post) => {
      const existing = postsByAuthor.get(post.authorId) || [];
      existing.push(post);
      postsByAuthor.set(post.authorId, existing);
    });

    return authorIds.map((id) => postsByAuthor.get(id) || []);
  }),
});
```

### `context.ts`

```typescript
import type { Request } from 'express';
import { createLoaders } from './dataloaders/userLoader';
import { verifyToken } from '../utils/jwt';

export interface Context {
  user: {
    id: string;
    email: string;
    role: string;
  } | null;
  loaders: ReturnType<typeof createLoaders>;
}

export async function createContext({ req }: { req: Request }): Promise<Context> {
  // Extraire le token du header Authorization
  const token = req.headers.authorization?.replace('Bearer ', '');

  let user = null;
  if (token) {
    try {
      user = verifyToken(token);
    } catch {
      // Token invalide, user reste null
    }
  }

  return {
    user,
    loaders: createLoaders(),
  };
}
```

### `server.ts`

```typescript
import { ApolloServer } from '@apollo/server';
import { expressMiddleware } from '@apollo/server/express4';
import { ApolloServerPluginDrainHttpServer } from '@apollo/server/plugin/drainHttpServer';
import express from 'express';
import http from 'http';
import cors from 'cors';
import { typeDefs } from './schema';
import { resolvers } from './resolvers';
import { createContext } from './context';

async function startServer() {
  const app = express();
  const httpServer = http.createServer(app);

  const server = new ApolloServer({
    typeDefs,
    resolvers,
    plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
    formatError: (formattedError, error) => {
      // Log l'erreur complète côté serveur
      console.error('GraphQL Error:', error);

      // Ne pas exposer les détails des erreurs internes en production
      if (process.env.NODE_ENV === 'production') {
        if (formattedError.extensions?.code === 'INTERNAL_SERVER_ERROR') {
          return {
            message: 'Une erreur interne est survenue',
            extensions: { code: 'INTERNAL_SERVER_ERROR' },
          };
        }
      }

      return formattedError;
    },
  });

  await server.start();

  app.use(
    '/graphql',
    cors<cors.CorsRequest>(),
    express.json(),
    expressMiddleware(server, {
      context: createContext,
    })
  );

  const PORT = process.env.PORT || 4000;
  await new Promise<void>((resolve) => {
    httpServer.listen({ port: PORT }, resolve);
  });

  console.log(`🚀 Server ready at http://localhost:${PORT}/graphql`);
}

startServer().catch(console.error);
```

## Exemple de requêtes

### Query

```graphql
# Récupérer l'utilisateur connecté
query Me {
  me {
    id
    email
    name
    role
    postsCount
  }
}

# Liste avec pagination et filtres
query Users($first: Int, $after: String, $filter: UsersFilterInput) {
  users(first: $first, after: $after, filter: $filter) {
    edges {
      node {
        id
        email
        name
        role
      }
      cursor
    }
    pageInfo {
      hasNextPage
      endCursor
    }
    totalCount
  }
}
```

### Mutation

```graphql
mutation CreateUser($input: CreateUserInput!) {
  createUser(input: $input) {
    id
    email
    name
    role
  }
}

mutation UpdateUser($id: ID!, $input: UpdateUserInput!) {
  updateUser(id: $id, input: $input) {
    id
    email
    name
  }
}
```

## Points clés

| Aspect | Implémentation |
|--------|----------------|
| **Pagination** | Cursor-based (Relay style) |
| **N+1** | DataLoader pour les relations |
| **Validation** | Zod dans les resolvers |
| **Erreurs** | `GraphQLError` avec codes |
| **Auth** | Context avec user et loaders |

## Commandes associées

- `/dev:dev-test` - Générer tests de resolvers
- `/qa:qa-security` - Audit sécurité GraphQL
- `/doc:doc-api-spec` - Documentation schema

---

:::tip Codegen
Utilisez `graphql-codegen` pour générer les types TypeScript depuis le schema :
```bash
npx graphql-codegen
```
:::
