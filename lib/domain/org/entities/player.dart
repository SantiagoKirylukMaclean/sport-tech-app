// lib/domain/org/entities/player.dart

import 'package:equatable/equatable.dart';

/// Represents a player in the domain
/// Maps to the public.players table in Supabase
class Player extends Equatable {
  final String id;
  final String teamId;
  final String? userId; // Optional link to auth user
  final String fullName;
  final int? jerseyNumber;
  final String? positionId;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.teamId,
    required this.fullName,
    required this.createdAt,
    this.userId,
    this.jerseyNumber,
    this.positionId,
  });

  @override
  List<Object?> get props => [
        id,
        teamId,
        userId,
        fullName,
        jerseyNumber,
        positionId,
        createdAt,
      ];

  @override
  String toString() => 'Player(id: $id, name: $fullName, #$jerseyNumber)';

  /// Create a copy with updated fields
  Player copyWith({
    String? id,
    String? teamId,
    String? userId,
    String? fullName,
    int? jerseyNumber,
    String? positionId,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      positionId: positionId ?? this.positionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
