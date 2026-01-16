# Agent DEV-SUPABASE

Configurer et utiliser Supabase comme backend (Auth, Database, Storage, Realtime, Edge Functions).

## Contexte
$ARGUMENTS

## Configuration initiale

### 1. Installation

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.3.0
```

### 2. Initialisation

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  runApp(const MyApp());
}

// Accès global (à utiliser avec parcimonie)
final supabase = Supabase.instance.client;
```

### 3. Variables d'environnement

```bash
# Lancement avec variables
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

## Authentication

### Email/Password

```dart
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  // Inscription
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        if (displayName != null) 'display_name': displayName,
      },
    );
  }

  // Connexion
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Déconnexion
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Réinitialisation mot de passe
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Utilisateur courant
  User? get currentUser => _client.auth.currentUser;

  // Session courante
  Session? get currentSession => _client.auth.currentSession;
}
```

### OAuth (Google, Apple, GitHub)

```dart
// OAuth
Future<bool> signInWithGoogle() async {
  return await _client.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: 'io.supabase.myapp://callback',
    scopes: 'email profile',
  );
}

Future<bool> signInWithApple() async {
  return await _client.auth.signInWithOAuth(
    OAuthProvider.apple,
    redirectTo: 'io.supabase.myapp://callback',
  );
}

