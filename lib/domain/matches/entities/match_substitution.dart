// lib/domain/matches/entities/match_substitution.dart

import 'package:equatable/equatable.dart';

/// Represents a substitution during a match
/// Maps to the public.match_substitutions table in Supabase
class MatchSubstitution extends Equatable {
  final String id;
  final String matchId;
  final int period; // 1-4 (quarter where substitution occurred)
  final String playerOut; // Player leaving the field
  final String playerIn; // Player entering the field
  final DateTime createdAt;

  const MatchSubstitution({
    required this.id,
    required this.matchId,
    required this.period,
    required this.playerOut,
    required this.playerIn,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        period,
        playerOut,
        playerIn,
        createdAt,
      ];

  @override
  String toString() =>
      'MatchSubstitution(id: $id, period: $period, out: $playerOut, in: $playerIn)';

  /// Create a copy with updated fields
  MatchSubstitution copyWith({
    String? id,
    String? matchId,
    int? period,
    String? playerOut,
    String? playerIn,
    DateTime? createdAt,
  }) {
    return MatchSubstitution(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      period: period ?? this.period,
      playerOut: playerOut ?? this.playerOut,
      playerIn: playerIn ?? this.playerIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
