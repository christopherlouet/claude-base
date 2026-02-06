---
sidebar_position: 10
title: "dev-graphql"
description: "Developpement d'APIs GraphQL. Declencher quand l'utilisateur veut creer des schemas, resolvers, ou queries GraphQL."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-graphql

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Developpement d'APIs GraphQL. Declencher quand l'utilisateur veut creer des schemas, resolvers, ou queries GraphQL.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `dev`, `graphql` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux dev..."_
- _"Je veux graphql..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
