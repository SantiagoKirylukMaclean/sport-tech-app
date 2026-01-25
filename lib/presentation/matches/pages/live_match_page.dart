import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_providers.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class LiveMatchPage extends ConsumerStatefulWidget {
  final String matchId;

  const LiveMatchPage({
    required this.matchId,
    super.key,
  });

  @override
  ConsumerState<LiveMatchPage> createState() => _LiveMatchPageState();
}

class _LiveMatchPageState extends ConsumerState<LiveMatchPage> {
  Timer? _timer;
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _startPolling();
    });
  }

  void _loadData() {
    ref
        .read(liveMatchDetailNotifierProvider.notifier)
        .loadMatchDetails(widget.matchId);
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _remainingSeconds = 30;
            _loadData();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveMatchDetailNotifierProvider);
    final match = state.match;
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading && match == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.matchLive)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.matchLive)),
        body: Center(child: Text(state.error ?? l10n.errorLoadingMatchDetail)),
      );
    }

    final isBasketball = state.sportName != null &&
        (state.sportName!.toLowerCase().contains('basket') ||
            state.sportName!.toLowerCase().contains('básq') ||
            state.sportName!.toLowerCase().contains('baloncesto'));

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.matchLive} vs ${match.opponent}'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scoreboard
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        l10n.matchLive.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // My Team Score
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'MY TEAM', // Placeholder or fetch team name
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${state.teamScore}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // VS
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '-',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 48,
                                  color: Colors.grey),
                            ),
                          ),
                          // Opponent Score
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  match.opponent.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${state.opponentScore}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Goals / Events Timeline
              Text(
                isBasketball ? l10n.matchStatistics : l10n.matchGoals,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (isBasketball
                  ? state.basketballStats.isEmpty
                  : state.goals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                        isBasketball
                            ? l10n.noStatisticsRecorded
                            : l10n.noGoalsRecorded,
                        style: const TextStyle(color: Colors.grey)),
                  ),
                )
              else if (isBasketball)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.basketballStats.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final stat = state.basketballStats[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            colorScheme.primary, // Blue-ish usually
                        foregroundColor: colorScheme.onPrimary,
                        child: Text(
                          stat.playerJerseyNumber?.toString() ??
                              stat.playerId.substring(0, 1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(stat.playerName ?? 'Player ${stat.playerId}'),
                      subtitle: Text(stat.statType.displayName),
                      trailing: Icon(Icons.sports_basketball,
                          color: stat.statType.pointsValue > 0
                              ? Colors.green
                              : Colors.orange),
                    );
                  },
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.goals.length,
                  itemBuilder: (context, index) {
                    final goal = state.goals[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          '${goal.quarter}Q',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(goal.scorerName),
                      subtitle: goal.assisterName != null
                          ? Text(l10n.assist(goal.assisterName!))
                          : null,
                      trailing: const Icon(Icons.sports_soccer),
                    );
                  },
                ),

              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: _remainingSeconds / 30,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Live updates in $_remainingSeconds s', // TODO: Localize
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
