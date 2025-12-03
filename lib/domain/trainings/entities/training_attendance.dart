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
  final String trainingId;
  final String playerId;
  final AttendanceStatus status;

  const TrainingAttendance({
    required this.trainingId,
    required this.playerId,
    required this.status,
  });

  TrainingAttendance copyWith({
    String? trainingId,
    String? playerId,
    AttendanceStatus? status,
  }) {
    return TrainingAttendance(
      trainingId: trainingId ?? this.trainingId,
      playerId: playerId ?? this.playerId,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        trainingId,
        playerId,
        status,
      ];
}
