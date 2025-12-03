import 'package:equatable/equatable.dart';
import '../../domain/evaluations/entities/evaluation_category.dart';
import '../../domain/evaluations/entities/evaluation_criterion.dart';

sealed class EvaluationCategoriesState extends Equatable {
  const EvaluationCategoriesState();

  @override
  List<Object?> get props => [];
}

class EvaluationCategoriesInitial extends EvaluationCategoriesState {
  const EvaluationCategoriesInitial();
}

class EvaluationCategoriesLoading extends EvaluationCategoriesState {
  const EvaluationCategoriesLoading();
}

class EvaluationCategoriesLoaded extends EvaluationCategoriesState {
  final List<EvaluationCategory> categories;
  final Map<String, List<EvaluationCriterion>> criteriaByCategory;

  const EvaluationCategoriesLoaded({
    required this.categories,
    required this.criteriaByCategory,
  });

  @override
  List<Object?> get props => [categories, criteriaByCategory];
}

class EvaluationCategoriesError extends EvaluationCategoriesState {
  final String message;

  const EvaluationCategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
