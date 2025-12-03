import '../../../domain/evaluations/entities/evaluation_category.dart';

class EvaluationCategoryMapper {
  static EvaluationCategory fromJson(Map<String, dynamic> json) {
    return EvaluationCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      displayOrder: json['order_index'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> toJson(EvaluationCategory category) {
    return {
      'id': category.id,
      'name': category.name,
      'description': category.description,
      'order_index': category.displayOrder,
      'created_at': category.createdAt.toIso8601String(),
    };
  }
}
