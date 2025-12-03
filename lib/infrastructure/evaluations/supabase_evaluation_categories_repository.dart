import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/evaluations/entities/evaluation_category.dart';
import '../../domain/evaluations/entities/evaluation_criterion.dart';
import '../../domain/evaluations/repositories/evaluation_categories_repository.dart';
import 'mappers/evaluation_category_mapper.dart';
import 'mappers/evaluation_criterion_mapper.dart';

class SupabaseEvaluationCategoriesRepository
    implements EvaluationCategoriesRepository {
  final SupabaseClient _client;

  SupabaseEvaluationCategoriesRepository(this._client);

  @override
  Future<List<EvaluationCategory>> listCategories() async {
    final response = await _client
        .from('evaluation_categories')
        .select()
        .order('order_index', ascending: true);

    return (response as List)
        .map((json) => EvaluationCategoryMapper.fromJson(json))
        .toList();
  }

  @override
  Future<List<EvaluationCriterion>> listCriterionsByCategory(
      String categoryId) async {
    final response = await _client
        .from('evaluation_criteria')
        .select()
        .eq('category_id', categoryId)
        .order('order_index', ascending: true);

    return (response as List)
        .map((json) => EvaluationCriterionMapper.fromJson(json))
        .toList();
  }

  @override
  Future<Map<String, List<EvaluationCriterion>>>
      listAllCategoriesWithCriteria() async {
    final categories = await listCategories();
    final Map<String, List<EvaluationCriterion>> result = {};

    for (final category in categories) {
      final criteria = await listCriterionsByCategory(category.id);
      result[category.id] = criteria;
    }

    return result;
  }
}
