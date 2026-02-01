# Guide Developpement Mobile

> Workflow complet pour applications mobiles avec Flutter

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Framework | Flutter 3.x |
| Architecture | Clean Architecture |
| State | BLoC, Riverpod, Provider |
| Backend | Supabase, Firebase, API REST |
| Database | SQLite, Hive, Isar |
| CI/CD | Fastlane, Codemagic, GitHub Actions |
| Stores | App Store, Google Play |

## Architecture Clean

```
lib/
├── core/                 # Constantes, erreurs, reseau, utils
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/             # Features par domaine
│   └── [feature]/
│       ├── data/        # Datasources, models, repositories impl
│       ├── domain/      # Entities, repositories interfaces, usecases
│       └── presentation/ # BLoC, pages, widgets
├── shared/               # Widgets et theme partages
├── l10n/                 # Traductions (ARB)
└── config/               # Routes (GoRouter), injection (get_it)
```

## Workflow Recommande

```
/work:work-explore → /work:work-plan → /dev:dev-flutter → /dev:dev-tdd → /qa:qa-mobile → /work:work-pr
```

## Phase 1: Exploration

### Comprendre le projet

```bash
/work:work-explore
```

### Questions a clarifier

- Architecture (Clean, MVVM, MVC)?
- State management (BLoC, Riverpod)?
- Backend (Supabase, Firebase, custom API)?
- Plateformes cibles (iOS, Android, Web)?

## Phase 2: Planification

### Planifier une feature

```bash
/work:work-plan "Ajouter l'authentification avec Supabase"
```

### Structure de plan type

```markdown
## Feature: Authentification Supabase

### Fichiers Domain (contracts)
- lib/features/auth/domain/entities/user.dart
- lib/features/auth/domain/repositories/auth_repository.dart
- lib/features/auth/domain/usecases/login.dart
- lib/features/auth/domain/usecases/register.dart
- lib/features/auth/domain/usecases/logout.dart

### Fichiers Data (implementation)
- lib/features/auth/data/models/user_model.dart
- lib/features/auth/data/datasources/auth_remote_datasource.dart
- lib/features/auth/data/repositories/auth_repository_impl.dart

### Fichiers Presentation (UI)
- lib/features/auth/presentation/bloc/auth_bloc.dart
- lib/features/auth/presentation/pages/login_page.dart
- lib/features/auth/presentation/pages/register_page.dart
- lib/features/auth/presentation/widgets/auth_form.dart

### Dependances a ajouter
- supabase_flutter: ^2.0.0
- flutter_bloc: ^8.1.0
- get_it: ^7.6.0
- injectable: ^2.3.0
```

## Phase 3: Developpement

### Creer une feature Flutter

```bash
/dev:dev-flutter "ecran de liste de produits avec infinite scroll"
```

### Creer un backend Supabase

```bash
/dev:dev-supabase "table products avec RLS et fonction de recherche"
```

### Structure BLoC generee

```dart
// auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({required this.loginUseCase, required this.logoutUseCase})
      : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
```

## Phase 4: Tests

### TDD pour use cases

```bash
/dev:dev-tdd "use case de login avec validation email"
```

### Types de tests Flutter

| Type | Fichier | Commande |
|------|---------|----------|
| Unit | `*_test.dart` | `flutter test test/unit/` |
| Widget | `*_widget_test.dart` | `flutter test test/widget/` |
| Integration | `*_integration_test.dart` | `flutter test integration_test/` |

### Generer tests

```bash
/dev:dev-test "tester le BLoC d'authentification"
```

## Phase 5: Qualite

### Audit mobile complet

```bash
/qa:qa-mobile
```

Checklist:
- [ ] Performance (60 fps)
- [ ] Offline mode
- [ ] Deep links
- [ ] Push notifications
- [ ] Permissions handling
- [ ] Accessibility

### Analyse statique

```bash
flutter analyze
dart fix --apply
```

### Couverture

```bash
/qa:qa-coverage
flutter test --coverage
```

## Phase 6: Release

### Configuration Fastlane

```bash
/ops:ops-mobile-release
```

### Workflow release

```bash
/work:work-flow-release "v2.0.0"
```

### Checklist pre-release

```bash
# iOS
- [ ] Increment version/build
- [ ] Screenshots App Store
- [ ] Privacy policy URL
- [ ] TestFlight beta OK

# Android
- [ ] versionCode/versionName
- [ ] APK/AAB signe
- [ ] Screenshots Play Store
- [ ] Internal testing OK
```

### Analytics stores

```bash
/growth:growth-app-store-analytics
```

## Commandes par Use Case

### Nouveau projet Flutter

```bash
1. flutter create --org com.example my_app
2. /work:work-explore        # Structure Clean Architecture
3. /work:work-plan          # Definir les features
4. /dev:dev-supabase       # Backend si Supabase
5. /ops:ops-ci             # Codemagic/GitHub Actions
```

### Nouvelle feature

```bash
1. /work:work-explore       # Comprendre le domaine
2. /work:work-plan         # Planifier Clean Architecture
3. /dev:dev-flutter       # Creer la feature
4. /dev:dev-tdd           # Tests unitaires
5. /qa:qa-mobile         # Audit qualite
6. /work:work-pr           # Pull Request
```

### Bug fix mobile

```bash
1. /dev:dev-debug         # Identifier la cause
2. /work:work-flow-bugfix  # Workflow complet
```

### Release

```bash
1. /qa:qa-mobile         # Audit pre-release
2. /doc:doc-changelog     # Mettre a jour changelog
3. /ops:ops-mobile-release # Configurer Fastlane
4. /work:work-flow-release # Release workflow
```

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Cree un widget" | dev-flutter | Clean Architecture + BLoC |
| "Configure Supabase" | dev-supabase | Auth, DB, Storage |
| "Audit qualite mobile" | qa-mobile | Performance, offline, a11y |
| "Debug cette erreur" | dev-debug | Investigation |

## Patterns Flutter

### Repository Pattern

```dart
// domain/repositories/product_repository.dart
abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductById(String id);
}

// data/repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final products = await remoteDataSource.getProducts();
        await localDataSource.cacheProducts(products);
        return Right(products);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      final cached = await localDataSource.getCachedProducts();
      return Right(cached);
    }
  }
}
```

### UseCase Pattern

```dart
// domain/usecases/get_products.dart
class GetProducts implements UseCase<List<Product>, NoParams> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) {
    return repository.getProducts();
  }
}
```

## Anti-patterns a Eviter

- Business logic dans les widgets → Utiliser BLoC/Riverpod
- setState excessif → Utiliser state management
- Pas de gestion d'erreurs → Either<Failure, Success>
- Pas d'offline mode → Cache local avec Hive/SQLite
- Ignorer les permissions → Demander au bon moment

## Ressources

- [Flutter Docs](https://flutter.dev/docs)
- [BLoC Library](https://bloclibrary.dev)
- [Supabase Flutter](https://supabase.com/docs/reference/dart)
- [Fastlane](https://fastlane.tools)
