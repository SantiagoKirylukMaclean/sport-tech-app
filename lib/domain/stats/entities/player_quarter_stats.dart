import 'package:equatable/equatable.dart';

class PlayerQuarterStats extends Equatable {
  final String playerId;
  final String playerName;
  final String jerseyNumber;
  final int quartersPlayed;
  final int quartersWon;
  final int quartersLost;
  final int quartersDrawn;

  const PlayerQuarterStats({
    required this.playerId,
    required this.playerName,
    required this.jerseyNumber,
    required this.quartersPlayed,
    required this.quartersWon,
    required this.quartersLost,
    required this.quartersDrawn,
  });

  double get winPercentage =>
      quartersPlayed > 0 ? (quartersWon / quartersPlayed) * 100 : 0.0;

  @override
  List<Object?> get props => [
        playerId,
        playerName,
        jerseyNumber,
        quartersPlayed,
        quartersWon,
        quartersLost,
        quartersDrawn,
      ];
}
