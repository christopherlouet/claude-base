---
sidebar_position: 3
title: Developpement Mobile
description: Guide pour Flutter et Dart
---

# Guide : Developpement Mobile

Guide complet pour les projets Flutter.

## Stack supportee

- **Framework** : Flutter 3.x
- **Langage** : Dart
- **Architecture** : Clean Architecture + BLoC
- **Backend** : Supabase, Firebase
- **Tests** : flutter_test, integration_test

## Commandes recommandees

### Developpement

| Commande | Usage |
|----------|-------|
| `/dev-flutter` | Creer widgets et screens |
| `/dev-supabase` | Backend Supabase |
| `/dev-tdd` | Developper en TDD |

### Qualite

| Commande | Usage |
|----------|-------|
| `/qa-mobile` | Audit qualite mobile |
| `/qa-review` | Code review |
| `/qa-perf` | Performance |

### Operations

| Commande | Usage |
|----------|-------|
| `/ops-mobile-release` | Release App Store/Play Store |
| `/ops-ci` | CI/CD mobile |

## Architecture Clean + BLoC

```
lib/
├── core/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   └── [feature]/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
├── shared/
│   ├── widgets/
│   └── theme/
└── config/
    ├── routes/
    └── injection/
```

## Workflow type

### Nouvelle feature

```bash
# 1. Explorer le code existant
/work-explore "feature authentification"

# 2. Planifier avec Clean Architecture
/work-plan "Ajouter feature notifications"

# 3. Creer la feature
/dev-flutter "Feature notifications avec BLoC"

# 4. Audit mobile
/qa-mobile

# 5. PR
/work-pr
```

## Bonnes pratiques

### Widget

```dart
// lib/features/auth/presentation/widgets/login_button.dart
class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const LoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text('Login'),
    );
  }
}
```

### BLoC

```dart
// lib/features/auth/presentation/bloc/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
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
      (user) => emit(AuthSuccess(user)),
    );
  }
}
```

## Regles appliquees

Les regles suivantes s'appliquent automatiquement :

- **flutter.md** - Clean Architecture, BLoC
- **testing.md** - Tests unitaires, widget, integration

## Exemple complet

```bash
# Ajouter un systeme de paiement

> /work-flow-feature "Integration paiement Stripe"

# Claude :
# 1. Explore l'architecture existante
# 2. Propose la structure Clean Arch
# 3. Cree les layers (data, domain, presentation)
# 4. Implemente le BLoC
# 5. Ajoute les tests
# 6. Audit mobile
# 7. Cree la PR
```

---

## Voir aussi

- [Flutter](/docs/commands/dev/dev-flutter)
- [Supabase](/docs/commands/dev/dev-supabase)
- [QA Mobile](/docs/commands/qa/qa-mobile)
