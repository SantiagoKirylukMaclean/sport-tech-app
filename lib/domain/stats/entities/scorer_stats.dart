import 'package:equatable/equatable.dart';

/// Entity representing scorer or assister statistics
class ScorerStats extends Equatable {
  final String playerId;
  final String playerName;
  final String? jerseyNumber;
  final int count;

  const ScorerStats({
    required this.playerId,
    required this.playerName,
    this.jerseyNumber,
    required this.count,
  });

  @override
  List<Object?> get props => [
        playerId,
        playerName,
        jerseyNumber,
        count,
      ];
}
