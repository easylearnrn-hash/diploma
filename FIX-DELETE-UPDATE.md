# Fix Delete and Update Issue

## Problem
The delete and update operations are failing because Supabase Row Level Security (RLS) policies don't allow anonymous users to UPDATE or DELETE from the registrations table.

## Solution
Run the SQL in `ADD-UPDATE-DELETE-POLICIES.sql` to add the missing policies.

## Steps

1. **Open Supabase Dashboard**
   - Go to: https://supabase.com/dashboard
   - Select your project

2. **Open SQL Editor**
   - Click "SQL Editor" in the left sidebar
   - Click "New query"

3. **Run the SQL**
   - Copy all content from `ADD-UPDATE-DELETE-POLICIES.sql`
   - Paste into the SQL editor
   - Click "Run" or press Cmd+Enter

4. **Verify**
   - The query should complete successfully
   - You should see output showing all 4 policies for the registrations table:
     - Public can submit registrations (INSERT)
     - Public can read registrations (SELECT)
     - Public can update registrations (UPDATE)
     - Public can delete registrations (DELETE)

5. **Test**
   - Go back to your admin page
   - Try editing a registration - it should save ✅
   - Try deleting a registration - it should delete ✅

## What This Does

The SQL adds two new RLS policies:
- **UPDATE policy**: Allows anonymous users to update any registration
- **DELETE policy**: Allows anonymous users to delete any registration

This enables the admin dashboard to approve, deny, edit, and delete registrations.

## Security Note

In production, you should add proper authentication and restrict these operations to authenticated admin users only. For now, this allows testing the full functionality.
