import 'package:sport_tech_app/domain/stats/entities/quarter_performance.dart';

class QuarterPerformanceMapper {
  static QuarterPerformance fromJson(Map<String, dynamic> json) {
    final wins = (json['wins'] as num?)?.toInt() ?? 0;
    final draws = (json['draws'] as num?)?.toInt() ?? 0;
    final losses = (json['losses'] as num?)?.toInt() ?? 0;
    final totalGames = wins + draws + losses;

    double effectiveness = 0.0;
    if (totalGames > 0) {
      // Effectiveness: (wins * 3 + draws * 1) / (totalGames * 3) * 100
      effectiveness = ((wins * 3 + draws * 1) / (totalGames * 3) * 100);
    }

    return QuarterPerformance(
      quarterNumber: (json['quarter_number'] as num).toInt(),
      goalsFor: (json['goals_for'] as num?)?.toInt() ?? 0,
      goalsAgainst: (json['goals_against'] as num?)?.toInt() ?? 0,
      wins: wins,
      draws: draws,
      losses: losses,
      effectiveness: effectiveness,
    );
  }
}
