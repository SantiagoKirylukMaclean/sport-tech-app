import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/stats/stats_providers.dart';

class GoalsTab extends ConsumerWidget {
  const GoalsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statsNotifierProvider);
    final scorers = statsState.scorers;
    final assisters = statsState.assisters;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top Scorers
        Text(
          'Top Scorers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (scorers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No goals scored yet'),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scorers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final scorer = scorers[index];
                final position = index + 1;

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
                    scorer.playerName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: scorer.jerseyNumber != null
                      ? Text('Jersey #${scorer.jerseyNumber}')
                      : null,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${scorer.count} ${scorer.count == 1 ? 'goal' : 'goals'}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 32),

        // Top Assisters
        Text(
          'Top Assisters',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (assisters.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No assists recorded yet'),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: assisters.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final assister = assisters[index];
                final position = index + 1;

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
                    assister.playerName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: assister.jerseyNumber != null
                      ? Text('Jersey #${assister.jerseyNumber}')
                      : null,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${assister.count} ${assister.count == 1 ? 'assist' : 'assists'}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
}
