---
sidebar_position: 5
title: "04 - Flutter + Supabase"
description: Construisez une app mobile Flutter avec authentification et backend Supabase
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# App Flutter avec Supabase

<DifficultyBadge level="intermediate" /> **Durée estimée : 60 minutes**

Ce tutoriel vous montre comment créer une application mobile Flutter avec un backend Supabase pour l'authentification et la base de données.

## Objectifs

À la fin de ce tutoriel, vous saurez :
- Utiliser `/dev:dev-supabase` pour configurer Supabase
- Utiliser `/dev:dev-flutter` pour créer des screens et widgets
- Implémenter l'authentification avec Supabase Auth
- Structurer une app Flutter en Clean Architecture

## Prérequis

- Flutter SDK installé
- Un compte Supabase (gratuit)
- Un projet Flutter existant ou nouveau
- Connaissances de base en Flutter/Dart

## Contexte

Nous allons créer une **app de notes** avec :
- Authentification email/password
- CRUD des notes
- Synchronisation temps réel
- Architecture BLoC

## Étape 1 : Configurer Supabase

### Créer le projet Supabase

1. Allez sur [supabase.com](https://supabase.com)
2. Créez un nouveau projet
3. Notez l'URL et la clé anon

### Configurer avec claude-socle

```bash
/dev:dev-supabase "Configurer Supabase pour une app de notes avec auth et CRUD"
```

Claude va créer :

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

**Migration SQL (à exécuter dans Supabase)**
```sql
-- Table des notes
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

## Étape 2 : Créer le modèle et repository

```bash
/dev:dev-flutter "Note entity et repository pour les opérations CRUD avec Supabase"
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

## Étape 3 : Créer le BLoC

```bash
/dev:dev-flutter "NotesBloc pour gérer l'état des notes avec les événements CRUD"
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

  NotesBloc(this._repository) : super(NotesInitial()) {
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

## Étape 4 : Créer les screens

```bash
/dev:dev-flutter "NotesListScreen avec liste des notes, FAB pour ajouter et swipe to delete"
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
        title: const Text('Mes Notes'),
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
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(
                child: Text('Aucune note. Créez-en une !'),
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

## Étape 5 : Tester avec l'émulateur

```bash
flutter run
```

Vérifiez que :
1. L'inscription fonctionne
2. La connexion fonctionne
3. Les notes se créent et s'affichent
4. Les modifications sont synchronisées

## Étape 6 : Audit qualité mobile

```bash
/qa:qa-mobile
```

Claude va vérifier :
- Performance de rendu
- Gestion de la mémoire
- Accessibilité
- Tests unitaires et widget

## Étape 7 : Commiter

```bash
/work:work-commit
```

**Message suggéré :**

```
feat(notes): add notes feature with Supabase backend

- Add Supabase configuration with RLS
- Add Note entity and repository
- Add NotesBloc for state management
- Add NotesListScreen with swipe to delete
- Add NoteEditorScreen for create/update
- Add real-time synchronization
```

## Structure finale

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

## Prochaines étapes

- [Tutoriel 05 : Audit sécurité](/docs/tutorials/audit-securite)
- [Guide Mobile](/docs/guides/mobile-guide)
- [Commande /dev:dev-flutter](/docs/commands/dev/dev-flutter)

---

:::tip Supabase RLS
Activez **toujours** Row Level Security sur vos tables Supabase. Claude le configure automatiquement avec `/dev:dev-supabase`.
:::
