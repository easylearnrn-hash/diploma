# Auto-Generated Email Signature Setup ✅

## Overview
Employee email signatures are now **automatically generated** from user profile information. No manual signature entry needed!

## What Changed

### 1. Database Schema (CREATE-ADMIN-USERS-TABLE.sql)
**New required fields:**
- `title TEXT NOT NULL` - Job title (e.g., "Senior Accountant")
- `phone_ext TEXT NOT NULL` - Phone extension (e.g., "101")
- `email TEXT NOT NULL` - Employee email address
- `signature TEXT NOT NULL` - Auto-generated signature (stored for reference)

**Fixed:**
- Added `DROP POLICY IF EXISTS` to prevent duplicate policy errors
- All RLS policies now safely re-runnable

### 2. User Management Form (admin-users.html)

**New Form Fields:**
- ✅ Job Title (required) - appears in signature
- ✅ Phone Extension (required) - appears as "ext. XXX"
- ✅ Email Address (required) - employee's email
- ✅ **Live Signature Preview** - updates as you type!

**Removed:**
- ❌ Manual signature textarea (no longer needed)

### 3. Auto-Generated Signature Format

```
[Full Name]
[Job Title]
Armenian College of Nursing & Health Sciences

📞 +374 93 798879 ext. [Extension]
📧 [Email Address]
🌐 www.acnhs.am
```

**Example Output:**
```
Sarah Johnson
Senior Accountant
Armenian College of Nursing & Health Sciences

📞 +374 93 798879 ext. 101
📧 sarah@acnhs.am
🌐 www.acnhs.am
```

## How It Works

### Real-Time Preview
As the admin fills in the form, the signature preview updates instantly:

```javascript
// Auto-updates on every keystroke
document.getElementById('userName').addEventListener('input', updateSignaturePreview);
document.getElementById('userTitle').addEventListener('input', updateSignaturePreview);
document.getElementById('userPhoneExt').addEventListener('input', updateSignaturePreview);
document.getElementById('userEmail').addEventListener('input', updateSignaturePreview);
```

### Signature Generation Function
```javascript
function generateSignature(name, title, phoneExt, email) {
  const companyName = 'Armenian College of Nursing & Health Sciences';
  const mainPhone = '+374 93 798879';
  const website = 'www.acnhs.am';

  let signature = '';
  
  if (name) signature += `${name}\n`;
  if (title) signature += `${title}\n`;
  signature += `${companyName}\n`;
  signature += `\n`;
  
  if (phoneExt) {
    signature += `📞 ${mainPhone} ext. ${phoneExt}\n`;
  } else {
    signature += `📞 ${mainPhone}\n`;
  }
  
  if (email) signature += `📧 ${email}\n`;
  signature += `🌐 ${website}`;

  return signature;
}
```

### User Card Display
User cards now show:
- ✅ Job title below role
- ✅ Email address
- ✅ Phone extension
- ✅ **Full signature preview** with proper formatting

## Setup Instructions

### Step 1: Update Database
Run the updated SQL script in Supabase SQL Editor:

```sql
-- This will now work even if policies already exist
-- The DROP POLICY IF EXISTS fixes the error
```

```bash
File: CREATE-ADMIN-USERS-TABLE.sql
```

**If table already exists without new fields:**
```sql
-- Add missing columns
ALTER TABLE admin_users 
ADD COLUMN IF NOT EXISTS title TEXT NOT NULL DEFAULT 'Team Member';

ALTER TABLE admin_users 
ADD COLUMN IF NOT EXISTS phone_ext TEXT NOT NULL DEFAULT '100';

ALTER TABLE admin_users 
ADD COLUMN IF NOT EXISTS email TEXT NOT NULL DEFAULT 'staff@acnhs.am';

ALTER TABLE admin_users 
ADD COLUMN IF NOT EXISTS signature TEXT;

-- Create index on email
CREATE INDEX IF NOT EXISTS idx_admin_users_email ON admin_users(email);

-- Update existing users' signatures
UPDATE admin_users 
SET signature = name || E'\n' || title || E'\nArmenian College of Nursing & Health Sciences\n\n📞 +374 93 798879 ext. ' || phone_ext || E'\n📧 ' || email || E'\n🌐 www.acnhs.am'
WHERE signature IS NULL;
```

