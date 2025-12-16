// lib/presentation/matches/widgets/draggable_field_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/domain/matches/entities/field_zone.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';

class DraggableFieldWidget extends ConsumerWidget {
  final String matchId;

  const DraggableFieldWidget({required this.matchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchLineupNotifierProvider(matchId));
    final notifier = ref.read(matchLineupNotifierProvider(matchId).notifier);

    // Get players grouped by field zone
    final Map<FieldZone, Player?> playersInZones = {};
    for (final zone in FieldZone.values) {
      playersInZones[zone] = null;
    }

    // Fill in the players currently on field
    for (final period in state.currentQuarterPeriods) {
      if (period.fieldZone != null) {
        final player = state.fieldPlayers
            .where((p) => p.id == period.playerId)
            .firstOrNull;
        if (player != null) {
          playersInZones[period.fieldZone!] = player;
        }
      }
    }

    // Debug: Check if we have players without zones
    final playersWithoutZone = state.fieldPlayers.where((player) {
      return !state.currentQuarterPeriods
          .any((p) => p.playerId == player.id && p.fieldZone != null);
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_soccer,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Formación - Cancha (${state.fieldPlayers.length}/7 jugadores)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Soccer Field
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 700,
                ),
                child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.shade700,
                      Colors.green.shade600,
                      Colors.green.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Stack(
                  children: [
                    // Field markings
                    _buildFieldMarkings(),

                    // Field zones (3 forwards + 3 midfielders + 3 defenders + 1 goalkeeper = 10 positions)
                    Column(
                      children: [
                        // Forward line (3 forwards)
                        Expanded(
                          child: Row(
                            children: [
                              _buildFieldZone(
                                context,
                                ref,
                                FieldZone.delanteroIzquierdo,
                                playersInZones[FieldZone.delanteroIzquierdo],
                                notifier,
                              ),
                              _buildFieldZone(
                                context,
                                ref,
                                FieldZone.delanteroCentro,
                                playersInZones[FieldZone.delanteroCentro],
                                notifier,
                              ),
                              _buildFieldZone(
                                context,
                                ref,
                                FieldZone.delanteroDerecho,
                                playersInZones[FieldZone.delanteroDerecho],
                                notifier,
                              ),
                            ],
                          ),
                        ),
                        // Midfield line
                        Expanded(
                          child: Row(
                            children: [
                              _buildFieldZone(
                                context,
                                ref,
                                FieldZone.volanteIzquierdo,
                                playersInZones[FieldZone.volanteIzquierdo],
                                notifier,
                              ),
                              _buildFieldZone(
                                context,
                                ref,
                                FieldZone.volanteCentral,
                                playersInZones[FieldZone.volanteCentral],
                                notifier,
                              ),
                              _buildFieldZone(
                                context,
                                ref,
                                FieldZone.volanteDerecho,
                                playersInZones[FieldZone.volanteDerecho],
                                notifier,
                              ),
                            ],
                          ),
                        ),
                        // Defense line
                        Expanded(
                          child: Row(
                            children: [
                              _buildFieldZone(
                                context,
                                ref,
                                FieldZone.defensaIzquierda,
                                playersInZones[FieldZone.defensaIzquierda],
                                notifier,
                              ),
                              _buildFieldZone(
                                context,
                                ref,
                                FieldZone.defensaCentral,
                                playersInZones[FieldZone.defensaCentral],
                                notifier,
                              ),
                              _buildFieldZone(
                                context,
                                ref,
                                FieldZone.defensaDerecha,
                                playersInZones[FieldZone.defensaDerecha],
                                notifier,
                              ),
                            ],
                          ),
                        ),
                        // Goalkeeper
                        Expanded(
                          child: Row(
                            children: [
                              const Spacer(),
                              Expanded(
                                flex: 2,
                                child: _buildFieldZone(
                                  context,
                                  ref,
                                  FieldZone.portero,
                                  playersInZones[FieldZone.portero],
                                  notifier,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ),
            ),

            const SizedBox(height: 16),

            // Available players (bench)
            Text(
              'Banco',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (state.benchPlayers.isEmpty)
              const Text(
                'Todos los jugadores están en la cancha',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.benchPlayers.map((player) {
                  return Draggable<Player>(
                    data: player,
                    feedback: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(20),
                      child: _buildPlayerChip(player, isDragging: true),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _buildPlayerChip(player),
                    ),
                    child: _buildPlayerChip(player),
                  );
                }).toList(),
              ),

            // Show players on field but without position assigned
            if (playersWithoutZone.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'En cancha sin posición asignada',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: playersWithoutZone.map((player) {
                        return Draggable<Player>(
                          data: player,
                          feedback: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(20),
                            child: _buildPlayerChip(player, isDragging: true),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildPlayerChip(player, onField: true),
                          ),
                          child: _buildPlayerChip(player, onField: true),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFieldMarkings() {
    return CustomPaint(
      painter: FieldMarkingsPainter(),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildFieldZone(
    BuildContext context,
    WidgetRef ref,
    FieldZone zone,
    Player? currentPlayer,
    MatchLineupNotifier notifier,
  ) {
    return Expanded(
      child: DragTarget<Player>(
        onAcceptWithDetails: (details) async {
          final player = details.data;
          final state = ref.read(matchLineupNotifierProvider(matchId));

          // Check if player is already on field
          final isOnField = state.fieldPlayers.any((p) => p.id == player.id);

          if (!isOnField) {
            // Add player to field first with the zone
            await notifier.addPlayerToFieldWithZone(player.id, zone);
          } else {
            // Just update their field zone
            await notifier.updatePlayerFieldZone(
              playerId: player.id,
              fieldZone: zone,
            );
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isDraggedOver = candidateData.isNotEmpty;

          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDraggedOver
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDraggedOver
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                width: isDraggedOver ? 2 : 1,
              ),
            ),
            child: currentPlayer != null
                ? Center(
                    child: Draggable<Player>(
                      data: currentPlayer,
                      feedback: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(20),
                        child: _buildPlayerChip(currentPlayer, isDragging: true),
                      ),
                      childWhenDragging: Container(),
                      child: _buildPlayerChip(currentPlayer, onField: true),
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        zone.displayName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerChip(Player player, {bool onField = false, bool isDragging = false}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 60),
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: onField ? Colors.green : Colors.grey,
          child: Text(
            player.jerseyNumber?.toString() ?? '?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        label: Text(
          player.fullName.split(' ').last, // Last name only for space
          style: TextStyle(
            fontSize: isDragging ? 13 : 12,
            fontWeight: isDragging ? FontWeight.bold : FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }
}

class FieldMarkingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      30,
      paint,
    );

    // Horizontal lines dividing the field
    final lineHeight = size.height / 4;
    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(0, lineHeight * i),
        Offset(size.width, lineHeight * i),
        paint,
      );
    }

    // Vertical lines dividing the field
    final lineWidth = size.width / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(lineWidth * i, 0),
        Offset(lineWidth * i, size.height * 0.75),
        paint,
      );
    }

    // Goal area (bottom)
    final goalWidth = size.width * 0.4;
    final goalLeft = (size.width - goalWidth) / 2;
    canvas.drawRect(
      Rect.fromLTWH(
        goalLeft,
        size.height * 0.9,
        goalWidth,
        size.height * 0.1,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
