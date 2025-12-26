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
    final wins = widget.matches.where((m) => m.result == MatchResult.win).length;
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
    final totalGoals = widget.matches.fold(0, (sum, match) => sum + match.teamGoals);
    return totalGoals / matchesPlayed;
  }

  /// Get color based on percentage (0% = red, 100% = green)
  Color _getPercentageColor(double percentage) {
    // Clamp percentage to 0-100 range
    final clampedPercentage = percentage.clamp(0.0, 100.0);

    // Use Material Design color scheme
    // 0-50%: Red to Yellow
    // 50-100%: Yellow to Green
    if (clampedPercentage < 50) {
      // Interpolate between red and yellow
      final t = clampedPercentage / 50;
      return Color.lerp(
        Colors.red.shade700,
        Colors.amber.shade700,
        t,
      )!;
    } else {
      // Interpolate between yellow and green
      final t = (clampedPercentage - 50) / 50;
      return Color.lerp(
        Colors.amber.shade700,
        Colors.green.shade700,
        t,
      )!;
    }
  }

  Color _getGoalDifferenceColor(BuildContext context, int goalDifference) {
    if (goalDifference > 0) {
      return Colors.green.shade700;
    } else if (goalDifference < 0) {
      return Theme.of(context).colorScheme.error;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  String _getGoalDifferenceSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final matchesPlayed = _getMatchesPlayed();
    if (matchesPlayed == 0) return '';
    final goalsFor = widget.matches.fold(0, (sum, match) => sum + match.teamGoals);
    final goalsAgainst =
        widget.matches.fold(0, (sum, match) => sum + match.opponentGoals);
    final averageGoals = _getAverageGoals();
    return '${l10n.goalsForAgainst(goalsFor.toString(), goalsAgainst.toString())}\nPromedio: ${averageGoals.toStringAsFixed(1)}';
  }

  String _getMatchesPlayedSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final matchesPlayed = _getMatchesPlayed();
    if (matchesPlayed == 0) return '';
    final wins = widget.matches.where((m) => m.result == MatchResult.win).length;
    final draws = widget.matches.where((m) => m.result == MatchResult.draw).length;
    final losses = widget.matches.where((m) => m.result == MatchResult.loss).length;
    return '${l10n.winsDrawsLosses(wins.toString(), draws.toString(), losses.toString())} • ${_getWinPercentage().toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matches.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    // Calculate values
    final matchesPlayed = _getMatchesPlayed();
    final winPercentage = _getWinPercentage();
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
                  title: l10n.matchesPlayed,
                  value: '$matchesPlayed',
                  subtitle: _getMatchesPlayedSubtitle(context),
                  icon: Icons.sports,
                  valueColor: _getPercentageColor(winPercentage),
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
                  title: l10n.goalDifference,
                  value: goalDifference >= 0
                      ? '+$goalDifference'
                      : '$goalDifference',
                  subtitle: _getGoalDifferenceSubtitle(context),
                  icon: Icons.sports_score,
                  valueColor: _getGoalDifferenceColor(context, goalDifference),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: cardSize,
                height: cardSize,
                child: StatCard(
                  title: l10n.cleanSheets,
                  value: '$cleanSheets',
                  subtitle: matchesPlayed > 0
                      ? l10n.percentageOfMatches(
                          (cleanSheets / matchesPlayed * 100).toStringAsFixed(1),
                        )
                      : '',
                  icon: Icons.shield,
                  valueColor: cleanSheets > 0 ? Colors.green.shade700 : null,
                ),
              ),
              if (widget.teamTrainingAttendance != null) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: cardSize,
                  height: cardSize,
                  child: StatCard(
                    title: l10n.trainings,
                    value: '${widget.teamTrainingAttendance!.toStringAsFixed(1)}%',
                    subtitle: l10n.teamAttendance,
                    icon: Icons.fitness_center,
                    valueColor: _getPercentageColor(widget.teamTrainingAttendance!),
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
                      Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
                      Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
