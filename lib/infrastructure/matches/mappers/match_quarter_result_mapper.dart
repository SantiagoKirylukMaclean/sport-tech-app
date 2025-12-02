// lib/infrastructure/matches/mappers/match_quarter_result_mapper.dart

import 'package:sport_tech_app/domain/matches/entities/match_quarter_result.dart';

/// Mapper for converting between Supabase JSON and MatchQuarterResult entity
class MatchQuarterResultMapper {
  /// Convert from Supabase JSON to MatchQuarterResult entity
  static MatchQuarterResult fromJson(Map<String, dynamic> json) {
    return MatchQuarterResult(
      id: json['id'].toString(),
      matchId: json['match_id'].toString(),
      quarter: json['quarter'] as int,
      teamGoals: json['team_goals'] as int,
      opponentGoals: json['opponent_goals'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert from MatchQuarterResult entity to Supabase JSON
  static Map<String, dynamic> toJson(MatchQuarterResult result) {
    return {
      'id': int.parse(result.id),
      'match_id': int.parse(result.matchId),
      'quarter': result.quarter,
      'team_goals': result.teamGoals,
      'opponent_goals': result.opponentGoals,
      'created_at': result.createdAt.toIso8601String(),
      'updated_at': result.updatedAt.toIso8601String(),
    };
  }
}
