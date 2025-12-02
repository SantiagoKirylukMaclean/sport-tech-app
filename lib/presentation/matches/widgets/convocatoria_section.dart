// lib/presentation/matches/widgets/convocatoria_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';

class ConvocatoriaSection extends ConsumerWidget {
  final String matchId;

  const ConvocatoriaSection({required this.matchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchLineupNotifierProvider(matchId));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Call-Up (Convocatoria)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Chip(
                  label: Text('${state.callUps.length} / 7 min'),
                  backgroundColor: state.hasMinimumCallUps
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                ),
              ],
            ),
            if (!state.hasMinimumCallUps) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Minimum 7 players required to manage lineup',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.calledUpPlayers.map((player) {
                return Chip(
                  avatar: CircleAvatar(
                    child: Text(
                      player.jerseyNumber?.toString() ?? '?',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  label: Text(player.fullName),
                  onDeleted: () {
                    ref
                        .read(matchLineupNotifierProvider(matchId).notifier)
                        .removePlayerFromCallUp(player.id);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
