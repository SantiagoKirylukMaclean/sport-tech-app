import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/evaluations/evaluation_categories_notifier.dart';
import 'package:sport_tech_app/application/evaluations/evaluation_categories_state.dart';
import 'package:sport_tech_app/application/evaluations/player_evaluations_notifier.dart';
import 'package:sport_tech_app/application/evaluations/player_evaluations_state.dart';
import 'package:sport_tech_app/application/evaluations/evaluations_providers.dart';
import 'package:sport_tech_app/application/org/players_notifier.dart';
import 'package:sport_tech_app/domain/evaluations/entities/evaluation_score.dart';
import 'package:sport_tech_app/domain/evaluations/entities/player_evaluation.dart';
import 'package:intl/intl.dart';

class EvaluationDetailPage extends ConsumerStatefulWidget {
  final String evaluationId;
  final String playerId;

  const EvaluationDetailPage({
    super.key,
    required this.evaluationId,
    required this.playerId,
  });

  @override
  ConsumerState<EvaluationDetailPage> createState() =>
      _EvaluationDetailPageState();
}

class _EvaluationDetailPageState extends ConsumerState<EvaluationDetailPage> {
  List<EvaluationScore>? _scores;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load categories if not loaded
      final categoriesState = ref.read(evaluationCategoriesNotifierProvider);
      if (categoriesState is! EvaluationCategoriesLoaded) {
        await ref
            .read(evaluationCategoriesNotifierProvider.notifier)
            .loadCategoriesWithCriteria();
      }

      // Load scores for this evaluation
      final scores = await ref
          .read(playerEvaluationsNotifierProvider.notifier)
          .getScoresForEvaluation(widget.evaluationId);

      if (mounted) {
        setState(() {
          _scores = scores;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersState = ref.watch(playersNotifierProvider);
    final evaluationsState = ref.watch(playerEvaluationsNotifierProvider);
    final categoriesState = ref.watch(evaluationCategoriesNotifierProvider);

    // Find the evaluation
    PlayerEvaluation? evaluation;
    if (evaluationsState is PlayerEvaluationsLoaded) {
      evaluation = evaluationsState.evaluations
          .where((e) => e.id == widget.evaluationId)
          .firstOrNull;
    }

    // Find player name
    String playerName = 'Jugador';
    if (playersState.players.isNotEmpty) {
      final player = playersState.players
          .firstWhere((p) => p.id == widget.playerId,
              orElse: () => null as dynamic);
      if (player != null) {
        playerName = player.fullName;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluación - $playerName'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(evaluation, categoriesState),
    );
  }

  Widget _buildBody(
    PlayerEvaluation? evaluation,
    EvaluationCategoriesState categoriesState,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (evaluation == null || _scores == null) {
      return const Center(
        child: Text('No se encontró la evaluación'),
      );
    }

    if (categoriesState is! EvaluationCategoriesLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de Evaluación',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          DateFormat('dd MMMM yyyy')
                              .format(evaluation.evaluationDate),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Radar Chart (only if we have at least 3 categories with data)
          if (_hasEnoughDataForRadar(categoriesState))
            ...[
              _buildRadarChart(context, categoriesState),
              const SizedBox(height: 24),
            ],

          // Scores by category
          ...categoriesState.categories.map((category) {
            final criteria = categoriesState.criteriaByCategory[category.id] ?? [];
            final criteriaIds = criteria.map((c) => c.id).toSet();
            final relevantScores =
                _scores!.where((s) => criteriaIds.contains(s.criterionId)).toList();

            if (relevantScores.isEmpty) return const SizedBox.shrink();

            return _buildCategorySection(
              context,
              category.name,
              criteria,
              relevantScores,
            );
          }),

          // General notes
          if (evaluation.generalNotes != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notes,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notas Generales',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      evaluation.generalNotes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasEnoughDataForRadar(EvaluationCategoriesLoaded categoriesState) {
    int categoriesWithData = 0;
    for (final category in categoriesState.categories) {
      final criteria = categoriesState.criteriaByCategory[category.id] ?? [];
      if (criteria.isEmpty) continue;

      final criteriaIds = criteria.map((c) => c.id).toSet();
      final relevantScores =
          _scores!.where((s) => criteriaIds.contains(s.criterionId)).toList();

      if (relevantScores.isNotEmpty) {
        categoriesWithData++;
      }
    }
    return categoriesWithData >= 3;
  }

  Widget _buildRadarChart(
    BuildContext context,
    EvaluationCategoriesLoaded categoriesState,
  ) {
    // Calculate averages by category
    final Map<String, double> categoryAverages = {};
    for (final category in categoriesState.categories) {
      final criteria = categoriesState.criteriaByCategory[category.id] ?? [];
      if (criteria.isEmpty) continue;

      final criteriaIds = criteria.map((c) => c.id).toSet();
      final relevantScores =
          _scores!.where((s) => criteriaIds.contains(s.criterionId)).toList();

      if (relevantScores.isNotEmpty) {
        final avg = relevantScores.map((s) => s.score).reduce((a, b) => a + b) /
            relevantScores.length;
        categoryAverages[category.name] = avg;
      }
    }

    final dataSpots = categoryAverages.values
        .map((value) => RadarEntry(value: value))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen por Categorías',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  ticksTextStyle:
                      Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
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
                  titleTextStyle:
                      Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                  getTitle: (index, angle) {
                    final categoryName = categoryAverages.keys.elementAt(index);
                    final shortName = categoryName.length > 15
                        ? '${categoryName.substring(0, 12)}...'
                        : categoryName;
                    return RadarChartTitle(text: shortName);
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                      borderColor: Theme.of(context).colorScheme.primary,
                      borderWidth: 2,
                      dataEntries: dataSpots,
                    ),
                  ],
                  radarTouchData: RadarTouchData(enabled: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String categoryName,
    List<dynamic> criteria,
    List<EvaluationScore> scores,
  ) {
    final avg = scores.map((s) => s.score).reduce((a, b) => a + b) / scores.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(avg.round()),
                    borderRadius: BorderRadius.circular(8),
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
            const SizedBox(height: 16),
            const Divider(),
            ...scores.map((score) {
              try {
                final criterion = criteria.firstWhere(
                  (c) => c.id == score.criterionId,
                );
                return _buildScoreItem(context, criterion, score);
              } catch (e) {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    dynamic criterion,
    EvaluationScore score,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      criterion.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (criterion.description != null)
                      Text(
                        criterion.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(score.score),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  score.score.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          if (score.notes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      score.notes!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
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
