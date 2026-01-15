# Agent DEV-GRAPHQL

Concevoir et implémenter des APIs GraphQL avec client Flutter.

## Contexte
$ARGUMENTS

## Schema Design

### 1. Types de base

```graphql
# Scalaires personnalisés
scalar DateTime
scalar JSON
scalar UUID

# Types
type User {
  id: ID!
  email: String!
  name: String!
  avatarUrl: String
  bio: String
  posts: [Post!]!
  comments: [Comment!]!
  followers: [User!]!
  following: [User!]!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  excerpt: String
  coverImage: String
  published: Boolean!
  author: User!
  comments: [Comment!]!
  tags: [Tag!]!
  viewCount: Int!
  createdAt: DateTime!
  updatedAt: DateTime!
}

type Comment {
  id: ID!
  content: String!
  author: User!
  post: Post!
  parent: Comment
  replies: [Comment!]!
  createdAt: DateTime!
}

type Tag {
  id: ID!
  name: String!
  slug: String!
  posts: [Post!]!
}
```

### 2. Input types

```graphql
# Inputs pour création/modification
input CreateUserInput {
  email: String!
  name: String!
  password: String!
  bio: String
}

input UpdateUserInput {
  name: String
  bio: String
  avatarUrl: String
}

input CreatePostInput {
  title: String!
  content: String!
  excerpt: String
  coverImage: String
  published: Boolean = false
  tagIds: [ID!]
}

input UpdatePostInput {
  title: String
  content: String
  excerpt: String
  coverImage: String
  published: Boolean
  tagIds: [ID!]
}

# Inputs pour filtrage et pagination
input PostsFilterInput {
  authorId: ID
  published: Boolean
  tagId: ID
  search: String
}

input PaginationInput {
  limit: Int = 10
  offset: Int = 0
}

input PostsOrderByInput {
  field: PostOrderField!
  direction: OrderDirection!
}

enum PostOrderField {
  CREATED_AT
  UPDATED_AT
  VIEW_COUNT
  TITLE
}

enum OrderDirection {
  ASC
  DESC
}
```

### 3. Queries

```graphql
type Query {
  # Users
  me: User
  user(id: ID!): User
  users(
    filter: UsersFilterInput
    pagination: PaginationInput
  ): UsersConnection!

  # Posts
  post(id: ID!): Post
  postBySlug(slug: String!): Post
  posts(
    filter: PostsFilterInput
    orderBy: PostsOrderByInput
    pagination: PaginationInput
  ): PostsConnection!

  # Tags
  tag(id: ID!): Tag
  tags: [Tag!]!
}

# Pagination avec curseurs (Relay-style)
type PostsConnection {
  edges: [PostEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type PostEdge {
  node: Post!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}
```

### 4. Mutations

```graphql
type Mutation {
  # Auth
  signUp(input: CreateUserInput!): AuthPayload!
  signIn(email: String!, password: String!): AuthPayload!
  signOut: Boolean!
  refreshToken: AuthPayload!

  # Users
  updateProfile(input: UpdateUserInput!): User!
  deleteAccount: Boolean!
  followUser(userId: ID!): User!
  unfollowUser(userId: ID!): User!

  # Posts
  createPost(input: CreatePostInput!): Post!
  updatePost(id: ID!, input: UpdatePostInput!): Post!
  deletePost(id: ID!): Boolean!
  publishPost(id: ID!): Post!
  unpublishPost(id: ID!): Post!

  # Comments
  createComment(postId: ID!, content: String!, parentId: ID): Comment!
  updateComment(id: ID!, content: String!): Comment!
  deleteComment(id: ID!): Boolean!
}

type AuthPayload {
  user: User!
  accessToken: String!
  refreshToken: String!
}
```

### 5. Subscriptions

```graphql
type Subscription {
  # Temps réel
  postCreated: Post!
  postUpdated(id: ID!): Post!
  commentAdded(postId: ID!): Comment!
  userOnlineStatus(userId: ID!): OnlineStatus!
}

type OnlineStatus {
  userId: ID!
  isOnline: Boolean!
  lastSeen: DateTime
}
```

## Client Flutter

### 1. Configuration graphql_flutter

```dart
// lib/core/graphql/graphql_client.dart
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static late GraphQLClient _client;

  static Future<void> init() async {
    await initHiveForFlutter();

    final httpLink = HttpLink(
      const String.fromEnvironment('GRAPHQL_ENDPOINT'),
    );

    final authLink = AuthLink(
      getToken: () async {
        final token = await SecureStorage.getAccessToken();
        return token != null ? 'Bearer $token' : null;
      },
    );

    final wsLink = WebSocketLink(
      const String.fromEnvironment('GRAPHQL_WS_ENDPOINT'),
      config: SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: const Duration(seconds: 30),
        initialPayload: () async {
          final token = await SecureStorage.getAccessToken();
          return {'Authorization': 'Bearer $token'};
        },
      ),
    );

    final link = Link.split(
      (request) => request.isSubscription,
      wsLink,
      authLink.concat(httpLink),
    );

    _client = GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    );
  }

  static GraphQLClient get client => _client;

  static ValueNotifier<GraphQLClient> get clientNotifier =>
      ValueNotifier(_client);
}
```

