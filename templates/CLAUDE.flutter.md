# Flutter Mobile Project

> Cross-platform mobile application with Flutter, Supabase backend and GraphQL support.

## Essential Commands
- `flutter pub get` - Install dependencies
- `flutter run` - Launch on connected device/emulator
- `flutter run -d chrome` - Launch in web mode
- `flutter test` - Unit and widget tests
- `flutter test --coverage` - Tests with coverage
- `flutter analyze` - Analyze code (lint)
- `dart fix --apply` - Automatically fix issues
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS (requires macOS)
- `flutter build web` - Build web
- `flutter gen-l10n` - Generate translations
- `dart run build_runner build` - Generate code (freezed, json_serializable)

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp configuration
├── /core
│   ├── /constants           # Global constants
│   ├── /errors              # Custom error classes
│   ├── /network             # Network configuration (Dio, interceptors)
│   └── /utils               # Utility functions
├── /features
│   └── /[feature_name]
│       ├── /data
│       │   ├── /datasources  # Data sources (API, local)
│       │   ├── /models       # Data models (JSON serialization)
│       │   └── /repositories # Repositories implementation
│       ├── /domain
│       │   ├── /entities     # Business entities (immutable)
│       │   ├── /repositories # Repositories interfaces (abstract)
│       │   └── /usecases     # Use cases
│       └── /presentation
│           ├── /bloc         # BLoC/Cubit (state management)
│           ├── /pages        # Screens/Pages
│           └── /widgets      # Feature-specific widgets
├── /shared
│   ├── /widgets             # Globally reusable widgets
│   └── /theme               # Theme, colors, typography
├── /l10n                    # Translation files (ARB)
└── /config
    ├── routes.dart          # GoRouter configuration
    └── injection.dart       # Dependency injection (get_it)

test/
├── /unit                    # Unit tests
├── /widget                  # Widget tests
├── /integration             # Integration tests
└── /golden                  # Golden tests (screenshots)
```

## Dart/Flutter Conventions

### Naming
| Type | Convention | Example |
|------|------------|---------|
| Classes/Widgets | PascalCase | `UserProfileCard` |
| Files | snake_case | `user_profile_card.dart` |
| Variables/Functions | camelCase | `getUserById()` |
| Constants | lowerCamelCase or kPrefix | `maxRetryCount`, `kApiBaseUrl` |
| Private | underscore prefix | `_privateMethod()` |
| Packages | snake_case | `my_awesome_package` |

### Dart Rules
- IMPORTANT: Null safety mandatory - avoid `!` except in justified cases
- IMPORTANT: Use `const` constructors wherever possible
- YOU MUST explicitly type generics (`List<User>` not `List`)
- YOU MUST separate UI, logic and data (Clean Architecture)
- Prefer `final` over `var` when the variable is not reassigned
- Use Dart 3+ records and patterns when appropriate

### Widget Best Practices
```dart
// GOOD: Widget with const constructor and typed props
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

// BAD: No const, poorly typed props
class BadUserCard extends StatelessWidget {
  BadUserCard(this.user, this.onTap); // No const, no key

  var user; // Not typed
  var onTap;
  // ...
}
```

## State Management (BLoC)

### Recommended BLoC Structure
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

### Usage in Widgets
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

## Supabase Integration

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

// Global access
final supabase = Supabase.instance.client;
```

### Repository Example with Supabase
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

## Flutter Tests

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
- Scope: feature name or widget name
- Example: `feat(auth): add Google OAuth login`

## Claude Code 2.1+ Hooks

| Hook | Type | Action |
|------|------|--------|
| Branch protection | PreToolUse | Blocks modifications on main/master |
| Dart format | PostToolUse | `dart format` on modified files |
| Flutter analyze | PostToolUse | `flutter analyze` after editing |
| Test before commit | PreToolUse | Runs `flutter test` before commit |
| Secret detection | PreToolUse | Blocks hardcoded secrets |

## Available Skills

| Skill | Trigger | Usage |
|-------|---------------|-------|
| `exploring-codebase` | "explore", "understand" | Analyze an existing codebase |
| `planning-implementation` | "plan", "architecture" | Define a plan before coding |
| `test-driven-development` | "TDD", "test first" | Red-Green-Refactor cycle |
| `qa-review` | "review", "verify" | In-depth code review |
| `debugging-issues` | "debug", "bug", "error" | Methodical diagnosis |
| `generating-commit-messages` | "commit", "message" | Conventional Commits |
| `creating-pull-requests` | "PR", "pull request" | Complete and documented PR |

