import 'package:equatable/equatable.dart';

/// Entity representing performance statistics for a specific quarter
class QuarterPerformance extends Equatable {
  final int quarterNumber;
  final int goalsFor;
  final int goalsAgainst;
  final int wins;
  final int draws;
  final int losses;
  final double effectiveness;

  const QuarterPerformance({
    required this.quarterNumber,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.effectiveness,
  });

  @override
  List<Object?> get props => [
        quarterNumber,
        goalsFor,
        goalsAgainst,
        wins,
        draws,
        losses,
        effectiveness,
      ];
}
