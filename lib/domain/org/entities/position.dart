// lib/domain/org/entities/position.dart

import 'package:equatable/equatable.dart';

/// Represents a position in a sport
/// Maps to the public.positions table in Supabase
class Position extends Equatable {
  final String id;
  final String name;
  final int displayOrder;
  final DateTime createdAt;

  const Position({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, displayOrder, createdAt];

  @override
  String toString() => 'Position(id: $id, name: $name)';

  /// Create a copy with updated fields
  Position copyWith({
    String? id,
    String? name,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return Position(
      id: id ?? this.id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
