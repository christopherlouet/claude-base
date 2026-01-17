---
paths:
  - "**/*.dart"
  - "**/lib/**"
  - "**/test/**"
---

# Flutter Rules

## Architecture (Clean Architecture)

```
lib/
├── core/           # Shared utilities
├── features/       # Feature modules
│   └── [feature]/
│       ├── data/          # Repository impl, models
│       ├── domain/        # Entities, use cases
│       └── presentation/  # BLoC, pages, widgets
└── shared/         # Shared widgets
```

## Widgets

- Preferer les StatelessWidget quand possible
- Extraire les widgets complexes
- Utiliser const constructors
- Nommage descriptif (UserCard, LoginButton)

## State Management (BLoC)

- Un BLoC par feature
- Events pour les actions utilisateur
- States pour les etats UI
- Separer logique metier du UI

```dart
// Event
abstract class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

// State
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
```

## Dependency Injection

- Utiliser get_it pour l'injection
- Enregistrer les dependances au demarrage
- Lazy singletons pour les services

## Navigation (GoRouter)

- Routes declaratives
- Nommage des routes en snake_case
- Deep linking support

## Tests

- Widget tests pour les composants UI
- Unit tests pour BLoCs et services
- Integration tests pour flows critiques
- Golden tests pour regressions visuelles

## Performance

- Utiliser const widgets
- Eviter rebuilds inutiles
- ListView.builder pour longues listes
- Cached images (cached_network_image)

## Anti-patterns

- NEVER bloquer le main isolate
- Eviter setState dans StatelessWidget
- Ne pas ignorer les erreurs async
- Eviter les widgets trop profonds (> 10 niveaux)
