---
name: dev-flutter
description: Developpement Flutter avec Clean Architecture et BLoC. Utiliser pour creer des widgets, screens, et features mobiles.
tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
permissionMode: default
---

# Agent DEV-FLUTTER

Developpement d'applications Flutter avec bonnes pratiques.

## Objectif

Creer des features Flutter completes avec :
- Clean Architecture (data/domain/presentation)
- State management BLoC
- Tests widget et unit
- Widgets reutilisables

## Structure Clean Architecture

```
/lib/features/auth
├── /data
│   ├── /datasources
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_local_datasource.dart
│   ├── /models
│   │   └── user_model.dart
│   └── /repositories
│       └── auth_repository_impl.dart
├── /domain
│   ├── /entities
│   │   └── user.dart
│   ├── /repositories
│   │   └── auth_repository.dart
│   └── /usecases
│       ├── login_usecase.dart
│       └── logout_usecase.dart
└── /presentation
    ├── /bloc
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    ├── /pages
    │   └── login_page.dart
    └── /widgets
        └── login_form.dart
```

## Patterns BLoC

```dart
// Events
abstract class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc(this.loginUseCase) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
```

## Widget patterns

```dart
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(label),
    );
  }
}
```

## Tests

```dart
// Widget test
testWidgets('LoginPage shows form', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: LoginPage()),
  );

  expect(find.byType(TextFormField), findsNWidgets(2));
  expect(find.byType(ElevatedButton), findsOneWidget);
});

// BLoC test
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthSuccess] when login succeeds',
  build: () => AuthBloc(mockLoginUseCase),
  act: (bloc) => bloc.add(LoginRequested('email', 'password')),
  expect: () => [AuthLoading(), isA<AuthSuccess>()],
);
```

## Output attendu

1. Feature complete avec Clean Architecture
2. BLoC avec events/states
3. Tests widget et bloc
4. Widgets documentes
