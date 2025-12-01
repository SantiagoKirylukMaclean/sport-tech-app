// lib/domain/org/entities/position.dart

import 'package:equatable/equatable.dart';

/// Represents a position in a sport
/// Maps to the public.positions table in Supabase
class Position extends Equatable {
  final String id;
  final String sportId;
  final String name;
  final String abbreviation;
  final String? fieldZone;

  const Position({
    required this.id,
    required this.sportId,
    required this.name,
    required this.abbreviation,
    this.fieldZone,
  });

  @override
  List<Object?> get props => [id, sportId, name, abbreviation, fieldZone];

  @override
  String toString() =>
      'Position(id: $id, name: $name, abbreviation: $abbreviation)';

  /// Create a copy with updated fields
  Position copyWith({
    String? id,
    String? sportId,
    String? name,
    String? abbreviation,
    String? fieldZone,
  }) {
    return Position(
      id: id ?? this.id,
      sportId: sportId ?? this.sportId,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      fieldZone: fieldZone ?? this.fieldZone,
    );
  }
}
