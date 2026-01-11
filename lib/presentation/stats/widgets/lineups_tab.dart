import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/domain/stats/entities/player_quarter_stats.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';
import 'package:sport_tech_app/presentation/stats/utils/stats_color_helpers.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class LineupsTab extends ConsumerStatefulWidget {
  const LineupsTab({super.key});

  @override
  ConsumerState<LineupsTab> createState() => _LineupsTabState();
}

class _LineupsTabState extends ConsumerState<LineupsTab> {
  int _sortColumnIndex = 0;
  bool _sortAscending =
      false; // Default to descending sort (best players first)

  void _sort(List<PlayerQuarterStats> stats, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      stats.sort((a, b) {
        int comparison = 0;
        switch (columnIndex) {
          case 0: // Player
            comparison = a.playerName.compareTo(b.playerName);
            break;
          case 1: // Quarters Played
            comparison = a.quartersPlayed.compareTo(b.quartersPlayed);
            break;
          case 2: // Won
            comparison = a.quartersWon.compareTo(b.quartersWon);
            break;
          case 3: // Draws
            comparison = a.quartersDrawn.compareTo(b.quartersDrawn);
            break;
          case 4: // Lost
            comparison = a.quartersLost.compareTo(b.quartersLost);
            break;
          case 5: // Win %
            comparison = a.winPercentage.compareTo(b.winPercentage);
            break;
        }
        return ascending ? comparison : -comparison;
      });
    });
  }

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
    final l10n = AppLocalizations.of(context)!;
    final statsState = ref.watch(statsNotifierProvider);
    // clone the list to allow sorting without mutating state directly (though copyWith should be used in notifier)
    // actually standard practice is to sort a local copy for display
    final lineups =
        List<PlayerQuarterStats>.from(statsState.playerQuarterStats);

    // Apply current sort
    if (lineups.isNotEmpty) {
      lineups.sort((a, b) {
        int comparison = 0;
        switch (_sortColumnIndex) {
          case 0: // Player
            comparison = a.playerName.compareTo(b.playerName);
            break;
          case 1: // Quarters Played
            comparison = a.quartersPlayed.compareTo(b.quartersPlayed);
            break;
          case 2: // Won
            comparison = a.quartersWon.compareTo(b.quartersWon);
            break;
          case 3: // Draws
            comparison = a.quartersDrawn.compareTo(b.quartersDrawn);
            break;
          case 4: // Lost
            comparison = a.quartersLost.compareTo(b.quartersLost);
            break;
          case 5: // Win %
            comparison = a.winPercentage.compareTo(b.winPercentage);
            break;
        }
        return _sortAscending ? comparison : -comparison;
      });
    }

    if (statsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lineups.isEmpty) {
      return Center(
        child: Text(l10n.noData),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.lineup,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 16,
              headingRowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columns: [
                DataColumn(
                  label: _buildColumnLabel(l10n.player, 0),
                  onSort: (columnIndex, ascending) =>
                      _sort(lineups, columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.quarters, 1),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort(lineups, columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.wins, 2),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort(lineups, columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.draws, 3),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort(lineups, columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.losses, 4),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort(lineups, columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.winPercentage, 5),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort(lineups, columnIndex, ascending),
                ),
              ],
              rows: lineups.map((stat) {
                final winRate = stat.winPercentage;
                final rateColor = getStatsPercentageColor(context, winRate);

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(stat.jerseyNumber,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                      fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text(
                            stat.playerName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(stat.quartersPlayed.toString())),
                    DataCell(Text(stat.quartersWon.toString())),
                    DataCell(Text(stat.quartersDrawn.toString())),
                    DataCell(Text(stat.quartersLost.toString())),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: rateColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${winRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: rateColor,
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
}
