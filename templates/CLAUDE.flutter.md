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

## Gestion des Environnements

### Configuration par environnement
```dart
// lib/config/env.dart
enum Environment { dev, staging, prod }

class EnvConfig {
  static late Environment current;

  static String get supabaseUrl => switch (current) {
    Environment.dev => 'https://xxx.supabase.co',
    Environment.staging => 'https://yyy.supabase.co',
    Environment.prod => 'https://zzz.supabase.co',
  };

  static String get supabaseAnonKey => switch (current) {
    Environment.dev => const String.fromEnvironment('SUPABASE_ANON_KEY_DEV'),
    Environment.staging => const String.fromEnvironment('SUPABASE_ANON_KEY_STAGING'),
    Environment.prod => const String.fromEnvironment('SUPABASE_ANON_KEY_PROD'),
  };
}
```

### Lancement par environnement
```bash
# Développement
flutter run --dart-define=ENV=dev --dart-define=SUPABASE_ANON_KEY_DEV=xxx

# Staging
flutter run --dart-define=ENV=staging --dart-define=SUPABASE_ANON_KEY_STAGING=yyy

# Production
flutter build apk --dart-define=ENV=prod --dart-define=SUPABASE_ANON_KEY_PROD=zzz
```

### Fichiers .env (avec flutter_dotenv)
```yaml
# .env.dev
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx

# .env.prod
SUPABASE_URL=https://zzz.supabase.co
SUPABASE_ANON_KEY=zzz
```

## CI/CD Flutter (GitHub Actions)

### Workflow de base
```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze --fatal-infos

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          cache: true

      - name: Build APK
        run: flutter build apk --release
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          cache: true

      - name: Build iOS (no codesign)
        run: flutter build ios --release --no-codesign
```

### Cache des dépendances
```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.pub-cache
      .dart_tool
    key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}
```

## Distribution (Stores)

### Android - Google Play Store

#### Préparation
```bash
# 1. Générer une keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload

# 2. Créer key.properties (NE PAS COMMITER)
# android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

#### Configuration Gradle
```groovy
// android/app/build.gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### Build et upload
```bash
# Build App Bundle (recommandé pour Play Store)
flutter build appbundle --release

# Upload via fastlane ou manuellement
# Le fichier est dans build/app/outputs/bundle/release/app-release.aab
```

### iOS - App Store

#### Préparation
1. Compte Apple Developer ($99/an)
2. Certificat de distribution dans Keychain
3. Provisioning profile dans Xcode

#### Configuration Xcode
```bash
# Ouvrir dans Xcode
open ios/Runner.xcworkspace
```
- Product → Scheme → Edit Scheme → Archive → Build Configuration: Release
- Signing & Capabilities → Team: Votre équipe
- Bundle Identifier: com.votrecompany.votreapp

#### Build et upload
```bash
# Build IPA
flutter build ipa --release

# Ou via Xcode: Product → Archive → Distribute App
```

### Fastlane (automatisation)
```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Push a new release build to TestFlight"
  lane :beta do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_testflight
  end
end
```

```ruby
# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to Play Store internal track"
  lane :internal do
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
end
```

## Push Notifications

### Configuration Firebase Cloud Messaging (FCM)

#### Installation
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
```

#### Configuration
```dart
// lib/core/notifications/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Traitement en background
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Demander permission (iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Récupérer le token FCM
      final token = await _messaging.getToken();
      // Envoyer au backend pour associer à l'utilisateur
      await _saveTokenToBackend(token);

      // Écouter les changements de token
      _messaging.onTokenRefresh.listen(_saveTokenToBackend);
    }

    // Handler background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handler foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handler quand l'app est ouverte via notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Afficher notification locale ou snackbar
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigation vers la page appropriée
  }

  Future<void> _saveTokenToBackend(String? token) async {
    if (token != null) {
      // Sauvegarder via Supabase ou API
    }
  }
}
```

#### Configuration Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <application>
    <!-- Channel par défaut -->
    <meta-data
      android:name="com.google.firebase.messaging.default_notification_channel_id"
      android:value="high_importance_channel" />
  </application>
</manifest>
```

#### Configuration iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

### Notifications locales (flutter_local_notifications)
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Gérer le tap
  }
}
```

## Performance et Optimisation

### Taille de l'APK
```bash
# Analyser la taille
flutter build apk --analyze-size

# Build avec split par ABI (réduit ~60%)
flutter build apk --split-per-abi

# Build optimisé
flutter build apk --release --shrink --obfuscate --split-debug-info=./debug-info
```

### Optimisation des images
```yaml
# pubspec.yaml - utiliser des assets optimisés
flutter:
  assets:
    - assets/images/1.5x/
    - assets/images/2.0x/
    - assets/images/3.0x/
```

### Lazy loading
```dart
// Charger les modules à la demande
final widget = await loadLibrary(() => import('package:heavy_feature/heavy_feature.dart'));
```

### Checklist performance
- [ ] Utiliser `const` constructors partout
- [ ] Éviter `setState` dans les boucles
- [ ] Utiliser `ListView.builder` pour les longues listes
- [ ] Implémenter pagination pour les données
- [ ] Compresser les images avant upload
- [ ] Utiliser le cache réseau (cached_network_image)
- [ ] Profile avec DevTools (flutter pub global run devtools)

## Anti-patterns à éviter

- NEVER mettre de logique métier dans les widgets
- NEVER utiliser `dynamic` sauf pour JSON parsing
- NEVER oublier de dispose les controllers/streams
- NEVER hardcoder les strings (utiliser l10n)
- NEVER stocker les secrets dans le code (utiliser --dart-define)
- NEVER ignorer les permissions iOS (Info.plist)
- Éviter les `!` (null assertion) - préférer le pattern matching
- Éviter les widgets trop profondément imbriqués (extraire en sous-widgets)
