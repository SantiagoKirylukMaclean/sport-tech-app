import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';

class BasketballMatchStatMapper {
  static BasketballMatchStat fromJson(Map<String, dynamic> json) {
    return BasketballMatchStat(
      id: json['id'].toString(),
      matchId: json['match_id'].toString(),
      playerId: json['player_id'].toString(),
      playerName: json['player'] != null ? json['player']['name'] : null,
      playerJerseyNumber:
          json['player'] != null ? json['player']['jersey_number'] : null,
      quarter: json['quarter'] as int,
      statType: BasketballStatType.fromString(json['stat_type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(BasketballMatchStat stat) {
    return {
      'id': int.tryParse(
          stat.id), // Assuming DB uses int ID, handled by Supabase usually
      'match_id': int.parse(stat.matchId),
      'player_id': int.parse(stat.playerId),
      'quarter': stat.quarter,
      'stat_type': stat.statType.value,
      'created_at': stat.createdAt.toIso8601String(),
    };
  }
}
