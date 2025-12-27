import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/domain/matches/entities/match.dart';
import 'package:sport_tech_app/domain/matches/entities/match_player_period.dart';
import 'package:sport_tech_app/domain/matches/entities/match_goal.dart';
import 'package:sport_tech_app/domain/matches/entities/match_quarter_result.dart';
import 'package:sport_tech_app/infrastructure/matches/providers/matches_repositories_providers.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// Provider to get player's match details
final playerMatchDetailProvider =
    FutureProvider.autoDispose.family<PlayerMatchDetail?, String>((ref, matchId) async {
  try {
    final authState = ref.watch(authNotifierProvider);
    if (authState is! AuthStateAuthenticated) {
      print('[PlayerMatchDetail] User not authenticated');
      return null;
    }

    final userId = authState.profile.userId;
    print('[PlayerMatchDetail] Loading match $matchId for user $userId');

    // Fetch match info
    final matchesRepo = ref.watch(matchesRepositoryProvider);
    final matchResult = await matchesRepo.getMatchById(matchId);

    if (matchResult.dataOrNull == null) {
      print('[PlayerMatchDetail] Match not found: $matchId');
      final failure = matchResult.failureOrNull;
      if (failure != null) {
        print('[PlayerMatchDetail] Match error: $failure');
      }
      return null;
    }
    final match = matchResult.dataOrNull!;
    print('[PlayerMatchDetail] Match loaded: ${match.opponent}');

    // Get player.id from user_id
    final playersRepo = ref.watch(playersRepositoryProvider);
    final playerResult = await playersRepo.getPlayerByUserId(userId);

    if (playerResult.dataOrNull == null) {
      print('[PlayerMatchDetail] ❌ No player found for user $userId');
      final failure = playerResult.failureOrNull;
      if (failure != null) {
        print('[PlayerMatchDetail] Error: ${failure.message}');
      }
      return null;
    }
    final player = playerResult.dataOrNull!;
    final playerId = player.id;
    print('[PlayerMatchDetail] Found player ID: $playerId for user $userId');

    // Fetch player periods - use direct query for better performance
    final periodsRepo = ref.watch(matchPlayerPeriodsRepositoryProvider);
    final playerPeriodsResult = await periodsRepo.getPeriodsByMatchAndPlayer(
      matchId: matchId,
      playerId: playerId,
    );

    final periodsFailure = playerPeriodsResult.failureOrNull;
    if (periodsFailure != null) {
      print('[PlayerMatchDetail] ❌ ERROR loading periods');
      print('[PlayerMatchDetail] Error message: ${periodsFailure.message}');
      print('[PlayerMatchDetail] Error code: ${periodsFailure.code}');
      print('[PlayerMatchDetail] Query params - matchId: $matchId (${matchId.runtimeType}), playerId: $playerId (${playerId.runtimeType})');
    }
    final myPeriods = playerPeriodsResult.dataOrNull ?? [];
    print('[PlayerMatchDetail] Player periods: ${myPeriods.length}');

    // Fetch quarter results
    final quarterResultsRepo = ref.watch(matchQuarterResultsRepositoryProvider);
    final quarterResultsResult = await quarterResultsRepo.getResultsByMatch(matchId);

    final quarterResultsFailure = quarterResultsResult.failureOrNull;
    if (quarterResultsFailure != null) {
      print('[PlayerMatchDetail] Error loading quarter results: $quarterResultsFailure');
    }
    final quarterResults = quarterResultsResult.dataOrNull ?? [];
    print('[PlayerMatchDetail] Quarter results: ${quarterResults.length}');

    // Fetch all goals
    final goalsRepo = ref.watch(matchGoalsRepositoryProvider);
    final allGoalsResult = await goalsRepo.getGoalsByMatch(matchId);

    final goalsFailure = allGoalsResult.failureOrNull;
    if (goalsFailure != null) {
      print('[PlayerMatchDetail] Error loading goals: $goalsFailure');
    }
    final allGoals = allGoalsResult.dataOrNull ?? [];
    print('[PlayerMatchDetail] Total goals: ${allGoals.length}');

    // Filter goals and assists by player
    final myGoals = allGoals.where((g) => g.scorerId == playerId).toList();
    final myAssists = allGoals.where((g) => g.assisterId == playerId).toList();
    print('[PlayerMatchDetail] My goals: ${myGoals.length}, assists: ${myAssists.length}');

    final detail = PlayerMatchDetail(
      match: match,
      playerPeriods: myPeriods,
      quarterResults: quarterResults,
      myGoals: myGoals,
      myAssists: myAssists,
      allGoals: allGoals,
    );

    print('[PlayerMatchDetail] Successfully loaded match detail');
    return detail;
  } catch (e, stackTrace) {
    print('[PlayerMatchDetail] Unexpected error: $e');
    print('[PlayerMatchDetail] Stack trace: $stackTrace');
    rethrow;
  }
});

