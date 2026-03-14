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
