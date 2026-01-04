import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class QuartersTab extends ConsumerStatefulWidget {
  const QuartersTab({super.key});

  @override
  ConsumerState<QuartersTab> createState() => _QuartersTabState();
}

class _QuartersTabState extends ConsumerState<QuartersTab> {
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
    final quarters = List.from(statsState.quarters);
    final l10n = AppLocalizations.of(context)!;

    if (quarters.isEmpty) {
      return const Center(
        child: Text('No quarter data available'),
      );
    }

    // Sort quarters based on selected column
    _sortQuarters(quarters);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.performanceByQuarter,
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
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              headingRowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              columns: [
                DataColumn(
                  label: _buildColumnLabel(l10n.quarter, 0),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.goalsFor, 1),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.goalsAgainst, 2),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.wins, 3),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.draws, 4),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.losses, 5),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
                DataColumn(
                  label: _buildColumnLabel(l10n.effectiveness, 6),
                  numeric: true,
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                    });
                  },
                ),
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
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
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
        const SizedBox(height: 16),
        _buildEffectivenessLegend(context),
      ],
    );
  }

  void _sortQuarters(List quarters) {
    switch (_sortColumnIndex) {
      case 0: // Quarter
        quarters.sort(
          (a, b) => _sortAscending
              ? a.quarterNumber.compareTo(b.quarterNumber)
              : b.quarterNumber.compareTo(a.quarterNumber),
        );
        break;
      case 1: // Goals For
        quarters.sort(
          (a, b) => _sortAscending
              ? a.goalsFor.compareTo(b.goalsFor)
              : b.goalsFor.compareTo(a.goalsFor),
        );
        break;
      case 2: // Goals Against
        quarters.sort(
          (a, b) => _sortAscending
              ? a.goalsAgainst.compareTo(b.goalsAgainst)
              : b.goalsAgainst.compareTo(a.goalsAgainst),
        );
        break;
      case 3: // Wins
        quarters.sort(
          (a, b) => _sortAscending
              ? a.wins.compareTo(b.wins)
              : b.wins.compareTo(a.wins),
        );
        break;
      case 4: // Draws
        quarters.sort(
          (a, b) => _sortAscending
              ? a.draws.compareTo(b.draws)
              : b.draws.compareTo(a.draws),
        );
        break;
      case 5: // Losses
        quarters.sort(
          (a, b) => _sortAscending
              ? a.losses.compareTo(b.losses)
              : b.losses.compareTo(a.losses),
        );
        break;
      case 6: // Effectiveness
        quarters.sort(
          (a, b) => _sortAscending
              ? a.effectiveness.compareTo(b.effectiveness)
              : b.effectiveness.compareTo(a.effectiveness),
        );
        break;
    }
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

  Widget _buildEffectivenessLegend(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.effectivenessCalculation,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.effectivenessFormula,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _legendItem(context, Colors.green, '≥75%', 'Excellent'),
                _legendItem(context, Colors.orange, '≥50%', 'Good'),
                _legendItem(
                  context,
                  Theme.of(context).colorScheme.error,
                  '<50%',
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