### Step 2: Test the Feature

1. **Open Admin User Management:**
   - Go to `admin-users.html`
   - Click "Add New User"

2. **Fill in the form:**
   - Full Name: "John Smith"
   - Username: "jsmith"
   - Password: (minimum 8 chars)
   - Role: "Accountant"
   - Job Title: "Senior Accountant"
   - Phone Extension: "105"
   - Email Address: "john@acnhs.am"

3. **Watch the signature preview update in real-time!**

4. **Save the user** - signature is automatically generated and stored

5. **View the user card** - signature displays in full with proper formatting

### Step 3: Verify Existing Users

If you already have users in the database:
- Edit each existing user
- Fill in the new required fields (title, phone ext, email)
- Signature will auto-generate when you save

## Email Integration (Next Step)

The signature is now stored in the database. To append it to sent emails:

1. **In email-system.html**, load current user's signature:
```javascript
let currentUserSignature = null;

async function loadCurrentUser() {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return;

  const { data } = await supabase
    .from('admin_users')
    .select('signature')
    .eq('email', user.email)
    .single();

  if (data) currentUserSignature = data.signature;
}
```

2. **Append to email body before sending:**
```javascript
async function sendEmail() {
  let emailBody = document.getElementById('messageBody').value;
  
  // Auto-append signature
  if (currentUserSignature) {
    emailBody += '\n\n' + currentUserSignature;
  }
  
  // ... rest of send email code
}
```

## Benefits

✅ **Consistency** - All emails have professional, standardized signatures
✅ **No Manual Entry** - Signatures auto-generate from profile data
✅ **Live Preview** - Admins see exactly what the signature looks like
✅ **Easy Updates** - Change phone number once, updates everyone's signature
✅ **Professional Format** - Includes emojis for visual appeal (📞📧🌐)
✅ **Complete Contact Info** - Name, title, company, phone, email, website

## Customization

### Change Company Info
Edit in `admin-users.html` line ~615:
```javascript
function generateSignature(name, title, phoneExt, email) {
  const companyName = 'Armenian College of Nursing & Health Sciences';
  const mainPhone = '+374 93 798879';  // Change main number here
  const website = 'www.acnhs.am';      // Change website here
  // ...
}
```

### Add More Fields
To add additional signature fields (e.g., department, office location):

1. Add column to database:
```sql
ALTER TABLE admin_users ADD COLUMN department TEXT;
```

2. Add form field in modal

3. Update `generateSignature()` function to include new field

4. Update `saveUser()` to collect new field value

## Testing Checklist

- [ ] Run CREATE-ADMIN-USERS-TABLE.sql (should succeed without errors)
- [ ] Open admin-users.html
- [ ] Click "Add New User"
- [ ] Fill in name field - see it appear in preview
- [ ] Fill in title field - see it appear in preview
- [ ] Fill in phone ext - see it appear in preview
- [ ] Fill in email - see it appear in preview
- [ ] Verify signature format matches expected output
- [ ] Save user successfully
- [ ] View user card - signature displays correctly
- [ ] Edit existing user - signature preview updates
- [ ] Save edited user - new signature stored

## Error Fixed

**Before:** 
```
ERROR: 42710: policy "Enable read access for authenticated users" 
for table "admin_users" already exists
```

**After:**
```sql
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON admin_users;
-- Now policy creation succeeds even if it already exists
```

## Summary

🎉 **All set!** Employee accounts now include:
- Job title
- Phone extension
- Email address
- **Auto-generated professional signature**

The signature automatically includes company name, formatted phone number with extension, email address, and website - all updating in real-time as the admin fills in the form!
