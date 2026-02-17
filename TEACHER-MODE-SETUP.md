# TEACHER MODE SETUP GUIDE
## Two-Laptop Synchronization System for test.html

### Overview
Teacher Mode enables real-time synchronization between two laptops during classroom instruction:
- **Laptop A (Student View)**: Screen shared to students - shows ONLY questions and options
- **Laptop B (Teacher View)**: Private teacher laptop - shows correct answers and rationales

Both devices stay perfectly synchronized with the same question order and current question number.

---

## 🚀 QUICK START

### Step 1: Database Setup
Run the SQL migration in Supabase SQL Editor:
```bash
# File: ADD-TEACHER-SESSIONS-TABLE.sql
# This creates the teacher_sessions table with Realtime enabled
```

Navigate to: https://supabase.com/dashboard → Your Project → SQL Editor → Paste the contents of `ADD-TEACHER-SESSIONS-TABLE.sql` → Run

### Step 2: Start Teacher Session
On **Laptop B (Teacher)**:
```
http://localhost:8000/test.html?session=class123&mode=teacher
```
- Replace `class123` with any unique session ID
- Teacher view will show:
  - ✅ Correct answers highlighted
  - 📖 Full rationale explanations
  - 🎓 Teacher control panel with student link
  - 📤 Copy button for student URL

### Step 3: Join Student Session
On **Laptop A (Student View)**:
```
http://localhost:8000/test.html?session=class123
```
- Use the SAME session ID as teacher
- Student view will show:
  - ❌ NO answers or rationales
  - ❌ NO "Check Answer" button
  - ❌ Cannot navigate independently
  - ✅ Follows teacher navigation automatically

---

## 🎯 HOW IT WORKS

### Synchronization Flow
```
Teacher Action                 Database Update              Student Auto-Sync
─────────────────            ─────────────────────         ──────────────────
Next Question    ──────►    current_index = 5    ────►    Jump to Q5
Previous Question ──────►   current_index = 4    ────►    Jump to Q4
Jump to Q10      ──────►    current_index = 10   ────►    Jump to Q10
```

### Technology Stack
- **Database**: Supabase PostgreSQL (`teacher_sessions` table)
- **Real-time**: Supabase Realtime (WebSocket channel subscription)
- **State Management**: Broadcast updates on every navigation action
- **Persistence**: Session state saved in database (survives teacher reload)

### Key Features
1. **Question Order Sync**: Shuffled order is saved to database - both devices use identical sequence
2. **Navigation Lock**: Student cannot navigate independently (buttons disabled with warning)
3. **Answer Hiding**: Student view NEVER shows answers, rationales, or "Check Answer" button
4. **Auto-Reconnect**: If connection drops, automatically attempts reconnection every 3 seconds
5. **Session Heartbeat**: Teacher sends keep-alive every 30 seconds to prevent cleanup
6. **"Waiting for Teacher"**: Student sees animated waiting screen if teacher hasn't started yet

---

## 🎓 TEACHER VIEW FEATURES

### Teacher Control Panel (Top Right)
```
┌──────────────────────────────────┐
│ 🎓 Teacher Mode Active           │
│ Session: class123                │
│                                  │
│ STUDENT VIEW URL:                │
│ [localhost:8000/test.html?...]   │
│                                  │
│ [📋 Copy Student Link]           │
│ [🛑 End Session]                 │
└──────────────────────────────────┘
```

### Teacher Answer Panel (Right Side)
```
┌──────────────────────────────────┐
│ 🎓 Teacher View    Q5 of 50      │
├──────────────────────────────────┤
│ ✅ CORRECT ANSWER:               │
│ ┌──────────────────────────────┐ │
│ │ Assess airway, breathing,    │ │
│ │ and circulation               │ │
│ └──────────────────────────────┘ │
│                                  │
│ 💡 RATIONALE:                    │
│ ┌──────────────────────────────┐ │
│ │ The ABC approach ensures...  │ │
│ └──────────────────────────────┘ │
└──────────────────────────────────┘
```

### Teacher Navigation
- Full control over Next/Previous/Jump buttons
- Each action broadcasts to all connected students instantly
- Answer panel updates automatically on every question change

---

## 👨‍🎓 STUDENT VIEW FEATURES

### Restrictions Enforced
- ❌ **No "Check Answer" button**: Completely hidden from DOM
- ❌ **No answer feedback**: `checkAnswer()` function blocked
- ❌ **No navigation control**: Buttons show warning "Navigation controlled by teacher"
- ❌ **No correct answer highlighting**: Options stay neutral (no green/red)
- ❌ **No rationales visible**: Never rendered in student view

### What Students CAN See
- ✅ Question stem (text)
- ✅ All answer options (radio/checkbox inputs)
- ✅ Current question number (synchronized with teacher)
- ✅ Question navigator (for reference only - clicking shows warning)

