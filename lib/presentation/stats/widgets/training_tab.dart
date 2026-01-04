import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class TrainingTab extends ConsumerWidget {
  const TrainingTab({super.key});

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
    final l10n = AppLocalizations.of(context)!;
    final statsState = ref.watch(statsNotifierProvider);
    final players = List.from(statsState.playerStatistics);

    // Sort players by training attendance percentage (descending)
    players.sort(
      (a, b) => b.trainingAttendancePercentage
          .compareTo(a.trainingAttendancePercentage),
    );

    if (players.isEmpty) {
      return const Center(child: Text('No training data available'));
    }

    final averageAttendance = players.fold<double>(
          0,
          (sum, item) => sum + item.trainingAttendancePercentage,
        ) /
        players.length;

    final poorAttendanceCount =
        players.where((p) => p.trainingAttendancePercentage < 75).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.trainingAttendanceRanking,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _buildSummaryCards(
            context, averageAttendance, poorAttendanceCount, l10n),
        const SizedBox(height: 16),
        ...players.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final color =
              _getAttendanceColor(player.trainingAttendancePercentage, context);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                player.playerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(player.jerseyNumber ?? '-'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${player.trainingAttendancePercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    double average,
    int needsWorkCount,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: l10n.teamSummary,
            value: '${average.toStringAsFixed(1)}%',
            color: Colors.blue,
            icon: Icons.group,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: l10n.needsWork,
            value: needsWorkCount.toString(),
            color: Theme.of(context).colorScheme.error,
            icon: Icons.warning_amber_rounded,
          ),
        ),
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
              'Attendance Color Legend',
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
                  'Excellent',
                ),
                _legendItem(
                  context,
                  Colors.grey,
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
