// lib/presentation/dashboard/widgets/player_stats_overview.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/domain/stats/entities/player_statistics.dart';
import 'package:sport_tech_app/presentation/stats/widgets/stat_card.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

/// Widget displaying an overview of player personal statistics
class PlayerStatsOverview extends StatefulWidget {
  final PlayerStatistics stats;

  const PlayerStatsOverview({
    required this.stats,
    super.key,
  });

  @override
  State<PlayerStatsOverview> createState() => _PlayerStatsOverviewState();
}

class _PlayerStatsOverviewState extends State<PlayerStatsOverview> {
  final ScrollController _scrollController = ScrollController();
  bool _showEndIndicator = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScroll());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _checkScroll();
  }

  void _checkScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // Show indicator if we're not at the end (with a small threshold)
    final shouldShow = currentScroll < maxScroll - 10;

    if (shouldShow != _showEndIndicator) {
      setState(() {
        _showEndIndicator = shouldShow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Define a fixed size for all cards (square cards)
    const cardSize = 180.0;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Partidos Jugados (Matches Called Up)
              SizedBox(
                width: cardSize,
                height: cardSize,
                child: GestureDetector(
                  onTap: () {
                    context.push('/dashboard/player-matches');
                  },
                  child: StatCard(
                    title: l10n.matchesPlayed, // "played matches"
                    value: '${widget.stats.matchesAttended}',
                    subtitle:
                        '${widget.stats.matchAttendancePercentage.toStringAsFixed(0)}% ${l10n.attendance}',
                    icon: Icons
                        .sports_soccer, // Icon is ignored in new StatCard build but required by constructor
                    valueColor: const Color(0xFF4CAF50), // Green
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Entrenamientos (Trainings Done)
              SizedBox(
                width: cardSize,
                height: cardSize,
                child: GestureDetector(
                  onTap: () {
                    context.push('/dashboard/trainings');
                  },
                  child: StatCard(
                    title: l10n.trainingsDone, // "trainings done"
                    value: '${widget.stats.trainingsAttended}',
                    subtitle:
                        '${widget.stats.trainingAttendancePercentage.toStringAsFixed(1)}% ${l10n.attendance}',
                    icon: Icons.fitness_center,
                    valueColor: const Color(0xFF4CAF50), // Green
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // % Cuartos Jugados (Quarters Played)
              SizedBox(
                width: cardSize,
                height: cardSize,
                child: GestureDetector(
                  onTap: () {
                    context.push('/dashboard/quarters-played-chart');
                  },
                  child: StatCard(
                    title: l10n.quartersPlayed, // "quarters played"
                    value: widget.stats.averagePeriods.toStringAsFixed(1),
                    subtitle:
                        '${(widget.stats.averagePeriods / 4 * 100).toStringAsFixed(1)}% ${l10n.attendance}', // Using attendance/total key logic
                    icon: Icons.timer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Intervenciones (Interventions)
              SizedBox(
                width: cardSize,
                height: cardSize,
                child: StatCard(
                  title: l10n.interventions, // "interventions"
                  value:
                      '${widget.stats.totalGoals + widget.stats.totalAssists}',
                  subtitle:
                      '${widget.stats.totalGoals} ${l10n.goals.toLowerCase()} - ${widget.stats.totalAssists} ${l10n.assists.toLowerCase()}',
                  icon: Icons.sports_score,
                  valueColor: const Color(0xFF4CAF50), // Green
                ),
              ),
            ],
          ),
        ),
        // Gradient indicator on the right side when there's more content
        if (_showEndIndicator)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.0),
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
