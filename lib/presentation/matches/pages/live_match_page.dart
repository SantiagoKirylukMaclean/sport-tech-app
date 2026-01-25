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
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
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
                (state.sportName != null &&
                        state.sportName!.toLowerCase().contains('basket'))
                    ? l10n.matchStatistics
                    : l10n.matchGoals,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if ((state.sportName != null &&
                      state.sportName!.toLowerCase().contains('basket'))
                  ? state.basketballStats.isEmpty
                  : state.goals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                        (state.sportName != null &&
                                state.sportName!
                                    .toLowerCase()
                                    .contains('basket'))
                            ? l10n.noStatisticsRecorded
                            : l10n.noGoalsRecorded,
                        style: const TextStyle(color: Colors.grey)),
                  ),
                )
              else if (state.sportName != null &&
                  state.sportName!.toLowerCase().contains('basket'))
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.basketballStats.length,
                  itemBuilder: (context, index) {
                    final stat = state.basketballStats[index];
                    String titleText;
                    if (stat.statType.pointsValue > 0) {
                      final pointLabel =
                          l10n.statPoint(stat.statType.pointsValue);
                      titleText =
                          '${stat.statType.pointsValue} $pointLabel ${stat.playerName ?? ''}';
                    } else {
                      String statName = stat.statType.displayName;
                      switch (stat.statType) {
                        case BasketballStatType.reboundOff:
                          statName = l10n.reboundOff;
                          break;
                        case BasketballStatType.reboundDef:
                          statName = l10n.reboundDef;
                          break;
                        case BasketballStatType.assist:
                          statName = l10n.assistStat;
                          break;
                        case BasketballStatType.block:
                          statName = l10n.block;
                          break;
                        case BasketballStatType.steal:
                          statName = l10n.steal;
                          break;
                        case BasketballStatType.turnover:
                          statName = l10n.turnover;
                          break;
                        case BasketballStatType.foul:
                          statName = l10n.foul;
                          break;
                        default:
                          break;
                      }
                      titleText = '$statName ${stat.playerName ?? ''}';
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: Text(
                          '${stat.quarter}Q',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                      title: Text(titleText),
                      trailing: const Icon(Icons.sports_basketball),
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
              // Auto-refresh indicator text
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 8),
                    Text(
                      'Live updates active', // TODO: Localize
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
