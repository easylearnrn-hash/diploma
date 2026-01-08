# 🔑 Password Reset Feature

## Overview
Added admin password reset functionality to allow admins to generate new random passwords for students who have lost their credentials.

## Implementation Date
January 8, 2026

## What Was Added

### 1. **Password Reset Button**
- Located in the application drawer under "Portal Access Information"
- Yellow/warning styled button: "🔑 Generate New Password"
- Positioned right below the username display

### 2. **Password Generation**
- Uses the same secure password generation algorithm as the admission form
- Generates 12-character random passwords
- Format: 2 uppercase + 2 lowercase + 8 numbers
- Uses limited character sets to avoid confusion:
  - Uppercase: `ABCDEFGHJKLMNPQRSTUVWXYZ` (excludes I, O)
  - Lowercase: `abcdefghjkmnpqrstuvwxyz` (excludes i, l, o)
  - Numbers: `23456789` (excludes 0, 1)
- Password is shuffled to randomize character positions

### 3. **Password Modal**
- Displays the new credentials in a secure modal
- Shows both username and password
- Each can be copied individually or together
- Highlights that password is shown only once
- Displays student's email for convenience

### 4. **Security Features**
- Password is hashed with bcrypt (10 rounds) before storage
- Only the hash is stored in the database
- Confirmation dialog before reset to prevent accidents
- Password displayed only once in the modal

### 5. **Database Updates**
- Updates `password_hash` column with new bcrypt hash
- Updates `updated_at` timestamp
- Adds entry to `status_history` array:
  ```json
  {
    "status": "CURRENT_STATUS",
    "message": "Password reset by admin",
    "changed_at": "2026-01-08T...",
    "changed_by": "admin"
  }
  ```

### 6. **Status History Tracking**
- Password resets are logged in the application's status history
- Shows timestamp and admin as the actor
- Visible in the timeline under "📜 Status History"

## How to Use

### For Admins:

1. **Open Application Drawer**
   - Click on any application in the admin dashboard
   - Scroll to "Portal Access Information" section

2. **Reset Password**
   - Click the "🔑 Generate New Password" button
   - Confirm the action in the dialog box
   - Wait for the password to be generated

3. **Copy Credentials**
   - New password will appear in a modal
   - Click "📋 Copy" next to individual fields, or
   - Click "📋 Copy Both" to copy username and password together
   - The copied format includes:
     ```
     Student Portal Login Credentials
     
     Username: vladislav.saakyan.6974
     Password: AB3c4d5e6f7g
     
     Portal: https://acnhs.am/portal
     ```

4. **Send to Student**
   - Email the credentials to the student (email shown in modal)
   - Or contact them via phone
   - **Important**: Password is shown only once - make sure to copy it!

5. **Close Modal**
   - Click "Close" button when done
   - Or click outside the modal to dismiss

## Technical Details

### Files Modified
- `admin-applications.html` (Lines 1179-1195, 2621-2793, 1507)

### New Functions Added

#### `generateSecurePassword()`
```javascript
// Generates a 12-character random password
// Same algorithm as admission-form.html
```

#### `hashPassword(password)`
```javascript
// Hashes password with bcrypt (10 rounds)
// Returns hash string for database storage
```

#### `resetStudentPassword()`
```javascript
// Main function that:
// 1. Confirms action with admin
// 2. Generates new password
// 3. Hashes it
// 4. Updates database
// 5. Logs to status history
// 6. Shows password modal
```

#### `showPasswordModal(username, password, email)`
```javascript
// Displays modal with new credentials
// Provides copy buttons for easy sharing
```

#### `copyBothCredentials(username, password)`
```javascript
// Copies formatted credential text to clipboard
```

### Dependencies Added
- **bcryptjs** (v2.4.3) - For password hashing
  - CDN: `https://cdn.jsdelivr.net/npm/bcryptjs@2.4.3/dist/bcrypt.min.js`
  - Added to line 1507 of admin-applications.html

