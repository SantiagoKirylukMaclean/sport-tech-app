// lib/application/notes/notes_state.dart

import 'package:sport_tech_app/domain/notes/entities/note.dart';

/// Base state for notes
sealed class NotesState {
  const NotesState();
}

/// Initial state
class NotesStateInitial extends NotesState {
  const NotesStateInitial();
}

/// Loading state
class NotesStateLoading extends NotesState {
  const NotesStateLoading();
}

/// Loaded state with notes
class NotesStateLoaded extends NotesState {
  final List<Note> notes;

  const NotesStateLoaded(this.notes);
}

/// Error state
class NotesStateError extends NotesState {
  final String message;

  const NotesStateError(this.message);
}
