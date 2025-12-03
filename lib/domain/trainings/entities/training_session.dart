import 'package:equatable/equatable.dart';

class TrainingSession extends Equatable {
  final String id;
  final String teamId;
  final DateTime sessionDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TrainingSession({
    required this.id,
    required this.teamId,
    required this.sessionDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  TrainingSession copyWith({
    String? id,
    String? teamId,
    DateTime? sessionDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingSession(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      sessionDate: sessionDate ?? this.sessionDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        teamId,
        sessionDate,
        notes,
        createdAt,
        updatedAt,
      ];
}
