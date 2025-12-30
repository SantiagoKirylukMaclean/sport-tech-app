import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';
import 'package:sport_tech_app/presentation/dashboard/widgets/player_stats_overview.dart';
import 'package:sport_tech_app/presentation/stats/widgets/team_stats_overview.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

/// Widget displaying the complete player dashboard with all sections
class PlayerDashboardContent extends StatelessWidget {
  final PlayerStatistics playerStats;
  final List<MatchSummary> teamMatches;
  final int evaluationsCount;
  final double teamTrainingAttendance;
  final String playerName;
  final String teamName;

  const PlayerDashboardContent({
    required this.playerStats,
    required this.teamMatches,
    required this.evaluationsCount,
    required this.teamTrainingAttendance,
    required this.playerName,
    required this.teamName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Player Personal Statistics
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.myStatistics(playerName),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          PlayerStatsOverview(stats: playerStats),

          const SizedBox(height: 24),

          // Section 2: Team Statistics
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l10n.teamStatistics(teamName),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          TeamStatsOverview(
            matches: teamMatches,
            teamTrainingAttendance: teamTrainingAttendance,
            enableInteraction: false,
          ),

          const SizedBox(height: 24),

          // Section 3: Evaluations Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: InkWell(
                onTap: () {
                  // Navigate to evaluations page
                  context.go(AppConstants.evaluationsRoute);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.assessment,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.evaluations,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.evaluationsCount(
                                  evaluationsCount.toString()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
