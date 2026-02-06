# Add Narine Avetisyan Transfer Credits - Quick Guide

## 📋 Student Information
- **Name:** Narine Avetisyan
- **Application Reference:** ACNHS-ADM-20260108-970
- **Institution:** Previous Institution (California, USA)

## 📊 Academic Summary
- **Total Units Attempted:** 98.00
- **Total Units Earned:** 94.00
- **GPA Units:** 93.00
- **Cumulative GPA:** 3.64
- **Cumulative GPA (excluding NDA):** 3.68

## 🎓 Transfer Credits to Add

| Course Code | Course Name | Credits | Grade | Points |
|------------|-------------|---------|-------|--------|
| ANAT001 | Intro to Human Anatomy | 4.0 | A | 4.0 |
| PHYS001 | Intro to Human Physiology | 4.0 | A | 4.0 |
| MICR020 | General Microbiology | 4.0 | A | 4.0 |
| BIOL003 | Introductory Biology | 4.0 | A | 4.0 |
| CHEM051 | Fundamental Chemistry I | 5.0 | B | 3.0 |
| MATH227 | Statistics | 4.0 | A | 4.0 |
| PSYC001 | General Psychology | 3.0 | A | 4.0 |
| PSYC041 | Life-Span Psychology | 3.0 | A | 4.0 |
| FAMCS021 | Nutrition | 3.0 | A | 4.0 |

**Total:** 9 courses, 36 credits

## 🚀 How to Add These Credits

### Option 1: Using SQL (Recommended)

1. **First, ensure transfer_credits table exists:**
   - Open Supabase SQL Editor: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql
   - Run `CREATE-TRANSFER-CREDITS-TABLE.sql` if not already done

2. **Add the credits:**
   - Open `ADD-NARINE-TRANSFER-CREDITS.sql`
   - **IMPORTANT:** Update line 8 with your admin email:
     ```sql
     v_created_by TEXT := 'your-email@acnhs.am';
     ```
   - Copy entire SQL script
   - Paste into Supabase SQL Editor
   - Click "Run"

3. **Verify:**
   - Should see: "✅ Successfully inserted 9 transfer credits"
   - Should show summary: 9 courses, 36 credits, ~3.64 GPA

### Option 2: Using Admin Interface (Manual)

1. Open `admin-student-page.html` with Narine's profile
2. Click "Grades & GPA" tab
3. Scroll to "🏫 Transfer Credits" section
4. Click "➕ Add Transfer Credit" for each course:

**Course 1:**
- Institution: Previous Institution
- Country: USA
- City: California
- Course Code: ANAT001
- Course Name: Intro to Human Anatomy
- Credits: 4.0
- Grade: A
- Letter Grade: A
- Grade Points: 4.0
- Term: Completed
- Year: 2024
- Status: Approved

*(Repeat for all 9 courses)*

## ✅ Verification Steps

After adding credits, verify in admin interface:

1. Go to Narine's student profile
2. Click "Grades & GPA" tab
3. Check Transfer Credits section shows 9 courses
4. Verify total: 36 credits
5. Check GPA calculation includes transfer credits

## 📝 Notes

- All courses are marked as "approved" status
- All completed in 2024
- GPA calculation: Weighted average = 3.64
- Chemistry (CHEM051) is the only B grade (3.0 points)
- All other courses are A grades (4.0 points)

## 🔧 Troubleshooting

**If SQL fails:**
- Check if transfer_credits table exists
- Verify student record exists for ACNHS-ADM-20260108-970
- Run `GET-NARINE-STUDENT-ID.sql` first to check student_id

**If credits don't appear:**
- Hard refresh: Cmd + Shift + R
- Check browser console for errors
- Verify Supabase connection
- Check RLS policies allow reading transfer_credits

## 🎯 Expected Result

After successful addition, Narine's profile should show:
- 9 transfer credit cards in the Transfer Credits section
- Each card showing institution, course details, grade
- All with green "✓ Approved" badge
- Total credits visible
