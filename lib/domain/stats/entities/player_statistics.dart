import 'package:equatable/equatable.dart';

/// Entity representing comprehensive statistics for a player
class PlayerStatistics extends Equatable {
  final String playerId;
  final String playerName;
  final String? jerseyNumber;
  final int totalMatches;
  final int totalTrainingSessions;
  final int matchesAttended;
  final int trainingsAttended;
  final double matchAttendancePercentage;
  final double trainingAttendancePercentage;
  final double averagePeriods;
  final int totalGoals;
  final int totalAssists;

  const PlayerStatistics({
    required this.playerId,
    required this.playerName,
    this.jerseyNumber,
    required this.totalMatches,
    required this.totalTrainingSessions,
    required this.matchesAttended,
    required this.trainingsAttended,
    required this.matchAttendancePercentage,
    required this.trainingAttendancePercentage,
    required this.averagePeriods,
    required this.totalGoals,
    required this.totalAssists,
  });

  @override
  List<Object?> get props => [
        playerId,
        playerName,
        jerseyNumber,
        totalMatches,
        totalTrainingSessions,
        matchesAttended,
        trainingsAttended,
        matchAttendancePercentage,
        trainingAttendancePercentage,
        averagePeriods,
        totalGoals,
        totalAssists,
      ];
}
