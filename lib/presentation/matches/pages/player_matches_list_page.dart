import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/application/matches/matches_notifier.dart';
import 'package:sport_tech_app/application/matches/matches_state.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/domain/matches/entities/match.dart';
import 'package:sport_tech_app/infrastructure/matches/providers/matches_repositories_providers.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';

/// Provider for matches with player participation status
final playerMatchesProvider =
    FutureProvider.autoDispose<List<PlayerMatchParticipation>>(
  (ref) async {
    final activeTeam = ref.watch(activeTeamNotifierProvider).activeTeam;
    if (activeTeam == null) return [];

    // Get current user's player ID
    final authState = ref.watch(authNotifierProvider);
    if (authState is! AuthStateAuthenticated) return [];

    final userId = authState.profile.userId;
    final playersRepo = ref.watch(playersRepositoryProvider);
    final playerResult = await playersRepo.getPlayersByUserId(userId);

    if (playerResult.dataOrNull == null || playerResult.dataOrNull!.isEmpty) {
      print('[PlayerMatchesList] No player found for user $userId');
      return [];
    }

    final playerId = playerResult.dataOrNull!.first.id;
    print('[PlayerMatchesList] Found player ID: $playerId for user $userId');

    final matchesNotifier =
        ref.watch(matchesNotifierProvider(activeTeam.id).notifier);
    await matchesNotifier.loadMatches();

    final matchesState = ref.watch(matchesNotifierProvider(activeTeam.id));
    if (matchesState is! MatchesStateLoaded) return [];

    final periodsRepo = ref.watch(matchPlayerPeriodsRepositoryProvider);
    final quarterResultsRepo = ref.watch(matchQuarterResultsRepositoryProvider);
    final participations = <PlayerMatchParticipation>[];

    for (final match in matchesState.matches) {
      // Check if player has any periods (quarters) played in this match
      final periodsResult = await periodsRepo.getPeriodsByMatchAndPlayer(
        matchId: match.id,
        playerId: playerId,
      );
      final periods = periodsResult.dataOrNull ?? [];
      final participated = periods.isNotEmpty;

      // Fetch match results
      final resultsResult =
          await quarterResultsRepo.getResultsByMatch(match.id);
      final results = resultsResult.dataOrNull ?? [];

      int? teamScore;
      int? opponentScore;

      if (results.isNotEmpty) {
        teamScore = results.fold<int>(0, (sum, res) => sum + res.teamGoals);
        opponentScore =
            results.fold<int>(0, (sum, res) => sum + res.opponentGoals);
      }

      participations.add(PlayerMatchParticipation(
        match: match,
        participated: participated,
        teamScore: teamScore,
        opponentScore: opponentScore,
      ));
    }

    return participations;
  },
);

/// Data class to hold match and participation status
class PlayerMatchParticipation {
  final Match match;
  final bool participated;
  final int? teamScore;
  final int? opponentScore;

  PlayerMatchParticipation({
    required this.match,
    required this.participated,
    this.teamScore,
    this.opponentScore,
  });
}

/// Page showing all matches with player participation indicator
class PlayerMatchesListPage extends ConsumerStatefulWidget {
  const PlayerMatchesListPage({super.key});

  @override
  ConsumerState<PlayerMatchesListPage> createState() =>
      _PlayerMatchesListPageState();
}

class _PlayerMatchesListPageState extends ConsumerState<PlayerMatchesListPage> {
  @override
  void initState() {
    super.initState();
    // Load matches when team is selected
    Future.microtask(() {
      final activeTeam = ref.read(activeTeamNotifierProvider).activeTeam;
      if (activeTeam != null) {
        ref.read(matchesNotifierProvider(activeTeam.id).notifier).loadMatches();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final activeTeam = activeTeamState.activeTeam;

    // Show message if no team is selected
    if (activeTeam == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.myMatches),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_soccer,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noTeamSelected,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.selectTeamToViewMatches,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final playerMatchesAsync = ref.watch(playerMatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myMatches),
      ),
      body: playerMatchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingMatches,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(playerMatchesProvider);
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (participations) {
          if (participations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.noMatchesPlayed,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.matchesWillAppearHere),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(playerMatchesProvider);
            },
            child: ListView.builder(
              itemCount: participations.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final participation = participations[index];
                final match = participation.match;
                final participated = participation.participated;
                final dateFormat = DateFormat('dd MMM yyyy', 'es');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: participated
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.sports_soccer,
                            size: 28,
                            color: participated
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                        if (participated)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            match.opponent,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!participated)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.didNotPlay,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(match.matchDate),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (match.location != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  match.location!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (participation.teamScore != null &&
                            participation.opponentScore != null)
                          Text(
                            '${participation.teamScore} - ${participation.opponentScore}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: participation.teamScore! >
                                      participation.opponentScore!
                                  ? Colors.green
                                  : participation.teamScore! <
                                          participation.opponentScore!
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to match detail page
                      context.push('/dashboard/player-matches/${match.id}');
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
