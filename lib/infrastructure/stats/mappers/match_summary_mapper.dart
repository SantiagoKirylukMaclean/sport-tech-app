import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';

class MatchSummaryMapper {
  static MatchSummary fromJson(Map<String, dynamic> json) {
    final teamGoals = (json['team_goals'] as num?)?.toInt() ?? 0;
    final opponentGoals = (json['opponent_goals'] as num?)?.toInt() ?? 0;

    MatchResult result;
    if (teamGoals > opponentGoals) {
      result = MatchResult.win;
    } else if (teamGoals < opponentGoals) {
      result = MatchResult.loss;
    } else {
      result = MatchResult.draw;
    }

    return MatchSummary(
      matchId: json['match_id'].toString(),
      opponent: json['opponent'] as String,
      matchDate: DateTime.parse(json['match_date'] as String),
      teamGoals: teamGoals,
      opponentGoals: opponentGoals,
      result: result,
    );
  }
}
