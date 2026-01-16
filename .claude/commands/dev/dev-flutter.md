# Agent DEV-FLUTTER

Créer des widgets, screens et features Flutter avec Clean Architecture.

## Contexte
$ARGUMENTS

## Processus de création

### 1. Définir le composant

#### Questions clés
- Type de composant (Widget simple, Screen, Feature complète) ?
- Props/paramètres attendus ?
- State management nécessaire (BLoC, Cubit, none) ?
- Intégration API (Supabase, GraphQL, REST) ?
- Animations requises ?

### 2. Structure par type

#### Widget simple
```
lib/shared/widgets/[widget_name]/
├── [widget_name].dart        # Widget principal
└── [widget_name]_test.dart   # Tests widget
```

#### Screen avec BLoC
```
lib/features/[feature]/presentation/
├── /bloc
│   ├── [feature]_bloc.dart   # BLoC
│   ├── [feature]_event.dart  # Events
│   └── [feature]_state.dart  # States
├── /pages
│   └── [feature]_page.dart   # Page/Screen
└── /widgets
    └── [widget_name].dart    # Widgets spécifiques
```

#### Feature complète (Clean Architecture)
```
lib/features/[feature]/
├── /data
│   ├── /datasources
│   │   ├── [feature]_remote_datasource.dart
│   │   └── [feature]_local_datasource.dart
│   ├── /models
│   │   └── [feature]_model.dart
│   └── /repositories
│       └── [feature]_repository_impl.dart
├── /domain
│   ├── /entities
│   │   └── [feature]_entity.dart
│   ├── /repositories
│   │   └── [feature]_repository.dart
│   └── /usecases
│       └── get_[feature]_usecase.dart
└── /presentation
    ├── /bloc
    ├── /pages
    └── /widgets
```

### 3. Templates

#### StatelessWidget
```dart
import 'package:flutter/material.dart';

/// [Description du widget]
///
/// Exemple:
/// ```dart
/// CustomButton(
///   label: 'Submit',
///   onPressed: () => print('Pressed'),
/// )
/// ```
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
  });

  /// Label du bouton
  final String label;

  /// Callback au clic
  final VoidCallback onPressed;

  /// Affiche un indicateur de chargement
  final bool isLoading;

  /// Variant visuel
  final ButtonVariant variant;

  /// Taille du bouton
  final ButtonSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: size.height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _buildStyle(theme),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Text(label),
      ),
    );
  }

  ButtonStyle _buildStyle(ThemeData theme) {
    return switch (variant) {
      ButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
        ),
      ButtonVariant.outline => ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary),
        ),
    };
  }
}

enum ButtonVariant { primary, secondary, outline }

enum ButtonSize {
  small(36),
  medium(44),
  large(52);

  const ButtonSize(this.height);
  final double height;
}
```

#### StatefulWidget (avec animations)
```dart
class AnimatedCard extends StatefulWidget {
  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(child: widget.child),
      ),
    );
  }
}
```

#### Screen avec BLoC
```dart
// [feature]_page.dart
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserProfileBloc>()..add(LoadUserProfile(userId)),
      child: const UserProfileView(),
    );
  }
}

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            UserProfileInitial() => const SizedBox.shrink(),
            UserProfileLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            UserProfileLoaded(:final user) => UserProfileContent(user: user),
            UserProfileError(:final message) => ErrorView(
                message: message,
                onRetry: () => context
                    .read<UserProfileBloc>()
                    .add(const RefreshUserProfile()),
              ),
          };
        },
      ),
    );
  }
}
```

#### BLoC complet
```dart
// events
sealed class UserProfileEvent {}

final class LoadUserProfile extends UserProfileEvent {
  LoadUserProfile(this.userId);
  final String userId;
}

final class RefreshUserProfile extends UserProfileEvent {
  const RefreshUserProfile();
}

final class UpdateUserProfile extends UserProfileEvent {
  UpdateUserProfile(this.user);
  final User user;
}

// states
sealed class UserProfileState {}

final class UserProfileInitial extends UserProfileState {}

final class UserProfileLoading extends UserProfileState {}

final class UserProfileLoaded extends UserProfileState {
  UserProfileLoaded(this.user);
  final User user;
}

final class UserProfileError extends UserProfileState {
  UserProfileError(this.message);
  final String message;
}

// bloc
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc({
    required GetUserUseCase getUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
  })  : _getUserUseCase = getUserUseCase,
        _updateUserUseCase = updateUserUseCase,
        super(UserProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<RefreshUserProfile>(_onRefreshUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  final GetUserUseCase _getUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  String? _currentUserId;

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(UserProfileLoading());

    final result = await _getUserUseCase(event.userId);
    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (user) => emit(UserProfileLoaded(user)),
    );
  }

  Future<void> _onRefreshUserProfile(
    RefreshUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    if (_currentUserId == null) return;
    add(LoadUserProfile(_currentUserId!));
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    final result = await _updateUserUseCase(event.user);
    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (user) => emit(UserProfileLoaded(user)),
    );
  }
}
```

### 4. Intégration API

#### Avec Supabase
```dart
class UserRemoteDataSource {
  UserRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<UserModel> getUser(String id) async {
    final data = await _client
        .from('users')
        .select('*, profiles(*)')
        .eq('id', id)
        .single();
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateUser(UserModel user) async {
    final data = await _client
        .from('users')
        .update(user.toJson())
        .eq('id', user.id)
        .select()
        .single();
    return UserModel.fromJson(data);
  }

  Stream<UserModel> watchUser(String id) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) => UserModel.fromJson(data.first));
  }
}
```

#### Avec GraphQL
```dart
class UserRemoteDataSource {
  UserRemoteDataSource(this._client);