### "Waiting for Teacher" State
If student loads before teacher starts:
```
⏳
Waiting for Teacher...

Your teacher will start the session shortly.
Session ID: class123

● ● ●  (animated loading dots)
```

---

## 🔧 TECHNICAL IMPLEMENTATION

### Database Schema
```sql
teacher_sessions (
  id UUID PRIMARY KEY,
  session_id TEXT UNIQUE,           -- Shared session identifier
  test_id TEXT,                     -- Test configuration ID
  question_order JSONB,             -- Array of question objects
  current_index INTEGER,            -- Current question (0-based)
  teacher_email TEXT,
  teacher_name TEXT,
  test_config JSONB,
  total_questions INTEGER,
  is_active BOOLEAN,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  last_heartbeat TIMESTAMPTZ        -- For cleanup of abandoned sessions
)
```

### Realtime Subscription (Student)
```javascript
db.channel(`teacher_session_${sessionId}`)
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'teacher_sessions',
    filter: `session_id=eq.${sessionId}`
  }, (payload) => {
    // Auto-sync to teacher's current_index
    testState.currentIndex = payload.new.current_index;
    displayQuestion(testState.currentIndex);
  })
  .subscribe();
```

### Broadcasting Updates (Teacher)
```javascript
async function broadcastSessionUpdate() {
  await db
    .from('teacher_sessions')
    .update({
      current_index: testState.currentIndex,
      question_order: testState.questions,
      last_heartbeat: new Date().toISOString()
    })
    .eq('session_id', TEACHER_MODE.sessionId);
}
```

### Navigation Interception
```javascript
function nextQuestion() {
  // Student view blocked
  if (TEACHER_MODE.isStudent && !TEACHER_MODE.enabled) {
    showToast('Navigation controlled by teacher', 'warning');
    return;
  }
  
  testState.currentIndex++;
  renderQuestion();
  
  // Teacher broadcasts update
  if (TEACHER_MODE.enabled) {
    broadcastSessionUpdate();
  }
}
```

---

## 🛠️ TROUBLESHOOTING

### Problem: Student sees "Waiting for teacher..." forever
**Solution**: Teacher must open their session first and click "Start Test"
- Teacher session creates the database record
- Student subscribes to updates from that record
- Teacher must complete test setup before student can sync

### Problem: Sync not working (student not following teacher)
**Solutions**:
1. Check Supabase Realtime is enabled:
   - Dashboard → Database → Replication → Enable `teacher_sessions` table
2. Verify both devices use SAME session ID:
   - Teacher: `?session=class123&mode=teacher`
   - Student: `?session=class123` (exact match required)
3. Check browser console for errors:
   - Teacher: Look for "📤 Broadcast update: Question X"
   - Student: Look for "📥 Teacher session update received"

### Problem: Teacher loses session on reload
**Solution**: Session state is saved in database
- Teacher reload automatically restores from `teacher_sessions` table
- Question order and current index are preserved
- Students remain connected and sync continues

### Problem: Old sessions accumulating in database
**Solution**: Automatic cleanup runs on server
```sql
-- Manual cleanup (if needed)
DELETE FROM teacher_sessions
WHERE created_at < NOW() - INTERVAL '24 hours'
   OR last_heartbeat < NOW() - INTERVAL '1 hour';
```

### Problem: Student can still click navigation buttons
**Solution**: Buttons are NOT disabled (for UI consistency), but clicks show warning toast
- This is intentional design
- Clicking Next/Previous/Jump shows: "Navigation controlled by teacher"
- No actual navigation occurs

---

## 🔒 SECURITY CONSIDERATIONS

### Current Implementation (Testing Phase)
- ✅ Anonymous access allowed for rapid testing
- ⚠️ Any user can create teacher sessions
- ⚠️ Session IDs are not encrypted
- ⚠️ No authentication required

### Production Recommendations
1. **Add Teacher Authentication**:
   ```sql
   -- Update RLS policies to require authenticated role
   CREATE POLICY "Teachers only"
     ON teacher_sessions FOR ALL
     TO authenticated
     USING (auth.uid() = teacher_id);
   ```

2. **Validate Teacher Email**:
   ```javascript
   const AUTHORIZED_TEACHERS = [
     'teacher1@acnhs.edu',
     'teacher2@acnhs.edu'
   ];
   
   if (!AUTHORIZED_TEACHERS.includes(userEmail)) {
     throw new Error('Unauthorized teacher');
   }
   ```

3. **Encrypt Session IDs**:
   ```javascript
   // Use cryptographically secure random IDs
   const sessionId = crypto.randomUUID();
   ```

