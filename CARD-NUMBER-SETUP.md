# Card Number Column Setup Guide

## Overview
This migration adds the `card_number` column to both `students` and `applications` tables to store unique card tracking numbers for student ID cards.

## Card Number Format
- Format: `CN-XXXX-YYNNN`
- Example: `CN-2395-26147`
- Components:
  - `CN-` = Card Number prefix
  - `XXXX` = Last 4 digits of student ID
  - `YY` = 2-digit year
  - `NNN` = 3-digit hash-based sequential number (deterministic, not random)

## Installation Steps

### 1. Run the SQL Migration
1. Go to Supabase Dashboard: https://supabase.com/dashboard
2. Select your project: `zlvnxvrzotamhpezqedr`
3. Navigate to: **SQL Editor**
4. Copy the contents of `ADD-CARD-NUMBER-COLUMN.sql`
5. Paste and click **Run**

### 2. Verify Installation
Run this query to confirm the columns were added:
```sql
-- Check students table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'students' 
AND column_name = 'card_number';

-- Check applications table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'applications' 
AND column_name = 'card_number';
```

### 3. Test Card Number Generation
1. Open a student card: `student-card.html?studentId=ACNHS-7022395`
2. Check browser console for: `✓ Card number saved to students table: CN-XXXX-YYNNN`
3. Verify in database:
```sql
SELECT student_id, card_number 
FROM students 
WHERE card_number IS NOT NULL;
```

## How It Works

### Automatic Generation
- Card numbers are **automatically generated** when a student card is first viewed
- Uses **deterministic hashing** so the same student ID always generates the same card number
- **Persists to database** immediately after generation

### Storage Priority
1. **Primary**: Saves to `students.card_number`
2. **Backup**: Falls back to `applications.card_number` if students update fails

### Retrieval Priority
Card numbers are checked in this order:
1. `profile.card_number` (from students table)
2. `metadata.card_number` (from students metadata)
3. `applicationData.card_number` (from applications table)
4. If none found, generates new card number

## Features

### Uniqueness
- Each student has ONE permanent card number
- Number never changes between page loads
- Based on student ID hash (deterministic)

### Tracking Use Cases
- Card reissuance tracking
- Lost/stolen card reporting
- Physical card inventory management
- Card version control
- Audit trail for card printing

## Database Schema

### students.card_number
- Type: `TEXT`
- Nullable: `YES`
- Indexed: `YES` (idx_students_card_number)
- Example: `CN-2395-26147`

### applications.card_number
- Type: `TEXT`
- Nullable: `YES`
- Indexed: `YES` (idx_applications_card_number)
- Example: `CN-2395-26147`

## Troubleshooting

### Error: "Could not find the 'card_number' column"
**Solution**: Run the `ADD-CARD-NUMBER-COLUMN.sql` migration in Supabase SQL Editor

### Card number keeps changing
**Problem**: This should NOT happen after migration
**Check**: Verify column exists in database
**Fix**: Re-run the migration SQL

### Card number not saving
**Check browser console for errors**:
- `✓ Card number saved to students table:` = Success
- `Error saving card number:` = Check RLS policies

**Fix RLS if needed**:
```sql
-- Allow updates to card_number column
CREATE POLICY "Allow anon to update card_number" ON students
FOR UPDATE USING (true)
WITH CHECK (true);
```

## Verification Queries

### Count students with card numbers
```sql
SELECT COUNT(*) as total_with_card_numbers
FROM students 
WHERE card_number IS NOT NULL;
```

### List all generated card numbers
```sql
SELECT 
  student_id,
  card_number,
  created_at
FROM students 
WHERE card_number IS NOT NULL
ORDER BY created_at DESC;
```

### Check for duplicates (should be 0)
```sql
SELECT 
  card_number,
  COUNT(*) as count
FROM students 
WHERE card_number IS NOT NULL
GROUP BY card_number
HAVING COUNT(*) > 1;
```

## Notes
- Card numbers are generated client-side using deterministic hashing
- No server-side generation needed
- Backwards compatible - existing students work fine, get card number on first view
- Forward compatible - new students get card number automatically
