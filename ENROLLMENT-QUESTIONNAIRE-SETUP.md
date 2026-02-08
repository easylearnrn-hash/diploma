# Enrollment Questionnaire System - Setup Guide

## Overview
The enrollment questionnaire (`final-form.html`) is a regulatory compliance form that collects detailed personal, educational, and travel history from admitted students. This document guides you through setting up the database and testing the integration.

## Architecture

### Data Flow
```
Student → final-form.html → Supabase → enrollment_questionnaires table
                                     ↓
                          applications.uploaded_documents (updated)
```

### Database Tables
1. **enrollment_questionnaires**: Stores questionnaire responses
2. **applications**: Links via control_number and application_id

## Setup Instructions

### Step 1: Create Database Table
Run the SQL migration in Supabase SQL Editor:

**File**: `CREATE-ENROLLMENT-QUESTIONNAIRES-TABLE.sql`

**URL**: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/editor

**What it does**:
- ✅ Creates `enrollment_questionnaires` table with JSONB storage
- ✅ Adds foreign key to `applications` table
- ✅ Creates indexes on control_number, application_id, created_at
- ✅ Enables Row Level Security (RLS)
- ✅ Adds policies for anonymous insert and select
- ✅ Creates updated_at trigger

### Step 2: Verify Applications Table Schema
Ensure the `applications` table has these columns:
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'applications' 
  AND column_name IN ('id', 'control_number', 'document_id', 'uploaded_documents');
```

**Required columns**:
- `id` (UUID) - Primary key
- `control_number` (TEXT) - Format: ACNHS-YYYY-XXXX
- `document_id` (TEXT) - Links to document system
- `uploaded_documents` (JSONB) - Document tracking metadata

### Step 3: Test Control Number Lookup
Verify at least one student exists with valid control_number:

```sql
SELECT id, control_number, document_id 
FROM applications 
WHERE control_number LIKE 'ACNHS-%' 
LIMIT 5;
```

**If no students exist**, create a test student:
```sql
INSERT INTO applications (
  control_number,
  document_id,
  first_name,
  last_name,
  email
) VALUES (
  'ACNHS-2026-0001',
  'DOC-' || gen_random_uuid()::text,
  'Test',
  'Student',
  'test@example.com'
);
```

### Step 4: Test Form Submission

#### 4.1 Start Local Server
```bash
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
python3 start-server.py
```

**Open**: http://localhost:8000/final-form.html

#### 4.2 Fill Out Form
1. **Control Number**: Use valid control number from Step 3 (e.g., `ACNHS-2026-0001`)
2. **Personal Info**: Fill first name, last name, DOB
3. **Education History**: Fill dates and institution info
4. **Travel History**: Add at least one travel entry
5. **Emergency Contact**: Fill contact details
6. **Attestation**: Sign and date

#### 4.3 Submit and Verify
Click "Submit Enrollment Questionnaire" button.

**Expected behaviors**:
- ✅ Button changes to "⏳ Submitting..."
- ✅ Success alert: "✓ Questionnaire submitted successfully!"
- ✅ Form resets after submission

**Check console** (F12 → Console):
```javascript
// Should see:
Submitting questionnaire for control number: ACNHS-2026-0001
Student found: { id: "...", control_number: "ACNHS-2026-0001", document_id: "..." }
Questionnaire saved successfully
```

#### 4.4 Verify Database
```sql
-- Check questionnaire was saved
SELECT 
  id,
  control_number,
  application_id,
  questionnaire_data->>'personal_info' as personal_info,
  created_at
FROM enrollment_questionnaires
ORDER BY created_at DESC
LIMIT 1;

-- Check uploaded_documents was updated
SELECT 
  control_number,
  uploaded_documents->'enrollment_questionnaire' as questionnaire_metadata
FROM applications
WHERE control_number = 'ACNHS-2026-0001';
```

**Expected results**:
- ✅ New row in `enrollment_questionnaires` with JSONB data
- ✅ `applications.uploaded_documents` contains:
  ```json
  {
    "enrollment_questionnaire": {
      "submitted": true,
      "submitted_at": "2026-02-08T10:30:00.000Z",
      "questionnaire_id": "uuid-here"
    }
  }
  ```

## Troubleshooting

### Error: "Student not found with control number"
**Cause**: No student exists with that control_number in applications table

**Solution**:
```sql
-- Check if student exists
SELECT id, control_number FROM applications WHERE control_number = 'ACNHS-YYYY-XXXX';

-- If not, create test student (see Step 3)
```

### Error: "relation 'enrollment_questionnaires' does not exist"
**Cause**: Table not created yet

**Solution**: Run `CREATE-ENROLLMENT-QUESTIONNAIRES-TABLE.sql` in Supabase SQL Editor

### Error: "column 'document_id' does not exist"
**Cause**: Applications table missing document_id column

**Solution**:
```sql
ALTER TABLE applications ADD COLUMN IF NOT EXISTS document_id TEXT;
UPDATE applications SET document_id = 'DOC-' || gen_random_uuid()::text WHERE document_id IS NULL;
```

### Error: "permission denied for table enrollment_questionnaires"
**Cause**: RLS policies not set up correctly

**Solution**: Re-run the RLS policies from the SQL migration:
```sql
-- Allow anonymous insert
CREATE POLICY "Allow anonymous insert questionnaires" 
ON enrollment_questionnaires 
FOR INSERT 
TO anon 
WITH CHECK (true);

