// lib/infrastructure/matches/mappers/match_call_up_mapper.dart

import 'package:sport_tech_app/domain/matches/entities/match_call_up.dart';

/// Mapper for converting between Supabase JSON and MatchCallUp entity
class MatchCallUpMapper {
  /// Convert from Supabase JSON to MatchCallUp entity
  static MatchCallUp fromJson(Map<String, dynamic> json) {
    return MatchCallUp(
      matchId: json['match_id'].toString(),
      playerId: json['player_id'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from MatchCallUp entity to Supabase JSON
  static Map<String, dynamic> toJson(MatchCallUp callUp) {
    return {
      'match_id': int.parse(callUp.matchId),
      'player_id': int.parse(callUp.playerId),
      'created_at': callUp.createdAt.toIso8601String(),
    };
  }
}
