# Language Picker — Bilingual Test Sessions (EN / HY)

## Overview

The test platform now supports **Armenian (Հայ) and English (EN) language switching** during a live or saved test session. Every user — teacher or student — can independently switch languages at any time, while always seeing **the exact same questions, in the exact same order, with the same answer choices and correct answer keys**.

---

## How It Works — Architecture

### 1. Session Snapshot (the core mechanism)
When a **new test session starts** (`initializeNewTest`), the system:
1. Loads all questions from Supabase (including `question_stem_hy`, `options_hy`, `rationale_hy`)
2. Applies the deterministic shuffle (same seed = same order on every device)
3. Calls `buildBilingualSnapshot(shuffledQuestions)` which produces **two frozen arrays**:
   - `snapshot.en` — English text in final shuffled order
   - `snapshot.hy` — Armenian text in the **exact same order**, with English option IDs preserved (`a`, `b`, `c`, `d`)
4. This snapshot is stored in:
   - `testState.snapshot` (in memory)
   - `localStorage` (for self-paced sessions)
   - `teacher_sessions.session_snapshot_en/hy` in Supabase (for teacher-mode sync)
   - `saved_test_sessions.session_snapshot_en/hy` in Supabase (for saved sessions)

The snapshot is **written once and never mutated**. Language switching only changes which snapshot array is read for display.

### 2. Answer Correctness
Correct answer keys (`correct_answers`) always use the English letter keys (`a`, `b`, `c`, `d`) and are **shared across both language snapshots**. Switching languages never affects scoring.

### 3. Per-Device Language Preference
- Each device (teacher or student) picks their own language independently
- Language preference is stored in `localStorage` (`acnhs_test_lang`) and persists across sessions
- Language choice is **never broadcast** via the realtime sync — only question index and order are synced

---

## Database Setup

### Step 1 — Run the migration SQL

Open [Supabase SQL Editor](https://supabase.com/dashboard) for project `zlvnxvrzotamhpezqedr` and run:

```
ADD-QUESTION-ARMENIAN-TRANSLATIONS.sql
```

This adds:
| Table | New Columns |
|---|---|
| `test_questions` | `question_stem_hy TEXT`, `options_hy JSONB`, `rationale_hy TEXT` |
| `teacher_sessions` | `session_snapshot_en JSONB`, `session_snapshot_hy JSONB` |

> **Note:** `saved_test_sessions` already stores a `questions` JSONB column; the new snapshot columns are added there at save-time automatically (no migration needed unless you want to add them explicitly for clarity).

---

### Step 2 — Add Armenian translations to questions

#### Option A: Update individual questions

```sql
UPDATE public.test_questions
SET
  question_stem_hy = 'Ի՞նչ է թթվածնի նորմալ հագեցվածությունը մեծահասակ հիվանդի համար:',
  options_hy = '[
    {"id":"a","text":"85-90%"},
    {"id":"b","text":"94-100%"},
    {"id":"c","text":"75-85%"},
    {"id":"d","text":"60-70%"}
  ]'::jsonb,
  rationale_hy = 'Թթվածնի նորմալ հագեցվածությունը (SpO2) 94-100% է։'
WHERE id = '<question-uuid>';
```

#### ⚠️ Critical Rule: Option IDs must match exactly
The `id` fields in `options_hy` MUST be identical to the English `options` ids. The platform maps HY text onto EN option positions — if ids don't match, the translation will silently fall back to English.

✅ Correct:
```json
English options: [{"id":"a","text":"Yes"},{"id":"b","text":"No"}]
Armenian options: [{"id":"a","text":"Այո"},{"id":"b","text":"Ոչ"}]
```

❌ Wrong:
```json
Armenian options: [{"id":"1","text":"Այո"},{"id":"2","text":"Ոչ"}]
```

#### Option B: Bulk import via CSV

You can export the `test_questions` table to CSV, fill in the `question_stem_hy`, `options_hy`, `rationale_hy` columns (using Excel or Google Sheets), then re-import via Supabase table editor.

---

## Using the Language Picker

### In the UI
Once a test session is active, a **language picker** appears in the top header (right side):

```
[ 🇺🇸 EN ]  [ 🇦🇲 ՀԱՅ ]
```

- Click **🇺🇸 EN** → view test in English
- Click **🇦🇲 ՀԱՅ** → view test in Armenian
- The active language is highlighted in gold
- If a test has **no Armenian translations**, the 🇦🇲 button is disabled (greyed out)

### Per-Question Fallback
If a specific question has no Armenian translation but the user has Armenian selected:
- The question shows in **English** automatically
- A yellow banner appears: `⚠️ Armenian translation not yet available for this question. Showing English.`

---

## Teacher + Student Multi-Language Scenario

| Device | Language | What they see |
|---|---|---|
| Teacher laptop | 🇦🇲 Armenian | Armenian text |
| Student laptop A | 🇺🇸 English | English text |
| Student laptop B | 🇦🇲 Armenian | Armenian text |
| Student laptop C | 🇺🇸 English | English text |

All devices see **the same question #, same answer choice order, same correct answer** — only the display language differs.

---

## Testing Checklist

- [ ] Run `ADD-QUESTION-ARMENIAN-TRANSLATIONS.sql` in Supabase
- [ ] Add at least one Armenian translation to a question (see Step 2 above)
- [ ] Open `test.html` and start a test session
- [ ] Confirm language picker appears in header
- [ ] Click 🇦🇲 ՀԱՅ — Armenian question text should appear
- [ ] Click 🇺🇸 EN — switch back; question order must be **identical**
- [ ] Open a second device on the same teacher session (`?session=X&mode=teacher` / `?session=X`)
- [ ] Switch languages independently on each device
- [ ] Confirm answer options are in the same A/B/C/D order on both devices
- [ ] Submit the test — score must be correct regardless of language used
- [ ] Save a session in Armenian, resume it — Armenian language preference is restored

---

## Files Modified / Created

| File | Change |
|---|---|
| `ADD-QUESTION-ARMENIAN-TRANSLATIONS.sql` | New — DB migration |
| `test.html` | Language picker UI, `buildBilingualSnapshot()`, updated `loadQuestions`, `initializeNewTest`, `resumeTest`, `renderQuestion`, `checkAnswer`, `createTeacherSession`, `loadTeacherSessionState`, `saveTestSession`, `loadSavedSession` |
| `LANGUAGE-PICKER-SETUP.md` | This file |
