import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';
import 'package:sport_tech_app/domain/stats/entities/match_summary.dart';

class MatchesTab extends ConsumerWidget {
  const MatchesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statsNotifierProvider);
    final matches = statsState.matches;

    if (matches.isEmpty) {
      return const Center(
        child: Text('No matches played yet'),
      );
    }

    // Calculate overall statistics
    final wins = matches.where((m) => m.result == MatchResult.win).length;
    final draws = matches.where((m) => m.result == MatchResult.draw).length;
    final losses = matches.where((m) => m.result == MatchResult.loss).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall stats card
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Record',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Wins',
                      wins.toString(),
                      Colors.green,
                    ),
                    _buildStatItem(
                      context,
                      'Draws',
                      draws.toString(),
                      Colors.grey,
                    ),
                    _buildStatItem(
                      context,
                      'Losses',
                      losses.toString(),
                      Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Matches list
        Text(
          'Match History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...matches.map((match) => _buildMatchCard(context, match)),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.8),
              ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchSummary match) {
    final resultColor = switch (match.result) {
      MatchResult.win => Colors.green,
      MatchResult.draw => Colors.grey,
      MatchResult.loss => Theme.of(context).colorScheme.error,
    };

    final resultIcon = switch (match.result) {
      MatchResult.win => Icons.check_circle,
      MatchResult.draw => Icons.horizontal_rule,
      MatchResult.loss => Icons.cancel,
    };

    final resultLabel = switch (match.result) {
      MatchResult.win => 'W',
      MatchResult.draw => 'D',
      MatchResult.loss => 'L',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: resultColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              resultIcon,
              color: resultColor,
              size: 28,
            ),
          ),
        ),
        title: Text(
          'vs ${match.opponent}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('MMM d, yyyy').format(match.matchDate),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: resultColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                resultLabel,
                style: TextStyle(
                  color: resultColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${match.teamGoals} - ${match.opponentGoals}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
