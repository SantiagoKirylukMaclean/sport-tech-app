// lib/infrastructure/notes/mappers/note_mapper.dart

import 'package:sport_tech_app/domain/notes/entities/note.dart';

/// Mapper for converting between Note domain entity and JSON
class NoteMapper {
  /// Convert JSON to Note entity
  static Note fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Note entity to JSON
  static Map<String, dynamic> toJson(Note note) {
    return {
      'id': note.id,
      'user_id': note.userId,
      'content': note.content,
      'created_at': note.createdAt.toIso8601String(),
      'updated_at': note.updatedAt?.toIso8601String(),
    };
  }
}
