# ACNHS Students Table Setup Guide

## Overview
This migration creates a dedicated `acnhs_students` table specifically for approved students from the admissions system. Only students whose applications have been approved will be added to this table with unique student identifiers.

## Step 1: Run the SQL Migration

1. Open Supabase Dashboard: https://supabase.com/dashboard
2. Navigate to your project: `zlvnxvrzotamhpezqedr`
3. Go to **SQL Editor** in the left sidebar
4. Open the file: `CREATE-ACNHS-STUDENTS-TABLE.sql`
5. Copy all the SQL code
6. Paste into Supabase SQL Editor
7. Click **Run** or press `Ctrl/Cmd + Enter`

You should see success messages confirming:
- ✅ ACNHS Students table created successfully!
- 📊 Table: public.acnhs_students
- 🔐 RLS Policies: Enabled
- ⚡ Indexes: Created
- 🔄 Auto-update trigger: Enabled

## Step 2: Verify Table Creation

Run this query in SQL Editor to verify:

```sql
SELECT 
    table_name, 
    column_name, 
    data_type 
FROM information_schema.columns 
WHERE table_name = 'acnhs_students' 
ORDER BY ordinal_position;
```

You should see columns:
- id (uuid)
- student_id (text) - Unique identifier like ACNHS-123456789
- application_id (uuid) - Links to applications table
- full_name (text)
- email (text)
- phone (text)
- date_of_birth (text)
- gender (text)
- nationality (text)
- program (text)
- start_term (text)
- expected_graduation (text)
- enrollment_status (text) - active, inactive, withdrawn, graduated, suspended
- current_gpa (numeric)
- total_credits_earned (integer)
- academic_standing (text)
- emergency_contact_name (text)
- emergency_contact_phone (text)
- emergency_contact_relation (text)
- metadata (jsonb)
- notes (text)
- enrolled_at (timestamptz)
- created_at (timestamptz)
- updated_at (timestamptz)

## Step 3: How It Works

### Automatic Student Creation
When an application status is changed to **Approved**, **Confirmed**, or **Enrolled** in `admin-applications.html`:

1. System checks if student already exists for this application
2. If not, generates unique student ID (format: `ACNHS-XXXXXXX`)
3. Creates student record in `acnhs_students` table with:
   - Personal info from application
   - Contact details
   - Emergency contacts
   - Program and term information
   - Links back to original application

### Student ID Format
- Prefix: `ACNHS-`
- 9-digit unique number
- Example: `ACNHS-123456789`
- Represents: Armenian College of Nursing & Health Sciences

## Step 4: Access Students

### Via Admin Portal
1. Login to admin portal
2. Click **"Students"** in sidebar
3. View all approved students with their unique IDs
4. Filter by:
   - Enrollment status (active/inactive/withdrawn)
   - Program (RN/LPN/BSN)
   - Search by name, email, student ID

### Via Direct Query
```sql
SELECT 
    student_id,
    full_name,
    email,
    program,
    enrollment_status,
    start_term
FROM acnhs_students
WHERE enrollment_status = 'active'
ORDER BY created_at DESC;
```

## Step 5: Managing Students

### Update Student Information
1. Go to Students page in admin
2. Click on any student row
3. Modal opens with all editable fields
4. Update as needed
5. Click "Save Changes"

### Change Enrollment Status
Options:
- **active** - Currently enrolled
- **inactive** - Temporary leave
- **withdrawn** - Permanently left
- **graduated** - Completed program
- **suspended** - Disciplinary/academic

### View Original Application
Click 📄 icon next to student to view their original application

## Step 6: Data Migration (Optional)

If you have existing students in the old `students` table, run this migration:

```sql
-- Copy existing students to new table
INSERT INTO acnhs_students (
    student_id,
    application_id,
    full_name,
    email,
    phone,
    date_of_birth,
    program,
    start_term,
    enrollment_status,
    metadata,
    created_at,
    updated_at
)
SELECT 
    student_id,
    application_id,
    full_name,
    email,
    phone,
    date_of_birth,
    program,
    start_term,
    CASE 
        WHEN status = 'active' THEN 'active'
        WHEN status = 'inactive' THEN 'inactive'
        WHEN status = 'withdrawn' THEN 'withdrawn'
        ELSE 'active'
    END as enrollment_status,
    metadata,
    created_at,
    updated_at
FROM students
WHERE application_id IS NOT NULL
ON CONFLICT (student_id) DO NOTHING;
```

## Troubleshooting

### Error: "relation 'acnhs_students' does not exist"
- Run `CREATE-ACNHS-STUDENTS-TABLE.sql` again
- Verify you're connected to correct Supabase project

### Error: "Students table not found"
- Check SQL migration completed successfully
- Verify RLS policies were created

### Students not appearing
- Check application status is "Approved", "Confirmed", or "Enrolled"
- Verify `application_id` foreign key exists
- Check browser console for errors

### Duplicate student_id error
- Each student ID must be unique
- System auto-generates unique IDs
- If manual entry, ensure no duplicates

## Database Schema

```sql
CREATE TABLE acnhs_students (
    id UUID PRIMARY KEY,
    student_id TEXT UNIQUE NOT NULL,
    application_id UUID REFERENCES applications(id),
    
    -- Personal
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    date_of_birth TEXT,
    
    -- Academic
    program TEXT NOT NULL,
    enrollment_status TEXT DEFAULT 'active',
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Benefits

1. **Clean Separation**: Only approved students, not applicants
2. **Unique Identifiers**: Each student gets ACNHS-XXXXXXX ID
3. **Automatic Creation**: No manual data entry needed
4. **Full History**: Links to original application
5. **Easy Management**: Edit, search, filter students
6. **Academic Tracking**: GPA, credits, standing fields ready
7. **Status Management**: Track enrollment lifecycle

## Next Steps

1. Run the SQL migration
2. Approve an existing application to test
3. Check Students page to see new record
4. Customize student ID format if needed
5. Add graduation tracking workflows
6. Implement GPA calculation system

---

**Created**: January 13, 2026  
**Version**: 1.0  
**Author**: ACNHS Development Team
