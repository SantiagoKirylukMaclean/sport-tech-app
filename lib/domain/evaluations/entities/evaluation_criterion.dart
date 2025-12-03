import 'package:equatable/equatable.dart';

class EvaluationCriterion extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final int displayOrder;
  final DateTime createdAt;

  const EvaluationCriterion({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.displayOrder,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, categoryId, name, description, displayOrder, createdAt];
}
