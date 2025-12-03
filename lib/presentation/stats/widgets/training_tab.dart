import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';

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
    final statsState = ref.watch(statsNotifierProvider);
    final players = statsState.playerStatistics;

    if (players.isEmpty) {
      return const Center(
        child: Text('No training attendance data available'),
      );
    }

    // Sort players by training attendance percentage (descending)
    final sortedPlayers = List.from(players)
      ..sort((a, b) =>
          b.trainingAttendancePercentage.compareTo(a.trainingAttendancePercentage));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Training Attendance Ranking',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedPlayers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final player = sortedPlayers[index];
              final position = index + 1;
              final attendanceColor = _getAttendanceColor(
                player.trainingAttendancePercentage,
                context,
              );

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRankColor(position, context),
                  child: Text(
                    position.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  player.playerName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${player.trainingsAttended} / ${player.totalTrainingSessions} trainings',
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: attendanceColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${player.trainingAttendancePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: attendanceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _buildSummaryCard(context, sortedPlayers),
        const SizedBox(height: 16),
        _buildLegend(context),
      ],
    );
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

  Widget _buildSummaryCard(BuildContext context, List players) {
    if (players.isEmpty) return const SizedBox.shrink();

    final totalPlayers = players.length;
    final excellentCount = players
        .where((p) => p.trainingAttendancePercentage >= 90)
        .length;
    final goodCount = players
        .where((p) =>
            p.trainingAttendancePercentage >= 75 &&
            p.trainingAttendancePercentage < 90)
        .length;
    final needsImprovementCount = players
        .where((p) => p.trainingAttendancePercentage < 75)
        .length;

    final averageAttendance = players.fold<double>(
          0,
          (sum, p) => sum + p.trainingAttendancePercentage,
        ) /
        totalPlayers;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  'Average',
                  '${averageAttendance.toStringAsFixed(1)}%',
                ),
                _buildSummaryItem(
                  context,
                  'Excellent',
                  excellentCount.toString(),
                ),
                _buildSummaryItem(
                  context,
                  'Good',
                  goodCount.toString(),
                ),
                _buildSummaryItem(
                  context,
                  'Needs Work',
                  needsImprovementCount.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.8),
              ),
        ),
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
