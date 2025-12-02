// lib/domain/matches/entities/match_goal.dart

import 'package:equatable/equatable.dart';

/// Represents a goal scored during a match
/// Maps to the public.match_goals table in Supabase
class MatchGoal extends Equatable {
  final String id;
  final String matchId;
  final int quarter; // 1-4 (quarter where goal was scored)
  final String scorerId; // Player who scored
  final String? assisterId; // Optional player who assisted
  final DateTime createdAt;

  const MatchGoal({
    required this.id,
    required this.matchId,
    required this.quarter,
    required this.scorerId,
    required this.createdAt,
    this.assisterId,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        quarter,
        scorerId,
        assisterId,
        createdAt,
      ];

  @override
  String toString() =>
      'MatchGoal(id: $id, quarter: $quarter, scorer: $scorerId${assisterId != null ? ', assist: $assisterId' : ''})';

  /// Create a copy with updated fields
  MatchGoal copyWith({
    String? id,
    String? matchId,
    int? quarter,
    String? scorerId,
    String? assisterId,
    DateTime? createdAt,
  }) {
    return MatchGoal(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      quarter: quarter ?? this.quarter,
      scorerId: scorerId ?? this.scorerId,
      assisterId: assisterId ?? this.assisterId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
