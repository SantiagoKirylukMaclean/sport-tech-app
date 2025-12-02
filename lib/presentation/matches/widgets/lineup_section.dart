// lib/presentation/matches/widgets/lineup_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';

class LineupSection extends ConsumerWidget {
  final String matchId;

  const LineupSection({required this.matchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchLineupNotifierProvider(matchId));
    final notifier = ref.read(matchLineupNotifierProvider(matchId).notifier);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_soccer,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lineup - Quarter ${state.currentQuarter}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Field Players
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sports, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'On Field (${state.fieldPlayers.length}/7)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.fieldPlayers.isEmpty)
                    const Text(
                      'No players on field. Tap players from bench to add.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.fieldPlayers.map((player) {
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              player.jerseyNumber?.toString() ?? '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          label: Text(player.fullName),
                          onDeleted: () {
                            notifier.removePlayerFromField(player.id);
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bench Players
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chair, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Bench (${state.benchPlayers.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.benchPlayers.isEmpty)
                    const Text(
                      'All called-up players are on the field',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.benchPlayers.map((player) {
                        final canAdd = !state.isFieldFull;
                        return ActionChip(
                          avatar: CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Text(
                              player.jerseyNumber?.toString() ?? '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          label: Text(player.fullName),
                          onPressed: canAdd
                              ? () {
                                  notifier.addPlayerToField(player.id);
                                }
                              : null,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            if (state.isFieldFull)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Field is full (7 players max). Remove a player to add another.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
