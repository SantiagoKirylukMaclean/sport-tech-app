import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';
import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/presentation/stats/utils/stats_color_helpers.dart';

import 'package:sport_tech_app/l10n/app_localizations.dart';

class PlayersTab extends ConsumerStatefulWidget {
  const PlayersTab({super.key});

  @override
  ConsumerState<PlayersTab> createState() => _PlayersTabState();
}

class _PlayersTabState extends ConsumerState<PlayersTab> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<PlayerStatistics> _getSortedPlayers(List<PlayerStatistics> players) {
    final sortedPlayers = List<PlayerStatistics>.from(players);

    sortedPlayers.sort((a, b) {
      int comparison;

      switch (_sortColumnIndex) {
        case 0: // Player name
          comparison = a.playerName.compareTo(b.playerName);
          break;
        case 1: // Jersey number
          final aJersey = a.jerseyNumber ?? '';
          final bJersey = b.jerseyNumber ?? '';
          // Try to compare as numbers first, if both are numeric
          final aNum = int.tryParse(aJersey);
          final bNum = int.tryParse(bJersey);
          if (aNum != null && bNum != null) {
            comparison = aNum.compareTo(bNum);
          } else {
            comparison = aJersey.compareTo(bJersey);
          }
          break;
        case 2: // Training %
          comparison = a.trainingAttendancePercentage
              .compareTo(b.trainingAttendancePercentage);
          break;
        case 3: // Match %
          comparison = a.matchAttendancePercentage
              .compareTo(b.matchAttendancePercentage);
          break;
        case 4: // Avg Periods
          comparison = a.averagePeriods.compareTo(b.averagePeriods);
          break;
        case 5: // Goals
          comparison = a.totalGoals.compareTo(b.totalGoals);
          break;
        case 6: // Assists
          comparison = a.totalAssists.compareTo(b.totalAssists);
          break;
        default:
          comparison = 0;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sortedPlayers;
  }

  Widget _buildColumnLabel(String text, int index) {
    // If this column is the sorted one, the DataTable will show the arrow.
    // We only want to show the "sortable" indicator (unfold_more) if it's NOT sorted.
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
    final players = _getSortedPlayers(statsState.playerStatistics);
    final l10n = AppLocalizations.of(context)!;

    if (players.isEmpty) {
      return Center(
        child: Text(l10n.noPlayerData),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.generalStats,
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
                  onSort: (columnIndex, ascending) =>
                      _sort(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.jerseyTitle, 1),
                  onSort: (columnIndex, ascending) =>
                      _sort(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.trainingPercent, 2),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.matchPercent, 3),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.avgPeriods, 4),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.goals, 5),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort(columnIndex, ascending),
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.assists, 6),
                  numeric: true,
                  onSort: (columnIndex, ascending) =>
                      _sort(columnIndex, ascending),
                ),
              ],
              rows: players.map((player) {
                final trainingColor = getStatsPercentageColor(
                  context,
                  player.trainingAttendancePercentage,
                );
                final matchColor = getStatsPercentageColor(
                  context,
                  player.matchAttendancePercentage,
                );

                return DataRow(
                  cells: [
                    DataCell(Text(player.playerName)),
                    DataCell(Text(player.jerseyNumber ?? '-')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: trainingColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${player.trainingAttendancePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: trainingColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: matchColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${player.matchAttendancePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: matchColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(player.averagePeriods.toStringAsFixed(2))),
                    DataCell(Text(player.totalGoals.toString())),
                    DataCell(Text(player.totalAssists.toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Color Legend', // This one might need localization too if not already
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _legendItem(
                  context,
                  Colors.green,
                  '≥90%',
                  'Excellent', // These too
                ),
                _legendItem(
                  context,
                  Colors.orange,
                  '≥75%',
                  'Good',
                ),
                _legendItem(
                  context,
                  Theme.of(context).colorScheme.error,
                  '<75%',
                  l10n.needsWork,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(
    BuildContext context,
    Color color,
    String range,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$range - $label',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
