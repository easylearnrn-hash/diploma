# Admin Applications - Edit All Fields Implementation Guide

## Current State
Currently in `admin-applications.html`, only 4 fields are editable:
- Email
- Phone
- Alternate Phone
- Address

## Goal
Make **ALL** application fields editable from the admin panel.

## Fields to Add Edit Capability For

### Personal Information
- ✅ Date of Birth
- ✅ Gender
- ✅ Nationality  
- ✅ Birth Location
- ✅ Applicant Name

### Program Selection
- ✅ Program
- ✅ Start Term
- ✅ Previous Application

### Emergency Contact
- ✅ Emergency Contact Name
- ✅ Emergency Relationship
- ✅ Emergency Phone

### Academic Background
- ✅ Education Level
- ✅ Institution
- ✅ Field of Study
- ✅ Graduation Year
- ✅ GPA

### Documents
- ✅ Statement of Purpose
- ✅ Document statuses (checkboxes)

## Implementation Steps

### Step 1: Add Edit Inputs to HTML

For each field in the drawer sections (lines ~1250-1400), add a corresponding edit input:

```html
<div class="info-card">
  <div class="label">Field Name</div>
  <div class="value" id="drawerFieldName">—</div>
  <input type="text" id="drawerFieldNameEdit" class="edit-input" style="display:none;">
</div>
```

### Step 2: Update Toggle Edit Mode Function

Find or create `toggleApplicationEditMode()` function to show/hide all edit inputs:

```javascript
function toggleApplicationEditMode() {
  const editInputs = document.querySelectorAll('.edit-input');
  const valueDisplays = document.querySelectorAll('.value');
  const isEditMode = !isApplicationEditMode;
  
  editInputs.forEach(input => {
    input.style.display = isEditMode ? 'block' : 'none';
  });
  
  valueDisplays.forEach(display => {
    if (display.closest('.info-card')?.querySelector('.edit-input')) {
      display.style.display = isEditMode ? 'none' : 'block';
    }
  });
  
  isApplicationEditMode = isEditMode;
  
  // Show/hide save/cancel buttons
  document.getElementById('editActions').style.display = isEditMode ? 'flex' : 'none';
}
```

### Step 3: Populate Edit Inputs When Opening Drawer

In `openApplicationDrawer()` function, after setting the display values, also populate edit inputs:

```javascript
// Example for all fields
document.getElementById('drawerDOBDetailEdit').value = payload.dob || '';
document.getElementById('drawerGenderEdit').value = payload.gender || '';
document.getElementById('drawerNationalityEdit').value = payload.nationality || '';
document.getElementById('drawerBirthLocationEdit').value = payload.birthLocation || '';
document.getElementById('drawerProgramEdit').value = payload.programChoice || '';
// ... etc for all fields
```

### Step 4: Update Save Function

Expand `saveApplicationEdits()` to save ALL fields:

