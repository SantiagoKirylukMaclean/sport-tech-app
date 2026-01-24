import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/presentation/matches/widgets/basketball_stats_selection_widget.dart';

class BasketballLineupListWidget extends ConsumerWidget {
  final String matchId;

  const BasketballLineupListWidget({required this.matchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchLineupNotifierProvider(matchId));
    final notifier = ref.read(matchLineupNotifierProvider(matchId).notifier);

    // Separate into field and bench
    final fieldPlayers = state.fieldPlayers;
    final benchPlayers = state.benchPlayers;

    // Combined sorted list: Field players first, then Bench
    final sortedPlayers = [
      ...fieldPlayers,
      ...benchPlayers,
    ];

    if (sortedPlayers.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No players called up yet.'),
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
                  Icons.sports_basketball,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Alineación (${fieldPlayers.length}/5)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedPlayers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final player = sortedPlayers[index];
                final isOnField = fieldPlayers.any((p) => p.id == player.id);

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isOnField
                        ? Colors.green
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(
                      player.jerseyNumber?.toString() ?? '?',
                      style: TextStyle(
                        color: isOnField ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    player.fullName,
                    style: TextStyle(
                      fontWeight:
                          isOnField ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isOnField
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.circle_outlined, color: Colors.grey),
                  onTap: () {
                    if (state.statsMode) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => BasketballStatsSelectionWidget(
                          matchId: matchId,
                          player: player,
                        ),
                      );
                    } else {
                      if (isOnField) {
                        // Remove from field
                        notifier.removePlayerFromField(player.id);
                      } else {
                        // Add to field (without specific zone)
                        if (fieldPlayers.length < 5) {
                          notifier.addPlayerToField(player.id);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Field is full (5 players max)'),
                            ),
                          );
                        }
                      }
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
