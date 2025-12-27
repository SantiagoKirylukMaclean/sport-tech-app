import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/domain/matches/entities/match.dart';
import 'package:sport_tech_app/domain/matches/entities/match_player_period.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/infrastructure/matches/providers/matches_repositories_providers.dart';

/// Provider to fetch match details by ID
final matchByIdProvider = FutureProvider.family<Match?, String>((ref, matchId) async {
  final matchesRepo = ref.watch(matchesRepositoryProvider);
  final result = await matchesRepo.getMatchById(matchId);
  return result.dataOrNull;
});

/// Read-only page showing detailed match information
class MatchDetailPage extends ConsumerStatefulWidget {
  final String matchId;

  const MatchDetailPage({
    required this.matchId,
    super.key,
  });

  @override
  ConsumerState<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends ConsumerState<MatchDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(matchLineupNotifierProvider(widget.matchId).notifier).loadMatchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchByIdProvider(widget.matchId));
    final state = ref.watch(matchLineupNotifierProvider(widget.matchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Partido'),
      ),
      body: state.isLoading || matchAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(matchLineupNotifierProvider(widget.matchId).notifier)
                              .loadMatchData();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : matchAsync.value == null
                  ? const Center(child: Text('Partido no encontrado'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(matchByIdProvider(widget.matchId));
                        await ref
                            .read(matchLineupNotifierProvider(widget.matchId).notifier)
                            .loadMatchData();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Match Info Card
                            _MatchInfoCard(
                              opponent: matchAsync.value!.opponent,
                              matchDate: matchAsync.value!.matchDate,
                              location: matchAsync.value!.location,
                              notes: matchAsync.value!.notes,
                            ),
                            const SizedBox(height: 24),

                            // Quarter Results Section
                            Text(
                              'Resultados por Cuarto',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _QuarterResultsSection(
                              quarterResults: state.quarterResults,
                            ),
                            const SizedBox(height: 24),

                            // Goals Section
                            Text(
                              'Goles (${state.allGoals.length})',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _GoalsSection(
                              goals: state.allGoals,
                              players: state.calledUpPlayers,
                            ),
                            const SizedBox(height: 24),

                            // Players by Quarter Section
                            Text(
                              'Jugadores por Cuarto',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _PlayersByQuarterSection(
                              allPeriods: state.allPeriods,
                              players: state.calledUpPlayers,
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

/// Card showing match information
class _MatchInfoCard extends StatelessWidget {
  final String opponent;
  final DateTime matchDate;
  final String? location;
  final String? notes;

  const _MatchInfoCard({
    required this.opponent,
    required this.matchDate,
    this.location,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'es');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.sports_soccer,
                    size: 28,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opponent,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(matchDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (location != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            if (notes != null && notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section showing quarter results
class _QuarterResultsSection extends StatelessWidget {
  final List quarterResults;

  const _QuarterResultsSection({
    required this.quarterResults,
  });

  @override
  Widget build(BuildContext context) {
    if (quarterResults.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No hay resultados por cuarto registrados'),
          ),
        ),
      );
    }

    // Calculate total score
    int totalTeamGoals = 0;
    int totalOpponentGoals = 0;
    for (final result in quarterResults) {
      totalTeamGoals += result.teamGoals as int;
      totalOpponentGoals += result.opponentGoals as int;
    }

    return Column(
      children: [
        // Total Score Card
        Card(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey[100],
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Resultado Final',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$totalTeamGoals - $totalOpponentGoals',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Quarter by quarter breakdown
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...List.generate(4, (index) {
                  final quarter = index + 1;
                  final result = quarterResults
                      .where((r) => r.quarter == quarter)
                      .firstOrNull;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            'Cuarto $quarter',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const Spacer(),
                        if (result != null)
                          Text(
                            '${result.teamGoals} - ${result.opponentGoals}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        else
                          Text(
                            'Sin datos',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Section showing goals
class _GoalsSection extends StatelessWidget {
  final List goals;
  final List<Player> players;

  const _GoalsSection({
    required this.goals,
    required this.players,
  });

  String _getPlayerName(String playerId) {
    final player = players.where((p) => p.id == playerId).firstOrNull;
    return player?.fullName ?? 'Desconocido';
  }

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No hay goles registrados'),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: goals.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final goal = goals[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: goal.isOwnGoal
                  ? Colors.orange.shade100
                  : Theme.of(context).colorScheme.tertiaryContainer,
              child: Icon(
                Icons.sports_score,
                color: goal.isOwnGoal
                    ? Colors.orange.shade800
                    : Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ),
            title: Text(
              goal.isOwnGoal ? 'Autogol del Rival' : _getPlayerName(goal.scorerId),
              style: TextStyle(
                fontWeight: goal.isOwnGoal ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            subtitle: !goal.isOwnGoal && goal.assisterId != null
                ? Text('Asistencia: ${_getPlayerName(goal.assisterId)}')
                : goal.isOwnGoal
                    ? const Text('Gol a favor del equipo')
                    : null,
            trailing: Chip(
              label: Text('Q${goal.quarter}'),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
          );
        },
      ),
    );
  }
}

/// Section showing players by quarter
class _PlayersByQuarterSection extends StatelessWidget {
  final List<MatchPlayerPeriod> allPeriods;
  final List<Player> players;

  const _PlayersByQuarterSection({
    required this.allPeriods,
    required this.players,
  });

  String _getPlayerName(String playerId) {
    final player = players.where((p) => p.id == playerId).firstOrNull;
    return player?.fullName ?? 'Desconocido';
  }

  String _getJerseyNumber(String playerId) {
    final player = players.where((p) => p.id == playerId).firstOrNull;
    return player?.jerseyNumber?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    if (allPeriods.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No hay información de jugadores por cuarto'),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(4, (index) {
        final quarter = index + 1;
        final quarterPeriods = allPeriods.where((p) => p.period == quarter).toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'Cuarto $quarter (${quarterPeriods.length} jugadores)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
              ),
              if (quarterPeriods.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('Sin jugadores en este cuarto'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: quarterPeriods.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final period = quarterPeriods[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          _getJerseyNumber(period.playerId),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(_getPlayerName(period.playerId)),
                      subtitle: period.fieldZone != null
                          ? Text('Zona: ${period.fieldZone!.value}')
                          : null,
                      trailing: Chip(
                        label: Text(
                          period.fraction == Fraction.full ? 'Completo' : 'Medio',
                        ),
                        backgroundColor:
                            period.fraction == Fraction.full
                                ? Theme.of(context).colorScheme.tertiaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
