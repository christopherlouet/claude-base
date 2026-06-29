---
sidebar_position: 2
title: Flutter BLoC Pattern
description: State management example with BLoC and tests
---

# Flutter BLoC Pattern

This example shows how to implement the BLoC pattern for state management with full tests.

## Command used

```bash
/dev:dev-flutter "Create a BLoC for authentication with login/logout"
```

## Generated structure

```
lib/features/auth/
├── domain/
│   ├── entities/
│   │   └── user.dart
│   └── repositories/
│       └── auth_repository.dart
└── presentation/
    └── bloc/
        ├── auth_bloc.dart
        ├── auth_event.dart
        └── auth_state.dart

test/features/auth/
└── presentation/
    └── bloc/
        └── auth_bloc_test.dart
```

## BLoC code

### `domain/entities/user.dart`

```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl, createdAt];

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### `presentation/bloc/auth_event.dart`

```dart
import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Checks the initial authentication state
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with email/password
final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Sign up with email/password
final class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Logout
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Password reset
final class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
```

### `presentation/bloc/auth_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state, check in progress
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading in progress (login, signup, etc.)
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated user
final class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated user
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication error
final class AuthError extends AuthState {
  final String message;
  final AuthErrorType type;

  const AuthError({
    required this.message,
    this.type = AuthErrorType.unknown,
  });

  @override
  List<Object?> get props => [message, type];
}

enum AuthErrorType {
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  networkError,
  unknown,
}

/// Password successfully reset
final class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);

  @override
  List<Object?> get props => [email];
}
```

### `presentation/bloc/auth_bloc.dart`

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);

    // Listen for auth state changes
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          // ignore: invalid_use_of_visible_for_testing_member
          emit(AuthAuthenticated(user));
        } else {
          // ignore: invalid_use_of_visible_for_testing_member
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        type: _mapFailureToErrorType(failure),
      )),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signUpWithEmailAndPassword(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
    );

    result.fold(
      (failure) => emit(AuthError(
        message: failure.message,
        type: _mapFailureToErrorType(failure),
      )),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signOut();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.sendPasswordResetEmail(event.email);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthPasswordResetSent(event.email)),
    );
  }

  AuthErrorType _mapFailureToErrorType(Failure failure) {
    return switch (failure.code) {
      'invalid-credential' => AuthErrorType.invalidCredentials,
      'email-already-in-use' => AuthErrorType.emailAlreadyInUse,
      'weak-password' => AuthErrorType.weakPassword,
      'network-error' => AuthErrorType.networkError,
      _ => AuthErrorType.unknown,
    };
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
```

## BLoC tests

### `auth_bloc_test.dart`

```dart
import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/bloc/auth_event.dart';
import 'package:app/features/auth/presentation/bloc/auth_state.dart';
import 'package:app/core/error/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late StreamController<User?> authStateController;

  final testUser = User(
    id: 'test-id',
    email: 'test@example.com',
    displayName: 'Test User',
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authStateController = StreamController<User?>.broadcast();

    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => authStateController.stream);

    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
    authStateController.close();
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when user is logged in',
      build: () {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [AuthAuthenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when user is not logged in',
      build: () {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthUnauthenticated()],
    );
  });

  group('AuthLoginRequested', () {
    const email = 'test@example.com';
    const password = 'password123';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(
              email: email,
              password: password,
            )).thenAnswer((_) async => Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: email,
        password: password,
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on invalid credentials',
      build: () {
        when(() => mockAuthRepository.signInWithEmailAndPassword(
              email: email,
              password: password,
            )).thenAnswer((_) async => Left(Failure(
              message: 'Invalid credentials',
              code: 'invalid-credential',
            )));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: email,
        password: password,
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(
          message: 'Invalid credentials',
          type: AuthErrorType.invalidCredentials,
        ),
      ],
    );
  });

  group('AuthSignUpRequested', () {
    const email = 'new@example.com';
    const password = 'password123';
    const displayName = 'New User';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful signup',
      build: () {
        when(() => mockAuthRepository.signUpWithEmailAndPassword(
              email: email,
              password: password,
              displayName: displayName,
            )).thenAnswer((_) async => Right(testUser.copyWith(
              email: email,
              displayName: displayName,
            )));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignUpRequested(
        email: email,
        password: password,
        displayName: displayName,
      )),
      expect: () => [
        const AuthLoading(),
        isA<AuthAuthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when email already in use',
      build: () {
        when(() => mockAuthRepository.signUpWithEmailAndPassword(
              email: email,
              password: password,
              displayName: displayName,
            )).thenAnswer((_) async => Left(Failure(
              message: 'Email already in use',
              code: 'email-already-in-use',
            )));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignUpRequested(
        email: email,
        password: password,
        displayName: displayName,
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError(
          message: 'Email already in use',
          type: AuthErrorType.emailAlreadyInUse,
        ),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on successful logout',
      build: () {
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  group('AuthPasswordResetRequested', () {
    const email = 'test@example.com';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSent] on success',
      build: () {
        when(() => mockAuthRepository.sendPasswordResetEmail(email))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthPasswordResetRequested(email: email)),
      expect: () => [
        const AuthLoading(),
        const AuthPasswordResetSent(email),
      ],
    );
  });

  group('Auth state stream', () {
    test('updates state when auth state changes', () async {
      // Simulate a login via the stream
      authStateController.add(testUser);

      await expectLater(
        authBloc.stream,
        emitsThrough(AuthAuthenticated(testUser)),
      );
    });

    test('emits AuthUnauthenticated when user logs out externally', () async {
      // Simulate an external logout (e.g., expired token)
      authStateController.add(null);

      await expectLater(
        authBloc.stream,
        emitsThrough(const AuthUnauthenticated()),
      );
    });
  });
}
```

## Usage in the UI

### Login Page

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(AuthLoginRequested(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ));
                          },
                    child: state is AuthLoading
                        ? const CircularProgressIndicator()
                        : const Text('Sign in'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## Key points

| Aspect | Implementation |
|--------|----------------|
| **Sealed classes** | Type-safe Events and States (Dart 3) |
| **Stream** | Listen for external auth changes |
| **Typed errors** | `AuthErrorType` for contextual UI |
| **Tests** | `bloc_test` + `mocktail` |
| **Cleanup** | `close()` to cancel the stream |

## Related commands

- `/dev:dev-tdd` - Generate more tests
- `/dev:dev-supabase` - Integrate with Supabase Auth
- `/qa:qa-mobile` - Quality audit

---

:::tip Hydrated BLoC
To persist the authentication state, use `hydrated_bloc`:
```dart
class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  @override
  AuthState? fromJson(Map<String, dynamic> json) { ... }

  @override
  Map<String, dynamic>? toJson(AuthState state) { ... }
}
```
:::
