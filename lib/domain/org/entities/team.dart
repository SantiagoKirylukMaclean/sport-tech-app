// lib/domain/org/entities/team.dart

import 'package:equatable/equatable.dart';

/// Represents a team in the domain
/// Maps to the public.teams table in Supabase
class Team extends Equatable {
  final String id;
  final String clubId;
  final String name;
  final DateTime createdAt;

  const Team({
    required this.id,
    required this.clubId,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, clubId, name, createdAt];

  @override
  String toString() => 'Team(id: $id, name: $name, clubId: $clubId)';

  /// Create a copy with updated fields
  Team copyWith({
    String? id,
    String? clubId,
    String? name,
    DateTime? createdAt,
  }) {
    return Team(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
