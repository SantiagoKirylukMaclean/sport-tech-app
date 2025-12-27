// lib/presentation/matches/widgets/substitutions_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';

class SubstitutionsSection extends ConsumerWidget {
  final String matchId;

  const SubstitutionsSection({required this.matchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchLineupNotifierProvider(matchId));
    final notifier = ref.read(matchLineupNotifierProvider(matchId).notifier);

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
                  Icons.swap_horiz,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sustituciones - Cuarto ${state.currentQuarter}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (!state.substitutionMode)
                  ElevatedButton.icon(
                    onPressed: state.isFieldFull
                        ? () => notifier.toggleSubstitutionMode()
                        : null,
                    icon: const Icon(Icons.swap_horiz, size: 20),
                    label: const Text('Hacer Cambio'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => notifier.toggleSubstitutionMode(),
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text('Cancelar'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Show substitution mode UI
            if (state.substitutionMode) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selecciona el jugador que sale y el que entra',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cada jugador computará 0.5 cuartos (medio cuarto)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Player Out Selection
                    Text(
                      'Jugador que sale (en cancha):',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    _buildPlayerOutSelection(context, ref, state),

                    const SizedBox(height: 16),

                    // Player In Selection
                    Text(
                      'Jugador que entra (del banco):',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    _buildPlayerInSelection(context, ref, state),

                    const SizedBox(height: 16),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: state.selectedPlayerOut != null &&
                                   state.selectedPlayerIn != null
                            ? () async {
                                await notifier.applySubstitution(
                                  state.selectedPlayerOut!,
                                  state.selectedPlayerIn!,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Aplicar Sustitución'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // List of substitutions for current quarter
            if (state.currentQuarterSubstitutions.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Sustituciones realizadas en este cuarto:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...state.currentQuarterSubstitutions.map((sub) {
                final playerOut = state.calledUpPlayers
                    .where((p) => p.id == sub.playerOut)
                    .firstOrNull;
                final playerIn = state.calledUpPlayers
                    .where((p) => p.id == sub.playerIn)
                    .firstOrNull;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Player Out
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.red.shade100,
                              child: Icon(
                                Icons.arrow_upward,
                                size: 16,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                playerOut?.fullName ?? 'Desconocido',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrow
                      const Icon(Icons.swap_horiz, size: 24),
                      // Player In
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.green.shade100,
                              child: Icon(
                                Icons.arrow_downward,
                                size: 16,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                playerIn?.fullName ?? 'Desconocido',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else if (!state.substitutionMode)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No hay sustituciones en este cuarto',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerOutSelection(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
  ) {
    final notifier = ref.read(matchLineupNotifierProvider(matchId).notifier);

    if (state.fieldPlayers.isEmpty) {
      return const Text(
        'No hay jugadores en cancha',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.fieldPlayers.map<Widget>((Player player) {
        final isSelected = state.selectedPlayerOut == player.id;

        return FilterChip(
          selected: isSelected,
          avatar: CircleAvatar(
            backgroundColor: isSelected ? Colors.red : Colors.green,
            child: Text(
              player.jerseyNumber?.toString() ?? '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          label: Text(player.fullName),
          onSelected: (selected) {
            if (selected) {
              notifier.selectPlayerOut(player.id);
            } else {
              notifier.selectPlayerOut(null);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildPlayerInSelection(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
  ) {
    final notifier = ref.read(matchLineupNotifierProvider(matchId).notifier);

    if (state.benchPlayers.isEmpty) {
      return const Text(
        'No hay jugadores en el banco',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.benchPlayers.map<Widget>((Player player) {
        final isSelected = state.selectedPlayerIn == player.id;

        return FilterChip(
          selected: isSelected,
          avatar: CircleAvatar(
            backgroundColor: isSelected ? Colors.green : Colors.grey,
            child: Text(
              player.jerseyNumber?.toString() ?? '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          label: Text(player.fullName),
          onSelected: (selected) {
            if (selected) {
              notifier.selectPlayerIn(player.id);
            } else {
              notifier.selectPlayerIn(null);
            }
          },
        );
      }).toList(),
    );
  }
}
