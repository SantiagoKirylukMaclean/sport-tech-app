// lib/domain/matches/entities/match_call_up.dart

import 'package:equatable/equatable.dart';

/// Represents a player called up for a match
/// Maps to the public.match_call_ups table in Supabase
class MatchCallUp extends Equatable {
  final String matchId;
  final String playerId;
  final DateTime createdAt;

  const MatchCallUp({
    required this.matchId,
    required this.playerId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [matchId, playerId, createdAt];

  @override
  String toString() =>
      'MatchCallUp(matchId: $matchId, playerId: $playerId)';

  /// Create a copy with updated fields
  MatchCallUp copyWith({
    String? matchId,
    String? playerId,
    DateTime? createdAt,
  }) {
    return MatchCallUp(
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
