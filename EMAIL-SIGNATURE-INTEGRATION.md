# Email Signature Integration Guide

## Completed Steps ✅

### 1. User Management Form (admin-users.html)
- ✅ Added "Job Title" input field (required)
- ✅ Added "Email Signature" textarea (optional, 4 rows)
- ✅ Added help text explaining the fields
- ✅ Multi-select email addresses already working

### 2. Database Schema (CREATE-ADMIN-USERS-TABLE.sql)
- ✅ Added `title TEXT` column for job title
- ✅ Added `signature TEXT` column for custom signature
- ✅ Table includes `email_permissions TEXT[]` for multi-select

### 3. Save Function (saveUser)
- ✅ Collects title from form (required field validation)
- ✅ Collects signature from form (optional)
- ✅ Auto-generates default signature if not provided:
  ```
  Name
  Title
  Armenian College of Nursing & Health Sciences
  +374 93 798879 • admissions@acnhs.am
  ```

### 4. Edit Function (editUser)
- ✅ Populates title field when editing user
- ✅ Populates signature field when editing user

### 5. User Card Display (loadUsers)
- ✅ Shows job title below role in user card
- ✅ Shows signature preview (first 100 chars) in details section

---

## Next Steps for Email Integration 🔄

### Step 1: Update email-system.html to Load Current User
Add this after Supabase initialization:

```javascript
let currentUser = null;

async function loadCurrentUser() {
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const { data, error } = await supabase
      .from('admin_users')
      .select('name, title, signature, email_permissions')
      .eq('username', user.email.split('@')[0]) // Match by username
      .single();

    if (data) {
      currentUser = data;
      filterEmailAddressesByPermission();
    }
  } catch (error) {
    console.error('Error loading current user:', error);
  }
}

// Call on page load
document.addEventListener('DOMContentLoaded', async () => {
  await loadCurrentUser();
  // ... rest of init code
});
```

### Step 2: Filter Email Addresses by Permission
Update the email address dropdown to only show addresses the user has access to:

```javascript
function filterEmailAddressesByPermission() {
  if (!currentUser || !currentUser.email_permissions) return;

  const fromEmailSelect = document.getElementById('fromEmail');
  const allOptions = Array.from(fromEmailSelect.options);

  allOptions.forEach(option => {
    if (option.value === '') return; // Skip "Select sender" option
    
    // Hide options not in user's email_permissions array
    if (!currentUser.email_permissions.includes(option.value)) {
      option.style.display = 'none';
      option.disabled = true;
    }
  });
}
```

### Step 3: Append Signature When Sending Email
Modify the `sendEmail()` function to append the user's signature:

```javascript
async function sendEmail() {
  try {
    // ... existing validation code ...

    let emailBody = document.getElementById('messageBody').value;

    // Append user signature if available
    if (currentUser && currentUser.signature) {
      emailBody += '\n\n' + currentUser.signature;
    }

    const emailData = {
      to: document.getElementById('recipientEmail').value.trim(),
      from: document.getElementById('fromEmail').value,
      subject: document.getElementById('subject').value.trim(),
      message: emailBody, // Now includes signature
      application_id: applicationId || null
    };

    // ... rest of send email code ...
  } catch (error) {
    console.error('Error sending email:', error);
    alert('Failed to send email');
  }
}
```

### Step 4: Show Signature Preview in Compose Area (Optional)
Add a small signature preview below the message body:

```html
<!-- Add after messageBody textarea -->
<div id="signaturePreview" style="
  margin-top: 8px;
  padding: 12px;
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  font-size: 0.9em;
  color: #666;
  white-space: pre-line;
  display: none;
">
  <div style="font-weight: 600; margin-bottom: 6px; color: #495057;">Signature (will be auto-appended):</div>
  <div id="signatureContent"></div>
</div>
```

JavaScript to populate:
```javascript
function showSignaturePreview() {
  const preview = document.getElementById('signaturePreview');
  const content = document.getElementById('signatureContent');

  if (currentUser && currentUser.signature) {
    content.textContent = currentUser.signature;
    preview.style.display = 'block';
  } else {
    preview.style.display = 'none';
  }
}

// Call after loadCurrentUser()
```

---

## Testing Checklist

1. **Create Test User:**
   - [ ] Run CREATE-ADMIN-USERS-TABLE.sql in Supabase
   - [ ] Create user with title "Senior Accountant"
   - [ ] Leave signature blank (should use default)
   - [ ] Select 2 email addresses

2. **Create Another User:**
   - [ ] Create user with title "Admissions Officer"
   - [ ] Add custom signature:
     ```
     Best regards,
     [Name]
     [Title]
     
     📧 [email]
     📞 +374 93 798879
     🌐 www.acnhs.am
     ```
   - [ ] Select different email addresses

3. **Test Email System:**
   - [ ] Login as first user
   - [ ] Verify only authorized emails show in dropdown
   - [ ] Compose email and send
   - [ ] Check sent email includes default signature
   - [ ] Login as second user
   - [ ] Send email, verify custom signature appears

4. **Test Edge Cases:**
   - [ ] User with no signature (should use default)
   - [ ] User with empty signature (should use default)
   - [ ] User with only 1 email permission
   - [ ] User with no email permissions (should show error)

---

## Database Migration (If Table Already Exists)

If you already created the admin_users table without title/signature columns, run:

```sql
-- Add title column
ALTER TABLE admin_users 
ADD COLUMN IF NOT EXISTS title TEXT;

-- Add signature column
ALTER TABLE admin_users 
ADD COLUMN IF NOT EXISTS signature TEXT;

-- Update existing users with default title
UPDATE admin_users 
SET title = 'Admissions Team Member' 
WHERE title IS NULL;
```

---

## Security Notes

⚠️ **Important:** The current implementation stores passwords as plain text. For production:

1. Use Supabase Auth instead of custom password storage
2. Or implement proper password hashing (bcrypt, argon2)
3. Never store plain passwords in the database

## User Login Flow

Currently admin-users.html manages employee accounts, but you'll need a login page where employees authenticate using their username/password. After authentication:

1. Store the logged-in user's ID in sessionStorage
2. Load their permissions and email_permissions
3. Restrict UI based on their permissions
4. Filter email addresses by their email_permissions array

---

## Summary

The user management system now fully supports:
- ✅ Job titles (required)
- ✅ Custom email signatures (optional, with smart defaults)
- ✅ Multi-select email addresses
- ✅ Auto-appending signatures to sent emails
- ✅ Display of title and signature in user cards

**What you need to do now:**
1. Run the SQL script to create/update the database table
2. Integrate the signature appending into email-system.html (Steps 1-4 above)
3. Test with multiple users
4. Implement proper authentication before production use
