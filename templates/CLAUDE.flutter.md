# Projet Flutter Mobile

> Application mobile cross-platform avec Flutter, Supabase backend et support GraphQL.

## Commandes Essentielles
- `flutter pub get` - Installer les dépendances
- `flutter run` - Lancer sur device/émulateur connecté
- `flutter run -d chrome` - Lancer en mode web
- `flutter test` - Tests unitaires et widget
- `flutter test --coverage` - Tests avec couverture
- `flutter analyze` - Analyser le code (lint)
- `dart fix --apply` - Corriger automatiquement les issues
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS (nécessite macOS)
- `flutter build web` - Build web
- `flutter gen-l10n` - Générer les traductions
- `dart run build_runner build` - Générer le code (freezed, json_serializable)

## Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée
├── app.dart                  # MaterialApp configuration
├── /core
│   ├── /constants           # Constantes globales
│   ├── /errors              # Classes d'erreur personnalisées
│   ├── /network             # Configuration réseau (Dio, interceptors)
│   └── /utils               # Fonctions utilitaires
├── /features
│   └── /[feature_name]
│       ├── /data
│       │   ├── /datasources  # Sources de données (API, local)
│       │   ├── /models       # Modèles de données (JSON serialization)
│       │   └── /repositories # Implémentation repositories
│       ├── /domain
│       │   ├── /entities     # Entités métier (immutables)
│       │   ├── /repositories # Interfaces repositories (abstraites)
│       │   └── /usecases     # Cas d'utilisation
│       └── /presentation
│           ├── /bloc         # BLoC/Cubit (state management)
│           ├── /pages        # Écrans/Pages
│           └── /widgets      # Widgets spécifiques à la feature
├── /shared
│   ├── /widgets             # Widgets réutilisables globaux
│   └── /theme               # Theme, couleurs, typography
├── /l10n                    # Fichiers de traduction (ARB)
└── /config
    ├── routes.dart          # Configuration GoRouter
    └── injection.dart       # Dependency injection (get_it)

test/
├── /unit                    # Tests unitaires
├── /widget                  # Tests de widgets
├── /integration             # Tests d'intégration
└── /golden                  # Golden tests (screenshots)
```

## Conventions Dart/Flutter

### Nommage
| Type | Convention | Exemple |
|------|------------|---------|
| Classes/Widgets | PascalCase | `UserProfileCard` |
| Fichiers | snake_case | `user_profile_card.dart` |
| Variables/Fonctions | camelCase | `getUserById()` |
| Constantes | lowerCamelCase ou kPrefix | `maxRetryCount`, `kApiBaseUrl` |
| Privé | underscore prefix | `_privateMethod()` |
| Packages | snake_case | `my_awesome_package` |

### Règles Dart
- IMPORTANT: Null safety obligatoire - éviter `!` sauf cas justifié
- IMPORTANT: Utiliser `const` constructors partout où possible
- YOU MUST typer explicitement les génériques (`List<User>` pas `List`)
- YOU MUST séparer UI, logique et données (Clean Architecture)
- Préférer `final` à `var` quand la variable n'est pas réassignée
- Utiliser les records et patterns Dart 3+ quand approprié

### Widget Best Practices
```dart
// BIEN: Widget avec const constructor et props typées
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
  });

  final User user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
        onTap: onTap,
      ),
    );
  }
}

// MAUVAIS: Pas de const, props mal typées
class BadUserCard extends StatelessWidget {
  BadUserCard(this.user, this.onTap); // Pas de const, pas de key

  var user; // Pas typé
  var onTap;
  // ...
}
```

## State Management (BLoC)

### Structure BLoC recommandée
```dart
// events/user_event.dart
sealed class UserEvent {}

final class LoadUser extends UserEvent {
  const LoadUser(this.userId);
  final String userId;
}

final class UpdateUser extends UserEvent {
  const UpdateUser(this.user);
  final User user;
}

// states/user_state.dart
sealed class UserState {}

final class UserInitial extends UserState {}
final class UserLoading extends UserState {}
final class UserLoaded extends UserState {
  const UserLoaded(this.user);
  final User user;
}
final class UserError extends UserState {
  const UserError(this.message);
  final String message;
}

