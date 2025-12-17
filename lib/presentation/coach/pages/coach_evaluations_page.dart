import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/application/evaluations/evaluations_providers.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/org/players_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';

class CoachEvaluationsPage extends ConsumerStatefulWidget {
  const CoachEvaluationsPage({super.key});

  @override
  ConsumerState<CoachEvaluationsPage> createState() =>
      _CoachEvaluationsPageState();
}

class _CoachEvaluationsPageState extends ConsumerState<CoachEvaluationsPage> {
  Map<String, int> _playerEvaluationCounts = {};
  bool _loadingCounts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlayers();
    });
  }

  void _loadPlayers() {
    final activeTeamState = ref.read(activeTeamNotifierProvider);
    if (activeTeamState.activeTeam != null) {
      ref
          .read(playersNotifierProvider.notifier)
          .loadPlayersByTeam(activeTeamState.activeTeam!.id, '1')
          .then((_) => _loadEvaluationCounts());
    }
  }

  Future<void> _loadEvaluationCounts() async {
    setState(() {
      _loadingCounts = true;
    });

    final playersState = ref.read(playersNotifierProvider);
    final Map<String, int> counts = {};

    for (final player in playersState.players) {
      try {
        final count = await ref
            .read(playerEvaluationsRepositoryProvider)
            .getEvaluationsCount(player.id);
        counts[player.id] = count;
      } catch (e) {
        counts[player.id] = 0;
      }
    }

    if (mounted) {
      setState(() {
        _playerEvaluationCounts = counts;
        _loadingCounts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final playersState = ref.watch(playersNotifierProvider);

    if (activeTeamState.activeTeam == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.evaluations),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppConstants.dashboardRoute),
          ),
        ),
        body: Center(
          child: Text(l10n.noTeamSelectedSelectFirst),
        ),
      );
    }

    if (playersState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.playerEvaluations),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppConstants.dashboardRoute),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (playersState.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.playerEvaluations),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppConstants.dashboardRoute),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.error,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('${playersState.error}'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPlayers,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (playersState.players.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.playerEvaluations),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppConstants.dashboardRoute),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noPlayersFoundForTeam,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      );
    }

    // Sort players by jersey number
    final sortedPlayers = List<Player>.from(playersState.players);
    sortedPlayers.sort((a, b) {
      final aNum = a.jerseyNumber ?? 999;
      final bNum = b.jerseyNumber ?? 999;
      return aNum.compareTo(bNum);
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadEvaluationCounts,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(l10n.playerEvaluations),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(AppConstants.dashboardRoute),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final player = sortedPlayers[index];
                    final evaluationCount = _playerEvaluationCounts[player.id] ?? 0;

                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          context.push(
                            '/evaluations/player/${player.id}',
                            extra: {
                              'playerId': player.id,
                              'playerName': player.fullName,
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Jersey number badge
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Center(
                                  child: Text(
                                    player.jerseyNumber?.toString() ?? '?',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Player name and evaluation count
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.fullName,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (_loadingCounts)
                                      SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      )
                                    else
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.assessment_outlined,
                                            size: 16,
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            l10n.evaluationsCount(evaluationCount.toString()),
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                                ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              // Evaluation count badge
                              if (!_loadingCounts)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: evaluationCount > 0
                                        ? Theme.of(context).colorScheme.secondaryContainer
                                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    evaluationCount.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: evaluationCount > 0
                                          ? Theme.of(context).colorScheme.onSecondaryContainer
                                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: sortedPlayers.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show player selection dialog for creating new evaluation
          _showPlayerSelectionDialog(context, sortedPlayers);
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newEvaluation),
      ),
    );
  }

  void _showPlayerSelectionDialog(BuildContext context, List<Player> players) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectAPlayer),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  child: Text(
                    player.jerseyNumber?.toString() ?? '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(player.fullName),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/coach-evaluations/new?playerId=${player.id}',
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
