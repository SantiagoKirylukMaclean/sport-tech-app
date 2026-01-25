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
      numberOfPeriods: json['number_of_periods'] as int?,
      periodDuration: json['period_duration'] as int?,
      status: _parseStatus(json['status'] as String?),
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
      'number_of_periods': match.numberOfPeriods,
      'period_duration': match.periodDuration,
      'status': match.status.name,
      'created_at': match.createdAt.toIso8601String(),
    };
  }

  static MatchStatus _parseStatus(String? status) {
    if (status == null) return MatchStatus.scheduled;
    try {
      return MatchStatus.values.firstWhere((e) => e.name == status);
    } catch (_) {
      return MatchStatus.scheduled;
    }
  }
}
