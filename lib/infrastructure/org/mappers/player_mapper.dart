// lib/infrastructure/org/mappers/player_mapper.dart

import 'package:sport_tech_app/domain/org/entities/player.dart';

/// Mapper for converting between Supabase JSON and Player entity
class PlayerMapper {
  /// Convert from Supabase JSON to Player entity
  static Player fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String,
      jerseyNumber: json['jersey_number'] as int?,
      positionId: json['position_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert from Player entity to Supabase JSON
  static Map<String, dynamic> toJson(Player player) {
    return {
      'id': player.id,
      'team_id': player.teamId,
      'user_id': player.userId,
      'full_name': player.fullName,
      'jersey_number': player.jerseyNumber,
      'position_id': player.positionId,
      'created_at': player.createdAt.toIso8601String(),
    };
  }
}
