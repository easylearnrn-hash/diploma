# Quick Start: Student Detail Page Setup

## 🎯 What You Get
Click any student row → Full student profile modal with:
- Personal & academic info
- All uploaded documents
- Grade history with auto-calculated GPA
- Email communication history
- Quick action buttons

## 📋 Setup Steps

### 1. Create the Grades Table (REQUIRED)
```bash
# Open Supabase SQL Editor
# https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql

# Copy and paste the entire contents of:
CREATE-STUDENT-GRADES-TABLE.sql

# Click "Run" button
```

**Verify it worked:**
```sql
SELECT COUNT(*) FROM student_grades;
-- Should return 0 (empty table is fine)
```

### 2. Test the Feature
```bash
# Start your local server
python3 start-server.py

# Open in browser
http://localhost:8000/admin-students.html

# Click on any student row
# The detail modal should open!
```

## 🎨 How to Use

### Viewing Student Details
1. Go to Admin → Students
2. Click any student row in the table
3. Modal opens with 5 tabs:
   - **Overview**: All personal info
   - **Documents**: Uploaded files
   - **Grades & GPA**: Academic records
   - **Email History**: Sent emails
   - **Application**: Original application

### Adding Grades (Manual for now)
```sql
-- In Supabase SQL Editor
INSERT INTO student_grades (
  student_id,
  course_code,
  course_name,
  credits,
  grade,
  grade_points,
  term
) VALUES (
  '<student-uuid-here>',
  'NUR-101',
  'Fundamentals of Nursing',
  3,
  'A',
  4.0,
  'Fall 2026'
);
```

**Grade Points Reference:**
- A = 4.0
- A- = 3.7
- B+ = 3.3
- B = 3.0
- B- = 2.7
- C+ = 2.3
- C = 2.0
- D = 1.0
- F = 0.0

### Closing the Modal
- Click the **×** button (top right)
- Press **Escape** key (auto-added)
- Click outside the modal (future feature)

## 🚀 What Happens Automatically

### GPA Calculation
- Loads all grades from `student_grades` table
- Calculates: `GPA = Σ(grade_points × credits) / Σ(credits)`
- Updates `acnhs_students.current_gpa` automatically
- Shows total credits earned

### Document Loading
- Reads `applications.uploaded_documents` JSON
- Shows all uploaded files as clickable cards
- Icons: 📄 (PDF) or 🖼️ (images)
- Click to open in new tab

### Email History
- Shows last 50 emails from `email_history` table
- Filters by student email automatically
- Newest emails first
- Click to view details (coming soon)

## 🔧 Action Buttons

**Edit Student**  
Opens edit modal (existing functionality)

**View Full Application**  
Goes to admin-applications.html with application ID

**Send Email**  
Opens email system with student pre-filled

**Withdraw Student**  
Updates status to "withdrawn" with confirmation

## ❗ Troubleshooting

### Modal doesn't open
```javascript
// Check browser console (Cmd+Option+I)
// Look for errors related to:
- Supabase connection
- Missing student ID
- File not found (admin-student-page.html)
```

### Grades show "No grades recorded"
```sql
-- Check if table exists
SELECT * FROM student_grades LIMIT 1;

-- If error, run CREATE-STUDENT-GRADES-TABLE.sql
```

### GPA shows 0.00 even with grades
```javascript
// Check console for:
"Error loading grades: ..."

// Verify student_id matches:
SELECT id, student_id FROM acnhs_students WHERE full_name = 'Name';
```

### Documents don't show
```sql
-- Check uploaded_documents field
SELECT uploaded_documents 
FROM applications 
WHERE id = (
  SELECT application_id 
  FROM acnhs_students 
  WHERE full_name = 'Name'
);

-- Should return JSON with document URLs
```

## 📝 Next Steps

### Add More Features
1. **Quick-add grades**: Button to add new grade from detail page
2. **Photo upload**: Add student photo to avatar
3. **Print profile**: Generate PDF of entire profile
4. **Notes section**: Admin comments about student
5. **Document upload**: Add documents directly from detail page

### Sample Data for Testing
```sql
-- Add test grades for first student
INSERT INTO student_grades (student_id, course_code, course_name, credits, grade, grade_points, term)
SELECT 
  id,
  unnest(ARRAY['NUR-101', 'BIO-201', 'PSY-101']),
  unnest(ARRAY['Fundamentals of Nursing', 'Human Anatomy', 'Introduction to Psychology']),
  unnest(ARRAY[3, 4, 3]),
  unnest(ARRAY['A', 'B+', 'A-']),
  unnest(ARRAY[4.0, 3.3, 3.7]),
  'Fall 2026'
FROM acnhs_students
LIMIT 1;
```

## 🎯 Success Checklist
- [ ] Ran `CREATE-STUDENT-GRADES-TABLE.sql`
- [ ] Server running on localhost:8000
- [ ] Clicked student row → modal opens
- [ ] All 5 tabs display correctly
- [ ] Close button (×) works
- [ ] Action buttons work
- [ ] No console errors

## 📚 Documentation
See `STUDENT-DETAIL-PAGE-COMPLETE.md` for full technical documentation.

---

**That's it!** You now have a complete student profile system. 🎉
