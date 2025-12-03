import 'package:flutter_riverpod/flutter_riverpod.dart';
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

      state = EvaluationCategoriesLoaded(
        categories: categories,
        criteriaByCategory: criteriaByCategory,
      );
    } catch (e) {
      state = EvaluationCategoriesError(e.toString());
    }
  }
}