// bloc/user_bloc.dart
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this._getUserUseCase) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
  }

  final GetUserUseCase _getUserUseCase;

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    final result = await _getUserUseCase(event.userId);
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user)),
    );
  }
}
```

### Usage dans les widgets
```dart
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserBloc>()..add(LoadUser(userId)),
      child: const UserProfileView(),
    );
  }
}

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return switch (state) {
            UserInitial() => const SizedBox.shrink(),
            UserLoading() => const Center(child: CircularProgressIndicator()),
            UserLoaded(:final user) => UserContent(user: user),
            UserError(:final message) => ErrorView(message: message),
          };
        },
      ),
    );
  }
}
```

## Intégration Supabase

### Configuration
```dart
// main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const MyApp());
}

// Accès global
final supabase = Supabase.instance.client;
```

### Exemple Repository avec Supabase
```dart
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', id)
          .single();
      return Right(UserModel.fromJson(data).toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

## Tests Flutter

### Widget Test
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserCard', () {
    testWidgets('displays user name and email', (tester) async {
      final user = User(name: 'John', email: 'john@example.com');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: UserCard(user: user)),
        ),
      );

      expect(find.text('John'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('calls onTap when pressed', (tester) async {
      var tapped = false;
      final user = User(name: 'John', email: 'john@example.com');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserCard(user: user, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(UserCard));
      expect(tapped, isTrue);
    });
  });
}
```

### BLoC Test
```dart
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('UserBloc', () {
    late MockGetUserUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockGetUserUseCase();
    });

    blocTest<UserBloc, UserState>(
      'emits [Loading, Loaded] when LoadUser succeeds',
      build: () {
        when(() => mockUseCase('123'))
            .thenAnswer((_) async => Right(testUser));
        return UserBloc(mockUseCase);
      },
      act: (bloc) => bloc.add(const LoadUser('123')),
      expect: () => [
        UserLoading(),
        isA<UserLoaded>().having((s) => s.user, 'user', testUser),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [Loading, Error] when LoadUser fails',
      build: () {
        when(() => mockUseCase('123'))
            .thenAnswer((_) async => Left(ServerFailure('Not found')));
        return UserBloc(mockUseCase);
      },
      act: (bloc) => bloc.add(const LoadUser('123')),
      expect: () => [
        UserLoading(),
        isA<UserError>().having((s) => s.message, 'message', 'Not found'),
      ],
    );
  });
}
```

## Git & Commits
- Format: `type(scope): description`
- Types: feat, fix, style, refactor, test, chore, perf
- Scope: feature name ou widget name
- Exemple: `feat(auth): add Google OAuth login`

## Hooks Claude Code 2.1+

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Bloque les modifications sur main/master |
| Dart format | PostToolUse | `dart format` sur fichiers modifiés |
| Flutter analyze | PostToolUse | `flutter analyze` après édition |
| Test avant commit | PreToolUse | Exécute `flutter test` avant commit |
| Détection secrets | PreToolUse | Bloque les secrets hardcodés |

## Skills disponibles

| Skill | Déclenchement | Usage |
|-------|---------------|-------|
| `exploring-codebase` | "explorer", "comprendre" | Analyser un codebase existant |
| `planning-implementation` | "planifier", "architecture" | Définir un plan avant de coder |
| `test-driven-development` | "TDD", "test first" | Cycle Red-Green-Refactor |
| `reviewing-code` | "review", "vérifier" | Revue de code approfondie |
| `debugging-issues` | "debug", "bug", "erreur" | Diagnostic méthodique |
| `generating-commit-messages` | "commit", "message" | Conventional Commits |
| `creating-pull-requests` | "PR", "pull request" | PR complète et documentée |

## Dépendances Recommandées

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_bloc: ^8.1.0
  # Dependency Injection
  get_it: ^7.6.0
  injectable: ^2.3.0
  # Functional Programming
  dartz: ^0.10.1
  # Networking
  dio: ^5.4.0
  # Backend
  supabase_flutter: ^2.3.0
  # Navigation
  go_router: ^13.0.0
  # Utils
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  injectable_generator: ^2.4.0
  flutter_lints: ^3.0.0
```

## Anti-patterns à éviter

- NEVER mettre de logique métier dans les widgets
- NEVER utiliser `dynamic` sauf pour JSON parsing
- NEVER oublier de dispose les controllers/streams
- NEVER hardcoder les strings (utiliser l10n)
- Éviter les `!` (null assertion) - préférer le pattern matching
- Éviter les widgets trop profondément imbriqués (extraire en sous-widgets)
