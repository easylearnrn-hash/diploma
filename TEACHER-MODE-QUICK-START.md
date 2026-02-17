# Teacher Mode - Quick Reference

## 🚀 ONE-TIME SETUP

### Step 1: Run SQL Migration
```
1. Open: https://supabase.com/dashboard
2. Navigate to: SQL Editor
3. Paste: Contents of ADD-TEACHER-SESSIONS-TABLE.sql
4. Click: Run
```

### Step 2: Enable Realtime (if needed)
```
1. Navigate to: Database → Replication
2. Find: teacher_sessions table
3. Toggle: Enable
```

---

## 📖 USAGE - EVERY CLASS

### Teacher Laptop (Private - Laptop B)
```
Open: test.html?session=YOUR_ID&mode=teacher

Example: test.html?session=period1&mode=teacher
         test.html?session=feb17-class2&mode=teacher
```

**What you'll see:**
- 🎓 "Teacher Mode Active" control panel (top-right)
- ✅ Correct answer highlighted in green (right panel)
- 📖 Full rationale explanation (right panel)
- 📋 Copy button for student link
- Full control over Next/Previous/Jump

### Student Laptop (Projected - Laptop A)
```
Open: test.html?session=YOUR_ID

Example: test.html?session=period1
         test.html?session=feb17-class2

⚠️ IMPORTANT: Must match teacher's session ID exactly!
```

**What students will see:**
- Questions and options ONLY
- NO answers or rationales
- NO "Check Answer" button
- Synced navigation (follows teacher)
- "Waiting for teacher..." if teacher not ready

---

## 🎯 TYPICAL WORKFLOW

### Before Class
1. **Teacher**: Open `test.html?session=class1&mode=teacher`
2. **Teacher**: Click "Start Test"
3. **Teacher**: Click "📋 Copy Student Link"
4. **Teacher**: Paste link on projector laptop

### During Class
1. **Projector** shows questions (no answers)
2. **Teacher laptop** shows answers + rationales
3. **Teacher** clicks "Next" → Both advance together
4. **Students** cannot navigate independently

### After Class
1. **Teacher**: Click "🛑 End Session"
2. Session automatically cleaned up after 24 hours

---

## ⚠️ IMPORTANT RULES

### DO:
✅ Use same session ID for both laptops
✅ Start teacher laptop first
✅ Let teacher control all navigation
✅ Copy student link from teacher panel

### DON'T:
❌ Let students access `?mode=teacher` URL
❌ Use different session IDs on teacher/student
❌ Try to navigate on student laptop
❌ Share teacher laptop screen (has answers!)

---

## 🔧 TROUBLESHOOTING

### Student stuck on "Waiting for teacher..."
**Fix**: Teacher must click "Start Test" first

### Student not following teacher navigation
**Fix**: Check session IDs match EXACTLY (case-sensitive)

### Teacher answer panel not showing
**Fix**: Make sure URL includes `&mode=teacher`

### Lost session after teacher reload
**Fix**: Session auto-restores from database (no action needed)

---

## 📋 SESSION ID EXAMPLES

### Good Session IDs
- `period1` (simple, memorable)
- `feb17-morning` (dated)
- `class-123` (numbered)
- `nursing-fundamentals-2026` (descriptive)

### Bad Session IDs
- `abc` (too short, confusing)
- `P3r!0d#1` (special characters can cause issues)
- `really-long-session-name-that-is-hard-to-type` (too long)

### Best Practice
- Use lowercase letters
- Use hyphens (not spaces)
- Keep under 20 characters
- Make it memorable for typing

---

## 🎓 TEACHER PANEL GUIDE

```
┌──────────────────────────────────┐
│ 🎓 Teacher Mode Active           │ ← You're in teacher mode
│ Session: class123                │ ← Current session ID
│                                  │
│ STUDENT VIEW URL:                │
│ [localhost:8000/test.html?...]   │ ← Student link
│                                  │
│ [📋 Copy Student Link]           │ ← Click to copy
│ [🛑 End Session]                 │ ← End teaching
└──────────────────────────────────┘
```

---

## 📱 ANSWER PANEL GUIDE

```
┌──────────────────────────────────┐
│ 🎓 Teacher View    Q5 of 50      │ ← Current question
├──────────────────────────────────┤
│ ✅ CORRECT ANSWER:               │
│ ┌──────────────────────────────┐ │
│ │ The correct option text      │ │ ← Answer in green
│ └──────────────────────────────┘ │
│                                  │
│ 💡 RATIONALE:                    │
│ ┌──────────────────────────────┐ │
│ │ Full explanation of why...   │ │ ← Educational content
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

---

## 🆘 EMERGENCY PROCEDURES

### Teacher Laptop Crashes
1. Reopen: `test.html?session=SAME_ID&mode=teacher`
2. Session auto-restores from database
3. Student laptop continues working

### Student Laptop Crashes
1. Reopen: `test.html?session=SAME_ID`
2. Auto-syncs to current question
3. No teacher action needed

### Reset Everything
```sql
-- Run in Supabase SQL Editor
UPDATE teacher_sessions SET is_active = false;
```

---

## 📊 SUCCESS CHECKLIST

Before starting class:
- [ ] SQL migration has been run
- [ ] Teacher can open `?mode=teacher` URL
- [ ] "Teacher Mode Active" panel appears
- [ ] Answer panel shows correct answers
- [ ] Student link can be copied

During class:
- [ ] Student laptop shows questions only
- [ ] Student laptop follows teacher navigation
- [ ] Teacher can see rationales
- [ ] Navigation works smoothly

After class:
- [ ] Session ended successfully
- [ ] Both laptops can close normally

---

## 🎉 YOU'RE READY!

Teacher Mode is now set up and ready to use. Remember:
1. **One-time setup**: Run SQL migration
2. **Every class**: Use matching session IDs
3. **Teacher controls**: All navigation
4. **Student follows**: Automatically synced

Need help? Check `TEACHER-MODE-SETUP.md` for detailed documentation.

---

**Quick Links:**
- Full Setup Guide: `TEACHER-MODE-SETUP.md`
- SQL Migration: `ADD-TEACHER-SESSIONS-TABLE.sql`
- Implementation Details: `TEACHER-MODE-COMPLETE.md`
