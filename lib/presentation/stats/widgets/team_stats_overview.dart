import 'package:flutter/material.dart';
import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';
import 'package:sport_tech_app/presentation/stats/widgets/stat_card.dart';

/// Widget displaying an overview of team statistics
class TeamStatsOverview extends StatelessWidget {
  final List<MatchSummary> matches;

  const TeamStatsOverview({
    required this.matches,
    super.key,
  });

  int get _matchesPlayed => matches.length;

  double get _winPercentage {
    if (_matchesPlayed == 0) return 0.0;
    final wins = matches.where((m) => m.result == MatchResult.win).length;
    return (wins / _matchesPlayed) * 100;
  }

  int get _goalDifference {
    return matches.fold(
      0,
      (sum, match) => sum + (match.teamGoals - match.opponentGoals),
    );
  }

  int get _cleanSheets {
    return matches.where((m) => m.opponentGoals == 0).length;
  }

  double get _averageGoals {
    if (_matchesPlayed == 0) return 0.0;
    final totalGoals = matches.fold(0, (sum, match) => sum + match.teamGoals);
    return totalGoals / _matchesPlayed;
  }

  Color _getGoalDifferenceColor(BuildContext context) {
    if (_goalDifference > 0) {
      return Colors.green;
    } else if (_goalDifference < 0) {
      return Theme.of(context).colorScheme.error;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  String _getGoalDifferenceSubtitle() {
    if (_matchesPlayed == 0) return '';
    final goalsFor = matches.fold(0, (sum, match) => sum + match.teamGoals);
    final goalsAgainst =
        matches.fold(0, (sum, match) => sum + match.opponentGoals);
    return '$goalsFor a favor - $goalsAgainst en contra';
  }

  String _getMatchesPlayedSubtitle() {
    if (_matchesPlayed == 0) return '';
    final wins = matches.where((m) => m.result == MatchResult.win).length;
    final draws = matches.where((m) => m.result == MatchResult.draw).length;
    final losses = matches.where((m) => m.result == MatchResult.loss).length;
    return '${wins}V - ${draws}E - ${losses}D';
  }

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: StatCard(
              title: 'Partidos Jugados',
              value: '$_matchesPlayed',
              subtitle: _getMatchesPlayedSubtitle(),
              icon: Icons.sports_soccer,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: StatCard(
              title: '% Victorias',
              value: '${_winPercentage.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              valueColor: _winPercentage >= 50 ? Colors.green : null,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: StatCard(
              title: 'Diferencia de Goles',
              value: _goalDifference >= 0
                  ? '+$_goalDifference'
                  : '$_goalDifference',
              subtitle: _getGoalDifferenceSubtitle(),
              icon: Icons.sports_score,
              valueColor: _getGoalDifferenceColor(context),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: StatCard(
              title: 'Vallas Invictas',
              value: '$_cleanSheets',
              subtitle:
                  _matchesPlayed > 0
                      ? '${(_cleanSheets / _matchesPlayed * 100).toStringAsFixed(1)}% de los partidos'
                      : '',
              icon: Icons.shield,
              valueColor: _cleanSheets > 0 ? Colors.green : null,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: StatCard(
              title: 'Promedio de Goles',
              value: _averageGoals.toStringAsFixed(1),
              subtitle:
                  _matchesPlayed > 0
                      ? 'A favor: ${(matches.fold(0, (sum, m) => sum + m.teamGoals) / _matchesPlayed).toStringAsFixed(1)} | En contra: ${(matches.fold(0, (sum, m) => sum + m.opponentGoals) / _matchesPlayed).toStringAsFixed(1)}'
                      : '',
              icon: Icons.analytics,
            ),
          ),
        ],
      ),
    );
  }
}
