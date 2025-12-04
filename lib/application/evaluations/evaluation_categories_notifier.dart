import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/evaluations/entities/evaluation_category.dart';
import '../../domain/evaluations/entities/evaluation_criterion.dart';
import '../../domain/evaluations/repositories/evaluation_categories_repository.dart';
import 'evaluation_categories_state.dart';

class EvaluationCategoriesNotifier
    extends StateNotifier<EvaluationCategoriesState> {
  final EvaluationCategoriesRepository _repository;

  EvaluationCategoriesNotifier(this._repository)
      : super(const EvaluationCategoriesInitial());

  Future<void> loadCategoriesWithCriteria() async {
    state = const EvaluationCategoriesLoading();
    try {
      final categories = await _repository.listCategories();
      final criteriaByCategory =
          await _repository.listAllCategoriesWithCriteria();

      // Remove duplicates by ID
      final uniqueCategoriesMap = <String, EvaluationCategory>{};
      for (final category in categories) {
        uniqueCategoriesMap[category.id] = category;
      }

      final uniqueCriteriaByCategory = <String, List<EvaluationCriterion>>{};
      criteriaByCategory.forEach((categoryId, criteria) {
        final uniqueCriteriaMap = <String, EvaluationCriterion>{};
        for (final criterion in criteria) {
          uniqueCriteriaMap[criterion.id] = criterion;
        }
        uniqueCriteriaByCategory[categoryId] = uniqueCriteriaMap.values.toList();
      });

      print('DEBUG: Loaded ${uniqueCategoriesMap.length} unique categories');
      uniqueCriteriaByCategory.forEach((catId, criteria) {
        print('DEBUG: Category $catId has ${criteria.length} unique criteria');
      });

      state = EvaluationCategoriesLoaded(
        categories: uniqueCategoriesMap.values.toList(),
        criteriaByCategory: uniqueCriteriaByCategory,
      );
    } catch (e) {
      state = EvaluationCategoriesError(e.toString());
    }
  }
}
