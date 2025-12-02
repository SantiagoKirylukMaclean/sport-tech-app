// lib/application/notes/notes_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/notes/notes_state.dart';
import 'package:sport_tech_app/domain/notes/repositories/notes_repository.dart';
import 'package:sport_tech_app/infrastructure/notes/providers/notes_repository_provider.dart';

/// Provider for notes notifier
final notesNotifierProvider =
    StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  final repository = ref.watch(notesRepositoryProvider);
  return NotesNotifier(repository);
});

/// Notifier for managing notes state
class NotesNotifier extends StateNotifier<NotesState> {
  final NotesRepository _repository;

  NotesNotifier(this._repository) : super(const NotesStateInitial());

  /// Load all notes for current user
  Future<void> loadNotes() async {
    state = const NotesStateLoading();

    final result = await _repository.getNotes();

    result.when(
      success: (notes) => state = NotesStateLoaded(notes),
      failure: (failure) => state = NotesStateError(failure.message),
    );
  }

  /// Create a new note
  Future<void> createNote(String content) async {
    if (content.trim().isEmpty) {
      state = const NotesStateError('Note content cannot be empty');
      return;
    }

    final result = await _repository.createNote(content: content);

    result.when(
      success: (_) => loadNotes(), // Reload notes after creation
      failure: (failure) => state = NotesStateError(failure.message),
    );
  }

  /// Update an existing note
  Future<void> updateNote(String noteId, String content) async {
    if (content.trim().isEmpty) {
      state = const NotesStateError('Note content cannot be empty');
      return;
    }

    final result = await _repository.updateNote(
      noteId: noteId,
      content: content,
    );

    result.when(
      success: (_) => loadNotes(), // Reload notes after update
      failure: (failure) => state = NotesStateError(failure.message),
    );
  }

  /// Delete a note
  Future<void> deleteNote(String noteId) async {
    final result = await _repository.deleteNote(noteId);

    result.when(
      success: (_) => loadNotes(), // Reload notes after deletion
      failure: (failure) => state = NotesStateError(failure.message),
    );
  }
}
