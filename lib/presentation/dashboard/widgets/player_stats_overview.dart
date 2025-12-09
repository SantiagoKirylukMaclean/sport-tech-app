// lib/presentation/dashboard/widgets/player_stats_overview.dart

import 'package:flutter/material.dart';
import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/presentation/stats/widgets/stat_card.dart';

/// Widget displaying an overview of player personal statistics
class PlayerStatsOverview extends StatelessWidget {
  final PlayerStatistics stats;

  const PlayerStatsOverview({
    required this.stats,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Partidos Jugados (Matches Called Up)
          SizedBox(
            width: 180,
            child: StatCard(
              title: 'Partidos Jugados',
              value: '${stats.matchesAttended}',
              subtitle: '${stats.matchAttendancePercentage.toStringAsFixed(1)}% asistencia',
              icon: Icons.sports_soccer,
              valueColor: stats.matchAttendancePercentage >= 80 ? Colors.green : null,
            ),
          ),
          const SizedBox(width: 12),
          // Entrenamientos (Training Sessions Attended)
          SizedBox(
            width: 180,
            child: StatCard(
              title: 'Entrenamientos',
              value: '${stats.trainingsAttended}',
              subtitle: '${stats.trainingAttendancePercentage.toStringAsFixed(1)}% asistencia',
              icon: Icons.fitness_center,
              valueColor: stats.trainingAttendancePercentage >= 80 ? Colors.green : null,
            ),
          ),
          const SizedBox(width: 12),
          // % Cuartos Jugados (Quarters Played Percentage)
          SizedBox(
            width: 180,
            child: StatCard(
              title: '% Cuartos Jugados',
              value: '${(stats.averagePeriods / 4 * 100).toStringAsFixed(1)}%',
              subtitle: 'Promedio: ${stats.averagePeriods.toStringAsFixed(1)} de 4',
              icon: Icons.timer,
            ),
          ),
          const SizedBox(width: 12),
          // Goles (Goals)
          SizedBox(
            width: 180,
            child: StatCard(
              title: 'Goles',
              value: '${stats.totalGoals}',
              icon: Icons.sports_score,
              valueColor: stats.totalGoals > 0 ? Colors.green : null,
            ),
          ),
          const SizedBox(width: 12),
          // Asistencias (Assists)
          SizedBox(
            width: 180,
            child: StatCard(
              title: 'Asistencias',
              value: '${stats.totalAssists}',
              icon: Icons.assistant,
              valueColor: stats.totalAssists > 0 ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
