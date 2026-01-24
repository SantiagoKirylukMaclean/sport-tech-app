import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/domain/matches/entities/basketball_match_stat.dart';

class BasketballStatsSummaryWidget extends ConsumerWidget {
  final String matchId;

  const BasketballStatsSummaryWidget({required this.matchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchLineupNotifierProvider(matchId));
    final notifier = ref.read(matchLineupNotifierProvider(matchId).notifier);

    final stats = state.currentQuarterBasketballStats;

    if (stats.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No stats recorded for this quarter.'),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stats Log (Q${state.currentQuarter})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final stat = stats[index];
                final player = state.teamPlayers
                    .where((p) => p.id == stat.playerId)
                    .firstOrNull;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      player?.jerseyNumber?.toString() ?? '#',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  title: Text(player?.fullName ?? 'Unknown Player'),
                  subtitle: Text(stat.statType.displayName),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      notifier.deleteBasketballStat(stat.id);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
