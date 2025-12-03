import '../entities/evaluation_category.dart';
import '../entities/evaluation_criterion.dart';

abstract class EvaluationCategoriesRepository {
  Future<List<EvaluationCategory>> listCategories();
  Future<List<EvaluationCriterion>> listCriterionsByCategory(
      String categoryId);
  Future<Map<String, List<EvaluationCriterion>>>
      listAllCategoriesWithCriteria();
}
