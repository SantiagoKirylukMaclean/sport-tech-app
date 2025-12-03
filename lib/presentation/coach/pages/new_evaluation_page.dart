import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/application/auth/auth_providers.dart';
import 'package:sport_tech_app/application/evaluations/evaluation_categories_notifier.dart';
import 'package:sport_tech_app/application/evaluations/evaluation_categories_state.dart';
import 'package:sport_tech_app/application/evaluations/player_evaluations_state.dart';
import 'package:sport_tech_app/application/evaluations/evaluations_providers.dart';
import 'package:sport_tech_app/application/org/org_providers.dart';
import 'package:sport_tech_app/application/org/players/players_state.dart';
import 'package:sport_tech_app/domain/evaluations/entities/evaluation_category.dart';
import 'package:sport_tech_app/domain/evaluations/entities/evaluation_criterion.dart';

class NewEvaluationPage extends ConsumerStatefulWidget {
  final String playerId;

  const NewEvaluationPage({
    super.key,
    required this.playerId,
  });

  @override
  ConsumerState<NewEvaluationPage> createState() => _NewEvaluationPageState();
}

class _NewEvaluationPageState extends ConsumerState<NewEvaluationPage> {
  final Map<String, int> _scores = {};
  final Map<String, String> _scoreNotes = {};
  final _generalNotesController = TextEditingController();
  DateTime _evaluationDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(evaluationCategoriesNotifierProvider.notifier)
          .loadCategoriesWithCriteria();
    });
  }

  @override
  void dispose() {
    _generalNotesController.dispose();
    super.dispose();
  }

  Future<void> _submitEvaluation() async {
    final categoriesState = ref.read(evaluationCategoriesNotifierProvider);
    if (categoriesState is! EvaluationCategoriesLoaded) return;

    // Validate that all criteria have scores
    final allCriteriaIds = categoriesState.criteriaByCategory.values
        .expand((criteria) => criteria)
        .map((c) => c.id)
        .toList();

    final missingScores =
        allCriteriaIds.where((id) => !_scores.containsKey(id)).toList();

    if (missingScores.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor califica todos los criterios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No hay usuario autenticado')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      await ref
          .read(playerEvaluationsNotifierProvider.notifier)
          .createEvaluation(
            playerId: widget.playerId,
            evaluatorId: user.id,
            evaluationDate: _evaluationDate,
            generalNotes: _generalNotesController.text.isEmpty
                ? null
                : _generalNotesController.text,
            scores: _scores,
            scoreNotes: _scoreNotes,
          );

      if (!mounted) return;

      final state = ref.read(playerEvaluationsNotifierProvider);
      if (state is PlayerEvaluationSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evaluación guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (state is PlayerEvaluationsError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersState = ref.watch(playersNotifierProvider);
    final categoriesState = ref.watch(evaluationCategoriesNotifierProvider);

    String playerName = 'Jugador';
    if (playersState is PlayersLoaded) {
      final player = playersState.players
          .firstWhere((p) => p.id == widget.playerId, orElse: () => null as dynamic);
      if (player != null) {
        playerName = player.fullName;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Evaluación - $playerName'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _submitEvaluation,
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            ),
        ],
      ),
      body: _buildBody(categoriesState),
    );
  }

  Widget _buildBody(EvaluationCategoriesState state) {
    if (state is EvaluationCategoriesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is EvaluationCategoriesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(evaluationCategoriesNotifierProvider.notifier)
                    .loadCategoriesWithCriteria();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state is! EvaluationCategoriesLoaded) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha de Evaluación'),
              subtitle: Text(
                '${_evaluationDate.day}/${_evaluationDate.month}/${_evaluationDate.year}',
              ),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _evaluationDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _evaluationDate = date);
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // Evaluation criteria by category
          ...state.categories.map((category) {
            final criteria = state.criteriaByCategory[category.id] ?? [];
            return _buildCategorySection(category, criteria);
          }),

          const SizedBox(height: 24),

          // General notes
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _generalNotesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Escribe observaciones generales sobre la evaluación...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _submitEvaluation,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSubmitting ? 'Guardando...' : 'Guardar Evaluación'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    EvaluationCategory category,
    List<EvaluationCriterion> criteria,
  ) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (category.description != null)
                        Text(
                          category.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            const SizedBox(height: 16),
            const Divider(),
            ...criteria.map((criterion) => _buildCriterionItem(criterion)),
          ],
        ),
      ),
    );
  }

  Widget _buildCriterionItem(EvaluationCriterion criterion) {
    final score = _scores[criterion.id] ?? 5;
    final hasNote = _scoreNotes.containsKey(criterion.id);

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
                  color: _getScoreColor(score),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  score.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: score.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: score.toString(),
                  onChanged: (value) {
                    setState(() {
                      _scores[criterion.id] = value.toInt();
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  hasNote ? Icons.note : Icons.note_add_outlined,
                  color: hasNote ? Theme.of(context).colorScheme.primary : null,
                ),
                onPressed: () => _showNotesDialog(criterion),
                tooltip: 'Agregar nota',
              ),
            ],
          ),
          if (hasNote)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color:
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _scoreNotes[criterion.id]!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showNotesDialog(criterion),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }

  void _showNotesDialog(EvaluationCriterion criterion) {
    final controller =
        TextEditingController(text: _scoreNotes[criterion.id] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nota - ${criterion.name}'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escribe una nota sobre este criterio...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          if (_scoreNotes.containsKey(criterion.id))
            TextButton(
              onPressed: () {
                setState(() {
                  _scoreNotes.remove(criterion.id);
                });
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _scoreNotes[criterion.id] = controller.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
