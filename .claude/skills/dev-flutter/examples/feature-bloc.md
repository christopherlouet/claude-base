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
  TaskBloc({required this.getTasks}): super(TaskInitial()) {
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
