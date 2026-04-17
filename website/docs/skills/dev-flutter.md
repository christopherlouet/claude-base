---
sidebar_position: 10
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

## Exemples pratiques


### 1. Example: Clean Architecture Feature with BLoC

# Example: Clean Architecture Feature with BLoC

## Scenario
Build a "Task List" feature in Flutter using Clean Architecture layers and BLoC state management.

## File Structure

```
lib/features/tasks/
  data/
    datasources/task_remote_datasource.dart
    models/task_model.dart
    repositories/task_repository_impl.dart
  domain/
    entities/task.dart
    repositories/task_repository.dart
    usecases/get_tasks.dart
  presentation/
    bloc/task_bloc.dart
    bloc/task_event.dart
    bloc/task_state.dart
    pages/task_list_page.dart
    widgets/task_tile.dart
```

## Domain Layer

```dart
// domain/entities/task.dart
class Task {
  final String id;
  final String title;
  final bool completed;
  const Task({required this.id, required this.title, required this.completed});
}

// domain/repositories/task_repository.dart
abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();
}

// domain/usecases/get_tasks.dart
class GetTasks {
  final TaskRepository repository;
  GetTasks(this.repository);
  Future<Either<Failure, List<Task>>> call() => repository.getTasks();
}
```

## BLoC (Presentation)

```dart
// presentation/bloc/task_event.dart
abstract class TaskEvent {}
class LoadTasks extends TaskEvent {}

// presentation/bloc/task_state.dart
abstract class TaskState {}
class TaskInitial extends TaskState {}
class TaskLoading extends TaskState {}
class TaskLoaded extends TaskState {
  final List<Task> tasks;
  TaskLoaded(this.tasks);
}
class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}

// presentation/bloc/task_bloc.dart
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  TaskBloc({required this.getTasks}) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskLoading());
      final result = await getTasks();
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (tasks) => emit(TaskLoaded(tasks)),
      );
    });
  }
}
```

## Page Widget

```dart
// presentation/pages/task_list_page.dart
class TaskListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) => switch (state) {
        TaskLoading() => const Center(child: CircularProgressIndicator()),
        TaskLoaded(:final tasks) => ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, i) => TaskTile(task: tasks[i]),
        ),
        TaskError(:final message) => Center(child: Text(message)),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
```

## Key Decisions

- **Either type**: `Either<Failure, T>` for explicit error handling (no exceptions)
- **UseCases as callable classes**: Single responsibility, easy to test and inject
- **BLoC over Riverpod/Provider**: Better for complex event-driven flows, testable
- **Sealed-style states**: Exhaustive switch ensures all states are handled in UI
- **DI with get_it**: Register `TaskRepository` -> `TaskRepositoryImpl` in service locator



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
