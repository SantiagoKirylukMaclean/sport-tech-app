-- 20251227000003_fix_existing_substitution_data.sql
-- Corregir datos de sustituciones existentes que quedaron sin field_zone

-- Para cada sustitución que existe, intentar asignar un field_zone razonable
-- Si no se puede determinar, asignar una zona por defecto

DO $$
DECLARE
  rec RECORD;
  available_zone text;
BEGIN
  -- Para cada registro con HALF y sin field_zone
  FOR rec IN
    SELECT DISTINCT
      mpp.match_id,
      mpp.player_id,
      mpp.period
    FROM match_player_periods mpp
    WHERE mpp.fraction = 'HALF'
      AND mpp.field_zone IS NULL
  LOOP
    -- Buscar una zona disponible (que no esté ocupada por otro jugador FULL en ese período)
    SELECT COALESCE(
      -- Primero intentar encontrar una zona que el jugador usó en otros períodos
      (
        SELECT field_zone
        FROM match_player_periods
        WHERE match_id = rec.match_id
          AND player_id = rec.player_id
          AND period != rec.period
          AND field_zone IS NOT NULL
        LIMIT 1
      ),
      -- Si no, buscar una zona no ocupada en ese cuarto
      (
        SELECT zone
        FROM (
          VALUES
            ('DELANTERO_IZQUIERDO'),
            ('DELANTERO_CENTRO'),
            ('DELANTERO_DERECHO'),
            ('VOLANTE_IZQUIERDO'),
            ('VOLANTE_CENTRAL'),
            ('VOLANTE_DERECHO'),
            ('DEFENSA_IZQUIERDA'),
            ('DEFENSA_CENTRAL'),
            ('DEFENSA_DERECHA'),
            ('PORTERO')
        ) AS zones(zone)
        WHERE zone NOT IN (
          SELECT field_zone
          FROM match_player_periods
          WHERE match_id = rec.match_id
            AND period = rec.period
            AND field_zone IS NOT NULL
            AND player_id != rec.player_id
        )
        LIMIT 1
      ),
      -- Si todo falla, usar volante central como default
      'VOLANTE_CENTRAL'
    ) INTO available_zone;

    -- Actualizar el registro
    UPDATE match_player_periods
    SET field_zone = available_zone
    WHERE match_id = rec.match_id
      AND player_id = rec.player_id
      AND period = rec.period
      AND fraction = 'HALF'
      AND field_zone IS NULL;

    RAISE NOTICE 'Asignado field_zone % para jugador % en match % periodo %',
      available_zone, rec.player_id, rec.match_id, rec.period;
  END LOOP;
END $$;
