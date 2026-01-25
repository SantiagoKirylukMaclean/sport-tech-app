import 'package:sport_tech_app/domain/matches/entities/match.dart';

abstract class LiveMatchRepository {
  /// Get the current live match for a team, if any
  Future<Match?> getLiveMatch(String teamId);
}
