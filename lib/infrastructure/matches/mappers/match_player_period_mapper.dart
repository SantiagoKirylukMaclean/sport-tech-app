// lib/infrastructure/matches/mappers/match_player_period_mapper.dart

import 'package:sport_tech_app/domain/matches/entities/field_zone.dart';
import 'package:sport_tech_app/domain/matches/entities/match_player_period.dart';

/// Mapper for converting between Supabase JSON and MatchPlayerPeriod entity
class MatchPlayerPeriodMapper {
  /// Convert from Supabase JSON to MatchPlayerPeriod entity
  static MatchPlayerPeriod fromJson(Map<String, dynamic> json) {
    return MatchPlayerPeriod(
      matchId: json['match_id'].toString(),
      playerId: json['player_id'].toString(),
      period: json['period'] as int,
      fraction: Fraction.fromString(json['fraction'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      fieldZone: json['field_zone'] != null
          ? FieldZone.fromString(json['field_zone'] as String)
          : null,
    );
  }

  /// Convert from MatchPlayerPeriod entity to Supabase JSON
  static Map<String, dynamic> toJson(MatchPlayerPeriod period) {
    final json = {
      'match_id': int.parse(period.matchId),
      'player_id': period.playerId, // Keep as string (UUID)
      'period': period.period,
      'fraction': period.fraction.value,
      'created_at': period.createdAt.toIso8601String(),
    };

    if (period.fieldZone != null) {
      json['field_zone'] = period.fieldZone!.value;
    }

    return json;
  }
}