### 2. Provider setup

```dart
// lib/app.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLService.clientNotifier,
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
      ),
    );
  }
}
```

### 3. Queries

```dart
// lib/features/posts/data/graphql/posts_queries.dart

const String getPostsQuery = r'''
  query GetPosts($filter: PostsFilterInput, $pagination: PaginationInput) {
    posts(filter: $filter, pagination: $pagination) {
      edges {
        node {
          id
          title
          excerpt
          coverImage
          published
          createdAt
          author {
            id
            name
            avatarUrl
          }
          tags {
            id
            name
          }
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
''';

const String getPostQuery = r'''
  query GetPost($id: ID!) {
    post(id: $id) {
      id
      title
      content
      coverImage
      published
      createdAt
      updatedAt
      viewCount
      author {
        id
        name
        avatarUrl
        bio
      }
      tags {
        id
        name
        slug
      }
      comments {
        id
        content
        createdAt
        author {
          id
          name
          avatarUrl
        }
      }
    }
  }
''';
```

### 4. Mutations

```dart
// lib/features/posts/data/graphql/posts_mutations.dart

const String createPostMutation = r'''
  mutation CreatePost($input: CreatePostInput!) {
    createPost(input: $input) {
      id
      title
      content
      published
      createdAt
    }
  }
''';

const String updatePostMutation = r'''
  mutation UpdatePost($id: ID!, $input: UpdatePostInput!) {
    updatePost(id: $id, input: $input) {
      id
      title
      content
      published
      updatedAt
    }
  }
''';

const String deletePostMutation = r'''
  mutation DeletePost($id: ID!) {
    deletePost(id: $id)
  }
''';
```

### 5. Usage dans les widgets

```dart
// Query widget
class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: Query(
        options: QueryOptions(
          document: gql(getPostsQuery),
          variables: const {
            'pagination': {'limit': 20, 'offset': 0},
          },
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading && result.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return ErrorView(
              message: result.exception.toString(),
              onRetry: refetch,
            );
          }

          final posts = (result.data!['posts']['edges'] as List)
              .map((e) => PostModel.fromJson(e['node']))
              .toList();

          final pageInfo = result.data!['posts']['pageInfo'];

          return RefreshIndicator(
            onRefresh: () async => refetch?.call(),
            child: ListView.builder(
              itemCount: posts.length + (pageInfo['hasNextPage'] ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  return LoadMoreButton(
                    onPressed: () => fetchMore?.call(
                      FetchMoreOptions(
                        variables: {
                          'pagination': {
                            'limit': 20,
                            'offset': posts.length,
                          },
                        },
                        updateQuery: (previous, fetchMore) {
                          final newEdges = fetchMore?['posts']['edges'] ?? [];
                          return {
                            'posts': {
                              ...fetchMore!['posts'],
                              'edges': [
                                ...previous!['posts']['edges'],
                                ...newEdges,
                              ],
                            },
                          };
                        },
                      ),
                    ),
                  );
                }
                return PostCard(post: posts[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
```

```dart
// Mutation widget
class CreatePostButton extends StatelessWidget {
  const CreatePostButton({super.key, required this.input});

  final CreatePostInput input;

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(createPostMutation),
        onCompleted: (data) {
          if (data != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post créé avec succès')),
            );
            context.pop();
          }
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${error?.graphqlErrors.first.message}')),
          );
        },
        update: (cache, result) {
          // Invalider le cache des posts
          cache.writeQuery(
            Request(operation: Operation(document: gql(getPostsQuery))),
            data: null,
          );
        },
      ),
      builder: (runMutation, result) {
        return ElevatedButton(
          onPressed: result?.isLoading == true
              ? null
              : () => runMutation({'input': input.toJson()}),
          child: result?.isLoading == true
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Créer'),
        );
      },
    );
  }
}
```

### 6. Subscriptions

```dart
class CommentsSubscription extends StatelessWidget {
  const CommentsSubscription({
    super.key,
    required this.postId,
    required this.builder,
  });

  final String postId;
  final Widget Function(List<CommentModel>) builder;

  @override
  Widget build(BuildContext context) {
    return Subscription(
      options: SubscriptionOptions(
        document: gql(r'''
          subscription OnCommentAdded($postId: ID!) {
            commentAdded(postId: $postId) {
              id
              content
              createdAt
              author {
                id
                name
                avatarUrl
              }
            }
          }
        '''),
        variables: {'postId': postId},
      ),
      builder: (result) {
        if (result.hasException) {
          return ErrorView(message: result.exception.toString());
        }

        if (result.data == null) {
          return const SizedBox.shrink();
        }

        final comment = CommentModel.fromJson(result.data!['commentAdded']);
        // Ajouter au state local ou utiliser un BLoC
        return builder([comment]);
      },
    );
  }
}
```