4. **Rate Limiting**:
   - Limit session creation to 1 per teacher per hour
   - Prevent spam from malicious users

---

## 📊 MONITORING & ANALYTICS

### Database Queries

#### Check Active Sessions
```sql
SELECT 
  session_id,
  teacher_name,
  total_questions,
  current_index,
  last_heartbeat,
  created_at
FROM teacher_sessions
WHERE is_active = true
ORDER BY last_heartbeat DESC;
```

#### Session Duration
```sql
SELECT 
  session_id,
  teacher_name,
  EXTRACT(EPOCH FROM (NOW() - created_at))/60 AS duration_minutes
FROM teacher_sessions
WHERE is_active = true;
```

#### Cleanup Old Sessions
```sql
SELECT cleanup_old_teacher_sessions();
```

### Console Logs to Monitor

**Teacher Console**:
```
🎓 Teacher Mode: TEACHER VIEW
📡 Session ID: class123
✅ Teacher session created: {...}
💓 Session heartbeat started
📤 Broadcast update: Question 5
```

**Student Console**:
```
🎓 Teacher Mode: STUDENT VIEW
📡 Session ID: class123
📡 Subscribing to teacher session: class123
✅ Subscribed to teacher session
📖 Loaded teacher session state: {...}
📥 Teacher session update received: {...}
🔄 Syncing with teacher: {...}
📍 Synced to question 5
```

---

## 🎬 TYPICAL USAGE SCENARIO

### Before Class
1. Teacher opens Laptop B: `test.html?session=period3&mode=teacher`
2. Teacher clicks "Start Test" → Session created
3. Teacher clicks "📋 Copy Student Link"
4. Teacher pastes link to projector laptop (Laptop A)

### During Class
1. Laptop A (projector) shows Student View - questions only
2. Laptop B (teacher) shows Teacher View - answers + rationales
3. Teacher explains concept, then clicks "Next"
4. Both screens advance together automatically
5. Students see clean questions, teacher sees full answers

### After Class
1. Teacher clicks "🛑 End Session"
2. Session marked inactive in database
3. Automatic cleanup removes after 24 hours

---

## 📝 CODE FILES MODIFIED

### 1. `ADD-TEACHER-SESSIONS-TABLE.sql`
- Creates `teacher_sessions` table
- Enables RLS policies
- Adds Realtime publication
- Includes cleanup function

### 2. `test.html`
**Added Sections**:
- Lines 1555-1600: Teacher Mode URL parsing
- Lines 1620-1900: Realtime sync functions
- Lines 1900-2100: Teacher UI panels
- Lines 2920-2960: Student view restrictions
- Lines 3100-3150: Navigation broadcasting

**Modified Functions**:
- `initializeNewTest()`: Session creation
- `nextQuestion()`: Broadcast on navigation
- `previousQuestion()`: Broadcast on navigation
- `goToQuestion()`: Broadcast on navigation
- `renderQuestion()`: Teacher answer panel
- `checkAnswer()`: Student view blocking

---

## 🚦 DEPLOYMENT CHECKLIST

- [ ] Run `ADD-TEACHER-SESSIONS-TABLE.sql` in Supabase
- [ ] Enable Realtime for `teacher_sessions` table
- [ ] Test teacher session creation
- [ ] Test student subscription and sync
- [ ] Test navigation synchronization
- [ ] Test reconnection on disconnect
- [ ] Test session persistence on teacher reload
- [ ] Test "Waiting for teacher" state
- [ ] Verify answer hiding in student view
- [ ] Verify navigation blocking in student view
- [ ] Test session cleanup (24 hour expiry)
- [ ] Document session IDs for teachers
- [ ] Create teacher training materials

---

## 📞 SUPPORT

For issues or questions:
1. Check console logs on both devices
2. Verify Supabase Realtime is enabled
3. Confirm session IDs match exactly
4. Review troubleshooting section above
5. Check `supabase/functions` logs for errors

**Emergency Reset**:
```sql
-- Clear all active sessions
UPDATE teacher_sessions SET is_active = false;
```

---

## 🎉 SUCCESS INDICATORS

Your Teacher Mode is working correctly when:
- ✅ Teacher sees "🎓 Teacher Mode Active" panel
- ✅ Teacher sees answer panel with correct answer highlighted
- ✅ Student sees "Waiting for teacher..." → then questions appear
- ✅ Teacher clicks Next → Student screen advances immediately
- ✅ Student clicks Next → Warning toast appears, no navigation
- ✅ Teacher answer panel shows rationale text
- ✅ Student view shows NO answers or rationales
- ✅ Teacher can copy student link with one click
- ✅ Session persists on teacher browser refresh

---

**Version**: 1.0  
**Last Updated**: February 17, 2026  
**Tested With**: Supabase v2, Chrome/Safari/Firefox
