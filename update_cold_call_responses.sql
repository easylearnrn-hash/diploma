ALTER TABLE cold_call_responses
ADD COLUMN IF NOT EXISTS question_id TEXT,
ADD COLUMN IF NOT EXISTS selected_answer JSONB;