## Codegen (ferry - recommandé)

### 1. Configuration

```yaml
# build.yaml
targets:
  $default:
    builders:
      ferry_generator|graphql_builder:
        enabled: true
        options:
          schema: lib/graphql/schema.graphql
          queries_glob: lib/**/*.graphql
          output_dir: lib/graphql/__generated__
          type_overrides:
            DateTime: DateTime
            UUID: String
```

```yaml
# pubspec.yaml
dependencies:
  ferry: ^0.14.0
  gql_http_link: ^1.0.0

dev_dependencies:
  ferry_generator: ^0.8.0
  build_runner: ^2.4.0
```

### 2. Fichiers .graphql

```graphql
# lib/features/posts/data/graphql/get_posts.graphql
query GetPosts($filter: PostsFilterInput, $pagination: PaginationInput) {
  posts(filter: $filter, pagination: $pagination) {
    edges {
      node {
        ...PostFragment
      }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}

fragment PostFragment on Post {
  id
  title
  excerpt
  coverImage
  createdAt
  author {
    ...AuthorFragment
  }
}

fragment AuthorFragment on User {
  id
  name
  avatarUrl
}
```

### 3. Usage avec types générés

```dart
import 'package:ferry/ferry.dart';
import '__generated__/get_posts.req.gql.dart';
import '__generated__/get_posts.data.gql.dart';

class PostsRepository {
  PostsRepository(this._client);

  final Client _client;

  Stream<OperationResponse<GGetPostsData, GGetPostsVars>> getPosts({
    int limit = 20,
    int offset = 0,
  }) {
    final request = GGetPostsReq(
      (b) => b
        ..vars.pagination.limit = limit
        ..vars.pagination.offset = offset,
    );

    return _client.request(request);
  }
}
```

## Error Handling

```dart
// lib/core/graphql/graphql_error_handler.dart

sealed class GraphQLFailure {
  const GraphQLFailure(this.message);
  final String message;
}

class NetworkFailure extends GraphQLFailure {
  const NetworkFailure(super.message);
}

class AuthenticationFailure extends GraphQLFailure {
  const AuthenticationFailure(super.message);
}

class ValidationFailure extends GraphQLFailure {
  const ValidationFailure(super.message, this.errors);
  final Map<String, List<String>> errors;
}

class ServerFailure extends GraphQLFailure {
  const ServerFailure(super.message, {this.code});
  final String? code;
}

GraphQLFailure parseGraphQLError(OperationException exception) {
  // Erreur réseau
  if (exception.linkException != null) {
    return NetworkFailure(exception.linkException.toString());
  }

  // Erreurs GraphQL
  final errors = exception.graphqlErrors;
  if (errors.isEmpty) {
    return const ServerFailure('Unknown error');
  }

  final firstError = errors.first;
  final code = firstError.extensions?['code'] as String?;

  return switch (code) {
    'UNAUTHENTICATED' => AuthenticationFailure(firstError.message),
    'VALIDATION_ERROR' => ValidationFailure(
        firstError.message,
        (firstError.extensions?['errors'] as Map?)?.cast() ?? {},
      ),
    _ => ServerFailure(firstError.message, code: code),
  };
}
```

## Caching

```dart
// Politiques de cache
QueryOptions(
  document: gql(query),
  // Stratégies disponibles:
  fetchPolicy: FetchPolicy.cacheFirst,      // Cache d'abord, puis réseau si absent
  // FetchPolicy.cacheAndNetwork,            // Cache + réseau en parallèle
  // FetchPolicy.networkOnly,                // Réseau uniquement
  // FetchPolicy.cacheOnly,                  // Cache uniquement
  // FetchPolicy.noCache,                    // Pas de cache
);

// Invalidation manuelle
final cache = GraphQLProvider.of(context).value.cache;

// Effacer une query spécifique
cache.writeQuery(
  Request(operation: Operation(document: gql(getPostsQuery))),
  data: null,
);

// Effacer tout le cache
await cache.store.reset();
```

## Checklist qualité

- [ ] Schema bien typé (pas de `String` pour les IDs, utiliser `ID!`)
- [ ] Input types pour toutes les mutations
- [ ] Pagination implémentée (offset ou cursor-based)
- [ ] Gestion des erreurs (network, auth, validation, server)
- [ ] Cache configuré avec politique appropriée
- [ ] Subscriptions avec reconnection automatique
- [ ] Variables utilisées (jamais d'interpolation de strings)

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev-flutter` | Widgets et screens |
| `/dev-supabase` | Alternative/complément Supabase |
| `/dev-api` | Design d'API REST |
| `/doc-api-spec` | Documentation OpenAPI |

---

IMPORTANT: Toujours utiliser des variables GraphQL - jamais de string interpolation.

YOU MUST implémenter la gestion des erreurs GraphQL (network + business).

NEVER exposer de données sensibles dans les queries côté client.

Think hard sur le schema avant d'implémenter - c'est le contrat d'API.
