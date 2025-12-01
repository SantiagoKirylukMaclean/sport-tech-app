// lib/domain/org/entities/club.dart

import 'package:equatable/equatable.dart';

/// Represents a club in the domain
/// Maps to the public.clubs table in Supabase
class Club extends Equatable {
  final String id;
  final String sportId;
  final String name;
  final DateTime createdAt;

  const Club({
    required this.id,
    required this.sportId,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, sportId, name, createdAt];

  @override
  String toString() => 'Club(id: $id, name: $name, sportId: $sportId)';

  /// Create a copy with updated fields
  Club copyWith({
    String? id,
    String? sportId,
    String? name,
    DateTime? createdAt,
  }) {
    return Club(
      id: id ?? this.id,
      sportId: sportId ?? this.sportId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
