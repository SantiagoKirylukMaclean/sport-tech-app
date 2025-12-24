// lib/domain/matches/entities/match_goal.dart

import 'package:equatable/equatable.dart';

/// Represents a goal scored during a match
/// Maps to the public.match_goals table in Supabase
class MatchGoal extends Equatable {
  final String id;
  final String matchId;
  final int quarter; // 1-4 (quarter where goal was scored)
  final String scorerId; // Player ID who scored
  final String scorerName; // Player name who scored
  final String? assisterId; // Optional player ID who assisted
  final String? assisterName; // Optional player name who assisted
  final DateTime createdAt;

  const MatchGoal({
    required this.id,
    required this.matchId,
    required this.quarter,
    required this.scorerId,
    required this.scorerName,
    required this.createdAt,
    this.assisterId,
    this.assisterName,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        quarter,
        scorerId,
        scorerName,
        assisterId,
        assisterName,
        createdAt,
      ];

  @override
  String toString() =>
      'MatchGoal(id: $id, quarter: $quarter, scorer: $scorerName${assisterName != null ? ', assist: $assisterName' : ''})';

  /// Create a copy with updated fields
  MatchGoal copyWith({
    String? id,
    String? matchId,
    int? quarter,
    String? scorerId,
    String? scorerName,
    String? assisterId,
    String? assisterName,
    DateTime? createdAt,
  }) {
    return MatchGoal(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      quarter: quarter ?? this.quarter,
      scorerId: scorerId ?? this.scorerId,
      scorerName: scorerName ?? this.scorerName,
      assisterId: assisterId ?? this.assisterId,
      assisterName: assisterName ?? this.assisterName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
