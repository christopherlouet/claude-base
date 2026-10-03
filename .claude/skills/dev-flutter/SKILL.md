---
name: dev-flutter
description: Flutter development with Clean Architecture and BLoC. Trigger when the user wants to create widgets, screens, or Flutter features.
argument-hint: "[widget-or-screen]"
---

# Flutter Development

## Architecture

```
/lib/features/[feature]
├── /data
│   ├── /datasources      # API, local storage
│   ├── /models           # JSON serialization
│   └── /repositories     # Implementation
├── /domain
│   ├── /entities         # Business objects
│   ├── /repositories     # Interfaces
│   └── /usecases         # Business logic
└── /presentation
    ├── /bloc             # State management
    ├── /pages            # Screens
    └── /widgets          # UI components
```

## BLoC Pattern

```dart
// Events
abstract class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested(this.email, this.password);
}

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState { AuthSuccess(this.user); final User user; }
class AuthFailure extends AuthState { AuthFailure(this.error); final String error; }

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      emit(AuthSuccess(await _repository.login(event.email, event.password)));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
```

## Widgets

- Stateless for pure UI
- Stateful only if local state is needed
- const constructors when possible
- Composition over inheritance

## Tests

```dart
// Widget test
testWidgets('shows button', (tester) async {
  await tester.pumpWidget(MaterialApp(home: MyWidget()));
  expect(find.byType(ElevatedButton), findsOneWidget);
});

// BLoC test
blocTest<AuthBloc, AuthState>(
  'emits [Loading, Success] on login',
  build: () => AuthBloc(FakeAuthRepository()),
  act: (bloc) => bloc.add(LoginRequested('email', 'pass')),
  // states have no == (no Equatable): match them by type
  expect: () => [isA<AuthLoading>(), isA<AuthSuccess>()],
);
```

## See also

This skill holds the foundation's architecture opinion (Clean Architecture + BLoC). For the framework itself, the Flutter team publishes its own skills at [`flutter/agent-plugins`](https://github.com/flutter/agent-plugins) (BSD-3-Clause): layouts and layout fixes, declarative routing, HTTP, JSON serialization, widget and integration tests, localization, plus 15 Dart skills. Its plugin also starts the Dart SDK's own MCP server (`dart mcp-server`, local).

- **Architecture differs**: the official `flutter-apply-architecture-best-practices` teaches MVVM with `ChangeNotifier`. A project that already chose BLoC keeps it: follow the project's established pattern, use the official skills for the framework APIs (layout, routing, HTTP, JSON, tests).
- **Deeper BLoC**: [`HoangNguyen0403/agent-skills-standard`](https://github.com/HoangNguyen0403/agent-skills-standard) — `skills/flutter/flutter-bloc-state-management` and `flutter-feature-based-clean-architecture` (MIT, community, 569★), pinned at commit `1fb0537c339c`. Link those two folders only: they hold nothing but their `references/`; the repo's hooks, agents and MCP config are for its own development.

