import '../../../domain/evaluations/entities/evaluation_criterion.dart';

class EvaluationCriterionMapper {
  static EvaluationCriterion fromJson(Map<String, dynamic> json) {
    return EvaluationCriterion(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      displayOrder: json['order_index'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(EvaluationCriterion criterion) {
    return {
      'id': criterion.id,
      'category_id': criterion.categoryId,
      'name': criterion.name,
      'description': criterion.description,
      'order_index': criterion.displayOrder,
      'created_at': criterion.createdAt.toIso8601String(),
    };
  }
}
