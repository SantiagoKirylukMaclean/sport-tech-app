// lib/infrastructure/matches/mappers/match_substitution_mapper.dart

import 'package:sport_tech_app/domain/matches/entities/match_substitution.dart';

/// Mapper for converting between Supabase JSON and MatchSubstitution entity
class MatchSubstitutionMapper {
  /// Convert from Supabase JSON to MatchSubstitution entity
  static MatchSubstitution fromJson(Map<String, dynamic> json) {
    return MatchSubstitution(
      id: json['id'].toString(),
      matchId: json['match_id'].toString(),
      period: json['period'] as int,
      playerOut: json['player_out'].toString(),
      playerIn: json['player_in'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from MatchSubstitution entity to Supabase JSON
  static Map<String, dynamic> toJson(MatchSubstitution substitution) {
    return {
      'id': int.parse(substitution.id),
      'match_id': int.parse(substitution.matchId),
      'period': substitution.period,
      'player_out': int.parse(substitution.playerOut),
      'player_in': int.parse(substitution.playerIn),
      'created_at': substitution.createdAt.toIso8601String(),
    };
  }
}
