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

- Prefer StatelessWidget when possible
- Extract complex widgets
- Use const constructors
- Descriptive naming (UserCard, LoginButton)

## State Management (BLoC)

- One BLoC per feature
- Events for user actions
- States for UI states
- Separate business logic from UI

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

- Use get_it for injection
- Register dependencies at startup
- Lazy singletons for services

## Navigation (GoRouter)

- Declarative routes
- Route naming in snake_case
- Deep linking support

## Tests

- Widget tests for UI components
- Unit tests for BLoCs and services
- Integration tests for critical flows
- Golden tests for visual regressions

## Performance

- Use const widgets
- Avoid unnecessary rebuilds
- ListView.builder for long lists
- Cached images (cached_network_image)

## Anti-patterns

- NEVER block the main isolate
- Avoid setState in StatelessWidget
- Do not ignore async errors
- Avoid widgets that are too deep (> 10 levels)
