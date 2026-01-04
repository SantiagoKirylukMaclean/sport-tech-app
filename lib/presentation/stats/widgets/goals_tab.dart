import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';
import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class GoalsTab extends ConsumerStatefulWidget {
  const GoalsTab({super.key});

  @override
  ConsumerState<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends ConsumerState<GoalsTab> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  Widget _buildColumnLabel(String text, int index) {
    if (_sortColumnIndex == index) {
      return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Icon(
          Icons.unfold_more,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(statsNotifierProvider);
    final playersStat = _getSortedPlayerStats(statsState.playerStatistics);
    final l10n = AppLocalizations.of(context)!;

    if (playersStat.isEmpty) {
      return Center(
        child: Text(l10n.noGoalsOrAssistsData),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.goalsAndAssists,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              horizontalMargin: 10,
              headingRowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columns: [
                DataColumn(
                  label: _buildColumnLabel(l10n.player, 0),
                  onSort: (columnIndex, ascending) {
                    _sort(columnIndex, ascending);
                  },
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.goals, 1),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    _sort(columnIndex, ascending);
                  },
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.assists, 2),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    _sort(columnIndex, ascending);
                  },
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.total, 3),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    _sort(columnIndex, ascending);
                  },
                ),
              ],
              rows: playersStat.map((player) {
                return DataRow(
                  cells: [
                    DataCell(Text(player.playerName)),
                    DataCell(
                      Text(
                        player.totalGoals.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(Text(player.totalAssists.toString())),
                    DataCell(
                      Text(
                        (player.totalGoals + player.totalAssists).toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
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

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<PlayerStatistics> _getSortedPlayerStats(List<PlayerStatistics> players) {
    if (players.isEmpty) return [];

    final sortedList = List<PlayerStatistics>.from(players);
    // Filter out players with no goals and no assists
    final activePlayers = sortedList
        .where((p) => p.totalGoals > 0 || p.totalAssists > 0)
        .toList();

    activePlayers.sort((a, b) {
      int comparison;
      switch (_sortColumnIndex) {
        case 0: // Player
          comparison = a.playerName.compareTo(b.playerName);
          break;
        case 1: // Goals
          comparison = a.totalGoals.compareTo(b.totalGoals);
          break;
        case 2: // Assists
          comparison = a.totalAssists.compareTo(b.totalAssists);
          break;
        case 3: // Total
          comparison = (a.totalGoals + a.totalAssists)
              .compareTo(b.totalGoals + b.totalAssists);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return activePlayers;
  }
}
