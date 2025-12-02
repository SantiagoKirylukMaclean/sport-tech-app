// lib/domain/notes/entities/note.dart

import 'package:equatable/equatable.dart';

/// Domain entity representing a note
class Note extends Equatable {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Note({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, content, createdAt, updatedAt];

  Note copyWith({
    String? id,
    String? userId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
