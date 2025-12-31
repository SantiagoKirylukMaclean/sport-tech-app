-- Repair migration to handle missing evaluation tables in Prod
-- Likely caused by manual deletion or out-of-sync migration file history

-- 1. Create evaluation_categories if it doesn't exist
CREATE TABLE IF NOT EXISTS evaluation_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create evaluation_criteria if it doesn't exist
CREATE TABLE IF NOT EXISTS evaluation_criteria (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES evaluation_categories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  max_score INTEGER DEFAULT 10,
  order_index INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create evaluation_scores if it doesn't exist
-- Note: player_evaluations is assumed to exist as it appears in Prod screenshots
CREATE TABLE IF NOT EXISTS evaluation_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  evaluation_id UUID REFERENCES player_evaluations(id) ON DELETE CASCADE,
  criterion_id UUID REFERENCES evaluation_criteria(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(evaluation_id, criterion_id)
);

-- 4. Enable RLS on new tables
ALTER TABLE evaluation_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluation_criteria ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluation_scores ENABLE ROW LEVEL SECURITY;

-- 5. Re-apply Policies (Drop first to avoid conflicts if they somehow partially exist)

-- evaluation_categories
DROP POLICY IF EXISTS "Anyone can view evaluation categories" ON evaluation_categories;
CREATE POLICY "Anyone can view evaluation categories" ON evaluation_categories FOR SELECT USING (true);

-- evaluation_criteria
DROP POLICY IF EXISTS "Anyone can view evaluation criteria" ON evaluation_criteria;
CREATE POLICY "Anyone can view evaluation criteria" ON evaluation_criteria FOR SELECT USING (true);

-- evaluation_scores
DROP POLICY IF EXISTS "Coaches can manage evaluation scores" ON evaluation_scores;
CREATE POLICY "Coaches can manage evaluation scores" ON evaluation_scores 
  FOR ALL 
  USING (
    EXISTS (
      SELECT 1 FROM player_evaluations pe
      WHERE pe.id = evaluation_id 
        AND pe.coach_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Players can view their own scores" ON evaluation_scores;
CREATE POLICY "Players can view their own scores" ON evaluation_scores 
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM player_evaluations pe
      JOIN players p ON pe.player_id = p.id
      WHERE pe.id = evaluation_id 
        AND p.user_id = auth.uid()
    )
  );

-- 6. Grant permissions
GRANT SELECT ON evaluation_categories TO authenticated;
GRANT SELECT ON evaluation_criteria TO authenticated;
GRANT ALL ON evaluation_scores TO authenticated;

-- 7. Create Indexes (IF NOT EXISTS is not standard for CREATE INDEX in all postgres versions, but typically safe to re-run if we check system catalog or just catch error. 
-- For simplicity in a migration, we can use IF NOT EXISTS if supported, or just let it fail? No, better to be safe.
-- Postgres 9.5+ supports IF NOT EXISTS)

CREATE INDEX IF NOT EXISTS idx_evaluation_criteria_category ON evaluation_criteria(category_id);
CREATE INDEX IF NOT EXISTS idx_evaluation_scores_evaluation ON evaluation_scores(evaluation_id);
CREATE INDEX IF NOT EXISTS idx_evaluation_scores_criterion ON evaluation_scores(criterion_id);

-- 8. Insert Data (Only if empty, to avoid duplicates)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM evaluation_categories) THEN
    INSERT INTO evaluation_categories (name, description, order_index) VALUES
      ('Coordinación Motriz', 'Coordinación general, óculo-pie, ritmo y balance', 1),
      ('Velocidad y Agilidad', 'Velocidad de reacción, aceleración y cambios de dirección', 2),
      ('Técnica con Balón', 'Control, conducción, pase, regate y tiro', 3),
      ('Toma de Decisiones', 'Lectura de espacios, visión de juego y timing', 4),
      ('Actitud y Concentración', 'Atención, respeto, resiliencia y autonomía', 5),
      ('Condición Física', 'Resistencia, saltabilidad, movilidad y core', 6),
      ('Habilidades Socioemocionales', 'Trabajo en equipo, liderazgo y juego limpio', 7);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM evaluation_criteria) THEN
    -- Insert evaluation criteria for each category
    INSERT INTO evaluation_criteria (category_id, name, description, order_index) 
    SELECT id, 'Coordinación general', 'Saltos, giros, equilibrio', 1 FROM evaluation_categories WHERE name = 'Coordinación Motriz'
    UNION ALL
    SELECT id, 'Coordinación óculo-pie', 'Control y recepción del balón', 2 FROM evaluation_categories WHERE name = 'Coordinación Motriz'
    UNION ALL
    SELECT id, 'Ritmo', 'Ejercicios con escalera', 3 FROM evaluation_categories WHERE name = 'Coordinación Motriz'
    UNION ALL
    SELECT id, 'Balance', 'Frenadas y estabilidad', 4 FROM evaluation_categories WHERE name = 'Coordinación Motriz'
    
    UNION ALL
    SELECT id, 'Velocidad de reacción', 'Respuesta rápida a estímulos', 1 FROM evaluation_categories WHERE name = 'Velocidad y Agilidad'
    UNION ALL
    SELECT id, 'Aceleración', 'Velocidad en 5-10m', 2 FROM evaluation_categories WHERE name = 'Velocidad y Agilidad'
    UNION ALL
    SELECT id, 'Agilidad', 'Cambios de dirección', 3 FROM evaluation_categories WHERE name = 'Velocidad y Agilidad'
    UNION ALL
    SELECT id, 'Velocidad gestual', 'Rapidez con balón', 4 FROM evaluation_categories WHERE name = 'Velocidad y Agilidad'
    
    UNION ALL
    SELECT id, 'Control', 'Recepción bilateral', 1 FROM evaluation_categories WHERE name = 'Técnica con Balón'
    UNION ALL
    SELECT id, 'Conducción', 'Cabeza arriba, cambios de ritmo', 2 FROM evaluation_categories WHERE name = 'Técnica con Balón'
    UNION ALL
    SELECT id, 'Pase', 'Precisión corta', 3 FROM evaluation_categories WHERE name = 'Técnica con Balón'
    UNION ALL
    SELECT id, 'Regate', 'Creatividad y uso de ambos pies', 4 FROM evaluation_categories WHERE name = 'Técnica con Balón'
    UNION ALL
    SELECT id, 'Tiro', 'Precisión sobre fuerza', 5 FROM evaluation_categories WHERE name = 'Técnica con Balón'
    
    UNION ALL
    SELECT id, 'Lectura de espacios', 'Comprensión del juego', 1 FROM evaluation_categories WHERE name = 'Toma de Decisiones'
    UNION ALL
    SELECT id, 'Escaneo previo', 'Observación antes de recibir', 2 FROM evaluation_categories WHERE name = 'Toma de Decisiones'
    UNION ALL
    SELECT id, 'Timing de pase', 'Momento adecuado del pase', 3 FROM evaluation_categories WHERE name = 'Toma de Decisiones'
    UNION ALL
    SELECT id, 'Superioridades', 'Aprovechamiento 2v1 y 3v2', 4 FROM evaluation_categories WHERE name = 'Toma de Decisiones'
    UNION ALL
    SELECT id, 'Movilidad tras pase', 'Movimiento después de pasar', 5 FROM evaluation_categories WHERE name = 'Toma de Decisiones'
    
    UNION ALL
    SELECT id, 'Atención continua', 'Concentración durante ejercicios', 1 FROM evaluation_categories WHERE name = 'Actitud y Concentración'
    UNION ALL
    SELECT id, 'Respeto y escucha', 'Actitud hacia compañeros y entrenador', 2 FROM evaluation_categories WHERE name = 'Actitud y Concentración'
    UNION ALL
    SELECT id, 'Resiliencia', 'Manejo del error', 3 FROM evaluation_categories WHERE name = 'Actitud y Concentración'
    UNION ALL
    SELECT id, 'Autonomía', 'Independencia en tareas', 4 FROM evaluation_categories WHERE name = 'Actitud y Concentración'
    UNION ALL
    SELECT id, 'Intensidad emocional', 'Control emocional equilibrado', 5 FROM evaluation_categories WHERE name = 'Actitud y Concentración'
    
    UNION ALL
    SELECT id, 'Resistencia', 'Capacidad aeróbica básica', 1 FROM evaluation_categories WHERE name = 'Condición Física'
    UNION ALL
    SELECT id, 'Saltabilidad', 'Salto horizontal y vertical', 2 FROM evaluation_categories WHERE name = 'Condición Física'
    UNION ALL
    SELECT id, 'Movilidad articular', 'Flexibilidad y rango de movimiento', 3 FROM evaluation_categories WHERE name = 'Condición Física'
    UNION ALL
    SELECT id, 'Core y equilibrio', 'Estabilidad central', 4 FROM evaluation_categories WHERE name = 'Condición Física'
    
    UNION ALL
    SELECT id, 'Trabajo en equipo', 'Colaboración con compañeros', 1 FROM evaluation_categories WHERE name = 'Habilidades Socioemocionales'
    UNION ALL
    SELECT id, 'Liderazgo positivo', 'Influencia constructiva', 2 FROM evaluation_categories WHERE name = 'Habilidades Socioemocionales'
    UNION ALL
    SELECT id, 'Gestión de frustración', 'Manejo de situaciones adversas', 3 FROM evaluation_categories WHERE name = 'Habilidades Socioemocionales'
    UNION ALL
    SELECT id, 'Juego limpio', 'Fair play y deportividad', 4 FROM evaluation_categories WHERE name = 'Habilidades Socioemocionales';
  END IF;
END $$;
