// lib/domain/org/entities/sport.dart

import 'package:equatable/equatable.dart';

/// Represents a sport in the domain
/// Maps to the public.sports table in Supabase
class Sport extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;

  const Sport({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt];

  @override
  String toString() => 'Sport(id: $id, name: $name)';

  /// Create a copy with updated fields
  Sport copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Sport(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
