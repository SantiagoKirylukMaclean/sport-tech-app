// lib/infrastructure/matches/mappers/match_goal_mapper.dart

import 'package:sport_tech_app/domain/matches/entities/match_goal.dart';

/// Mapper for converting between Supabase JSON and MatchGoal entity
class MatchGoalMapper {
  /// Convert from Supabase JSON to MatchGoal entity
  static MatchGoal fromJson(Map<String, dynamic> json) {
    return MatchGoal(
      id: json['id'].toString(),
      matchId: json['match_id'].toString(),
      quarter: json['quarter'] as int,
      scorerId: json['scorer_id'].toString(),
      assisterId: json['assister_id']?.toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from MatchGoal entity to Supabase JSON
  static Map<String, dynamic> toJson(MatchGoal goal) {
    return {
      'id': int.parse(goal.id),
      'match_id': int.parse(goal.matchId),
      'quarter': goal.quarter,
      'scorer_id': int.parse(goal.scorerId),
      'assister_id':
          goal.assisterId != null ? int.parse(goal.assisterId!) : null,
      'created_at': goal.createdAt.toIso8601String(),
    };
  }
}
