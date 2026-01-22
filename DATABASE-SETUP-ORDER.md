# Database Setup Order for Supabase

Run these SQL files **in this exact order** in your Supabase SQL Editor:

## Step 1: Create Base Tables (REQUIRED)
Run these files first - they create the core tables that other migrations depend on:

```sql
1. CREATE-EMAIL-HISTORY-TABLE.sql
2. CREATE-ADMIN-USERS-TABLE.sql          ← FIXED: Removed problematic DO blocks
3. CREATE-USER-TASKS-TABLE.sql
4. CREATE-USER-ACTIVITY-LOG-TABLE.sql
5. CREATE-EMAIL-CONFIGURATION-TABLE.sql
6. CREATE-STUDENTS-TABLE.sql
7. CREATE-NOTES-TABLES.sql
8. CREATE-STORAGE-BUCKET.sql
9. CREATE-EMAIL-ATTACHMENTS-BUCKET.sql
```

## Step 2: Add Columns (Run after Step 1)
These files add columns to existing tables. You can run them in any order:

```sql
ADD-ACCEPTANCE-LETTER-SENT-STATUS.sql
ADD-APPLICATION-CREDENTIALS.sql
ADD-APPLICATION-DOCUMENT-FIELDS.sql
ADD-ARMENIAN-CITIZENSHIP-FIELDS.sql       ← Already ran ✓
ADD-CREDENTIALS-SCREENSHOT-COLUMN.sql
ADD-EMAIL-ARCHIVED-COLUMN.sql
ADD-EMAIL-ATTACHMENTS-COLUMN.sql
ADD-EMAIL-DELETE-POLICY.sql
ADD-EMAIL-FORWARDING-COLUMNS.sql
ADD-ENROLLED-STATUS.sql
ADD-HTML-BODY-COLUMN.sql
ADD-REMINDER-DATE-COLUMN.sql
ADD-RFE-TRACKING.sql
ADD-SENDER-COLUMN.sql
ADD-SENT-BY-ADMIN-COLUMN.sql
ADD-STATUS-HISTORY-COLUMN.sql
ADD-TASK-ARCHIVED-COLUMN.sql
ADD-TASK-STATUS-AND-COMMENTS.sql
ADD-UNIQUE-IDENTIFIERS.sql
ADD-UPDATE-DELETE-POLICIES.sql
ADD-UPLOADED-DOCUMENTS-COLUMN.sql
```

## Step 3: Skip These Files
- `ADD-RECEIVED-STATUS.sql` - Already included in CREATE-EMAIL-HISTORY-TABLE.sql

## What I Fixed
The `CREATE-ADMIN-USERS-TABLE.sql` file had DO blocks at the top that tried to ALTER the table before creating it. I removed those blocks so the file now only creates the table with all columns included from the start.

## Quick Test
After running Step 1, verify tables were created:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

You should see: `admin_users`, `email_history`, `user_tasks`, etc.
