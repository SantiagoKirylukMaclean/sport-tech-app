import 'package:equatable/equatable.dart';

class EvaluationCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int displayOrder;
  final DateTime createdAt;

  const EvaluationCategory({
    required this.id,
    required this.name,
    this.description,
    required this.displayOrder,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, displayOrder, createdAt];
}