// Configuration deep links (AndroidManifest.xml)
// <intent-filter>
//   <action android:name="android.intent.action.VIEW" />
//   <category android:name="android.intent.category.DEFAULT" />
//   <category android:name="android.intent.category.BROWSABLE" />
//   <data android:scheme="io.supabase.myapp" android:host="callback" />
// </intent-filter>
```

### Magic Link

```dart
Future<void> signInWithMagicLink(String email) async {
  await _client.auth.signInWithOtp(
    email: email,
    emailRedirectTo: 'io.supabase.myapp://callback',
  );
}
```

### Auth State Listener

```dart
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _subscription = supabase.auth.onAuthStateChange.listen((data) {
      _event = data.event;
      _session = data.session;
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;
  AuthChangeEvent? _event;
  Session? _session;

  AuthChangeEvent? get event => _event;
  Session? get session => _session;
  User? get user => _session?.user;
  bool get isAuthenticated => _session != null;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Usage avec BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authService) : super(AuthInitial()) {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      add(AuthStateChanged(data.event, data.session));
    });

    on<AuthStateChanged>(_onAuthStateChanged);
    on<SignOutRequested>(_onSignOutRequested);
  }

  final AuthService _authService;
  late final StreamSubscription<AuthState> _authSubscription;

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.session != null) {
      emit(Authenticated(event.session!.user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
```

## Database (PostgreSQL)

### CRUD Operations

```dart
class UserRepository {
  UserRepository(this._client);

  final SupabaseClient _client;

  // SELECT
  Future<List<UserModel>> getUsers({
    int limit = 10,
    int offset = 0,
    String? status,
  }) async {
    var query = _client
        .from('users')
        .select('id, name, email, avatar_url, created_at');

    if (status != null) {
      query = query.eq('status', status);
    }

    final data = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  // SELECT avec jointures
  Future<UserModel> getUserWithProfile(String id) async {
    final data = await _client
        .from('users')
        .select('''
          *,
          profiles (
            bio,
            website,
            social_links
          ),
          posts (
            id,
            title,
            created_at
          )
        ''')
        .eq('id', id)
        .single();

    return UserModel.fromJson(data);
  }

  // INSERT
  Future<UserModel> createUser(CreateUserDto dto) async {
    final data = await _client
        .from('users')
        .insert(dto.toJson())
        .select()
        .single();

    return UserModel.fromJson(data);
  }

  // UPDATE
  Future<UserModel> updateUser(String id, UpdateUserDto dto) async {
    final data = await _client
        .from('users')
        .update(dto.toJson())
        .eq('id', id)
        .select()
        .single();

    return UserModel.fromJson(data);
  }

  // UPSERT
  Future<UserModel> upsertUser(UserModel user) async {
    final data = await _client
        .from('users')
        .upsert(user.toJson())
        .select()
        .single();

    return UserModel.fromJson(data);
  }

  // DELETE
  Future<void> deleteUser(String id) async {
    await _client
        .from('users')
        .delete()
        .eq('id', id);
  }

  // COUNT
  Future<int> countUsers({String? status}) async {
    var query = _client.from('users').select();

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.count(CountOption.exact);
    return response.count;
  }
}
```

### Row Level Security (RLS)

```sql
-- Activer RLS sur une table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Lecture par tous les utilisateurs authentifiés
CREATE POLICY "Users can view all users"
  ON users FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Modification uniquement son propre profil
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Policy: Insertion avec son propre ID
CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Policy: Suppression uniquement son propre profil
CREATE POLICY "Users can delete own profile"
  ON users FOR DELETE
  TO authenticated
  USING (auth.uid() = id);

-- Policy: Admin peut tout faire
CREATE POLICY "Admins have full access"
  ON users FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );
```

### Gestion des erreurs

```dart
Future<Either<Failure, UserModel>> getUser(String id) async {
  try {
    final data = await _client
        .from('users')
        .select()
        .eq('id', id)
        .single();

    return Right(UserModel.fromJson(data));
  } on PostgrestException catch (e) {
    return Left(ServerFailure(e.message, code: e.code));
  } on AuthException catch (e) {
    return Left(AuthFailure(e.message));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
```

## Realtime Subscriptions

### Écouter les changements

```dart
class RealtimeService {
  RealtimeService(this._client);

  final SupabaseClient _client;
  RealtimeChannel? _channel;

  Stream<List<MessageModel>> watchMessages(String roomId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((data) => data.map((e) => MessageModel.fromJson(e)).toList());
  }

  void subscribeToChanges({
    required String table,
    required void Function(PostgresChangePayload) onInsert,
    required void Function(PostgresChangePayload) onUpdate,
    required void Function(PostgresChangePayload) onDelete,
  }) {
    _channel = _client.channel('public:$table');

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: onInsert,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          callback: onUpdate,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          callback: onDelete,
        )
        .subscribe();
  }

  Future<void> unsubscribe() async {
    await _channel?.unsubscribe();
    _channel = null;
  }
}

// Usage avec BLoC
class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc(this._realtimeService) : super(MessagesInitial()) {
    on<SubscribeToMessages>(_onSubscribe);
    on<MessageReceived>(_onMessageReceived);
  }

  final RealtimeService _realtimeService;
  StreamSubscription? _subscription;

  Future<void> _onSubscribe(
    SubscribeToMessages event,
    Emitter<MessagesState> emit,
  ) async {
    _subscription = _realtimeService
        .watchMessages(event.roomId)
        .listen((messages) => add(MessageReceived(messages)));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _realtimeService.unsubscribe();
    return super.close();
  }
}
```

## Storage

### Upload/Download

```dart
class StorageService {
  StorageService(this._client);

  final SupabaseClient _client;

  // Upload depuis un fichier
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    await _client.storage
        .from(bucket)
        .upload(path, file);

    return getPublicUrl(bucket: bucket, path: path);
  }

  // Upload depuis des bytes
  Future<String> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  }) async {
    await _client.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    return getPublicUrl(bucket: bucket, path: path);
  }

  // URL publique
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // URL signée (privée, temporaire)
  Future<String> getSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 3600,
  }) async {
    return await _client.storage
        .from(bucket)
        .createSignedUrl(path, expiresIn);
  }

  // Download
  Future<Uint8List> downloadFile({
    required String bucket,
    required String path,
  }) async {
    return await _client.storage
        .from(bucket)
        .download(path);
  }

  // Delete
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage
        .from(bucket)
        .remove([path]);
  }

  // List files
  Future<List<FileObject>> listFiles({
    required String bucket,
    String path = '',
  }) async {
    return await _client.storage
        .from(bucket)
        .list(path: path);
  }
}
```

### Upload avec progression

```dart
Future<String> uploadWithProgress({
  required String bucket,
  required String path,
  required File file,
  required void Function(double) onProgress,
}) async {
  final bytes = await file.readAsBytes();
  final totalBytes = bytes.length;
  var uploadedBytes = 0;

  // Note: Supabase Flutter ne supporte pas nativement la progression
  // Alternative: utiliser Dio directement avec l'API Storage

  await _client.storage.from(bucket).uploadBinary(
    path,
    bytes,
    fileOptions: FileOptions(
      contentType: lookupMimeType(file.path),
    ),
  );

  onProgress(1.0);
  return getPublicUrl(bucket: bucket, path: path);
}
```

## Edge Functions

### Appel d'une fonction

```dart
class FunctionsService {
  FunctionsService(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> invoke({
    required String functionName,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await _client.functions.invoke(
      functionName,
      body: body,
      headers: headers,
    );

    if (response.status != 200) {
      throw FunctionException(
        'Function error: ${response.status}',
        response.data,
      );
    }

    return response.data as Map<String, dynamic>;
  }
}

// Usage
final result = await functionsService.invoke(
  functionName: 'send-notification',
  body: {
    'user_id': userId,
    'title': 'Nouveau message',
    'body': 'Vous avez reçu un nouveau message',
  },
);
```

## Checklist sécurité

- [ ] RLS activé sur TOUTES les tables
- [ ] Policies testées pour chaque opération (SELECT, INSERT, UPDATE, DELETE)
- [ ] Service role key JAMAIS exposée côté client
- [ ] Variables d'environnement pour URL et anon key
- [ ] Validation des inputs avant envoi
- [ ] Gestion des erreurs (PostgrestException, AuthException)
- [ ] Nettoyage des subscriptions (dispose/close)

## Output attendu

### Configuration
- `main.dart` avec initialisation Supabase
- Service d'authentification
- Repositories avec CRUD
- Services Realtime et Storage

### Tests
- Tests unitaires des repositories (avec mocks)
- Tests d'intégration (optionnel, avec Supabase local)

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev-flutter` | Widgets et screens |
| `/dev-graphql` | Alternative/complément GraphQL |
| `/ops-database` | Design de schéma |
| `/qa-security` | Audit sécurité RLS |

---

IMPORTANT: NEVER exposer la `service_role` key dans le code client Flutter.

YOU MUST activer RLS sur chaque table avec des policies appropriées.

NEVER désactiver RLS en production, même temporairement.

Think hard sur les policies RLS - elles sont votre dernière ligne de défense.
