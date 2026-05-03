---
sidebar_position: 5
title: "04 - Flutter + Supabase"
description: Build a Flutter mobile app with authentication and Supabase backend
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Flutter App with Supabase

<DifficultyBadge level="intermediate" /> **Estimated duration: 60 minutes**

This tutorial shows you how to create a Flutter mobile application with a Supabase backend for authentication and database.

## Objectives

By the end of this tutorial, you will know how to:
- Use `/dev:dev-supabase` to configure Supabase
- Use `/dev:dev-flutter` to create screens and widgets
- Implement authentication with Supabase Auth
- Structure a Flutter app in Clean Architecture

## Prerequisites

- Flutter SDK installed
- A Supabase account (free)
- An existing or new Flutter project
- Basic knowledge of Flutter/Dart

## Context

We are going to create a **notes app** with:
- Email/password authentication
- Notes CRUD
- Real-time synchronization
- BLoC architecture

## Step 1: Configure Supabase

### Create the Supabase project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note the URL and the anon key

### Configure with claude-socle

```bash
/dev:dev-supabase "Configure Supabase for a notes app with auth and CRUD"
```

Claude will create:

**`lib/core/supabase/supabase_client.dart`**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }

  static User? get currentUser => client.auth.currentUser;
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
```

**SQL Migration (to run in Supabase)**
```sql
-- Notes table
create table notes (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  content text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- RLS (Row Level Security)
alter table notes enable row level security;

create policy "Users can view their own notes"
  on notes for select
  using (auth.uid() = user_id);

create policy "Users can create their own notes"
  on notes for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own notes"
  on notes for update
  using (auth.uid() = user_id);

create policy "Users can delete their own notes"
  on notes for delete
  using (auth.uid() = user_id);
```

## Step 2: Create the model and repository

```bash
/dev:dev-flutter "Note entity and repository for CRUD operations with Supabase"
```

**`lib/features/notes/domain/entities/note.dart`**
```dart
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, title, content, createdAt, updatedAt];
}
```

**`lib/features/notes/data/repositories/note_repository_impl.dart`**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final SupabaseClient _client;

  NoteRepositoryImpl(this._client);

  @override
  Future<List<Note>> getNotes() async {
    final response = await _client
        .from('notes')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => NoteModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<Note> createNote(String title, String? content) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client.from('notes').insert({
      'user_id': userId,
      'title': title,
      'content': content,
    }).select().single();

    return NoteModel.fromJson(response).toEntity();
  }

  @override
  Future<Note> updateNote(String id, String title, String? content) async {
    final response = await _client.from('notes').update({
      'title': title,
      'content': content,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id).select().single();

    return NoteModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deleteNote(String id) async {
    await _client.from('notes').delete().eq('id', id);
  }

  @override
  Stream<List<Note>> watchNotes() {
    return _client
        .from('notes')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => NoteModel.fromJson(json).toEntity()).toList());
  }
}
```

## Step 3: Create the BLoC

```bash
/dev:dev-flutter "NotesBloc to manage notes state with CRUD events"
```

**`lib/features/notes/presentation/bloc/notes_bloc.dart`**
```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

// Events
abstract class NotesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {}
class WatchNotes extends NotesEvent {}
class AddNote extends NotesEvent {
  final String title;
  final String? content;
  AddNote(this.title, this.content);
  @override
  List<Object?> get props => [title, content];
}
class UpdateNote extends NotesEvent {
  final String id;
  final String title;
  final String? content;
  UpdateNote(this.id, this.title, this.content);
  @override
  List<Object?> get props => [id, title, content];
}
class DeleteNote extends NotesEvent {
  final String id;
  DeleteNote(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class NotesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}
class NotesLoading extends NotesState {}
class NotesLoaded extends NotesState {
  final List<Note> notes;
  NotesLoaded(this.notes);
  @override
  List<Object?> get props => [notes];
}
class NotesError extends NotesState {
  final String message;
  NotesError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository _repository;
  StreamSubscription<List<Note>>? _subscription;

  NotesBloc(this._repository): super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<WatchNotes>(_onWatchNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await _repository.getNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onWatchNotes(WatchNotes event, Emitter<NotesState> emit) async {
    _subscription?.cancel();
    _subscription = _repository.watchNotes().listen(
      (notes) => add(LoadNotes()),
      onError: (e) => emit(NotesError(e.toString())),
    );
  }

  Future<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      await _repository.createNote(event.title, event.content);
      add(LoadNotes());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      await _repository.updateNote(event.id, event.title, event.content);
      add(LoadNotes());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await _repository.deleteNote(event.id);
      add(LoadNotes());
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

## Step 4: Create the screens

```bash
/dev:dev-flutter "NotesListScreen with notes list, FAB to add and swipe to delete"
```

**`lib/features/notes/presentation/pages/notes_list_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../widgets/note_card.dart';
import 'note_editor_screen.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () => context.read<NotesBloc>().add(LoadNotes()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(
                child: Text('No notes. Create one!'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return Dismissible(
                  key: Key(note.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context.read<NotesBloc>().add(DeleteNote(note.id));
                  },
                  child: NoteCard(
                    note: note,
                    onTap: () => _editNote(context, note),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNote(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _createNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );
  }

  void _editNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
  }

  void _logout(BuildContext context) async {
    await SupabaseService.client.auth.signOut();
  }
}
```

## Step 5: Test with the emulator

```bash
flutter run
```

Verify that:
1. Sign-up works
2. Sign-in works
3. Notes are created and displayed
4. Updates are synchronized

## Step 6: Mobile quality audit

```bash
/qa:qa-mobile
```

Claude will check:
- Rendering performance
- Memory management
- Accessibility
- Unit and widget tests

## Step 7: Commit

```bash
/work:work-commit
```

**Suggested message:**

```
feat(notes): add notes feature with Supabase backend

- Add Supabase configuration with RLS
- Add Note entity and repository
- Add NotesBloc for state management
- Add NotesListScreen with swipe to delete
- Add NoteEditorScreen for create/update
- Add real-time synchronization
```

## Final structure

```
lib/
├── core/
│   └── supabase/
│       └── supabase_client.dart
├── features/
│   └── notes/
│       ├── data/
│       │   ├── models/
│       │   │   └── note_model.dart
│       │   └── repositories/
│       │       └── note_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── note.dart
│       │   └── repositories/
│       │       └── note_repository.dart
│       └── presentation/
│           ├── bloc/
│           │   └── notes_bloc.dart
│           ├── pages/
│           │   ├── notes_list_screen.dart
│           │   └── note_editor_screen.dart
│           └── widgets/
│               └── note_card.dart
└── config/
    └── injection.dart
```

## Next steps

- [Tutorial 05: Security audit](/docs/tutorials/security-audit)
- [Mobile Guide](/docs/concepts/stack-recipes)
- [/dev:dev-flutter command](/docs/commands/dev/dev-flutter)

---

:::tip Supabase RLS
**Always** enable Row Level Security on your Supabase tables. Claude configures it automatically with `/dev:dev-supabase`.
:::
