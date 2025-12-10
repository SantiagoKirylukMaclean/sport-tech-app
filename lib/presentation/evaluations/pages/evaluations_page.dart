import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/auth/auth_providers.dart';
import 'package:sport_tech_app/application/evaluations/evaluation_categories_notifier.dart';
import 'package:sport_tech_app/application/evaluations/evaluation_categories_state.dart';
import 'package:sport_tech_app/application/evaluations/player_evaluations_notifier.dart';
import 'package:sport_tech_app/application/evaluations/player_evaluations_state.dart';
import 'package:sport_tech_app/application/evaluations/evaluations_providers.dart';
import 'package:sport_tech_app/application/org/active_team_notifier.dart';
import 'package:sport_tech_app/application/org/players_notifier.dart';
import 'package:sport_tech_app/domain/evaluations/entities/evaluation_score.dart';
import 'package:sport_tech_app/domain/evaluations/entities/player_evaluation.dart';
import 'package:sport_tech_app/presentation/coach/pages/coach_evaluations_page.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class EvaluationsPage extends ConsumerStatefulWidget {
  const EvaluationsPage({super.key});

  @override
  ConsumerState<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends ConsumerState<EvaluationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // First, load the user's teams to get the active team
    await ref.read(activeTeamNotifierProvider.notifier).loadUserTeams(user.id);

    final activeTeamState = ref.read(activeTeamNotifierProvider);
    if (activeTeamState.activeTeam == null) return;

    // Load players for the active team
    await ref.read(playersNotifierProvider.notifier).loadPlayersByTeam(
      activeTeamState.activeTeam!.id,
      '1', // TODO: Get sport ID from team
    );

    // Now find the current player
    final playersState = ref.read(playersNotifierProvider);
    final currentPlayer = playersState.players
        .where((p) => p.userId == user.id)
        .firstOrNull;

    if (currentPlayer != null) {
      // Load evaluations
      ref
          .read(playerEvaluationsNotifierProvider.notifier)
          .loadEvaluationsForPlayer(currentPlayer.id);

      // Load categories
      ref
          .read(evaluationCategoriesNotifierProvider.notifier)
          .loadCategoriesWithCriteria();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    final playersState = ref.watch(playersNotifierProvider);
    final evaluationsState = ref.watch(playerEvaluationsNotifierProvider);
    final categoriesState = ref.watch(evaluationCategoriesNotifierProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user authenticated')),
      );
    }

    // If user is a coach or admin, show the coach evaluations page instead
    if (userProfile != null &&
        (userProfile.role == UserRole.coach || userProfile.role.isAdmin)) {
      return const CoachEvaluationsPage();
    }

    if (playersState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (playersState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${playersState.error}'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final currentPlayer = playersState.players
        .where((p) => p.userId == user.id)
        .firstOrNull;

    if (currentPlayer == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'No estás asociado a ningún jugador',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    if (evaluationsState is PlayerEvaluationsLoading ||
        categoriesState is EvaluationCategoriesLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (evaluationsState is PlayerEvaluationsError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${evaluationsState.message}'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (evaluationsState is! PlayerEvaluationsLoaded ||
        categoriesState is! EvaluationCategoriesLoaded) {
      return const Scaffold(
        body: Center(child: Text('Cargando datos...')),
      );
    }

    if (evaluationsState.evaluations.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assessment_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Aún no tienes evaluaciones',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Tu entrenador te evaluará pronto',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, currentPlayer.fullName),
            const SizedBox(height: 24),

            // Latest Evaluation Card
            _buildLatestEvaluationCard(
              context,
              evaluationsState.latestEvaluation!,
              evaluationsState.latestScores,
              categoriesState,
            ),
            const SizedBox(height: 24),

            // Evaluation History
            _buildEvaluationHistory(
              context,
              evaluationsState.evaluations,
              categoriesState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String playerName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Evaluaciones',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          playerName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildLatestEvaluationCard(
    BuildContext context,
    PlayerEvaluation evaluation,
    List<EvaluationScore> scores,
    EvaluationCategoriesLoaded categoriesState,
  ) {
    // Calculate averages by category
    final Map<String, double> categoryAverages = {};
    for (final category in categoriesState.categories) {
      final criteria = categoriesState.criteriaByCategory[category.id] ?? [];
      if (criteria.isEmpty) continue;

      final criteriaIds = criteria.map((c) => c.id).toSet();
      final relevantScores =
          scores.where((s) => criteriaIds.contains(s.criterionId)).toList();

      if (relevantScores.isNotEmpty) {
        final avg = relevantScores.map((s) => s.score).reduce((a, b) => a + b) /
            relevantScores.length;
        categoryAverages[category.name] = avg;
      }
    }

    final overallAverage = categoryAverages.values.isEmpty
        ? 0.0
        : categoryAverages.values.reduce((a, b) => a + b) /
            categoryAverages.values.length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Última Evaluación',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        DateFormat('dd MMMM yyyy')
                            .format(evaluation.evaluationDate),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getScoreColor(overallAverage.round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${overallAverage.toStringAsFixed(1)}/10',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            if (evaluation.generalNotes != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notas del Entrenador',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          evaluation.generalNotes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            // Radar Chart (only if we have at least 3 data points)
            if (categoryAverages.length >= 3)
              SizedBox(
                height: 300,
                child: _buildRadarChart(context, categoryAverages),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChart(
    BuildContext context,
    Map<String, double> categoryAverages,
  ) {
    final dataSpots = categoryAverages.values
        .map((value) => RadarEntry(value: value))
        .toList();

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 5,
        ticksTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
        tickBorderData: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        gridBorderData: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        radarBorderData: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        titlePositionPercentageOffset: 0.15,
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        titleTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
            ),
        getTitle: (index, angle) {
          final categoryName = categoryAverages.keys.elementAt(index);
          // Shorten long category names
          final shortName = categoryName.length > 15
              ? '${categoryName.substring(0, 12)}...'
              : categoryName;
          return RadarChartTitle(text: shortName);
        },
        dataSets: [
          RadarDataSet(
            fillColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            borderColor: Theme.of(context).colorScheme.primary,
            borderWidth: 2,
            dataEntries: dataSpots,
          ),
        ],
        radarTouchData: RadarTouchData(enabled: false),
      ),
    );
  }

  Widget _buildEvaluationHistory(
    BuildContext context,
    List<PlayerEvaluation> evaluations,
    EvaluationCategoriesLoaded categoriesState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de Evaluaciones',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: evaluations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final evaluation = evaluations[index];
            return _buildHistoryItem(context, evaluation, index, categoriesState);
          },
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    PlayerEvaluation evaluation,
    int index,
    EvaluationCategoriesLoaded categoriesState,
  ) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          child: Text('${index + 1}'),
        ),
        title: Text(
          DateFormat('dd MMM yyyy').format(evaluation.evaluationDate),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: evaluation.generalNotes != null
            ? Text(
                evaluation.generalNotes!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        children: [
          FutureBuilder<List<EvaluationScore>>(
            future: ref
                .read(playerEvaluationsNotifierProvider.notifier)
                .getScoresForEvaluation(evaluation.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final scores = snapshot.data!;
              return _buildScoreDetails(
                  context, scores, categoriesState, evaluation);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetails(
    BuildContext context,
    List<EvaluationScore> scores,
    EvaluationCategoriesLoaded categoriesState,
    PlayerEvaluation evaluation,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...categoriesState.categories.map((category) {
            final criteria = categoriesState.criteriaByCategory[category.id] ?? [];
            final criteriaIds = criteria.map((c) => c.id).toSet();
            final relevantScores =
                scores.where((s) => criteriaIds.contains(s.criterionId)).toList();

            if (relevantScores.isEmpty) return const SizedBox.shrink();

            final avg = relevantScores.map((s) => s.score).reduce((a, b) => a + b) /
                relevantScores.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(avg.round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (evaluation.generalNotes != null) ...[
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Notas:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(evaluation.generalNotes!),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }
}
