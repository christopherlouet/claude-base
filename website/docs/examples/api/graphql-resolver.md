---
sidebar_position: 2
title: GraphQL Resolver
description: Example of a GraphQL resolver with Apollo Server and validation
---

# GraphQL Resolver with Apollo Server

This example shows how to create professional GraphQL resolvers with Apollo Server, TypeScript and validation.

## Command used

```bash
/dev:dev-graphql "Create queries and mutations for users"
```

## Generated structure

```
src/graphql/
├── schema/
│   ├── typeDefs.ts        # GraphQL schema
│   └── index.ts
├── resolvers/
│   ├── userResolver.ts    # User resolvers
│   ├── index.ts
│   └── scalars.ts         # Custom scalars
├── dataloaders/
│   └── userLoader.ts      # DataLoader for N+1
├── context.ts             # GraphQL context
└── server.ts              # Apollo configuration
```

## Resolver code

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
    # Get a user by ID
    user(id: ID!): User

    # Get the currently logged-in user
    me: User

    # List users with cursor-based pagination
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
    # Create a new user
    createUser(input: CreateUserInput!): User!

    # Update a user
    updateUser(id: ID!, input: UpdateUserInput!): User!

    # Delete a user
    deleteUser(id: ID!): Boolean!

    # Change a user's role (admin only)
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

// Validation schemas
const createUserSchema = z.object({
  email: z.string().email('Invalid email'),
  name: z.string().min(2).max(100).optional(),
  role: z.enum(['ADMIN', 'USER', 'GUEST']).default('USER'),
});

const updateUserSchema = z.object({
  email: z.string().email('Invalid email').optional(),
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
        throw new GraphQLError('Not authenticated', {
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

      // Build the filter
      const where = {
        ...(filter?.search && {
          OR: [
            { name: { contains: filter.search, mode: 'insensitive' as const } },
            { email: { contains: filter.search, mode: 'insensitive' as const } },
          ],
        }),
        ...(filter?.role && { role: filter.role }),
      };

      // Sort order
      const orderBy = sort
        ? { [sort.field.toLowerCase()]: sort.order.toLowerCase() }
        : { createdAt: 'desc' as const };

      // Queries
      const [users, totalCount] = await Promise.all([
        prisma.user.findMany({
          where,
          take: take + 1, // +1 to know if there is a next page
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

      // Check that the email does not already exist
      const existing = await prisma.user.findUnique({
        where: { email: data.email },
      });

      if (existing) {
        throw new GraphQLError('A user with this email already exists', {
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
        throw new GraphQLError('Not authenticated', {
          extensions: { code: 'UNAUTHENTICATED' },
        });
      }

      // Validation
      const data = updateUserSchema.parse(input);

      // Check that the user exists
      const existing = await prisma.user.findUnique({ where: { id } });

      if (!existing) {
        throw new GraphQLError('User not found', {
          extensions: { code: 'NOT_FOUND' },
        });
      }

      // Check permissions (self or admin)
      if (existing.id !== user.id && user.role !== 'ADMIN') {
        throw new GraphQLError('Not authorized', {
          extensions: { code: 'FORBIDDEN' },
        });
      }

      // Check email uniqueness if changed
      if (data.email && data.email !== existing.email) {
        const emailExists = await prisma.user.findUnique({
          where: { email: data.email },
        });
        if (emailExists) {
          throw new GraphQLError('This email is already in use', {
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
        throw new GraphQLError('Not authorized', {
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
        throw new GraphQLError('Only admins can change roles', {
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
      // Use DataLoader to avoid N+1
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
  // Load users by ID (to avoid N+1 on author)
  userById: new DataLoader<string, any>(async (ids) => {
    const users = await prisma.user.findMany({
      where: { id: { in: [...ids] } },
    });

    const userMap = new Map(users.map((u) => [u.id, u]));
    return ids.map((id) => userMap.get(id) || null);
  }),

  // Load posts by authorId (for the posts field resolver)
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
  // Extract the token from the Authorization header
  const token = req.headers.authorization?.replace('Bearer ', '');

  let user = null;
  if (token) {
    try {
      user = verifyToken(token);
    } catch {
      // Invalid token, user stays null
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
      // Log the full error on the server side
      console.error('GraphQL Error:', error);

      // Do not expose internal error details in production
      if (process.env.NODE_ENV === 'production') {
        if (formattedError.extensions?.code === 'INTERNAL_SERVER_ERROR') {
          return {
            message: 'An internal error occurred',
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

## Example queries

### Query

```graphql
# Get the currently logged-in user
query Me {
  me {
    id
    email
    name
    role
    postsCount
  }
}

# List with pagination and filters
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

## Key points

| Aspect | Implementation |
|--------|----------------|
| **Pagination** | Cursor-based (Relay style) |
| **N+1** | DataLoader for relations |
| **Validation** | Zod inside the resolvers |
| **Errors** | `GraphQLError` with codes |
| **Auth** | Context with user and loaders |

## Related commands

- `/dev:dev-test` - Generate resolver tests
- `/qa:qa-security` - GraphQL security audit
- `/doc:doc-api-spec` - Schema documentation

---

:::tip Codegen
Use `graphql-codegen` to generate the TypeScript types from the schema:
```bash
npx graphql-codegen
```
:::
