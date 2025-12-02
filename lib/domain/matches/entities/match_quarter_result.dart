// lib/domain/matches/entities/match_quarter_result.dart

import 'package:equatable/equatable.dart';

/// Represents the result of a specific quarter in a match
/// Maps to the public.match_quarter_results table in Supabase
class MatchQuarterResult extends Equatable {
  final String id;
  final String matchId;
  final int quarter; // 1-4
  final int teamGoals;
  final int opponentGoals;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MatchQuarterResult({
    required this.id,
    required this.matchId,
    required this.quarter,
    required this.teamGoals,
    required this.opponentGoals,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        quarter,
        teamGoals,
        opponentGoals,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'MatchQuarterResult(quarter: $quarter, team: $teamGoals, opponent: $opponentGoals)';

  /// Create a copy with updated fields
  MatchQuarterResult copyWith({
    String? id,
    String? matchId,
    int? quarter,
    int? teamGoals,
    int? opponentGoals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MatchQuarterResult(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      quarter: quarter ?? this.quarter,
      teamGoals: teamGoals ?? this.teamGoals,
      opponentGoals: opponentGoals ?? this.opponentGoals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
