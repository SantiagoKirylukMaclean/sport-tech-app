import 'package:equatable/equatable.dart';

/// Result type for a match
enum MatchResult { win, draw, loss }

/// Entity representing a summary of a match
class MatchSummary extends Equatable {
  final String matchId;
  final String opponent;
  final DateTime matchDate;
  final int teamGoals;
  final int opponentGoals;
  final MatchResult result;

  const MatchSummary({
    required this.matchId,
    required this.opponent,
    required this.matchDate,
    required this.teamGoals,
    required this.opponentGoals,
    required this.result,
  });

  @override
  List<Object?> get props => [
        matchId,
        opponent,
        matchDate,
        teamGoals,
        opponentGoals,
        result,
      ];
}
