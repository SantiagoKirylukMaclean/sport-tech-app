-- Migration to clean up zombie tables/views found in Prod but not in codebase
-- These objects are likely leftovers from early development or experiments

-- 1. Drop match_quarter_lineups (Identified as a Table in screenshots)
-- Using CASCADE to ensure any dependent triggers/policies are also removed
DROP TABLE IF EXISTS match_quarter_lineups CASCADE;

-- 2. Drop match_quarter_participation (Identified as a View in screenshots)
-- Using CASCADE to ensure any dependent objects are also removed
DROP VIEW IF EXISTS match_quarter_participation CASCADE;
