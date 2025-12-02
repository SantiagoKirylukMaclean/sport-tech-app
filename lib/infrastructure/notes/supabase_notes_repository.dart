// lib/infrastructure/notes/supabase_notes_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_tech_app/core/error/failures.dart';
import 'package:sport_tech_app/core/utils/result.dart';
import 'package:sport_tech_app/domain/notes/entities/note.dart';
import 'package:sport_tech_app/domain/notes/repositories/notes_repository.dart';
import 'package:sport_tech_app/infrastructure/notes/mappers/note_mapper.dart';
import 'package:uuid/uuid.dart';

/// Supabase implementation of [NotesRepository]
class SupabaseNotesRepository implements NotesRepository {
  final SupabaseClient _client;
  final Uuid _uuid;

  SupabaseNotesRepository(this._client, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  @override
  Future<Result<List<Note>>> getNotes() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failed(AuthFailure('No authenticated user'));
      }

      final response = await _client
          .from('notes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final notes = (response as List)
          .map((json) => NoteMapper.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(notes);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting notes: $e'));
    }
  }

  @override
  Future<Result<Note>> getNoteById(String noteId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failed(AuthFailure('No authenticated user'));
      }

      final response = await _client
          .from('notes')
          .select()
          .eq('id', noteId)
          .eq('user_id', userId)
          .single();

      return Success(NoteMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Note not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error getting note: $e'));
    }
  }

  @override
  Future<Result<Note>> createNote({required String content}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failed(AuthFailure('No authenticated user'));
      }

      final now = DateTime.now().toIso8601String();
      final noteId = _uuid.v4();

      final response = await _client.from('notes').insert({
        'id': noteId,
        'user_id': userId,
        'content': content.trim(),
        'created_at': now,
      }).select().single();

      return Success(NoteMapper.fromJson(response));
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error creating note: $e'));
    }
  }

  @override
  Future<Result<Note>> updateNote({
    required String noteId,
    required String content,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failed(AuthFailure('No authenticated user'));
      }

      final now = DateTime.now().toIso8601String();

      final response = await _client
          .from('notes')
          .update({
            'content': content.trim(),
            'updated_at': now,
          })
          .eq('id', noteId)
          .eq('user_id', userId)
          .select()
          .single();

      return Success(NoteMapper.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Failed(NotFoundFailure('Note not found', code: e.code));
      }
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error updating note: $e'));
    }
  }

  @override
  Future<Result<void>> deleteNote(String noteId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failed(AuthFailure('No authenticated user'));
      }

      await _client
          .from('notes')
          .delete()
          .eq('id', noteId)
          .eq('user_id', userId);

      return const Success(null);
    } on PostgrestException catch (e) {
      return Failed(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Failed(ServerFailure('Error deleting note: $e'));
    }
  }
}
