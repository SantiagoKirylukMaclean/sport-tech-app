-- Add color columns to clubs table for Material Design 3 theming
-- Colors are stored as BIGINT in ARGB format (Flutter Color.value format)
-- BIGINT is required because ARGB values can exceed INTEGER range (2^31-1)

-- Add color columns (nullable to support clubs without custom colors)
ALTER TABLE public.clubs
ADD COLUMN IF NOT EXISTS primary_color BIGINT,
ADD COLUMN IF NOT EXISTS secondary_color BIGINT,
ADD COLUMN IF NOT EXISTS tertiary_color BIGINT;

-- Add comments for documentation
COMMENT ON COLUMN public.clubs.primary_color IS 'Primary brand color as ARGB bigint (Flutter Color.value format). Example: 0xFF2196F3 = 4283190348';
COMMENT ON COLUMN public.clubs.secondary_color IS 'Secondary brand color as ARGB bigint (Flutter Color.value format)';
COMMENT ON COLUMN public.clubs.tertiary_color IS 'Tertiary brand color as ARGB bigint (Flutter Color.value format)';

-- Apply default colors to existing clubs (Material Design Blue 500, Green 500, Orange 500)
-- This ensures backward compatibility and provides professional defaults
UPDATE public.clubs
SET
  primary_color = 4283190348,   -- 0xFF2196F3 (Blue 500)
  secondary_color = 4287861583, -- 0xFF4CAF50 (Green 500)
  tertiary_color = 4294940928   -- 0xFFFF9800 (Orange 500)
WHERE primary_color IS NULL;
