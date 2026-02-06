---
sidebar_position: 9
title: "dev-flutter"
description: "Developpement Flutter avec Clean Architecture et BLoC. Declencher quand l'utilisateur veut creer des widgets, screens, ou features Flutter."
tags:
  - "skill"
  - "fork"
---

# Skill: dev-flutter

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Developpement Flutter avec Clean Architecture et BLoC. Declencher quand l'utilisateur veut creer des widgets, screens, ou features Flutter.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `dev`, `flutter` |

## Description detaillee

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
class AuthSuccess extends AuthState { final User user; }
class AuthFailure extends AuthState { final String error; }

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
  }
}
```

## Widgets

- Stateless pour UI pure
- Stateful uniquement si etat local necessaire
- const constructors quand possible
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
  build: () => AuthBloc(),
  act: (bloc) => bloc.add(LoginRequested('email', 'pass')),
  expect: () => [AuthLoading(), isA<AuthSuccess>()],
);
```

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux dev..."_
- _"Je veux flutter..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
