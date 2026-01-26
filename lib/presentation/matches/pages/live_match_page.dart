import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_providers.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/presentation/matches/widgets/basketball_stats_table.dart';

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

    // Timer Widget
    final timerWidget = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: _remainingSeconds / 30,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Live updates in $_remainingSeconds s',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );

    // Scoreboard Widget
    final scoreboard = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            timerWidget,
            const SizedBox(height: 16),
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
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'MY TEAM',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${state.teamScore}',
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                      ),
                    ],
                  ),
                ),
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
                            ?.copyWith(fontWeight: FontWeight.bold),
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
    );

    // Filtered Logs
    Widget buildEventLog() {
      final allStats = state.basketballStats;
      // Show last 3 events (assuming list is oldest->newest, reversed gives newest first)
      final recentStats = allStats.reversed.take(3).toList();

      if (isBasketball ? allStats.isEmpty : state.goals.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
                isBasketball ? l10n.noStatisticsRecorded : l10n.noGoalsRecorded,
                style: const TextStyle(color: Colors.grey)),
          ),
        );
      } else if (isBasketball) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentStats.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final stat = recentStats[index];
            final isPositive = stat.statType.pointsValue > 0;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: colorScheme.primary,
                child: Text(
                  stat.playerJerseyNumber?.toString() ??
                      (stat.playerId.length > 2
                          ? stat.playerId.substring(0, 2)
                          : stat.playerId),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              title: Text(
                stat.playerName ?? 'Player',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              subtitle: Text(
                stat.statType.displayName,
                style: TextStyle(
                  fontSize: 11,
                  color: isPositive ? Colors.green : Colors.grey[600],
                  fontWeight: isPositive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              trailing: stat.statType.pointsValue > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '+${stat.statType.pointsValue}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    )
                  : Icon(
                      _getIconForStatType(stat.statType),
                      color: Colors.grey,
                      size: 16,
                    ),
            );
          },
        );
      } else {
        return ListView.builder(
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
        );
      }
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 700;

              Widget topSection;

              if (isTablet) {
                topSection = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: scoreboard),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isBasketball
                                ? l10n.matchStatistics
                                : l10n.matchGoals,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          buildEventLog(),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                topSection = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    scoreboard,
                    const SizedBox(height: 24),
                    Text(
                      isBasketball ? l10n.matchStatistics : l10n.matchGoals,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    buildEventLog(),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  topSection,
                  // Basketball Stats Table (Team Convoked)
                  if (isBasketball && state.callUps.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Team Statistics',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: BasketballStatsTable(
                          callUps: state.callUps,
                          stats: state.basketballStats,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getIconForStatType(BasketballStatType type) {
    switch (type) {
      case BasketballStatType.reboundOff:
      case BasketballStatType.reboundDef:
        return Icons.sports_basketball;
      case BasketballStatType.assist:
        return Icons.handshake;
      case BasketballStatType.block:
        return Icons.pan_tool;
      case BasketballStatType.steal:
        return Icons.flash_on;
      case BasketballStatType.turnover:
        return Icons.loop;
      case BasketballStatType.foul:
        return Icons.warning;
      default:
        return Icons.circle;
    }
  }
}