## Recommended Dependencies

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

## Environment Management

### Per-environment Configuration
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

### Per-environment Launch
```bash
# Development
flutter run --dart-define=ENV=dev --dart-define=SUPABASE_ANON_KEY_DEV=xxx

# Staging
flutter run --dart-define=ENV=staging --dart-define=SUPABASE_ANON_KEY_STAGING=yyy

# Production
flutter build apk --dart-define=ENV=prod --dart-define=SUPABASE_ANON_KEY_PROD=zzz
```

### .env Files (with flutter_dotenv)
```yaml
# .env.dev
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=xxx

# .env.prod
SUPABASE_URL=https://zzz.supabase.co
SUPABASE_ANON_KEY=zzz
```

## Flutter CI/CD (GitHub Actions)

### Basic Workflow
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

### Dependency Cache
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

#### Preparation
```bash
# 1. Generate a keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload

# 2. Create key.properties (DO NOT COMMIT)
# android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

#### Gradle Configuration
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

#### Build and Upload
```bash
# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Upload via fastlane or manually
# The file is in build/app/outputs/bundle/release/app-release.aab
```

### iOS - App Store

#### Preparation
1. Apple Developer account ($99/year)
2. Distribution certificate in Keychain
3. Provisioning profile in Xcode

#### Xcode Configuration
```bash
# Open in Xcode
open ios/Runner.xcworkspace
```
- Product → Scheme → Edit Scheme → Archive → Build Configuration: Release
- Signing & Capabilities → Team: Your team
- Bundle Identifier: com.yourcompany.yourapp

#### Build and Upload
```bash
# Build IPA
flutter build ipa --release

# Or via Xcode: Product → Archive → Distribute App
```

### Fastlane (automation)
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

### Firebase Cloud Messaging (FCM) Configuration

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
  // Background handling
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission (iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Retrieve the FCM token
      final token = await _messaging.getToken();
      // Send to backend to associate with the user
      await _saveTokenToBackend(token);

      // Listen for token changes
      _messaging.onTokenRefresh.listen(_saveTokenToBackend);
    }

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handler when the app is opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Display local notification or snackbar
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to the appropriate page
  }

  Future<void> _saveTokenToBackend(String? token) async {
    if (token != null) {
      // Save via Supabase or API
    }
  }
}
```

#### Android Configuration
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <application>
    <!-- Default channel -->
    <meta-data
      android:name="com.google.firebase.messaging.default_notification_channel_id"
      android:value="high_importance_channel" />
  </application>
</manifest>
```

#### iOS Configuration
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

### Local Notifications (flutter_local_notifications)
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
    // Handle the tap
  }
}
```

## Performance and Optimization

### APK Size
```bash
# Analyze size
flutter build apk --analyze-size

# Build with split per ABI (reduces ~60%)
flutter build apk --split-per-abi

# Optimized build
flutter build apk --release --shrink --obfuscate --split-debug-info=./debug-info
```

### Image Optimization
```yaml
# pubspec.yaml - use optimized assets
flutter:
  assets:
    - assets/images/1.5x/
    - assets/images/2.0x/
    - assets/images/3.0x/
```

### Lazy Loading
```dart
// Load modules on demand
final widget = await loadLibrary(() => import('package:heavy_feature/heavy_feature.dart'));
```

### Performance Checklist
- [ ] Use `const` constructors everywhere
- [ ] Avoid `setState` in loops
- [ ] Use `ListView.builder` for long lists
- [ ] Implement pagination for data
- [ ] Compress images before upload
- [ ] Use network cache (cached_network_image)
- [ ] Profile with DevTools (flutter pub global run devtools)

## Anti-patterns to Avoid

- NEVER put business logic in widgets
- NEVER use `dynamic` except for JSON parsing
- NEVER forget to dispose controllers/streams
- NEVER hardcode strings (use l10n)
- NEVER store secrets in code (use --dart-define)
- NEVER ignore iOS permissions (Info.plist)
- Avoid `!` (null assertion) - prefer pattern matching
- Avoid widgets that are too deeply nested (extract into sub-widgets)
