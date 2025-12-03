import 'package:sport_tech_app/domain/stats/entities/scorer_stats.dart';

class ScorerStatsMapper {
  static ScorerStats fromJson(Map<String, dynamic> json) {
    return ScorerStats(
      playerId: json['player_id'].toString(),
      playerName: json['full_name'] as String,
      jerseyNumber: json['jersey_number']?.toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}
