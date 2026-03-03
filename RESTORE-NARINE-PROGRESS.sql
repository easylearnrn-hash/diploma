-- Restore Narine Avetisyan's module progress to 22%
-- Student UUID: 03f0f55c-1743-421d-a16b-bfe2325815c3
-- Note ID: note_mt_1 (Medical Terminology)
--
-- Progress formula:
--   ha  (high-alert meds opened)  → 40 pts  (6 total, ~6.67 pts each)
--   sfx (side-effect pills)       → 20 pts  (capped at 20 unique)
--   dc  (drug class cards)        → 20 pts  (capped at 20 unique)
--   ms  (active time in ms)       → 20 pts  (cap = 432,000,000 ms)
--   clicks                        → max 5 pts (0.0001 per click)
--
-- Target: 22%
--   3 ha items  → 3/6  × 40 = 20.0 pts
--   6 sfx items → 6/20 × 20 =  6.0 pts  (total would be 26 — clamp if needed)
--   Actually simpler: 3 ha = 20pts, 1 sfx = 1pt, 1 dc = 1pt → 22pts exactly
--
-- Using:  ha=3 items (20pts) + sfx=1 item (1pt) + dc=1 item (1pt) = 22%
-- reset_at is set to NULL so the module page does NOT trigger a reset on next open.

INSERT INTO public.module_progress (
  student_id,
  note_id,
  ha,
  sfx,
  dc,
  ms,
  clicks,
  updated_at,
  reset_at
)
VALUES (
  '03f0f55c-1743-421d-a16b-bfe2325815c3',
  'note_mt_1',
  ARRAY['insulin', 'heparin', 'warfarin'],   -- 3 of 6 high-alert items = 20pts
  ARRAY['item_1'],                            -- 1 sfx item = 1pt
  ARRAY['item_1'],                            -- 1 dc item = 1pt
  0,                                          -- no time contribution needed
  0,
  NOW(),
  NULL                                        -- NULL = no pending admin reset
)
ON CONFLICT (student_id, note_id)
DO UPDATE SET
  ha         = ARRAY['insulin', 'heparin', 'warfarin'],
  sfx        = ARRAY['item_1'],
  dc         = ARRAY['item_1'],
  ms         = 0,
  clicks     = 0,
  updated_at = NOW(),
  reset_at   = NULL;

-- Verify the result:
SELECT
  student_id,
  note_id,
  array_length(ha,  1) AS ha_count,
  array_length(sfx, 1) AS sfx_count,
  array_length(dc,  1) AS dc_count,
  ms,
  clicks,
  reset_at,
  updated_at,
  -- Recalculate progress score to confirm 22%
  ROUND(
    LEAST(array_length(ha,  1)::numeric / 6,  1) * 40 +
    LEAST(array_length(sfx, 1)::numeric / 20, 1) * 20 +
    LEAST(array_length(dc,  1)::numeric / 20, 1) * 20 +
    LEAST(ms::numeric / 432000000,            1) * 20 +
    LEAST(clicks * 0.0001,                    5)
  ) AS calculated_progress_pct
FROM public.module_progress
WHERE student_id = '03f0f55c-1743-421d-a16b-bfe2325815c3'
  AND note_id = 'note_mt_1';
