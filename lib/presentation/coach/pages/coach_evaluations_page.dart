import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/evaluations/player_evaluations_notifier.dart';
import 'package:sport_tech_app/application/evaluations/player_evaluations_state.dart';
import 'package:sport_tech_app/application/evaluations/evaluations_providers.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/org/players/players_notifier.dart';
import 'package:sport_tech_app/application/org/players/players_state.dart';
import 'package:sport_tech_app/application/org/org_providers.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class CoachEvaluationsPage extends ConsumerStatefulWidget {
  const CoachEvaluationsPage({super.key});

  @override
  ConsumerState<CoachEvaluationsPage> createState() =>
      _CoachEvaluationsPageState();
}

class _CoachEvaluationsPageState extends ConsumerState<CoachEvaluationsPage> {
  Player? _selectedPlayer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlayers();
    });
  }

  void _loadPlayers() {
    final activeTeamState = ref.read(activeTeamNotifierProvider);
    if (activeTeamState.activeTeam != null) {
      ref
          .read(playersNotifierProvider.notifier)
          .loadPlayers(activeTeamState.activeTeam!.id);
    }
  }

  void _loadEvaluationsForPlayer(Player player) {
    ref
        .read(playerEvaluationsNotifierProvider.notifier)
        .loadEvaluationsForPlayer(player.id);
  }

  @override
  Widget build(BuildContext context) {
    final activeTeamState = ref.watch(activeTeamNotifierProvider);
    final playersState = ref.watch(playersNotifierProvider);
    final evaluationsState = ref.watch(playerEvaluationsNotifierProvider);

    if (activeTeamState.activeTeam == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Evaluaciones'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppConstants.dashboardRoute),
          ),
        ),
        body: const Center(
          child: Text('No team selected. Please select a team first.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluaciones de Jugadores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.dashboardRoute),
        ),
      ),
      body: Row(
        children: [
          // Left sidebar - Player selector
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Selecciona un Jugador',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Expanded(
                  child: _buildPlayersList(playersState),
                ),
              ],
            ),
          ),

          // Right content - Evaluations list
          Expanded(
            child: _selectedPlayer == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assessment_outlined,
                          size: 80,
                          color:
                              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selecciona un jugador',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Elige un jugador de la lista para ver sus evaluaciones',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                        ),
                      ],
                    ),
                  )
                : _buildEvaluationsContent(evaluationsState),
          ),
        ],
      ),
      floatingActionButton: _selectedPlayer != null
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push(
                  '/coach-evaluations/new?playerId=${_selectedPlayer!.id}',
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva Evaluación'),
            )
          : null,
    );
  }

  Widget _buildPlayersList(PlayersState state) {
    if (state is PlayersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PlayersError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error: ${state.message}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state is! PlayersLoaded || state.players.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No hay jugadores en este equipo',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final players = state.players;
    players.sort((a, b) {
      final aNum = a.jerseyNumber ?? 999;
      final bNum = b.jerseyNumber ?? 999;
      return aNum.compareTo(bNum);
    });

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isSelected = _selectedPlayer?.id == player.id;

        return ListTile(
          selected: isSelected,
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            child: Text(
              player.jerseyNumber?.toString() ?? '?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(player.fullName),
          onTap: () {
            setState(() {
              _selectedPlayer = player;
            });
            _loadEvaluationsForPlayer(player);
          },
        );
      },
    );
  }

  Widget _buildEvaluationsContent(PlayerEvaluationsState state) {
    if (state is PlayerEvaluationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PlayerEvaluationsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar evaluaciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadEvaluationsForPlayer(_selectedPlayer!),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state is! PlayerEvaluationsLoaded) {
      return const SizedBox.shrink();
    }

    if (state.evaluations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin evaluaciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Este jugador aún no tiene evaluaciones.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/coach-evaluations/new?playerId=${_selectedPlayer!.id}',
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Primera Evaluación'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                child: Text(
                  _selectedPlayer!.jerseyNumber?.toString() ?? '?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPlayer!.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '${state.evaluations.length} evaluación${state.evaluations.length != 1 ? 'es' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.evaluations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final evaluation = state.evaluations[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                    child: const Icon(Icons.assessment),
                  ),
                  title: Text(
                    DateFormat('dd MMM yyyy').format(evaluation.evaluationDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: evaluation.generalNotes != null
                      ? Text(
                          evaluation.generalNotes!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar evaluación'),
                          content: const Text(
                            '¿Estás seguro de que deseas eliminar esta evaluación?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && mounted) {
                        ref
                            .read(playerEvaluationsNotifierProvider.notifier)
                            .deleteEvaluation(
                              evaluation.id,
                              _selectedPlayer!.id,
                            );
                      }
                    },
                  ),
                  onTap: () {
                    context.push(
                      '/coach-evaluations/${evaluation.id}?playerId=${_selectedPlayer!.id}',
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