  final GraphQLClient _client;

  Future<UserModel> getUser(String id) async {
    final result = await _client.query(
      QueryOptions(
        document: gql('''
          query GetUser(\$id: ID!) {
            user(id: \$id) {
              id
              name
              email
              avatarUrl
              createdAt
            }
          }
        '''),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception.toString());
    }

    return UserModel.fromJson(result.data!['user']);
  }
}
```

### 5. Tests

#### Widget Test
```dart
void main() {
  group('CustomButton', () {
    testWidgets('displays label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Submit',
              onPressed: _noOp,
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Submit',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Submit',
              onPressed: _noOp,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('does not call onPressed when isLoading', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              label: 'Submit',
              onPressed: () => pressed = true,
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton));
      expect(pressed, isFalse);
    });
  });
}

void _noOp() {}
```

#### BLoC Test
```dart
void main() {
  late MockGetUserUseCase mockGetUserUseCase;
  late UserProfileBloc bloc;

  setUp(() {
    mockGetUserUseCase = MockGetUserUseCase();
    bloc = UserProfileBloc(
      getUserUseCase: mockGetUserUseCase,
      updateUserUseCase: MockUpdateUserUseCase(),
    );
  });

  tearDown(() => bloc.close());

  group('UserProfileBloc', () {
    final testUser = User(id: '1', name: 'John', email: 'john@example.com');

    blocTest<UserProfileBloc, UserProfileState>(
      'emits [Loading, Loaded] when LoadUserProfile succeeds',
      build: () {
        when(() => mockGetUserUseCase('1'))
            .thenAnswer((_) async => Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadUserProfile('1')),
      expect: () => [
        isA<UserProfileLoading>(),
        isA<UserProfileLoaded>().having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<UserProfileBloc, UserProfileState>(
      'emits [Loading, Error] when LoadUserProfile fails',
      build: () {
        when(() => mockGetUserUseCase('1'))
            .thenAnswer((_) async => Left(ServerFailure('Not found')));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadUserProfile('1')),
      expect: () => [
        isA<UserProfileLoading>(),
        isA<UserProfileError>().having((s) => s.message, 'message', 'Not found'),
      ],
    );
  });
}
```

### 6. Navigation (GoRouter)

```dart
// config/routes.dart
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
      routes: [
        GoRoute(
          path: 'profile/:userId',
          builder: (_, state) => UserProfilePage(
            userId: state.pathParameters['userId']!,
          ),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (_, state) => EditProfilePage(
                userId: state.pathParameters['userId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = supabase.auth.currentUser != null;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoggingIn) return '/login';
    if (isLoggedIn && isLoggingIn) return '/';
    return null;
  },
);
```

### 7. Checklist qualité

- [ ] Widget avec `const` constructor
- [ ] Props typées et documentées (/// comments)
- [ ] Gestion des états (loading, error, empty, data)
- [ ] Utilisation de `switch` expressions pour les états
- [ ] Responsive (MediaQuery, LayoutBuilder si nécessaire)
- [ ] Accessibilité (Semantics labels)
- [ ] Tests widget (≥80% coverage)
- [ ] Tests BLoC si applicable
- [ ] Dispose des controllers/streams
- [ ] Pas de `!` (null assertion) - utiliser le pattern matching

## Output attendu

### Fichiers générés

Pour un widget simple:
- `[widget_name].dart`
- `[widget_name]_test.dart`

Pour une feature complète:
- Couche data (datasources, models, repository impl)
- Couche domain (entities, repository interface, usecases)
- Couche presentation (bloc, pages, widgets)
- Tests pour chaque couche

### Documentation
```markdown
## [WidgetName]

### Usage
```dart
[WidgetName](
  param1: value1,
  param2: value2,
  onEvent: () => handleEvent(),
)
```

### Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| param1 | String | required | Description |
| param2 | bool | false | Description |
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev-supabase` | Configuration backend Supabase |
| `/dev-graphql` | Intégration GraphQL |
| `/qa-mobile` | Audit performance et accessibilité mobile |
| `/qa-a11y` | Accessibilité approfondie |
| `/dev-test` | Tests complémentaires |

---

IMPORTANT: Toujours utiliser `const` constructors pour optimiser les rebuilds.

YOU MUST séparer la logique métier de la présentation (Clean Architecture).

NEVER mettre de logique métier dans les widgets - utiliser BLoC/UseCases.

Think hard sur la réutilisabilité du widget avant de coder.
