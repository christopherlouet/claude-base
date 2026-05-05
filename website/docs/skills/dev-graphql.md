---
sidebar_position: 12
title: "dev-graphql"
description: "GraphQL API development. Trigger when the user wants to create schemas, resolvers, or GraphQL queries."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-graphql

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> GraphQL API development. Trigger when the user wants to create schemas, resolvers, or GraphQL queries.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Keywords** | `dev`, `graphql` |

## Detailed description

# GraphQL Development

## Schema Definition

```graphql
type User {
  id: ID!
  email: String!
  name: String!
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String
  author: User!
  published: Boolean!
}

type Query {
  user(id: ID!): User
  users(limit: Int, offset: Int): [User!]!
  post(id: ID!): Post
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
}

input CreateUserInput {
  email: String!
  name: String!
  password: String!
}
```

## Resolvers

```typescript
const resolvers = {
  Query: {
    user: (_, { id }, ctx) => ctx.userService.findById(id),
    users: (_, { limit, offset }, ctx) => ctx.userService.findAll({ limit, offset }),
  },

  Mutation: {
    createUser: (_, { input }, ctx) => ctx.userService.create(input),
  },

  User: {
    posts: (user, _, ctx) => ctx.postService.findByAuthor(user.id),
  },
};
```

## DataLoader (N+1 Prevention)

```typescript
import DataLoader from 'dataloader';

const userLoader = new DataLoader(async (ids: string[]) => {
  const users = await userService.findByIds(ids);
  return ids.map(id => users.find(u => u.id === id));
});

// In the context
context: ({ req }) => ({
  userLoader,
  postLoader: createPostLoader(),
});
```

## Client (Apollo)

```typescript
const GET_USER = gql`
  query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
      posts {
        id
        title
      }
    }
  }
`;

function UserProfile({ userId }) {
  const { data, loading, error } = useQuery(GET_USER, {
    variables: { id: userId }
  });

  if (loading) return <Loading />;
  if (error) return <Error message={error.message} />;

  return <Profile user={data.user} />;
}
```

## See also

Apollo GraphQL publishes their own official agent skills at [`apollographql/skills`](https://github.com/apollographql/skills) (maintained by the Apollo team, last commit 2026-05-04). The repo covers Apollo Client, Apollo Server 5, Apollo Connectors, Federation 2, and Apollo Kotlin — the **Apollo-specific** stack.

When working on a project that uses Apollo, install the vendor skill alongside this one. This skill captures the **stack-agnostic** angle (schema design, DataLoader, N+1 prevention, query depth limits, generic security) that complements Apollo's vendor-specific guidance. Both together is the recommended setup for Apollo users; for non-Apollo GraphQL stacks (Yoga, Pothos, Mercurius, Strawberry, gqlgen), this skill remains the primary reference.

Audit pilot trace: `specs/marketplace-audit/dev-skills-pilot-2026-05-05.md`.

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to dev..."_
- _"I want to graphql..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Example: GraphQL Schema + Resolvers + Queries

# Example: GraphQL Schema + Resolvers + Queries

## Scenario
A bookstore API with authors and books, including pagination and nested queries.

## Schema Definition

```graphql
# schema.graphql
type Query {
  book(id: ID!): Book
  books(first: Int = 10, after: String): BookConnection!
  author(id: ID!): Author
}

type Mutation {
  createBook(input: CreateBookInput!): Book!
}

type Book {
  id: ID!
  title: String!
  isbn: String!
  author: Author!
  publishedAt: DateTime
}

type Author {
  id: ID!
  name: String!
  books: [Book!]!
}

input CreateBookInput {
  title: String!
  isbn: String!
  authorId: ID!
}

type BookConnection {
  edges: [BookEdge!]!
  pageInfo: PageInfo!
}

type BookEdge {
  node: Book!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  endCursor: String
}
```

## Resolvers

```typescript
// resolvers/book.resolver.ts
export const bookResolvers = {
  Query: {
    book: async (_, { id }, { dataSources }) => {
      return dataSources.bookAPI.getById(id);
    },
    books: async (_, { first, after }, { dataSources }) => {
      return dataSources.bookAPI.getPaginated(first, after);
    },
  },

  Mutation: {
    createBook: async (_, { input }, { dataSources, user }) => {
      if (!user) throw new AuthenticationError('Login required');
      return dataSources.bookAPI.create(input);
    },
  },

  // Nested resolver: avoids N+1 with DataLoader
  Book: {
    author: async (book, _, { loaders }) => {
      return loaders.authorLoader.load(book.authorId);
    },
  },

  Author: {
    books: async (author, _, { dataSources }) => {
      return dataSources.bookAPI.getByAuthorId(author.id);
    },
  },
};
```

## Client Query

```graphql
# Fetch books with authors (single request, no over-fetching)
query GetBooks($first: Int!, $after: String) {
  books(first: $first, after: $after) {
    edges {
      node {
        id
        title
        author {
          name
        }
      }
      cursor
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

## Key Decisions

- **Relay-style pagination**: `Connection/Edge/PageInfo` pattern for cursor-based pagination
- **DataLoader for N+1**: `authorLoader.load()` batches author lookups into a single query
- **Input types for mutations**: Separate `CreateBookInput` keeps mutations clean and versionable
- **Auth in context**: User injected via context, checked in mutation resolvers
- **Nested resolvers**: `Book.author` resolved lazily, only when client requests it



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
