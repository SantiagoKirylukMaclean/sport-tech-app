import 'package:equatable/equatable.dart';

enum AttendanceStatus {
  onTime('on_time'),
  late('late'),
  absent('absent');

  final String value;
  const AttendanceStatus(this.value);

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AttendanceStatus.absent,
    );
  }
}

class TrainingAttendance extends Equatable {
  final String id;
  final String sessionId;
  final String playerId;
  final AttendanceStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TrainingAttendance({
    required this.id,
    required this.sessionId,
    required this.playerId,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  TrainingAttendance copyWith({
    String? id,
    String? sessionId,
    String? playerId,
    AttendanceStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingAttendance(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      playerId: playerId ?? this.playerId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        playerId,
        status,
        notes,
        createdAt,
        updatedAt,
      ];
}