/// Data class for player match details
class PlayerMatchDetail {
  final Match match;
  final List<MatchPlayerPeriod> playerPeriods;
  final List<MatchQuarterResult> quarterResults;
  final List<MatchGoal> myGoals;
  final List<MatchGoal> myAssists;
  final List<MatchGoal> allGoals;

  PlayerMatchDetail({
    required this.match,
    required this.playerPeriods,
    required this.quarterResults,
    required this.myGoals,
    required this.myAssists,
    required this.allGoals,
  });

  /// Calculate total quarters played considering fractions
  /// FULL = 1.0, HALF = 0.5
  double get quartersPlayed {
    return playerPeriods.fold<double>(0.0, (sum, period) {
      return sum + (period.fraction == Fraction.full ? 1.0 : 0.5);
    });
  }

  List<int> get quartersPlayedList => playerPeriods.map((p) => p.period).toList()..sort();

  bool get didPlay => playerPeriods.isNotEmpty;
}

/// Page showing player's personal match details
class PlayerMatchDetailPage extends ConsumerWidget {
  final String matchId;

  const PlayerMatchDetailPage({
    required this.matchId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(playerMatchDetailProvider(matchId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.matchDetail),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingMatchDetail,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(playerMatchDetailProvider(matchId));
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (detail) {
          if (detail == null) {
            return Center(
              child: Text(l10n.matchNotFound),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(playerMatchDetailProvider(matchId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Match Info Card
                  _MatchInfoCard(
                    opponent: detail.match.opponent,
                    matchDate: detail.match.matchDate,
                    location: detail.match.location,
                  ),
                  const SizedBox(height: 24),

                  // My Performance Section
                  Text(
                    l10n.myPerformance,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _MyPerformanceCard(detail: detail, l10n: l10n),
                  const SizedBox(height: 24),

                  // Quarters Played Section
                  Text(
                    l10n.quartersPlayed,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _QuartersPlayedSection(playerPeriods: detail.playerPeriods, l10n: l10n),
                  const SizedBox(height: 24),

                  // Match Results Section
                  Text(
                    l10n.matchResults,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _QuarterResultsSection(quarterResults: detail.quarterResults, l10n: l10n),
                  const SizedBox(height: 24),

                  // Match Goals Section
                  Text(
                    l10n.matchGoals,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _MatchGoalsSection(goals: detail.allGoals, l10n: l10n),
                  const SizedBox(height: 24),

                  // Coming Soon Sections
                  Text(
                    l10n.comingSoon,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _ComingSoonCard(
                    icon: Icons.star_rate,
                    title: l10n.matchRating,
                    description: l10n.matchRatingDescription,
                  ),
                  const SizedBox(height: 12),
                  _ComingSoonCard(
                    icon: Icons.notes,
                    title: l10n.matchNotes,
                    description: l10n.matchNotesDescription,
                  ),
                  const SizedBox(height: 12),
                  _ComingSoonCard(
                    icon: Icons.video_library,
                    title: l10n.videoAnalysis,
                    description: l10n.videoAnalysisDescription,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Card showing match information
class _MatchInfoCard extends StatelessWidget {
  final String opponent;
  final DateTime matchDate;
  final String? location;

  const _MatchInfoCard({
    required this.opponent,
    required this.matchDate,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'es');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.sports_soccer,
                    size: 28,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opponent,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(matchDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (location != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card showing player's performance summary
class _MyPerformanceCard extends StatelessWidget {
  final PlayerMatchDetail detail;
  final AppLocalizations l10n;

  const _MyPerformanceCard({
    required this.detail,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatColumn(
              icon: Icons.timer,
              label: l10n.quarters,
              value: '${detail.quartersPlayed % 1 == 0 ? detail.quartersPlayed.toInt() : detail.quartersPlayed.toStringAsFixed(1)}/4',
              color: Theme.of(context).colorScheme.primary,
            ),
            _StatColumn(
              icon: Icons.sports_score,
              label: l10n.goals,
              value: '${detail.myGoals.length}',
              color: Colors.green,
            ),
            _StatColumn(
              icon: Icons.sports_handball,
              label: l10n.assists,
              value: '${detail.myAssists.length}',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

/// Column showing a single stat
class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// Section showing quarters played by the player
class _QuartersPlayedSection extends StatelessWidget {
  final List<MatchPlayerPeriod> playerPeriods;
  final AppLocalizations l10n;

  const _QuartersPlayedSection({
    required this.playerPeriods,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (playerPeriods.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(l10n.didNotPlayInThisMatch),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Visual representation of quarters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final quarter = index + 1;
                final period = playerPeriods.where((p) => p.period == quarter).firstOrNull;
                final played = period != null;
                final isFull = period?.fraction == Fraction.full;

                return Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: played
                            ? (isFull
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.5))
                            : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Q$quarter',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: played
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (played)
                      Icon(
                        isFull ? Icons.check_circle : Icons.check_circle_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Details for each quarter played
            ...playerPeriods.map((period) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${l10n.quarter} ${period.period}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (period.fieldZone != null)
                            Text(
                              '${l10n.position}: ${_formatFieldZone(period.fieldZone!.value)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          Text(
                            period.fraction == Fraction.full
                                ? l10n.fullQuarter
                                : l10n.halfQuarter,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatFieldZone(String zone) {
    // Format field zone for display
    return zone.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

/// Section showing quarter results
class _QuarterResultsSection extends StatelessWidget {
  final List<MatchQuarterResult> quarterResults;
  final AppLocalizations l10n;

  const _QuarterResultsSection({
    required this.quarterResults,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (quarterResults.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(l10n.noQuarterResultsRecorded),
          ),
        ),
      );
    }

    // Calculate total score
    int totalTeamGoals = 0;
    int totalOpponentGoals = 0;
    for (final result in quarterResults) {
      totalTeamGoals += result.teamGoals;
      totalOpponentGoals += result.opponentGoals;
    }

    final won = totalTeamGoals > totalOpponentGoals;
    final tied = totalTeamGoals == totalOpponentGoals;

    return Column(
      children: [
        // Total Score Card
        Card(
          color: won
              ? Colors.green.shade100
              : tied
                  ? Colors.grey.shade300
                  : Colors.red.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.finalResult,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalTeamGoals - $totalOpponentGoals',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  won
                      ? l10n.victory
                      : tied
                          ? l10n.tie
                          : l10n.defeat,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Quarter by quarter breakdown
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...List.generate(4, (index) {
                  final quarter = index + 1;
                  final result = quarterResults.where((r) => r.quarter == quarter).firstOrNull;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            '${l10n.quarter} $quarter',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const Spacer(),
                        if (result != null)
                          Text(
                            '${result.teamGoals} - ${result.opponentGoals}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        else
                          Text(
                            l10n.noData,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Section showing all match goals
class _MatchGoalsSection extends StatelessWidget {
  final List<MatchGoal> goals;
  final AppLocalizations l10n;

  const _MatchGoalsSection({
    required this.goals,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(l10n.noGoalsRecorded),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: goals.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final goal = goals[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              child: Icon(
                Icons.sports_score,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
            title: Text(
              goal.scorerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: goal.assisterName != null
                ? Text(l10n.assist(goal.assisterName!))
                : null,
            trailing: Chip(
              label: Text('${l10n.quarter} ${goal.quarter}'),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
          );
        },
      ),
    );
  }
}

/// Card showing coming soon feature
class _ComingSoonCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ComingSoonCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