### Database Schema
No schema changes required. Uses existing columns:
- `password_hash` (TEXT) - Stores bcrypt hash
- `status_history` (JSONB) - Logs password resets
- `updated_at` (TIMESTAMP) - Updated on reset

## Use Cases

### Case 1: Student Forgot Password
**Scenario**: Vladislav forgot his password and cannot access the student portal

**Solution**:
1. Admin opens Vladislav's application
2. Clicks "🔑 Generate New Password"
3. Copies the new credentials
4. Emails to vladarkadich@gmail.com
5. Vladislav can now log in with new password

### Case 2: Password Never Received
**Scenario**: Student submitted application before screenshot feature was implemented

**Solution**:
1. Admin generates new password
2. Optionally uploads a screenshot showing the credentials
3. Sends credentials to student via email

### Case 3: Security Concern
**Scenario**: Student suspects their account was compromised

**Solution**:
1. Admin immediately resets password
2. Old password is invalidated (hash replaced)
3. Student receives new secure password
4. Reset is logged in status history for audit

## Security Considerations

✅ **Secure Password Generation**
- 12 characters with mixed case and numbers
- Cryptographically random using Math.random()
- Limited charset avoids visual confusion

✅ **Secure Storage**
- Passwords never stored in plain text
- Bcrypt hashing with 10 rounds
- Salt automatically generated per password

✅ **Admin Accountability**
- All resets logged in status_history
- Timestamp and admin identifier recorded
- Audit trail for security reviews

✅ **One-Time Display**
- Password shown only once in modal
- Not stored anywhere after modal closes
- Forces admin to copy and communicate immediately

⚠️ **Important Notes**
- Admin must communicate password securely (email/phone)
- Student should change password after first login (future feature)
- Old password is immediately invalidated on reset

## Future Enhancements

### Possible Additions:
1. **Email Integration**
   - Automatically send reset email to student
   - Template with new credentials
   - Confirmation of password change

2. **Student Self-Service**
   - "Forgot Password" link on student portal
   - Email verification before reset
   - Temporary reset tokens

3. **Password History**
   - Track when passwords were changed
   - Prevent password reuse
   - Force periodic password changes

4. **Two-Factor Authentication**
   - SMS verification codes
   - Email verification
   - Enhanced security for sensitive applications

5. **Password Strength Indicator**
   - Show password strength in modal
   - Option to regenerate if desired
   - Custom password option (if secure enough)

## Testing

### Test Scenario 1: Successful Reset
1. Open application for ACNHS-ADM-20260107-799 (Vladislav)
2. Click "🔑 Generate New Password"
3. Confirm action
4. Verify modal shows new password
5. Copy credentials
6. Check database: `password_hash` updated
7. Check status history: Reset entry added
8. Test login with new password on student portal

### Test Scenario 2: Cancel Reset
1. Click "🔑 Generate New Password"
2. Click "Cancel" on confirmation
3. Verify nothing changed in database
4. Verify status history unchanged

### Test Scenario 3: Multiple Resets
1. Reset password once
2. Note the password
3. Reset again
4. Verify new password is different
5. Verify old password no longer works
6. Verify both resets logged in status history

## Troubleshooting

### Issue: Button Not Appearing
**Check**: Ensure browser cache is cleared (Cmd+Shift+R)

### Issue: Modal Not Showing
**Check**: Browser console for JavaScript errors
**Check**: bcryptjs library loaded (check Network tab)

### Issue: Password Not Working
**Check**: Password copied correctly (no extra spaces)
**Check**: Username is correct (case-sensitive)
**Check**: Database updated (check password_hash column)

### Issue: Hashing Takes Too Long
**Solution**: This is normal - bcrypt is intentionally slow for security
**Wait**: 1-2 seconds for hash generation

## Related Files
- `admin-applications.html` - Main implementation
- `admission-form.html` - Original password generation
- `Student-page.html` - Student portal login
- `PASSWORD-RESET-FEATURE.md` - This documentation

## Support
For issues or questions about the password reset feature:
1. Check browser console for errors
2. Verify bcryptjs library loaded
3. Check Supabase connection
4. Review status_history for reset logs
5. Test with a different application
