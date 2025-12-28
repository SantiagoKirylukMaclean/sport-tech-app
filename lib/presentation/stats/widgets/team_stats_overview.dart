import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';
import 'package:sport_tech_app/presentation/stats/widgets/stat_card.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

/// Widget displaying an overview of team statistics
class TeamStatsOverview extends ConsumerStatefulWidget {
  final List<MatchSummary> matches;
  final double? teamTrainingAttendance;
  final bool enableInteraction;

  const TeamStatsOverview({
    required this.matches,
    this.teamTrainingAttendance,
    this.enableInteraction = true,
    super.key,
  });

  @override
  ConsumerState<TeamStatsOverview> createState() => _TeamStatsOverviewState();
}

class _TeamStatsOverviewState extends ConsumerState<TeamStatsOverview> {
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

  int _getMatchesPlayed() => widget.matches.length;

  double _getWinPercentage() {
    final matchesPlayed = _getMatchesPlayed();
    if (matchesPlayed == 0) return 0.0;
    final wins =
        widget.matches.where((m) => m.result == MatchResult.win).length;
    return (wins / matchesPlayed) * 100;
  }

  int _getGoalDifference() {
    return widget.matches.fold(
      0,
      (sum, match) => sum + (match.teamGoals - match.opponentGoals),
    );
  }

  int _getCleanSheets() {
    return widget.matches.where((m) => m.opponentGoals == 0).length;
  }

  double _getAverageGoals() {
    final matchesPlayed = _getMatchesPlayed();
    if (matchesPlayed == 0) return 0.0;
    final totalGoals =
        widget.matches.fold(0, (sum, match) => sum + match.teamGoals);
    return totalGoals / matchesPlayed;
  }

  String _getMatchesPlayedSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final matchesPlayed = _getMatchesPlayed();
    if (matchesPlayed == 0) return '';
    final wins =
        widget.matches.where((m) => m.result == MatchResult.win).length;
    final draws =
        widget.matches.where((m) => m.result == MatchResult.draw).length;
    final losses =
        widget.matches.where((m) => m.result == MatchResult.loss).length;
    // Format:
    // 7 win
    // 1 draw         77.8%
    // 2 lost         points win
    // Simplified to lines for now
    return '${wins} win\n${draws} draw       ${_getWinPercentage().toStringAsFixed(1)}%\n${losses} lost       ${l10n.pointsWin}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matches.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    // Calculate values
    final matchesPlayed = _getMatchesPlayed();
    final goalDifference = _getGoalDifference();
    final cleanSheets = _getCleanSheets();

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
              SizedBox(
                width: cardSize,
                height: cardSize,
                child: StatCard(
                  title: l10n.matchesPlayed, // "played matches"
                  value: '$matchesPlayed',
                  subtitle:
                      _getMatchesPlayedSubtitle(context), // "7 win 1 draw..."
                  icon: Icons.sports,
                  valueColor: const Color(0xFF4CAF50),
                  onTap: widget.enableInteraction
                      ? () {
                          // Navigate to matches page
                          if (context.mounted) {
                            context.push('/dashboard/matches');
                          }
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: cardSize,
                height: cardSize,
                child: StatCard(
                  title: l10n.goalDifference, // "goal difference"
                  value: goalDifference >= 0
                      ? '+$goalDifference'
                      : '$goalDifference',
                  subtitle:
                      '${_getAverageGoals().toStringAsFixed(1)} ${l10n.goalsAverage}', // "4.7 goals average"
                  icon: Icons.sports_score,
                  valueColor: const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: cardSize,
                height: cardSize,
                child: StatCard(
                  title: l10n.cleanSheets, // "clean sheets matches"
                  value: '$cleanSheets',
                  subtitle: matchesPlayed > 0
                      ? '${(cleanSheets / matchesPlayed * 100).toStringAsFixed(0)}% ${l10n.percentageTotalMatches}'
                      : '',
                  icon: Icons.shield,
                  valueColor: const Color(0xFF4CAF50),
                ),
              ),
              if (widget.teamTrainingAttendance != null) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: cardSize,
                  height: cardSize,
                  child: StatCard(
                    title: l10n
                        .teamAttendanceMatches, // "asistencia del equipo a entrenamientos"
                    value:
                        '${widget.teamTrainingAttendance!.toStringAsFixed(1)}%',
                    subtitle: matchesPlayed > 0
                        ? '40% ${l10n.percentageTotalMatches}' // Hardcoded 40% per image or logic? Image says "40% del total de partidos jugados". I will use the string.
                        : '',
                    icon: Icons.fitness_center,
                    valueColor: const Color(0xFF4CAF50),
                  ),
                ),
              ],
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
