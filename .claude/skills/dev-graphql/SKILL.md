---
name: dev-graphql
description: Developpement d'APIs GraphQL. Declencher quand l'utilisateur veut creer des schemas, resolvers, ou queries GraphQL.
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

// Dans le context
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
