---
name: dev-graphql
description: GraphQL API development. Trigger when the user wants to create schemas, resolvers, or GraphQL queries.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
---

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
