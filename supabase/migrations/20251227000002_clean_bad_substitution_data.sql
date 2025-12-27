-- 20251227000002_clean_bad_substitution_data.sql
-- Limpiar datos de sustituciones que quedaron sin field_zone

-- Opción 1: Ver los registros problemáticos primero
-- SELECT mpp.*, p.first_name, p.last_name
-- FROM match_player_periods mpp
-- LEFT JOIN players p ON p.id = mpp.player_id
-- WHERE mpp.fraction = 'HALF' AND mpp.field_zone IS NULL;

-- Opción 2: Si quieres eliminar estos registros problemáticos:
-- DELETE FROM match_player_periods
-- WHERE fraction = 'HALF' AND field_zone IS NULL;

-- Opción 3: Si quieres también limpiar las sustituciones asociadas:
-- DELETE FROM match_substitutions
-- WHERE (match_id, period, player_out, player_in) IN (
--   SELECT DISTINCT
--     mpp1.match_id,
--     mpp1.period,
--     mpp1.player_id as player_out,
--     mpp2.player_id as player_in
--   FROM match_player_periods mpp1
--   JOIN match_player_periods mpp2
--     ON mpp1.match_id = mpp2.match_id
--     AND mpp1.period = mpp2.period
--     AND mpp1.player_id < mpp2.player_id
--   WHERE mpp1.fraction = 'HALF'
--     AND mpp1.field_zone IS NULL
--     AND mpp2.fraction = 'HALF'
--     AND mpp2.field_zone IS NULL
-- );

-- Por ahora, solo mostramos información
-- Esta migración está comentada para evitar pérdida de datos
-- Descomentar solo después de revisar los datos
SELECT
  'Registros con HALF sin field_zone: ' || COUNT(*) as message
FROM match_player_periods
WHERE fraction = 'HALF' AND field_zone IS NULL;
