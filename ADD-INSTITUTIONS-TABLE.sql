-- ══════════════════════════════════════════════════════════════
--  ACNHS Institution Autocomplete — Verified Armenian Institutions
--  Run this in: https://supabase.com/dashboard → SQL Editor
--
--  Purpose: server-side, curated list of Armenian educational
--  institutions used by the "search-institutions" Edge Function to
--  power the Name of Institution autocomplete on the admission form.
--  International institutions are resolved via an external API at
--  request time (see supabase/functions/search-institutions), so this
--  table only needs to stay small and Armenia-focused.
-- ══════════════════════════════════════════════════════════════

-- 1. Create the table
CREATE TABLE IF NOT EXISTS institutions (
  id          BIGSERIAL PRIMARY KEY,
  name        TEXT        NOT NULL,
  city        TEXT,
  state       TEXT,                          -- state / province / region (e.g. marz for Armenia)
  country     TEXT        NOT NULL DEFAULT 'Armenia',
  type        TEXT,                          -- 'university' | 'college' | 'vocational' | 'high-school' | 'other'
  aliases     TEXT[]      DEFAULT '{}',       -- alternate spellings / transliterations
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1b. Add state column to an already-existing table (idempotent)
ALTER TABLE institutions ADD COLUMN IF NOT EXISTS state TEXT;

-- 2. Index for fast case-insensitive partial-name search
-- Requires pg_trgm extension for the trigram index below (safe if already enabled)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IF NOT EXISTS idx_institutions_name_trgm
  ON institutions USING gin (name gin_trgm_ops);

-- 2b. Search function: matches full name OR any alias/abbreviation
-- (e.g. "ACNHS" matches "Armenian College of Nursing and Health Sciences"),
-- both case-insensitive. Only falls back to trigram similarity (pg_trgm)
-- when there is NO exact substring/alias hit at all — this keeps precise
-- matches (e.g. "UCLA") from being diluted by unrelated institutions that
-- merely share a generic word like "University" at a low similarity score.
-- Avoids a generated column since array_to_string() isn't IMMUTABLE in
-- Postgres and can't be used in GENERATED ALWAYS AS.
DROP FUNCTION IF EXISTS search_institutions_fuzzy(TEXT, INT);
CREATE FUNCTION search_institutions_fuzzy(q TEXT, max_results INT DEFAULT 10)
RETURNS TABLE(name TEXT, city TEXT, state TEXT, country TEXT, aliases TEXT[], match_score REAL)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  exact_count INT;
BEGIN
  RETURN QUERY
    SELECT i.name, i.city, i.state, i.country, i.aliases, 1::REAL AS match_score
    FROM institutions i
    WHERE i.name ILIKE '%' || q || '%'
       OR EXISTS (SELECT 1 FROM unnest(i.aliases) a WHERE a ILIKE '%' || q || '%')
    ORDER BY i.name
    LIMIT max_results;

  GET DIAGNOSTICS exact_count = ROW_COUNT;

  -- Trigram similarity inflates scores for long, generic multi-word queries
  -- (e.g. any "University of ..." query looks similar to any other), so only
  -- trust it for short queries where it reliably reflects a genuine near-miss
  -- (typos, truncated abbreviations) rather than shared filler words.
  IF exact_count = 0 AND length(q) <= 20 THEN
    RETURN QUERY
      SELECT
        i.name, i.city, i.state, i.country, i.aliases,
        GREATEST(
          similarity(i.name, q),
          COALESCE((SELECT MAX(similarity(a, q)) FROM unnest(i.aliases) a), 0)
        ) AS match_score
      FROM institutions i
      WHERE similarity(i.name, q) > 0.3
         OR EXISTS (SELECT 1 FROM unnest(i.aliases) a WHERE similarity(a, q) > 0.3)
      ORDER BY match_score DESC, i.name
      LIMIT max_results;
  END IF;
END;
$$;

-- 3. RLS: public read-only (no sensitive data; names are public information)
ALTER TABLE institutions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow anon select institutions" ON institutions;
CREATE POLICY "Allow anon select institutions"
  ON institutions FOR SELECT TO anon USING (true);

-- 4. Seed verified Armenian institutions (idempotent — skips existing names)
-- Note: Yerevan is its own administrative region, so state is left NULL
-- for Yerevan-based entries to avoid a redundant "Yerevan, Yerevan" display.
INSERT INTO institutions (name, city, state, country, type, aliases)
SELECT v.name, v.city, v.state, 'Armenia', v.type, v.aliases
FROM (VALUES
  ('Yerevan State Medical University after Mkhitar Heratsi', 'Yerevan', NULL, 'university', ARRAY['YSMU']),
  ('Yerevan State University', 'Yerevan', NULL, 'university', ARRAY['YSU']),
  ('American University of Armenia', 'Yerevan', NULL, 'university', ARRAY['AUA']),
  ('Armenian National Agrarian University', 'Yerevan', NULL, 'university', ARRAY['ANAU']),
  ('National Polytechnic University of Armenia', 'Yerevan', NULL, 'university', ARRAY['NPUA']),
  ('Armenian State Pedagogical University after Khachatur Abovyan', 'Yerevan', NULL, 'university', ARRAY['ASPU']),
  ('Yerevan State Medical College', 'Yerevan', NULL, 'college', ARRAY['YSMC']),
  ('Yerevan State College of Health Care after Mkhitar Heratsi', 'Yerevan', NULL, 'college', ARRAY['YSCHC']),
  ('Gyumri State Medical College', 'Gyumri', 'Shirak', 'college', ARRAY['GSMC']),
  ('Vanadzor State University after Hovhannes Tumanyan', 'Vanadzor', 'Lori', 'university', ARRAY['VSU']),
  ('Shirak State University after Mikayel Nalbandyan', 'Gyumri', 'Shirak', 'university', ARRAY['ShSU']),
  ('Gavar State University', 'Gavar', 'Gegharkunik', 'university', ARRAY['GaSU']),
  ('Armenian State University of Economics', 'Yerevan', NULL, 'university', ARRAY['ASUE']),
  ('Yerevan Brusov State University of Languages and Social Sciences', 'Yerevan', NULL, 'university', ARRAY['Brusov University']),
  ('Armenian College of Nursing and Health Sciences', 'Yerevan', NULL, 'college', ARRAY['ACNHS'])
) AS v(name, city, state, type, aliases)
WHERE NOT EXISTS (
  SELECT 1 FROM institutions i WHERE i.name = v.name
);

-- 4c. Non-Armenian institutions explicitly requested by admissions staff
-- (kept separate from the Armenian seed above since these have their own
-- country/state and are unrelated to ACNHS despite a similar-looking name).
INSERT INTO institutions (name, city, state, country, type, aliases)
SELECT v.name, v.city, v.state, v.country, v.type, v.aliases
FROM (VALUES
  ('International College of Health Sciences', 'Miami', 'Florida', 'United States', 'college', ARRAY['ICHS'])
) AS v(name, city, state, country, type, aliases)
WHERE NOT EXISTS (
  SELECT 1 FROM institutions i WHERE i.name = v.name
);

-- 4b. Backfill aliases for rows already inserted before this update (idempotent)
UPDATE institutions SET aliases = ARRAY['YSMU'] WHERE name = 'Yerevan State Medical University after Mkhitar Heratsi' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['YSU'] WHERE name = 'Yerevan State University' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['AUA'] WHERE name = 'American University of Armenia' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['ANAU'] WHERE name = 'Armenian National Agrarian University' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['NPUA'] WHERE name = 'National Polytechnic University of Armenia' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['ASPU'] WHERE name = 'Armenian State Pedagogical University after Khachatur Abovyan' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['YSMC'] WHERE name = 'Yerevan State Medical College' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['YSCHC'] WHERE name = 'Yerevan State College of Health Care after Mkhitar Heratsi' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['GSMC'] WHERE name = 'Gyumri State Medical College' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['VSU'] WHERE name = 'Vanadzor State University after Hovhannes Tumanyan' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['ShSU'] WHERE name = 'Shirak State University after Mikayel Nalbandyan' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['GaSU'] WHERE name = 'Gavar State University' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['ASUE'] WHERE name = 'Armenian State University of Economics' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['Brusov University'] WHERE name = 'Yerevan Brusov State University of Languages and Social Sciences' AND aliases = '{}';
UPDATE institutions SET aliases = ARRAY['ACNHS'] WHERE name = 'Armenian College of Nursing and Health Sciences' AND aliases = '{}';

-- 4d. CORRECTION: an earlier version of this script mistakenly added 'ICHS'
-- as an alias of ACNHS, treating it as the same institution. It is not —
-- International College of Health Sciences (Miami, FL) is a separate, real
-- institution. Remove the incorrect alias if it was applied.
UPDATE institutions SET aliases = array_remove(aliases, 'ICHS')
  WHERE name = 'Armenian College of Nursing and Health Sciences' AND 'ICHS' = ANY(aliases);

