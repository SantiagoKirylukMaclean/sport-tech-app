import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';
import 'package:sport_tech_app/presentation/dashboard/widgets/player_stats_overview.dart';
import 'package:sport_tech_app/presentation/stats/widgets/team_stats_overview.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';

/// Widget displaying the complete player dashboard with all sections
class PlayerDashboardContent extends StatelessWidget {
  final PlayerStatistics playerStats;
  final List<MatchSummary> teamMatches;
  final int evaluationsCount;
  final double teamTrainingAttendance;
  final String playerName;
  final String teamName;
  final List<Team> availableTeams;
  final String? activeTeamId;
  final Function(String)? onTeamSelected;

  const PlayerDashboardContent({
    required this.playerStats,
    required this.teamMatches,
    required this.evaluationsCount,
    required this.teamTrainingAttendance,
    required this.playerName,
    required this.teamName,
    this.availableTeams = const [],
    this.activeTeamId,
    this.onTeamSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Selector (if multiple teams available)
          if (availableTeams.length > 1 &&
              activeTeamId != null &&
              onTeamSelected != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.groups_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.selectTeam,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: activeTeamId,
                                isExpanded: true,
                                isDense: true,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                items: availableTeams.map((team) {
                                  return DropdownMenuItem<String>(
                                    value: team.id,
                                    child: Text(
                                      team.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    onTeamSelected!(value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

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
