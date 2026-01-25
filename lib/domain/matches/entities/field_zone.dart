// lib/domain/matches/entities/field_zone.dart

/// Represents the zones on a 7-a-side soccer field
/// Layout (from goalkeeper's perspective):
///
///       DELANTERO_IZQUIERDO | DELANTERO_DERECHO
///  VOLANTE_IZQUIERDO | VOLANTE_CENTRAL | VOLANTE_DERECHO
///  DEFENSA_IZQUIERDA | DEFENSA_CENTRAL | DEFENSA_DERECHA
///                       PORTERO
///
/// Note: DELANTERO_CENTRO is kept for backwards compatibility but not used in UI
enum FieldZone {
  portero('PORTERO', 'Portero'),
  defensaIzquierda('DEFENSA_IZQUIERDA', 'Defensa Izquierda'),
  defensaCentral('DEFENSA_CENTRAL', 'Defensa Central'),
  defensaDerecha('DEFENSA_DERECHA', 'Defensa Derecha'),
  volanteIzquierdo('VOLANTE_IZQUIERDO', 'Volante Izquierdo'),
  volanteCentral('VOLANTE_CENTRAL', 'Volante Central'),
  volanteDerecho('VOLANTE_DERECHO', 'Volante Derecho'),
  delanteroIzquierdo('DELANTERO_IZQUIERDO', 'Delantero Izquierdo'),
  delanteroCentro('DELANTERO_CENTRO', 'Delantero Centro'),
  delanteroDerecho('DELANTERO_DERECHO', 'Delantero Derecho'),
  // Basketball Positions
  base('BASE', 'Base'),
  escolta('ESCOLTA', 'Escolta'),
  alero('ALERO', 'Alero'),
  alaPivot('ALA_PIVOT', 'Ala-Pívot'),
  pivot('PIVOT', 'Pívot');

  const FieldZone(this.value, this.displayName);
  final String value;
  final String displayName;

  static FieldZone? fromString(String? value) {
    if (value == null) return null;

    return FieldZone.values.firstWhere(
      (z) => z.value == value.toUpperCase(),
      orElse: () => FieldZone.portero,
    );
  }
}
