import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';

class QuartersTab extends ConsumerWidget {
  const QuartersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statsNotifierProvider);
    final quarters = statsState.quarters;

    if (quarters.isEmpty) {
      return const Center(
        child: Text('No quarter data available'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Performance by Quarter',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              columns: const [
                DataColumn(label: Text('Quarter')),
                DataColumn(label: Text('Goals For')),
                DataColumn(label: Text('Goals Against')),
                DataColumn(label: Text('Wins')),
                DataColumn(label: Text('Draws')),
                DataColumn(label: Text('Losses')),
                DataColumn(label: Text('Effectiveness')),
              ],
              rows: quarters.map((quarter) {
                final effectivenessColor = _getEffectivenessColor(
                  quarter.effectiveness,
                  context,
                );

                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Q${quarter.quarterNumber}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        quarter.goalsFor.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        quarter.goalsAgainst.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quarter.wins.toString(),
                          style: const TextStyle(
                            color: Colors.green,
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
                          color: Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quarter.draws.toString(),
                          style: const TextStyle(
                            color: Colors.grey,
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
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quarter.losses.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
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
                          color: effectivenessColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${quarter.effectiveness.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: effectivenessColor,
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
        const SizedBox(height: 24),
        _buildQuarterCards(context, quarters),
        const SizedBox(height: 16),
        _buildEffectivenessLegend(context),
      ],
    );
  }

  Color _getEffectivenessColor(double effectiveness, BuildContext context) {
    if (effectiveness >= 75) {
      return Colors.green;
    } else if (effectiveness >= 50) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  Widget _buildQuarterCards(BuildContext context, List quarters) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: quarters.length,
      itemBuilder: (context, index) {
        final quarter = quarters[index];
        final effectivenessColor = _getEffectivenessColor(
          quarter.effectiveness,
          context,
        );

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Quarter ${quarter.quarterNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${quarter.effectiveness.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: effectivenessColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Effectiveness',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${quarter.goalsFor}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      ' - ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${quarter.goalsAgainst}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEffectivenessLegend(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Effectiveness Calculation',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Effectiveness = (Wins × 3 + Draws × 1) / (Total Games × 3) × 100',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _legendItem(context, Colors.green, '≥75%', 'Excellent'),
                const SizedBox(width: 16),
                _legendItem(context, Colors.orange, '≥50%', 'Good'),
                const SizedBox(width: 16),
                _legendItem(
                  context,
                  Theme.of(context).colorScheme.error,
                  '<50%',
                  'Needs work',
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
