// lib/domain/notes/repositories/notes_repository.dart

import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/notes/entities/note.dart';

/// Repository interface for notes operations
abstract class NotesRepository {
  /// Get all notes for the current user
  Future<Result<List<Note>>> getNotes();

  /// Get a specific note by ID
  Future<Result<Note>> getNoteById(String noteId);

  /// Create a new note
  Future<Result<Note>> createNote({required String content});

  /// Update an existing note
  Future<Result<Note>> updateNote({
    required String noteId,
    required String content,
  });

  /// Delete a note
  Future<Result<void>> deleteNote(String noteId);
}