```javascript
async function saveApplicationEdits() {
  if (!currentApplicationId) return;
  const supabase = initSupabase();
  if (!supabase) {
    showModal('Supabase is not configured.', 'error');
    return;
  }

  // Gather all edited values
  const updatedPayload = {
    ...(currentApplicationPayload || {}),
    // Contact
    email: document.getElementById('drawerEmailEdit')?.value.trim() || '',
    phone: document.getElementById('drawerPhoneEdit')?.value.trim() || '',
    altPhone: document.getElementById('drawerAltPhoneEdit')?.value.trim() || '',
    addressLine: document.getElementById('drawerAddressEdit')?.value.trim() || '',
    
    // Personal
    applicantName: document.getElementById('drawerNameEdit')?.value.trim() || '',
    dob: document.getElementById('drawerDOBDetailEdit')?.value.trim() || '',
    gender: document.getElementById('drawerGenderEdit')?.value.trim() || '',
    nationality: document.getElementById('drawerNationalityEdit')?.value.trim() || '',
    birthLocation: document.getElementById('drawerBirthLocationEdit')?.value.trim() || '',
    
    // Program
    programChoice: document.getElementById('drawerProgramEdit')?.value.trim() || '',
    startTerm: document.getElementById('drawerStartEdit')?.value.trim() || '',
    previousApplication: document.getElementById('drawerPreviousApplicationEdit')?.value.trim() || '',
    
    // Emergency
    emergencyName: document.getElementById('drawerEmergencyNameEdit')?.value.trim() || '',
    emergencyRelation: document.getElementById('drawerEmergencyRelationEdit')?.value.trim() || '',
    emergencyPhone: document.getElementById('drawerEmergencyPhoneEdit')?.value.trim() || '',
    
    // Academic
    educationLevel: document.getElementById('drawerEducationLevelEdit')?.value.trim() || '',
    institution: document.getElementById('drawerInstitutionEdit')?.value.trim() || '',
    fieldOfStudy: document.getElementById('drawerFieldOfStudyEdit')?.value.trim() || '',
    gradYear: document.getElementById('drawerGradYearEdit')?.value.trim() || '',
    gpa: document.getElementById('drawerGPAEdit')?.value.trim() || '',
    
    // Statement
    statement: document.getElementById('drawerStatementEdit')?.value.trim() || ''
  };

  // Update top-level fields that are also stored outside payload
  const { error } = await supabase
    .from('applications')
    .update({
      applicant_name: updatedPayload.applicantName,
      email: updatedPayload.email || null,
      phone: updatedPayload.phone || null,
      program: updatedPayload.programChoice,
      start_term: updatedPayload.startTerm,
      payload: updatedPayload
    })
    .eq('id', currentApplicationId);

  if (error) {
    console.error('Error updating application:', error);
    showModal('Failed to save application changes: ' + error.message, 'error');
    return;
  }

  // Update local cache
  currentApplicationPayload = updatedPayload;
  updateApplicationRecordLocally(currentApplicationId, {
    applicant_name: updatedPayload.applicantName,
    email: updatedPayload.email,
    phone: updatedPayload.phone,
    program: updatedPayload.programChoice,
    start_term: updatedPayload.startTerm,
    payload: updatedPayload
  });

  showModal('✅ All fields updated successfully', 'success');
  toggleApplicationEditMode(); // Exit edit mode
  filterApplications(); // Refresh table
  openApplicationDrawer(currentApplicationId); // Reload drawer with new data
}
```

### Step 5: Add Edit Button to UI

In the drawer actions section (around line 1143-1180), add an edit toggle button:

```html
<button class="action-btn" onclick="toggleApplicationEditMode()" 
        style="background:rgba(251,191,36,0.15);color:#fbbf24;border:1px solid rgba(251,191,36,0.3);">
  <span id="editButtonText">✏️ Edit All Fields</span>
</button>
```

Update the button text when toggling:

```javascript
function toggleApplicationEditMode() {
  // ... existing code ...
  
  const button = document.getElementById('editButtonText');
  button.textContent = isEditMode ? '❌ Cancel Editing' : '✏️ Edit All Fields';
}
```

## File Structure

- **HTML Section**: Lines ~1140-1500 (drawer structure)
- **JavaScript Functions**: 
  - `openApplicationDrawer()`: ~line 3607
  - `saveApplicationEdits()`: ~line 4953
  - `toggleApplicationEditMode()`: Need to add
  
## Testing Checklist

- [ ] All fields display correctly in view mode
- [ ] Edit button shows/hides all edit inputs
- [ ] Edit inputs are populated with current values
- [ ] Save button updates all fields in database
- [ ] Changes reflect immediately in drawer after save
- [ ] Changes reflect in applications table
- [ ] Cancel button reverts to view mode without saving

## Notes

- The `payload` JSONB column stores most field values
- Some fields (applicant_name, email, phone, program, start_term) are BOTH in payload AND as separate columns
- Always update both locations for consistency
- Use optional chaining (`?.`) when reading values to avoid errors
- Trim all string inputs before saving

## Alternative: Quick Implementation

If you want a faster implementation, I can create a modal-based editor instead of inline editing. This would be less code to modify. Let me know which approach you prefer.
