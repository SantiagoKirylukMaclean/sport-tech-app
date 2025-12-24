// lib/infrastructure/matches/mappers/match_goal_mapper.dart

import 'package:sport_tech_app/domain/matches/entities/match_goal.dart';

/// Mapper for converting between Supabase JSON and MatchGoal entity
class MatchGoalMapper {
  /// Convert from Supabase JSON to MatchGoal entity
  /// Expects JSON with joined player data (scorer_name, assister_name)
  static MatchGoal fromJson(Map<String, dynamic> json) {
    // Handle nested player objects or direct fields
    final scorerName = json['scorer_name'] as String? ??
                      json['scorer']?['full_name'] as String? ??
                      'Unknown Player';
    final assisterName = json['assister_name'] as String? ??
                        json['assister']?['full_name'] as String?;

    return MatchGoal(
      id: json['id'].toString(),
      matchId: json['match_id'].toString(),
      quarter: json['quarter'] as int,
      scorerId: json['scorer_id'].toString(),
      scorerName: scorerName,
      assisterId: json['assister_id']?.toString(),
      assisterName: assisterName,
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
