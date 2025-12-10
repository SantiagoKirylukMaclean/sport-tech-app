import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';

/// Combined player statistics for goals and assists
class _PlayerGoalsAssists {
  final String playerId;
  final String playerName;
  final String? jerseyNumber;
  final int goals;
  final int assists;

  _PlayerGoalsAssists({
    required this.playerId,
    required this.playerName,
    required this.goals,
    required this.assists,
    this.jerseyNumber,
  });

  int get total => goals + assists;
}

class GoalsTab extends ConsumerStatefulWidget {
  const GoalsTab({super.key});

  @override
  ConsumerState<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends ConsumerState<GoalsTab> {
  int _sortColumnIndex = 3; // Default sort by total
  bool _sortAscending = false; // Descending by default

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statsState = ref.watch(statsNotifierProvider);
    final scorers = statsState.scorers;
    final assisters = statsState.assisters;

    // Combine scorers and assisters into a single list
    final combinedStats = _combinePlayerStats(scorers, assisters);

    if (combinedStats.isEmpty) {
      return Center(
        child: Text(l10n.noGoalsOrAssistsData),
      );
    }

    // Sort the combined stats
    _sortPlayerStats(combinedStats);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Goals & Assists',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              headingRowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              columns: [
                DataColumn(
                  label: Text(l10n.player),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: Text(l10n.goals),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: Text(l10n.assists),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: Text(l10n.total),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
              ],
              rows: combinedStats.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                final position = index + 1;

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: _getRankColor(position, context),
                            child: Text(
                              position.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                player.playerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (player.jerseyNumber != null)
                                Text(
                                  'Jersey #${player.jerseyNumber}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: player.goals > 0
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          player.goals.toString(),
                          style: TextStyle(
                            color: player.goals > 0
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                            fontWeight: player.goals > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: player.assists > 0
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          player.assists.toString(),
                          style: TextStyle(
                            color: player.assists > 0
                                ? Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                            fontWeight: player.assists > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          player.total.toString(),
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<_PlayerGoalsAssists> _combinePlayerStats(
    List scorers,
    List assisters,
  ) {
    final Map<String, _PlayerGoalsAssists> playersMap = {};

    // Add goals
    for (final scorer in scorers) {
      playersMap[scorer.playerId] = _PlayerGoalsAssists(
        playerId: scorer.playerId,
        playerName: scorer.playerName,
        jerseyNumber: scorer.jerseyNumber,
        goals: scorer.count,
        assists: 0,
      );
    }

    // Add assists
    for (final assister in assisters) {
      if (playersMap.containsKey(assister.playerId)) {
        final existing = playersMap[assister.playerId]!;
        playersMap[assister.playerId] = _PlayerGoalsAssists(
          playerId: existing.playerId,
          playerName: existing.playerName,
          jerseyNumber: existing.jerseyNumber,
          goals: existing.goals,
          assists: assister.count,
        );
      } else {
        playersMap[assister.playerId] = _PlayerGoalsAssists(
          playerId: assister.playerId,
          playerName: assister.playerName,
          jerseyNumber: assister.jerseyNumber,
          goals: 0,
          assists: assister.count,
        );
      }
    }

    return playersMap.values.toList();
  }

  void _sortPlayerStats(List<_PlayerGoalsAssists> stats) {
    switch (_sortColumnIndex) {
      case 0: // Player name
        stats.sort(
          (a, b) => _sortAscending
              ? a.playerName.compareTo(b.playerName)
              : b.playerName.compareTo(a.playerName),
        );
        break;
      case 1: // Goals
        stats.sort(
          (a, b) =>
              _sortAscending ? a.goals.compareTo(b.goals) : b.goals.compareTo(a.goals),
        );
        break;
      case 2: // Assists
        stats.sort(
          (a, b) => _sortAscending
              ? a.assists.compareTo(b.assists)
              : b.assists.compareTo(a.assists),
        );
        break;
      case 3: // Total
        stats.sort(
          (a, b) =>
              _sortAscending ? a.total.compareTo(b.total) : b.total.compareTo(a.total),
        );
        break;
    }
  }

  Color _getRankColor(int position, BuildContext context) {
    switch (position) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey; // Silver
      case 3:
        return Colors.brown; // Bronze
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
