// lib/infrastructure/org/mappers/player_mapper.dart

import 'package:sport_tech_app/domain/org/entities/player.dart';

/// Mapper for converting between Supabase JSON and Player entity
class PlayerMapper {
  /// Convert from Supabase JSON to Player entity
  static Player fromJson(Map<String, dynamic> json) {
    try {
      print('DEBUG PlayerMapper: Converting JSON: $json');
      print('DEBUG PlayerMapper: team_id value: ${json['team_id']} (type: ${json['team_id'].runtimeType})');

      final player = Player(
        id: json['id'].toString(),
        teamId: json['team_id'].toString(),
        userId: json['user_id']?.toString(),
        fullName: json['full_name'] as String,
        jerseyNumber: json['jersey_number'] as int?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

      print('DEBUG PlayerMapper: Successfully created player: ${player.fullName}');
      return player;
    } catch (e, stackTrace) {
      print('DEBUG PlayerMapper: ERROR converting JSON: $e');
      print('DEBUG PlayerMapper: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Convert from Player entity to Supabase JSON
  static Map<String, dynamic> toJson(Player player) {
    return {
      'id': player.id,
      'team_id': player.teamId,
      'user_id': player.userId,
      'full_name': player.fullName,
      'jersey_number': player.jerseyNumber,
      'created_at': player.createdAt.toIso8601String(),
    };
  }
}
