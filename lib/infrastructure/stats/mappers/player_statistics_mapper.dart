import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';

class PlayerStatisticsMapper {
  static PlayerStatistics fromJson(Map<String, dynamic> json) {
    return PlayerStatistics(
      playerId: json['player_id'].toString(),
      playerName: json['full_name'] as String,
      jerseyNumber: json['jersey_number']?.toString(),
      totalMatches: (json['total_matches'] as num?)?.toInt() ?? 0,
      totalTrainingSessions: (json['total_trainings'] as num?)?.toInt() ?? 0,
      matchesAttended: (json['matches_called_up'] as num?)?.toInt() ?? 0,
      trainingsAttended: (json['trainings_attended'] as num?)?.toInt() ?? 0,
      matchAttendancePercentage: (json['match_attendance_pct'] as num?)?.toDouble() ?? 0.0,
      trainingAttendancePercentage: (json['training_attendance_pct'] as num?)?.toDouble() ?? 0.0,
      averagePeriods: (json['avg_periods_played'] as num?)?.toDouble() ?? 0.0,
      totalGoals: (json['total_goals'] as num?)?.toInt() ?? 0,
      totalAssists: (json['total_assists'] as num?)?.toInt() ?? 0,
    );
  }
}
