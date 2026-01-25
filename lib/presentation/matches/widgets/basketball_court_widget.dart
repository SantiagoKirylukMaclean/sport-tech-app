import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/match_lineup_notifier.dart';
import 'package:sport_tech_app/domain/matches/entities/field_zone.dart';
import 'package:sport_tech_app/domain/org/entities/player.dart';
import 'package:sport_tech_app/presentation/matches/widgets/basketball_stats_selection_widget.dart';

class BasketballCourtWidget extends ConsumerWidget {
  final String matchId;

  const BasketballCourtWidget({required this.matchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchLineupNotifierProvider(matchId));
    final notifier = ref.read(matchLineupNotifierProvider(matchId).notifier);

    // Group players by zone
    final Map<FieldZone, List<Player>> playersInZones = {};
    for (final zone in FieldZone.values) {
      playersInZones[zone] = [];
    }

    for (final period in state.currentQuarterPeriods) {
      if (period.fieldZone != null) {
        final player = state.fieldPlayers
            .where((p) => p.id == period.playerId)
            .firstOrNull;
        if (player != null) {
          playersInZones[period.fieldZone!]!.add(player);
        }
      }
    }

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
                  Icons.sports_basketball,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cancha (${state.fieldPlayers.length}/5)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 700,
                ),
                child: AspectRatio(
                  aspectRatio: 15 / 28, // Standard court ratio approx
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2B48C), // Wood color
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: BasketballCourtPainter(),
                          child: const SizedBox.expand(),
                        ),
                        // Layout 5 positions
                        // Assuming attacking up? Or just static placement.
                        // Standard setup: PG top, SG/SF wings, PF/C paint/corners

                        // Point Guard (Base) - Top Center (bottom of view if defending?)
                        // Let's assume standard view:
                        // Top: Base
                        // Wings: Escolta, Alero
                        // Low post: AlaPivot, Pivot

                        Column(
                          children: [
                            // Backcourt / Perimeter (Base)
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildFieldZone(
                                    context,
                                    ref,
                                    FieldZone.base,
                                    playersInZones[FieldZone.base]!,
                                    notifier,
                                  ),
                                ],
                              ),
                            ),
                            // Wings (Escolta, Alero)
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  _buildFieldZone(
                                    context,
                                    ref,
                                    FieldZone.escolta,
                                    playersInZones[FieldZone.escolta]!,
                                    notifier,
                                  ),
                                  const Spacer(),
                                  _buildFieldZone(
                                    context,
                                    ref,
                                    FieldZone.alero,
                                    playersInZones[FieldZone.alero]!,
                                    notifier,
                                  ),
                                ],
                              ),
                            ),
                            // Frontcourt / Paint (AlaPivot, Pivot)
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFieldZone(
                                    context,
                                    ref,
                                    FieldZone.alaPivot,
                                    playersInZones[FieldZone.alaPivot]!,
                                    notifier,
                                  ),
                                  _buildFieldZone(
                                    context,
                                    ref,
                                    FieldZone.pivot,
                                    playersInZones[FieldZone.pivot]!,
                                    notifier,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(flex: 1), // Basket area clearance
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bench and warnings (Reused logic ideally, but copied for now)
            Text(
              'Banco',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (state.benchPlayers.isEmpty)
              const Text(
                'Todos en cancha',
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

            if (playersWithoutZone.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text('Sin posición asignada',
                        style: TextStyle(color: Colors.orange)),
                    Wrap(
                      children: playersWithoutZone
                          .map((p) => _buildPlayerChip(p, onField: true))
                          .toList(),
                    )
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Helper methods reusing logic from DraggableFieldWidget (simplified for brevity)
  Widget _buildFieldZone(
    BuildContext context,
    WidgetRef ref,
    FieldZone zone,
    List<Player> playersInZone,
    MatchLineupNotifier notifier,
  ) {
    return Expanded(
      child: DragTarget<Player>(
        onAcceptWithDetails: (details) async {
          final player = details.data;
          final state = ref.read(matchLineupNotifierProvider(matchId));
          final isOnField = state.fieldPlayers.any((p) => p.id == player.id);
          if (!isOnField) {
            await notifier.addPlayerToFieldWithZone(player.id, zone);
          } else {
            await notifier.updatePlayerFieldZone(
              playerId: player.id,
              fieldZone: zone,
            );
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isDraggedOver = candidateData.isNotEmpty;
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDraggedOver
                  ? Colors.orange.withValues(alpha: 0.5)
                  : Colors.transparent,
              border: Border.all(color: Colors.white24),
              shape: BoxShape.circle,
            ),
            child: playersInZone.isNotEmpty
                ? _buildPlayerChip(playersInZone.first, onField: true)
                : Text(
                    zone.displayName,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerChip(Player player,
      {bool onField = false, bool isDragging = false}) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(matchLineupNotifierProvider(matchId));
        return GestureDetector(
          onTap: () {
            if (state.statsMode) {
              showModalBottomSheet(
                context: context,
                builder: (context) => BasketballStatsSelectionWidget(
                  matchId: matchId,
                  player: player,
                ),
              );
            }
          },
          child: Chip(
            label: Text(player.fullName.split(' ').last),
            avatar: CircleAvatar(
                child: Text(player.jerseyNumber?.toString() ?? '#')),
            backgroundColor: onField ? Colors.orange : null,
          ),
        );
      },
    );
  }
}

class BasketballCourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Outer boundary is drawn by container border

    // Half court line (assuming full court view? Or half court?)
    // Usually tactical boards show half court for simpler positioning or full court.
    // Let's draw full court simplified.

    // Center circle
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 5, paint);
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Key areas (Top and Bottom)
    _drawKey(canvas, size, paint, isTop: true);
    _drawKey(canvas, size, paint, isTop: false);
  }

  void _drawKey(Canvas canvas, Size size, Paint paint, {required bool isTop}) {
    final keyWidth = size.width * 0.4;
    final keyHeight = size.height * 0.2;
    final left = (size.width - keyWidth) / 2;
    final top = isTop ? 0.0 : size.height - keyHeight;

    canvas.drawRect(Rect.fromLTWH(left, top, keyWidth, keyHeight), paint);

    // Free throw circle
    final centerY = isTop ? keyHeight : size.height - keyHeight;
    canvas.drawCircle(Offset(size.width / 2, centerY), keyWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
