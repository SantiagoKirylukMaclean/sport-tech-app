import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';

class PlayersTab extends ConsumerWidget {
  const PlayersTab({super.key});

  Color _getAttendanceColor(double percentage, BuildContext context) {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 75) {
      return Colors.grey;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statsNotifierProvider);
    final players = statsState.playerStatistics;

    if (players.isEmpty) {
      return const Center(
        child: Text('No player statistics available'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              columns: const [
                DataColumn(label: Text('Player')),
                DataColumn(label: Text('Jersey')),
                DataColumn(label: Text('Training %')),
                DataColumn(label: Text('Match %')),
                DataColumn(label: Text('Avg Periods')),
                DataColumn(label: Text('Goals')),
                DataColumn(label: Text('Assists')),
              ],
              rows: players.map((player) {
                final trainingColor = _getAttendanceColor(
                  player.trainingAttendancePercentage,
                  context,
                );
                final matchColor = _getAttendanceColor(
                  player.matchAttendancePercentage,
                  context,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Color Legend',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _legendItem(
                  context,
                  Colors.green,
                  '≥90%',
                  'Excellent',
                ),
                const SizedBox(width: 16),
                _legendItem(
                  context,
                  Colors.grey,
                  '≥75%',
                  'Good',
                ),
                const SizedBox(width: 16),
                _legendItem(
                  context,
                  Theme.of(context).colorScheme.error,
                  '<75%',
                  'Needs improvement',
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