-- Allow anonymous select
CREATE POLICY "Allow anonymous select own questionnaire" 
ON enrollment_questionnaires 
FOR SELECT 
TO anon 
USING (true);
```

### Form validation errors
**Cause**: Required fields not filled or pattern mismatch

**Required fields**:
- Control Number (format: ACNHS-YYYY-XXXX)
- Full Name
- Date of Birth
- High School Graduation Date
- Armenian Education Yes/No
- Permanent Departure Date
- Emergency Contact Name, Relationship, Phone
- Signature and Date

### Logo not displaying
**Cause**: `js/acnhs-logo-base64.js` not loaded

**Solution**: 
1. Check file exists: `ls -lh js/acnhs-logo-base64.js`
2. Verify script tag in HTML: `<script src="js/acnhs-logo-base64.js"></script>`
3. Check console for errors

### PDF generation fails
**Cause**: Not running on localhost (file:// protocol has CORS restrictions)

**Solution**: Always use `python3 start-server.py` and access via http://localhost:8000

## Data Structure Reference

### questionnaire_data JSONB Schema
```json
{
  "control_number": "ACNHS-2026-0001",
  "personal_info": {
    "full_name": "John Smith",
    "date_of_birth": "2000-01-01"
  },
  "education_history": {
    "hs_grad_date": "2018-06-15",
    "armenian_edu": "yes",
    "armenian_institution": "Yerevan State University",
    "armenian_program": "Medicine",
    "application_date": "2020-09-01",
    "graduation_date": "2024-06-15"
  },
  "residency_travel": {
    "permanent_departure_date": "2024-07-01",
    "travel_history": [
      {
        "arrival": "2024-12-20",
        "departure": "2025-01-05",
        "duration": "16",
        "purpose": "Family visit"
      }
    ]
  },
  "emergency_contact": {
    "name": "Jane Smith",
    "relationship": "Mother",
    "phone": "+374 XX XXX XXX",
    "email": "jane@example.com",
    "address": "123 Main St, Yerevan, Armenia"
  },
  "attestation": {
    "signature": "John Smith",
    "date": "2026-02-08"
  },
  "submitted_at": "2026-02-08T10:30:00.000Z"
}
```

## Admin Integration (Future)

### Admin Dashboard View
Create `admin-questionnaires.html` to:
- ✅ List all submitted questionnaires
- ✅ Filter by control_number, date range
- ✅ View full questionnaire details
- ✅ Export to PDF
- ✅ Flag for review/approval

### Sample Admin Query
```sql
SELECT 
  eq.id,
  eq.control_number,
  eq.questionnaire_data->>'personal_info'->>'full_name' as student_name,
  a.email,
  eq.created_at as submitted_at,
  CASE 
    WHEN a.uploaded_documents->'enrollment_questionnaire'->>'reviewed' = 'true' 
    THEN 'Reviewed' 
    ELSE 'Pending' 
  END as review_status
FROM enrollment_questionnaires eq
JOIN applications a ON eq.application_id = a.id
ORDER BY eq.created_at DESC;
```

## Security Considerations

### Row Level Security (RLS)
- ✅ Anonymous users can INSERT (form submission)
- ✅ Anonymous users can SELECT (students view their own)
- ✅ Authenticated users (admins) have full access

### Production Hardening
**Before going live**:

1. **Restrict anonymous SELECT** to only own records:
```sql
DROP POLICY "Allow anonymous select own questionnaire" ON enrollment_questionnaires;

CREATE POLICY "Allow anonymous select own questionnaire" 
ON enrollment_questionnaires 
FOR SELECT 
TO anon 
USING (
  control_number = current_setting('request.jwt.claim.control_number', true)
);
```

2. **Add audit logging**:
```sql
CREATE TABLE questionnaire_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  questionnaire_id UUID REFERENCES enrollment_questionnaires(id),
  action TEXT NOT NULL, -- 'created', 'viewed', 'updated', 'deleted'
  performed_by TEXT,
  performed_at TIMESTAMPTZ DEFAULT NOW()
);
```

3. **Add rate limiting** to prevent spam submissions (use Edge Function)

## Success Criteria

### Form is working correctly when:
- ✅ Logo displays without errors
- ✅ Form validation prevents invalid submissions
- ✅ Student lookup works with valid control numbers
- ✅ Questionnaire data saves to database
- ✅ Applications.uploaded_documents updates correctly
- ✅ Travel history table calculates durations automatically
- ✅ Attestation section displays government-grade styling
- ✅ Success/error messages display appropriately
- ✅ Form resets after successful submission

## Next Steps

1. ☐ Run SQL migration to create table
2. ☐ Test form submission with valid control number
3. ☐ Create admin review interface
4. ☐ Add email notification on submission
5. ☐ Implement PDF export functionality
6. ☐ Set up analytics dashboard
7. ☐ Add automated compliance checking

## Contact
For issues or questions, contact: Hrachfilm@gmail.com
