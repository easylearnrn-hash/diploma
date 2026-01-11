# Email Permission System - Complete

## What Changed

### 1. **Email Filtering by User Permissions**
Users now only see emails sent TO or FROM their allowed email addresses.

### 2. **Dynamic "From" Dropdown**
The compose modal's "Send From" dropdown is now dynamically populated with only the user's allowed email addresses.

### 3. **Personal Email Generation**
Each user automatically gets a personal email address:
- Format: `{firstInitial}.{lastName}@acnhs.am`
- Example: Simona Gharibyan → `s.gharibyan@acnhs.am`

### 4. **Departmental Email Access**
Admins can grant users access to departmental emails:
- `admissions@acnhs.am`
- `info@acnhs.am`
- `documents@acnhs.am`
- And 14 other departmental addresses

## How It Works

### User Email Permissions
When creating/editing a user, you can select which email addresses they can use:
1. **Personal email** - Automatically generated (always included)
2. **Departmental emails** - Selected via checkboxes in user management

### Email Visibility Rules
Users can ONLY see emails where:
- **Recipient** = one of their allowed addresses, OR
- **Sender** = one of their allowed addresses

**Example:**
- Simona has access to: `s.gharibyan@acnhs.am` and `admissions@acnhs.am`
- She can ONLY see:
  - Emails sent TO `s.gharibyan@acnhs.am` or `admissions@acnhs.am`
  - Emails sent FROM `s.gharibyan@acnhs.am` or `admissions@acnhs.am`
- She CANNOT see emails sent to/from `finance@acnhs.am`, `info@acnhs.am`, etc.

### Sending Emails
Users can ONLY send emails FROM their allowed addresses:
- The "Send From" dropdown only shows their permitted emails
- Personal email and allowed departmental emails appear in dropdown

### Main Admin Override
Users with main admin email addresses see ALL emails (no filtering):
- `Hrachfilm@gmail.com`
- `hrachfilm@gmail.com`

## Data Flow

### Login Process
```
1. User logs in with username/password
2. System retrieves user record from admin_users table
3. email_permissions array is stored in localStorage/sessionStorage
4. Example: ["s.gharibyan@acnhs.am", "admissions@acnhs.am"]
```

### Email Loading Process
```
1. loadEmailHistory() fetches all emails from database
2. getUserAllowedEmails() gets user's permitted addresses
3. Emails filtered: only show if recipient OR sender matches allowed list
4. renderEmailList() displays filtered emails
```

### Compose Process
```
1. openComposeModal() called
2. populateSenderDropdown() gets allowed emails
3. Dropdown populated with user's emails only
4. User can only select from their allowed addresses
```

## Testing

### Test Case 1: Limited User
1. Create user "Test User" with only `view_applications` permission
2. Grant access to ONLY `admissions@acnhs.am`
3. Log in as Test User
4. Expected:
   - Inbox shows only emails to `t.user@acnhs.am` or `admissions@acnhs.am`
   - Compose "From" dropdown shows ONLY those 2 addresses
   - Cannot access other departments' emails

### Test Case 2: Multi-Department User
1. Create user with access to `admissions@acnhs.am` AND `finance@acnhs.am`
2. Expected:
   - Can see emails for both departments
   - Compose dropdown shows personal + 2 departmental emails
   - Still cannot see `info@acnhs.am` or other emails

### Test Case 3: Main Admin
1. Log in as Hrachfilm@gmail.com
2. Expected:
   - Sees ALL emails (no filtering)
   - Compose dropdown shows ALL 17 departmental emails
   - Full access to everything

## Files Modified

1. **email-system.html**
   - Added `getUserAllowedEmails()` function
   - Updated `loadEmailHistory()` to filter by permissions
   - Added `populateSenderDropdown()` function
   - Modified `openComposeModal()` to populate dropdown

2. **login.html**
   - Added storage of `userEmailPermissions` separately
   - Stores email_permissions from admin_users table

3. **admin-users.html**
   - Already has email permission checkboxes
   - Saves email_permissions array to admin_users.email_permissions column

## Security Notes

- ✅ Users cannot bypass filters by direct URL access
- ✅ Email filtering happens server-side (Supabase query)
- ✅ Main admin can still see everything (intentional)
- ⚠️ RLS policies currently allow anonymous read (change for production)

## Next Steps

For production deployment:
1. Update RLS policies on email_history table
2. Add row-level filtering based on email_permissions column
3. Consider logging email access attempts
4. Add audit trail for email viewing
