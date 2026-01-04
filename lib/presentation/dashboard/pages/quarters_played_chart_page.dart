import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/application/auth/auth_notifier.dart';
import 'package:sport_tech_app/application/auth/auth_state.dart';
import 'package:sport_tech_app/application/matches/matches_notifier.dart';
import 'package:sport_tech_app/application/matches/matches_state.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/domain/matches/entities/match_player_period.dart';
import 'package:sport_tech_app/infrastructure/matches/providers/matches_repositories_providers.dart';
import 'package:sport_tech_app/infrastructure/org/providers/org_repositories_providers.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

/// Data point for quarters played chart
class QuartersPlayedDataPoint {
  final DateTime date;
  final String matchOpponent;
  final double quarters;

  QuartersPlayedDataPoint({
    required this.date,
    required this.matchOpponent,
    required this.quarters,
  });
}

/// Provider for quarters played data
final quartersPlayedDataProvider =
    FutureProvider.autoDispose<List<QuartersPlayedDataPoint>>(
  (ref) async {
    final activeTeam = ref.watch(activeTeamNotifierProvider).activeTeam;
    if (activeTeam == null) return [];

    // Get current user's player ID
    final authState = ref.watch(authNotifierProvider);
    if (authState is! AuthStateAuthenticated) return [];

    final userId = authState.profile.userId;
    final playersRepo = ref.watch(playersRepositoryProvider);
    final playerResult = await playersRepo.getPlayerByUserId(userId);

    if (playerResult.dataOrNull == null) {
      return [];
    }

    final playerId = playerResult.dataOrNull!.id;

    final matchesNotifier =
        ref.watch(matchesNotifierProvider(activeTeam.id).notifier);
    await matchesNotifier.loadMatches();

    final matchesState = ref.watch(matchesNotifierProvider(activeTeam.id));
    if (matchesState is! MatchesStateLoaded) return [];

    final periodsRepo = ref.watch(matchPlayerPeriodsRepositoryProvider);
    final dataPoints = <QuartersPlayedDataPoint>[];

    for (final match in matchesState.matches) {
      // Get periods (quarters) played in this match
      final periodsResult = await periodsRepo.getPeriodsByMatchAndPlayer(
        matchId: match.id,
        playerId: playerId,
      );
      final periods = periodsResult.dataOrNull ?? [];

      if (periods.isEmpty) continue;

      // Calculate total quarters played (full = 1, half = 0.5)
      double totalQuarters = 0;
      for (final period in periods) {
        totalQuarters += period.fraction == Fraction.full ? 1.0 : 0.5;
      }

      dataPoints.add(
        QuartersPlayedDataPoint(
          date: match.matchDate,
          matchOpponent: match.opponent,
          quarters: totalQuarters,
        ),
      );
    }

    // Sort by date
    dataPoints.sort((a, b) => a.date.compareTo(b.date));

    return dataPoints;
  },
);

/// Page displaying quarters played over time chart
class QuartersPlayedChartPage extends ConsumerWidget {
  const QuartersPlayedChartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(quartersPlayedDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quartersPlayed),
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingStatistics,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(quartersPlayedDataProvider);
                },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (dataPoints) {
          if (dataPoints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.noData,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.noMatchesPlayed),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chart
                SizedBox(
                  height: 300,
                  child: _QuartersPlayedChart(dataPoints: dataPoints),
                ),
                const SizedBox(height: 32),
                // Legend/Summary
                Text(
                  l10n.summary,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildSummaryCards(context, dataPoints),
                const SizedBox(height: 24),
                // Data table
                Text(
                  l10n.matchDetail,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildDataTable(context, dataPoints),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(
      BuildContext context, List<QuartersPlayedDataPoint> dataPoints) {
    final l10n = AppLocalizations.of(context)!;
    final totalQuarters =
        dataPoints.fold<double>(0, (sum, point) => sum + point.quarters);
    final avgQuarters = totalQuarters / dataPoints.length;
    final maxQuarters =
        dataPoints.map((p) => p.quarters).reduce((a, b) => a > b ? a : b);
    final minQuarters =
        dataPoints.map((p) => p.quarters).reduce((a, b) => a < b ? a : b);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: l10n.average,
            value: avgQuarters.toStringAsFixed(1),
            icon: Icons.trending_up,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: l10n.maximum,
            value: maxQuarters.toStringAsFixed(1),
            icon: Icons.arrow_upward,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: l10n.minimum,
            value: minQuarters.toStringAsFixed(1),
            icon: Icons.arrow_downward,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(
      BuildContext context, List<QuartersPlayedDataPoint> dataPoints) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    return Card(
      child: Column(
        children: dataPoints.reversed.map((point) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                point.quarters.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              point.matchOpponent,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(dateFormat.format(point.date)),
            trailing: Text(
              '${(point.quarters / 4 * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuartersPlayedChart extends StatelessWidget {
  final List<QuartersPlayedDataPoint> dataPoints;

  const _QuartersPlayedChart({required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    final spots = dataPoints
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.quarters))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dataPoints.length) {
                  return const SizedBox.shrink();
                }

                final point = dataPoints[index];

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Text(
                      point.matchOpponent,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        minX: 0,
        maxX: (dataPoints.length - 1).toDouble(),
        minY: 0,
        maxY: 4,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= dataPoints.length) {
                  return null;
                }
                final point = dataPoints[index];
                final dateFormat = DateFormat('dd MMM', 'es');
                return LineTooltipItem(
                  '${point.matchOpponent}\n${dateFormat.format(point.date)}\n${point.quarters.toStringAsFixed(1)} cuartos',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
