// lib/infrastructure/matches/mappers/match_mapper.dart

import 'package:sport_tech_app/domain/matches/entities/match.dart';

/// Mapper for converting between Supabase JSON and Match entity
class MatchMapper {
  /// Convert from Supabase JSON to Match entity
  static Match fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'].toString(),
      teamId: json['team_id'].toString(),
      opponent: json['opponent'] as String,
      matchDate: DateTime.parse(json['match_date'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from Match entity to Supabase JSON
  static Map<String, dynamic> toJson(Match match) {
    return {
      'id': int.parse(match.id),
      'team_id': int.parse(match.teamId),
      'opponent': match.opponent,
      'match_date': match.matchDate.toIso8601String().split('T')[0],
      'location': match.location,
      'notes': match.notes,
      'created_at': match.createdAt.toIso8601String(),
    };
  }
}
