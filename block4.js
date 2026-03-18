
// ============================================
// SUPABASE INITIALIZATION
// ============================================

let db = null;

function initializeSupabase() {
  try {
    if (typeof setSupabaseOwnerHeader === 'function') {
      // SESSION_ROLE may not be populated yet on first call (before DOMContentLoaded).
      // refreshSupabaseOwner() will re-set the correct role header once the role is known.
      const role = (SESSION_ROLE && SESSION_ROLE.userRole) || 'student';
      setSupabaseOwnerHeader(getOwnerId(), role);
    }
    db = initSupabase();
    if (!db) {
      throw new Error('Failed to initialize Supabase client');
    }
    console.log('✓ Supabase connected');
    return true;
  } catch (error) {
    console.error('Supabase initialization error:', error);
    showToast('Database connection failed', 'error');
    return false;
  }
}

// ============================================
// SESSION ROLE — AUTH & PERMISSION STATE
// ============================================
// Populated on DOMContentLoaded from sessionStorage/localStorage.
// isLoggedIn  — gate: unauthenticated users are redirected to login.html
// isTeacher   — true only for admin_users with role 'teacher','admin','superadmin'
//               Students always have isTeacher === false.
// ============================================
const SESSION_ROLE = {
  isLoggedIn: false,
  isTeacher: false,
  userRole: null,
  userName: null
};

function initSessionRole() {
  const loggedIn =
    sessionStorage.getItem('isLoggedIn') === 'true' ||
    localStorage.getItem('isLoggedIn') === 'true';

  if (!loggedIn) {
    // Not authenticated — send to login
    window.location.replace('login.html');
    return;
  }

  SESSION_ROLE.isLoggedIn = true;

  // Role is set in sessionStorage/localStorage by login.html when an admin_user logs in.
  // Students do NOT have isAdmin='true' and have no userRole in storage.
  const isAdmin =
    sessionStorage.getItem('isAdmin') === 'true' ||
    localStorage.getItem('isAdmin') === 'true';

  const storedRole = (
    sessionStorage.getItem('userRole') ||
    localStorage.getItem('userRole') ||
    ''
  ).toLowerCase().trim();

  const TEACHER_ROLES = ['teacher', 'admin', 'superadmin', 'instructor'];
  const roleIsTeacher = TEACHER_ROLES.includes(storedRole);

  SESSION_ROLE.userRole = storedRole || (isAdmin ? 'admin' : 'student');
  // Prefer generic 'userName' (set by login.html for admins), then teacher-specific
  // 'teacherName' (set by teacher.html), then localStorage mirrors of both.
  SESSION_ROLE.userName =
    sessionStorage.getItem('userName') ||
    sessionStorage.getItem('teacherName') ||
    localStorage.getItem('userName') ||
    localStorage.getItem('teacherName') ||
    null;

  // A user is a teacher if:
  //   - their stored role matches a teacher role, OR
  //   - isAdmin flag is true (superadmin / primary admin)
  SESSION_ROLE.isTeacher = roleIsTeacher || isAdmin;
}

// ============================================
// OWNER IDENTITY — DATA ISOLATION
// ============================================
// Returns a stable, non-spoofable identity string for the currently
// logged-in user.  Used as 'student_id' in Supabase rows AND as the
// suffix of the localStorage in-progress key so that sessions, saved
// tests, and results are STRICTLY isolated per account.
//
// Priority (first non-empty value wins):
//   1. teacherEmail / userEmail  — set by teacher.html or login.html
//   2. studentId from sessionStorage — set for real student accounts
//   3. userName as last resort
// Falls back to a random ephemeral ID (never 'guest') so that an
// anonymous device still has its own bucket.
// ============================================
function getOwnerId() {
  const email =
    sessionStorage.getItem('teacherEmail') ||
    localStorage.getItem('teacherEmail') ||
    sessionStorage.getItem('userEmail') ||
    localStorage.getItem('userEmail') || '';
  if (email) return email.toLowerCase().trim();

  const studentId =
    sessionStorage.getItem('studentId') ||
    localStorage.getItem('studentId') || '';
  if (studentId && studentId !== 'guest') return studentId;

  const name =
    sessionStorage.getItem('userName') ||
    sessionStorage.getItem('teacherName') ||
    localStorage.getItem('userName') ||
    localStorage.getItem('teacherName') || '';
  if (name) return name.toLowerCase().replace(/\s+/g, '_');

  // Truly anonymous: generate a per-device ephemeral ID and persist it
  let anonId = localStorage.getItem('_acnhs_anon_id');
  if (!anonId) {
    anonId = 'anon_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    localStorage.setItem('_acnhs_anon_id', anonId);
  }
  return anonId;
}

// Apply role-gated UI — call after DOM is ready
function applySessionRole() {
  const revealBtn    = document.getElementById('revealAllBtn');
  const coldCallPanel = document.getElementById('coldCallPanel');
  if (!revealBtn) return;

  if (SESSION_ROLE.isTeacher) {
    revealBtn.style.display = 'inline-flex';
    if (coldCallPanel) {
      coldCallPanel.style.display = 'flex';
      // Load groups immediately since panel is always visible
      if (coldCallState.groups.length === 0) coldCallLoadGroups();
    }
  } else {
    // Students: remove the reveal button entirely
    revealBtn.remove();

    // Students: replace cold call panel with a read-only name card
    if (coldCallPanel) {
      // Resolve the student's own display name
      const studentName =
        sessionStorage.getItem('userName') ||
        sessionStorage.getItem('teacherName') ||
        localStorage.getItem('userName') ||
        localStorage.getItem('teacherName') ||
        SESSION_ROLE.userName || 'You';

      coldCallPanel.innerHTML = `
        <h3 class="cc-panel-title">Cold Call</h3>

        <!-- Lock row — identical to .cc-field-label treatment -->
        <div style="display:flex;align-items:center;gap:7px;">
          <div class="cc-field-label" style="display:flex;align-items:center;gap:6px;margin-bottom:0;">
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
            Teacher controls only
          </div>
        </div>

        <!-- Name display — identical structure to cc-name-display used by teacher -->
        <div class="cc-name-display standby" style="gap:8px;">
          <div class="cc-called-label" style="color:var(--gold-primary);">
            <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            On standby
          </div>
          <div class="cc-name-text" style="font-size:17px;">${studentName}</div>
          <div style="font-size:10.5px;color:#64748b;letter-spacing:0.2px;line-height:1.5;">
            Your name is in the pool.<br>Stay ready.
          </div>
        </div>

        <!-- Progress row — same layout as teacher, but read-only placeholder -->
        <div>
          <div class="cc-progress-row">
            <span class="cc-progress-label-text">Round progress</span>
            <span class="cc-progress-fraction">—</span>
          </div>
          <div class="cc-progress-bar-wrap">
            <div class="cc-progress-bar-fill" style="width:0%"></div>
          </div>
        </div>
      `;
      coldCallPanel.style.display = 'flex';
    }
  }

  // ── User identity pill ─────────────────────────────────────────────────
  const pill    = document.getElementById('sessionUserPill');
  const avatar  = document.getElementById('sessionUserAvatar');
  const nameEl  = document.getElementById('sessionUserName');
  const roleEl  = document.getElementById('sessionUserRole');
  if (!pill) return;

  // Resolve display name: prefer stored name, fall back to email username
  const rawName  = SESSION_ROLE.userName ||
    sessionStorage.getItem('userName') ||
    sessionStorage.getItem('teacherName') ||
    localStorage.getItem('userName') ||
    localStorage.getItem('teacherName') || '';
  const rawEmail = sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail') ||
    sessionStorage.getItem('teacherEmail') || localStorage.getItem('teacherEmail') || '';

  let displayName = rawName.trim();
  if (!displayName && rawEmail) {
    // Use the part before @ as a readable fallback
    displayName = rawEmail.split('@')[0].replace(/[._]/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
  }
  if (!displayName) displayName = SESSION_ROLE.isTeacher ? 'Faculty' : 'Student';

  // Initials for the avatar circle (up to 2 chars)
  const parts    = displayName.split(/\s+/).filter(Boolean);
  const initials = parts.length >= 2
    ? (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
    : displayName.slice(0, 2).toUpperCase();

  // Role label & colour
  const roleLabel = SESSION_ROLE.isTeacher
    ? (SESSION_ROLE.userRole === 'admin' || SESSION_ROLE.userRole === 'superadmin' ? 'Administrator' : 'Faculty')
    : 'Student';

  const isTeacher = SESSION_ROLE.isTeacher;
  const goldColor = 'var(--gold-primary)';
  const blueColor = '#38bdf8';
  const roleColor   = isTeacher ? goldColor : blueColor;
  const avatarBg    = isTeacher ? 'rgba(201,168,76,0.15)' : 'rgba(56,189,248,0.12)';
  const avatarBorder= isTeacher ? 'rgba(201,168,76,0.5)'  : 'rgba(56,189,248,0.45)';
  const pillBg      = isTeacher ? 'rgba(201,168,76,0.07)' : 'rgba(56,189,248,0.07)';
  const pillBorder  = isTeacher ? 'rgba(201,168,76,0.22)' : 'rgba(56,189,248,0.18)';

  avatar.textContent      = initials;
  avatar.style.background = avatarBg;
  avatar.style.borderColor= avatarBorder;
  avatar.style.color      = roleColor;
  nameEl.textContent      = displayName;
  roleEl.textContent      = roleLabel;
  roleEl.style.color      = roleColor;
  pill.style.display      = 'inline-flex';
  pill.style.background   = pillBg;
  pill.style.borderColor  = pillBorder;
}

// ============================================
// TEACHER MODE - TWO-LAPTOP SYNC SYSTEM
// ============================================
// USAGE:
// Student View: test.html?session=ABC123
// Teacher View: test.html?session=ABC123&mode=teacher
//
// How it works:
// 1. Teacher creates session with unique session ID
// 2. Student joins same session (via URL parameter)
// 3. Supabase Realtime keeps both devices in perfect sync
// 4. Teacher controls navigation, student follows automatically
// 5. Student NEVER sees answers/rationales (teacher-only)
// ============================================

const TEACHER_MODE = {
  enabled: false,        // Is this device in teacher mode?
  isStudent: false,      // Is this device in student mode?
  sessionId: null,       // Shared session ID for sync
  channel: null,         // Supabase Realtime channel
  teacherEmail: null,    // Teacher identifier
  syncActive: false,     // Is real-time sync connected?
  heartbeatInterval: null // Keep-alive heartbeat
};

// Parse URL parameters for Teacher Mode
function parseTeacherModeParams() {
  const urlParams = new URLSearchParams(window.location.search);
  const sessionParam = urlParams.get('session');
  const modeParam = urlParams.get('mode');
  
  if (sessionParam) {
    TEACHER_MODE.sessionId = sessionParam;
    TEACHER_MODE.isStudent = modeParam !== 'teacher';
    TEACHER_MODE.enabled = modeParam === 'teacher';
    
    console.log(`🎓 Teacher Mode: ${TEACHER_MODE.enabled ? 'TEACHER VIEW' : 'STUDENT VIEW'}`);
    console.log(`📡 Session ID: ${TEACHER_MODE.sessionId}`);
  }
}

// Initialize Teacher Mode on page load
parseTeacherModeParams();

// ============================================
// TEACHER MODE - REALTIME SYNC FUNCTIONS
// ============================================

// Generate a unique session ID
function generateSessionId() {
  return 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

// Create a new teacher session in database
async function createTeacherSession(testId, questionOrder) {
  if (!SESSION_ROLE.isTeacher) {
    console.warn('[ACNHS] createTeacherSession() blocked: student role.');
    return null;
  }
  if (!TEACHER_MODE.sessionId) {
    TEACHER_MODE.sessionId = generateSessionId();
  }
  
  try {
    const sessionData = {
      session_id: TEACHER_MODE.sessionId,
      test_id: testId,
      question_order: questionOrder,
      current_index: 0,
      teacher_email: TEACHER_MODE.teacherEmail || 'teacher@acnhs.edu',
      teacher_name: 'Teacher',
      test_config: TEST_CONFIG,
      total_questions: questionOrder.length,
      is_active: true,
      last_heartbeat: new Date().toISOString(),
      // Frozen bilingual snapshots — written once, never changed
      session_snapshot_en: testState.snapshot.en || null,
      session_snapshot_hy: testState.snapshot.hy || null
    };
    
    const { data, error } = await db
      .from('teacher_sessions')
      .upsert(sessionData, { onConflict: 'session_id' })
      .select()
      .single();
    
    if (error) throw error;
    
    console.log('✅ Teacher session created:', data);
    return data;
  } catch (error) {
    console.error('❌ Error creating teacher session:', error);
    throw error;
  }
}

// Subscribe to teacher session updates (for student view)
async function subscribeToTeacherSession() {
  if (!TEACHER_MODE.sessionId || TEACHER_MODE.enabled) return;
  
  console.log('📡 Subscribing to teacher session:', TEACHER_MODE.sessionId);
  
  try {
    // Create a channel for this session
    const channel = db.channel(`teacher_session_${TEACHER_MODE.sessionId}`)
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'teacher_sessions',
          filter: `session_id=eq.${TEACHER_MODE.sessionId}`
        },
        (payload) => {
          console.log('📥 Teacher session update received:', payload);
          handleTeacherSessionUpdate(payload.new);
        }
      )
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          console.log('✅ Subscribed to teacher session');
          TEACHER_MODE.syncActive = true;
          TEACHER_MODE.channel = channel;
        } else if (status === 'CHANNEL_ERROR') {
          console.error('❌ Channel subscription error');
          TEACHER_MODE.syncActive = false;
          // Attempt reconnection after 3 seconds
          setTimeout(() => subscribeToTeacherSession(), 3000);
        } else if (status === 'TIMED_OUT') {
          console.error('⏱️ Channel subscription timed out');
          setTimeout(() => subscribeToTeacherSession(), 3000);
        }
      });
    
    // Load initial session state
    await loadTeacherSessionState();
    
  } catch (error) {
    console.error('❌ Error subscribing to teacher session:', error);
  }
}

// Load current session state from database
async function loadTeacherSessionState() {
  try {
    const { data, error } = await db
      .from('teacher_sessions')
      .select('*')
      .eq('session_id', TEACHER_MODE.sessionId)
      .single();
    
    if (error) {
      if (error.code === 'PGRST116') {
        // Session doesn't exist yet - show waiting message
        showWaitingForTeacher();
      } else {
        throw error;
      }
      return;
    }
    
    console.log('📖 Loaded teacher session state:', data);

    // ── Load the frozen bilingual snapshot (set once by teacher at session start) ──
    if (data.session_snapshot_en) {
      testState.snapshot = {
        en: data.session_snapshot_en,
        hy: data.session_snapshot_hy || null
      };
      applyLanguagePicker();
      console.log('🌐 Bilingual snapshot loaded from teacher session');
    }
    
    // Apply the session state
    if (data.question_order && data.question_order.length > 0) {
      testState.questions = data.question_order;
      testState.currentIndex = data.current_index || 0;
      
      // If test is already started, sync to current question
      if (document.getElementById('testContainer').style.display !== 'none') {
        renderQuestion();
      }
      
      hideWaitingForTeacher();
    }
    
  } catch (error) {
    console.error('❌ Error loading teacher session state:', error);
  }
}

// Handle incoming teacher session updates
function handleTeacherSessionUpdate(sessionData) {
  console.log('🔄 Syncing with teacher:', sessionData);
  
  // Update question order if changed
  if (sessionData.question_order) {
    testState.questions = sessionData.question_order;
  }
  
  // Sync to current question index
  if (sessionData.current_index !== undefined && sessionData.current_index !== testState.currentIndex) {
    testState.currentIndex = sessionData.current_index;
    renderQuestion();
    console.log(`📍 Synced to question ${testState.currentIndex + 1}`);
  }
}

// Broadcast session state update (teacher only)
async function broadcastSessionUpdate() {
  if (!SESSION_ROLE.isTeacher) {
    console.warn('[ACNHS] broadcastSessionUpdate() blocked: student role.');
    return;
  }
  if (!TEACHER_MODE.enabled || !TEACHER_MODE.sessionId) return;
  
  try {
    const { error } = await db
      .from('teacher_sessions')
      .update({
        current_index: testState.currentIndex,
        question_order: testState.questions,
        last_heartbeat: new Date().toISOString()
      })
      .eq('session_id', TEACHER_MODE.sessionId);
    
    if (error) throw error;
    
    console.log('📤 Broadcast update: Question', testState.currentIndex + 1);
  } catch (error) {
    console.error('❌ Error broadcasting session update:', error);
  }
}

// Send heartbeat to keep session alive
async function sendSessionHeartbeat() {
  if (!SESSION_ROLE.isTeacher) {
    console.warn('[ACNHS] sendSessionHeartbeat() blocked: student role.');
    return;
  }
  if (!TEACHER_MODE.enabled || !TEACHER_MODE.sessionId) return;
  
  try {
    await db
      .from('teacher_sessions')
      .update({ last_heartbeat: new Date().toISOString() })
      .eq('session_id', TEACHER_MODE.sessionId);
  } catch (error) {
    console.error('❌ Heartbeat error:', error);
  }
}

// Start heartbeat interval (teacher only)
function startSessionHeartbeat() {
  if (!SESSION_ROLE.isTeacher) {
    console.warn('[ACNHS] startSessionHeartbeat() blocked: student role.');
    return;
  }
  if (!TEACHER_MODE.enabled) return;
  
  TEACHER_MODE.heartbeatInterval = setInterval(() => {
    sendSessionHeartbeat();
  }, 30000); // Every 30 seconds
  
  console.log('💓 Session heartbeat started');
}

// Cleanup session on disconnect
async function endTeacherSession() {
  if (!SESSION_ROLE.isTeacher) {
    console.warn('[ACNHS] endTeacherSession() blocked: student role.');
    return;
  }
  if (!TEACHER_MODE.enabled || !TEACHER_MODE.sessionId) return;
  
  try {
    await db
      .from('teacher_sessions')
      .update({ is_active: false })
      .eq('session_id', TEACHER_MODE.sessionId);
    
    if (TEACHER_MODE.heartbeatInterval) {
      clearInterval(TEACHER_MODE.heartbeatInterval);
    }
    
    if (TEACHER_MODE.channel) {
      await db.removeChannel(TEACHER_MODE.channel);
    }
    
    console.log('👋 Teacher session ended');
  } catch (error) {
    console.error('❌ Error ending session:', error);
  }
}

// Show "Waiting for teacher..." message
function showWaitingForTeacher() {
  const container = document.getElementById('testContainer');
  if (!container) return;
  
  container.innerHTML = `
    <div style="text-align: center; padding: 60px 20px; max-width: 600px; margin: 0 auto;">
      <div style="font-size: 64px; margin-bottom: 24px; animation: pulse 2s infinite;">⏳</div>
      <h2 style="color: var(--gold-primary); margin-bottom: 16px; font-size: 28px;">Waiting for Teacher...</h2>
      <p style="color: var(--text-muted); font-size: 16px; line-height: 1.6;">
        Your teacher will start the session shortly.<br>
        Session ID: <strong style="color: white;">${TEACHER_MODE.sessionId}</strong>
      </p>
      <div style="margin-top: 32px;">
        <div style="display: inline-block; width: 12px; height: 12px; background: var(--gold-primary); border-radius: 50%; margin: 0 6px; animation: bounce 1.4s infinite ease-in-out both; animation-delay: -0.32s;"></div>
        <div style="display: inline-block; width: 12px; height: 12px; background: var(--gold-primary); border-radius: 50%; margin: 0 6px; animation: bounce 1.4s infinite ease-in-out both; animation-delay: -0.16s;"></div>
        <div style="display: inline-block; width: 12px; height: 12px; background: var(--gold-primary); border-radius: 50%; margin: 0 6px; animation: bounce 1.4s infinite ease-in-out both;"></div>
      </div>
    </div>
    <style>
      @keyframes pulse {
        0%, 100% { opacity: 1; transform: scale(1); }
        50% { opacity: 0.7; transform: scale(1.05); }
      }
      @keyframes bounce {
        0%, 80%, 100% { transform: scale(0); }
        40% { transform: scale(1); }
      }
    </style>
  `;
}

function hideWaitingForTeacher() {
  // Will be cleared when displayQuestion() renders the question
}

// Show Teacher Answer Panel with correct answer highlighted
function showTeacherAnswerPanel() {
  if (!TEACHER_MODE.enabled) return;
  
  const question = testState.questions[testState.currentIndex];
  if (!question) return;
  
  let teacherPanel = document.getElementById('teacherAnswerPanel');
  
  if (!teacherPanel) {
    teacherPanel = document.createElement('div');
    teacherPanel.id = 'teacherAnswerPanel';
    teacherPanel.style.cssText = `
      position: fixed;
      top: 80px;
      right: 20px;
      width: 380px;
      max-height: calc(100vh - 100px);
      overflow-y: auto;
      background: linear-gradient(145deg, #1e293b 0%, #0f172a 100%);
      border: 2px solid var(--gold-primary);
      border-radius: 16px;
      padding: 24px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
      z-index: 9999;
    `;
    document.body.appendChild(teacherPanel);
  }
  
  // Get correct option texts
  const correctOptions = question.options.filter(opt => 
    question.correct.map(String).includes(String(opt.id))
  );
  const correctTexts = correctOptions.map(opt => opt.text).join(', ');
  
  teacherPanel.innerHTML = `
    <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid rgba(201,168,76,0.25);">
      <div style="display:flex;align-items:center;justify-content:center;width:44px;height:44px;border-radius:12px;background:rgba(201,168,76,0.12);border:1.5px solid rgba(201,168,76,0.35);flex-shrink:0;">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#c9a84c" stroke-width="1.5"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
      </div>
      <div>
        <div style="color: var(--gold-primary); font-weight: 800; font-size: 18px;">Teacher View</div>
        <div style="color: var(--text-muted); font-size: 12px;">Q${testState.currentIndex + 1} of ${testState.questions.length}</div>
      </div>
    </div>
    
    <div style="margin-bottom: 20px;">
      <div style="color: var(--success); font-weight: 700; font-size: 14px; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
        CORRECT ANSWER${correctOptions.length > 1 ? 'S' : ''}:
      </div>
      <div style="background: rgba(34, 197, 94, 0.15); border: 2px solid var(--success); border-radius: 12px; padding: 16px; color: #86efac; font-size: 15px; line-height: 1.6;">
        ${correctTexts}
      </div>
    </div>
    
    ${question.rationale ? `
      <div>
        <div style="color: #fbbf24; font-weight: 700; font-size: 14px; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>
          </svg>
          RATIONALE:
        </div>
        <div style="background: rgba(251, 191, 36, 0.1); border: 2px solid rgba(251, 191, 36, 0.3); border-radius: 12px; padding: 16px; color: #e2e8f0; font-size: 14px; line-height: 1.7;">
          ${question.rationale}
        </div>
      </div>
    ` : ''}
    
    ${question.key_point ? `
      <div style="margin-top: 16px; padding: 12px 16px; background: rgba(201,168,76,0.07); border-left: 4px solid var(--gold-primary); border-radius: 8px; color: #475569; font-size: 13px;">
        <strong style="color: #92640c;">Key Point:</strong> ${question.key_point}
      </div>
    ` : ''}
  `;
}

// ============================================
// REVEAL ALL — TEACHER ONLY
// Shows correct answers + rationales for every question
// in a full-screen scrollable modal.
// JS-enforced: aborts immediately if SESSION_ROLE.isTeacher is false.
// Respects the active language (EN / HY) set by the language picker.
// ============================================
function revealAllAnswers() {
  // Hard server-side-equivalent gate — students cannot reach this path
  if (!SESSION_ROLE.isTeacher) {
    console.warn('revealAllAnswers() blocked: insufficient role');
    return;
  }

  if (!testState.questions || testState.questions.length === 0) {
    showToast('No questions loaded yet.', 'warning');
    return;
  }

  // Remove any previous modal
  const existing = document.getElementById('revealAllModal');
  if (existing) existing.remove();

  // Resolve the language-aware snapshot for display text.
  // Use HY snapshot when the teacher has switched to Armenian AND translations exist.
  const useHy = testState.language === 'hy'
    && testState.snapshot
    && testState.snapshot.hy
    && testState.snapshot.hy.length > 0;

  const displaySource = useHy ? testState.snapshot.hy : testState.snapshot.en;

  // Build question cards
  const cards = testState.questions.map((q, idx) => {
    // Pull display text from the language-aware snapshot; fall back to raw question if snapshot missing
    const snapQ = displaySource ? displaySource[idx] : null;
    const displayStem    = snapQ ? (snapQ.stem || q.stem || '') : (q.stem || '');
    const displayOptions = snapQ ? (snapQ.options || q.options || []) : (q.options || []);
    const displayRationale = snapQ ? (snapQ.rationale || q.rationale || '') : (q.rationale || '');

    const correctIds = (q.correct || []).map(String);

    // Option list with correct ones highlighted
    const optionRows = displayOptions.map((opt, oi) => {
      const letter = String.fromCharCode(65 + oi);
      const isCorrect = correctIds.includes(String(opt.id));
      return `
        <div style="display:flex;align-items:flex-start;gap:10px;padding:10px 14px;border-radius:8px;margin-bottom:6px;
          background:${isCorrect ? 'rgba(34,197,94,0.12)' : 'rgba(255,255,255,0.03)'};
          border:1.5px solid ${isCorrect ? 'rgba(34,197,94,0.45)' : 'rgba(255,255,255,0.07)'};">
          <span style="display:inline-flex;align-items:center;justify-content:center;width:24px;height:24px;border-radius:50%;flex-shrink:0;
            background:${isCorrect ? 'rgba(34,197,94,0.3)' : 'rgba(255,255,255,0.08)'};
            border:2px solid ${isCorrect ? 'var(--success)' : 'rgba(255,255,255,0.15)'};
            color:${isCorrect ? '#86efac' : '#94a3b8'};font-weight:800;font-size:12px;">${letter}</span>
          <span style="color:${isCorrect ? '#d1fae5' : '#94a3b8'};font-size:14px;line-height:1.6;${isCorrect ? 'font-weight:600;' : ''}">${opt.text}</span>
          ${isCorrect ? '<span style="margin-left:auto;color:var(--success);flex-shrink:0">✓</span>' : ''}
        </div>`;
    }).join('');

    return `
      <div data-q-index="${idx}" style="background:linear-gradient(145deg,#1e293b,#151f2e);border:1px solid rgba(201,168,76,0.18);border-radius:14px;padding:24px;margin-bottom:20px;">
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px;">
          <span style="background:rgba(201,168,76,0.18);border:1.5px solid rgba(201,168,76,0.4);color:var(--gold-primary);font-weight:900;font-size:15px;padding:5px 14px;border-radius:20px;flex-shrink:0;font-family:'Inter',sans-serif;">${idx + 1}</span>
          ${q.multi ? '<span style="background:rgba(99,102,241,0.15);border:1px solid rgba(99,102,241,0.4);color:#a5b4fc;font-size:11px;padding:3px 9px;border-radius:12px;">Multi-select</span>' : ''}
          ${useHy ? '<span style="background:rgba(201,168,76,0.10);border:1px solid rgba(201,168,76,0.3);color:#c9a84c;font-size:11px;padding:3px 9px;border-radius:12px;">ՀԱՅ</span>' : ''}
        </div>
        <div style="color:#f1f5f9;font-size:15px;font-weight:500;line-height:1.65;margin-bottom:16px;">${displayStem}</div>
        <div style="margin-bottom:14px;">${optionRows}</div>
        ${displayRationale ? `
          <div style="background:rgba(251,191,36,0.08);border-left:4px solid rgba(251,191,36,0.5);border-radius:0 8px 8px 0;padding:14px 16px;margin-top:4px;">
            <div style="color:#fbbf24;font-weight:700;font-size:12px;letter-spacing:0.5px;margin-bottom:6px;">${useHy ? 'ՀԻՄՆԱՎՈՐՈՒՄ' : 'RATIONALE'}</div>
            <div style="color:#e2e8f0;font-size:13px;line-height:1.7;">${displayRationale}</div>
          </div>` : ''}
        ${q.key_point ? `
          <div style="background:rgba(201,168,76,0.06);border-left:3px solid rgba(201,168,76,0.35);border-radius:0 6px 6px 0;padding:10px 14px;margin-top:10px;">
            <span style="color:#b45309;font-weight:700;font-size:12px;">KEY POINT: </span>
            <span style="color:#78716c;font-size:13px;">${q.key_point}</span>
          </div>` : ''}
      </div>`;
  }).join('');

  const modal = document.createElement('div');
  modal.id = 'revealAllModal';
  modal.style.cssText = `
    position:fixed;inset:0;z-index:100000;
    background:rgba(0,0,0,0.92);
    display:flex;flex-direction:column;
    overflow:hidden;
  `;

  modal.innerHTML = `
    <!-- Header bar -->
    <div style="flex-shrink:0;display:flex;align-items:center;justify-content:space-between;padding:18px 28px;
      background:linear-gradient(135deg,#0f172a,#1e293b);
      border-bottom:2px solid rgba(201,168,76,0.35);flex-wrap:wrap;gap:12px;">
      <div style="display:flex;align-items:center;gap:14px;">
        <div style="display:flex;align-items:center;justify-content:center;width:46px;height:46px;border-radius:13px;background:rgba(201,168,76,0.12);border:1.5px solid rgba(201,168,76,0.35);flex-shrink:0;">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#c9a84c" stroke-width="1.5"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
        </div>
        <div>
          <div style="color:var(--gold-primary);font-weight:800;font-size:20px;letter-spacing:0.3px;">Answer Key — Teacher View</div>
          <div style="color:#64748b;font-size:13px;margin-top:2px;">${testState.questions.length} questions · Strictly confidential · ${useHy ? 'ՀԱՅ' : 'EN'}</div>
        </div>
      </div>
      <div style="display:flex;align-items:center;gap:10px;">
        ${testState.snapshot && testState.snapshot.hy ? `
          <div style="display:flex;border-radius:10px;overflow:hidden;border:1.5px solid rgba(201,168,76,0.35);">
            <button onclick="switchLanguage('en');document.getElementById('revealAllModal').remove();revealAllAnswers();"
              style="padding:8px 16px;font-size:13px;font-weight:700;cursor:pointer;border:none;
                background:${!useHy ? 'rgba(201,168,76,0.25)' : 'rgba(255,255,255,0.05)'};
                color:${!useHy ? '#f1f5f9' : '#64748b'};">EN</button>
            <button onclick="switchLanguage('hy');document.getElementById('revealAllModal').remove();revealAllAnswers();"
              style="padding:8px 16px;font-size:13px;font-weight:700;cursor:pointer;border:none;
                background:${useHy ? 'rgba(201,168,76,0.25)' : 'rgba(255,255,255,0.05)'};
                color:${useHy ? '#f1f5f9' : '#64748b'};">ՀԱՅ</button>
          </div>
        ` : ''}
        <button onclick="document.getElementById('revealAllModal').remove()"
          style="background:rgba(239,68,68,0.12);border:1.5px solid rgba(239,68,68,0.4);color:#f87171;
            font-weight:700;font-size:14px;padding:10px 20px;border-radius:10px;cursor:pointer;
            display:flex;align-items:center;gap:8px;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
          Close
        </button>
      </div>
    </div>
    <!-- Scrollable body -->
    <div data-reveal-body style="flex:1;overflow-y:auto;padding:28px;max-width:900px;width:100%;margin:0 auto;box-sizing:border-box;">
      <div style="background:rgba(239,68,68,0.08);border:1.5px solid rgba(239,68,68,0.25);border-radius:10px;
        padding:12px 18px;margin-bottom:24px;color:#fca5a5;font-size:13px;font-weight:600;display:flex;align-items:center;gap:10px;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="flex-shrink:0">
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
        </svg>
        This answer key is restricted to authorised teaching staff. Do not share with students.
      </div>
      ${cards}
    </div>
  `;

  document.body.appendChild(modal);

  // Click outside (on backdrop) to close
  modal.addEventListener('click', (e) => {
    if (e.target === modal) {
      modal.remove();
      document.removeEventListener('keydown', onKeyDown);
    }
  });

  // Scroll the modal body to the current question
  requestAnimationFrame(() => {
    const scrollBody = modal.querySelector('[data-reveal-body]');
    if (scrollBody) {
      const targetCard = scrollBody.querySelector(`[data-q-index="${testState.currentIndex}"]`);
      if (targetCard) {
        targetCard.scrollIntoView({ block: 'start' });
        // small offset so the card isn't hard against the top
        scrollBody.scrollTop = Math.max(0, scrollBody.scrollTop - 24);
      }
    }
  });

  // Trap Escape key to close
  const onKeyDown = (e) => {
    if (e.key === 'Escape') {
      modal.remove();
      document.removeEventListener('keydown', onKeyDown);
    }
  };
  document.addEventListener('keydown', onKeyDown);
  modal.addEventListener('remove', () => document.removeEventListener('keydown', onKeyDown));
}

// Show Teacher Control Panel with session link
function showTeacherPanel() {
  if (!TEACHER_MODE.enabled) return;
  
  const panel = document.createElement('div');
  panel.id = 'teacherControlPanel';
  panel.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    background: linear-gradient(135deg, #14b8a6 0%, #0d9488 100%);
    border-radius: 16px;
    padding: 20px;
    box-shadow: 0 10px 40px rgba(20, 184, 166, 0.4);
    z-index: 10000;
    min-width: 320px;
  `;
  
  const studentUrl = `${window.location.origin}${window.location.pathname}?session=${TEACHER_MODE.sessionId}`;
  
  panel.innerHTML = `
    <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 16px;">
        <div style="display:flex;align-items:center;justify-content:center;width:42px;height:42px;border-radius:12px;background:rgba(201,168,76,0.12);border:1.5px solid rgba(201,168,76,0.35);flex-shrink:0;">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#c9a84c" stroke-width="1.5"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
        </div>
        <div>
          <div style="color: white; font-weight: 800; font-size: 16px;">Teacher Mode Active</div>
          <div style="color: rgba(255,255,255,0.8); font-size: 12px;">Session: ${TEACHER_MODE.sessionId}</div>
        </div>
    </div>
    
    <div style="background: rgba(255,255,255,0.2); border-radius: 8px; padding: 12px; margin-bottom: 12px;">
      <div style="color: rgba(255,255,255,0.9); font-size: 11px; font-weight: 600; margin-bottom: 6px;">STUDENT VIEW URL:</div>
      <input type="text" value="${studentUrl}" readonly 
        style="width: 100%; padding: 8px; border: none; border-radius: 6px; font-size: 12px; background: white; font-family: monospace;"
        onclick="this.select()">
    </div>
    
    <button onclick="copyStudentUrl()" style="
      width: 100%;
      padding: 10px;
      background: white;
      color: #0d9488;
      border: none;
      border-radius: 8px;
      font-weight: 700;
      font-size: 13px;
      cursor: pointer;
      transition: all 0.2s;
    " onmouseover="this.style.transform='translateY(-2px)'" onmouseout="this.style.transform='translateY(0)'">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
      Copy Student Link
    </button>
    
    <button onclick="endTeacherSession(); this.closest('#teacherControlPanel').remove();" style="
      width: 100%;
      padding: 8px;
      background: rgba(239, 68, 68, 0.2);
      color: white;
      border: 1px solid rgba(239, 68, 68, 0.5);
      border-radius: 8px;
      font-weight: 600;
      font-size: 12px;
      cursor: pointer;
      margin-top: 8px;
    ">
      🛑 End Session
    </button>
  `;
  
  document.body.appendChild(panel);
}

// Copy student URL to clipboard
function copyStudentUrl() {
  const url = `${window.location.origin}${window.location.pathname}?session=${TEACHER_MODE.sessionId}`;
  navigator.clipboard.writeText(url).then(() => {
    showToast('Student link copied to clipboard!', 'success');
  }).catch(err => {
    console.error('Failed to copy:', err);
    showToast('Failed to copy link', 'error');
  });
}

// ============================================
// TEST CONFIGURATION
// ============================================

const TEST_CONFIG = {
  testTitle: "Nursing Fundamentals - Midterm Exam",
  durationMinutes: 60,
  shuffleQuestions: true, // Default: enabled (can be toggled via Mix Q/A checkbox)
  shuffleOptions: true,   // Default: enabled (can be toggled via Mix Q/A checkbox)
  showBackButton: true,
  allowReview: true,
  passingScorePercent: 70,
  testId: null, // Will be loaded from Supabase or URL parameter
  categoryFilter: null, // Optional: filter questions by category
  selectedTopicIds: [],   // Topic UUIDs chosen by the user
  selectedTopicNames: []  // Human-readable names — persisted so title works after resume
};

// ============================================
// STATE MANAGEMENT
// ============================================

let testState = {
  questions: [],
  currentIndex: 0,
  answers: {},
  answerStatus: {},
  flagged: new Set(),
  startTime: null,
  endTime: null,
  timerInterval: null,
  sessionId: null,
  shuffleSeed: null,
  testConfig: null,
  studentId: null,
  savedSessionDbId: null, // DB id of a manually-named saved session
  autoSaveDbId: null,     // DB id of the auto-save (is_in_progress=true) row
  // ── Bilingual session snapshot ────────────────────────────────────────
  // Built once at session creation, never changes.
  // snapshot.en  — array of {id,stem,options,correct,rationale,multi,points,category}
  // snapshot.hy  — same array but with Armenian text (stem_hy / options_hy / rationale_hy)
  //               null if no Armenian translations are available.
  snapshot: { en: null, hy: null },
  language: localStorage.getItem('acnhs_test_lang') || 'en' // persisted per device
};

// ============================================
// DATABASE FUNCTIONS
// ============================================

function withTimeout(promise, ms, timeoutMessage) {
  let timerId;
  const timeout = new Promise((_, reject) => {
    timerId = setTimeout(() => {
      reject(new Error(timeoutMessage || 'Request timed out'));
    }, ms);
  });

  return Promise.race([promise, timeout]).finally(() => {
    if (timerId) clearTimeout(timerId);
  });
}

function isNetworkFailure(error) {
  const msg = String(error?.message || '');
  return msg.includes('Load failed') ||
    msg.includes('TLS') ||
    msg.includes('Failed to fetch') ||
    msg.includes('network_timeout') ||
    msg.includes('Request timed out') ||
    msg.includes('timed out');
}

function setLoadingStatus(message) {
  const statusEl = document.getElementById('startStatus');
  if (statusEl) {
    statusEl.textContent = message || '';
  }
}

function refreshSupabaseOwner() {
  if (typeof setSupabaseOwnerHeader === 'function') {
    const ownerId = getOwnerId();
    const ownerRole = SESSION_ROLE.userRole || 'student';
    // Ensure the base client exists before injecting the header —
    // setSupabaseOwnerHeader only rebuilds if supabaseClient is already set.
    if (!db) initializeSupabase();
    // Pass both owner id AND role — RLS policies use both headers.
    setSupabaseOwnerHeader(ownerId, ownerRole);
    // Always rebind db so every subsequent query uses the updated headers.
    db = initSupabase();
    console.log(`✓ Owner header set for: ${ownerId} (role: ${ownerRole})`);
  }
}

async function loadTestConfiguration(testId) {
  // Cache per testId — avoids double round-trip when showSubjectSelection()
  // and startTest() both call this for the same testId in the same session.
  if (window._cachedTestConfig && window._cachedTestConfig._id === testId) {
    Object.assign(TEST_CONFIG, window._cachedTestConfig);
    return window._cachedTestConfig;
  }
  try {
    setLoadingStatus('Fetching test configuration...');
    // Fetch test configuration from test_configs table
    const { data: config, error: configError } = await withTimeout(
      db
        .from('test_configs')
        .select('*')
        .eq('id', testId)
        .single(),
      7000,
      'Loading test configuration timed out'
    );
    
    if (configError) throw configError;
    
    if (!config.is_active) {
      throw new Error('This test is not currently available');
    }
    
    // Update TEST_CONFIG with database values
    TEST_CONFIG.testTitle = config.title;
    TEST_CONFIG.durationMinutes = config.duration_minutes;
    TEST_CONFIG.shuffleQuestions = config.shuffle_questions;
    TEST_CONFIG.shuffleOptions = config.shuffle_options;
    TEST_CONFIG.showBackButton = config.show_back_button;
    TEST_CONFIG.allowReview = config.allow_review;
    TEST_CONFIG.passingScorePercent = config.passing_score_percent;
    TEST_CONFIG.testId = testId;
    
    testState.testConfig = config;
    
    // Cache so the second call (from startTest) is instant
    window._cachedTestConfig = { ...config, _id: testId };
    
    return config;
  } catch (error) {
    console.error('Error loading test configuration:', error);
    showToast('Failed to load test configuration', 'error');
    const friendly = isNetworkFailure(error)
      ? 'Network blocked the test configuration request (TLS/SSL). Try disabling VPN/ad blockers or use Chrome.'
      : (error.message || 'Unknown error');
    error.message = `Test configuration failed: ${friendly}`;
    throw error;
  }
}

async function loadQuestions(testId, categoryFilter = null, questionCount = null, topicIds = null) {
  try {
    setLoadingStatus('Querying question bank...');
    // When topic IDs are provided (multi-subject system), skip the test_id filter —
    // questions from different subjects have different test_ids (e.g. endocrine = 0004,
    // fundamentals = 0001) and the topic_id already uniquely identifies the questions.
    const useTopicSystem = topicIds && Array.isArray(topicIds) && topicIds.length > 0;

    let query = db
      .from('test_questions')
      .select('id, test_id, question_stem, question_stem_hy, options, options_hy, correct_answers, is_multiple_choice, rationale, rationale_hy, category, display_order, points, is_active, topic_id')
      .eq('is_active', true)
      .order('display_order', { ascending: true });

    if (useTopicSystem) {
      // Topic-based: filter by topic_id only (works across all subjects/test_ids)
      query = query.in('topic_id', topicIds);
    } else {
      // Legacy: filter by test_id, optionally by category
      query = query.eq('test_id', testId);
      if (categoryFilter) {
        query = query.eq('category', categoryFilter);
      }
    }

    // Raise the page limit so large question banks (300+) are never silently truncated.
    // PostgREST defaults to 1000; we set 5000 to accommodate all current subjects combined.
    query = query.limit(5000);

    const { data: questions, error } = await withTimeout(
      query,
      12000,
      'Loading questions timed out'
    );
    if (error) throw error;
    
    if (!questions || questions.length === 0) {
      throw new Error('No questions found for the selected topics');
    }
    
    try {
      setLoadingStatus('Analyzing past attempts...');
      const studentId = getOwnerId();
      let historyMap = {}; // question_id -> timestamp (ms)

      if (studentId && db) {
        // Fetch student's test attempts to prioritize least-used questions
        const { data: attempts, error: historyError } = await db
          .from('test_attempts')
          .select('created_at, answers')
          .eq('student_id', studentId);
        
        if (!historyError && attempts) {
          attempts.forEach(attempt => {
            const time = new Date(attempt.created_at).getTime();
            if (Array.isArray(attempt.answers)) {
              attempt.answers.forEach(ans => {
                if (ans && ans.question_id) {
                  // Keep the latest time the question was seen
                  if (!historyMap[ans.question_id] || time > historyMap[ans.question_id]) {
                    historyMap[ans.question_id] = time;
                  }
                }
              });
            }
          });
        }
      }

      // Sort all questions based on last seen time (oldest/unseen first)
      // Unseen questions (time 0) will bubble to the top.
      questions.sort((a, b) => {
        const timeA = historyMap[a.id] || 0;
        const timeB = historyMap[b.id] || 0;
        return timeA - timeB;
      });
    } catch (e) {
      console.warn('Could not fetch question history, ignoring:', e);
    }
    
    // Apply question count limit AFTER fetching, distributing evenly across topics
    let finalQuestions = [];
    if (questionCount && questionCount > 0 && questions.length > questionCount) {
      if (useTopicSystem) {
        // Group by topic_id (already sorted oldest-first within groups)
        const groups = {};
        questions.forEach(q => {
          if (!groups[q.topic_id]) groups[q.topic_id] = [];
          groups[q.topic_id].push(q);
        });

        const topicKeys = Object.keys(groups);
        // Randomize topics so remainder doesn't always go to the same first topic
        topicKeys.sort(() => Math.random() - 0.5);
        
        let remainingToPick = questionCount;
        
        while (remainingToPick > 0) {
          const activeTopics = topicKeys.filter(t => groups[t].length > 0);
          if (activeTopics.length === 0) break; // Used all available questions
          
          let share = Math.floor(remainingToPick / activeTopics.length);
          if (share === 0) share = 1;
          
          for (let i = 0; i < activeTopics.length && remainingToPick > 0; i++) {
            const tid = activeTopics[i];
            const toTake = Math.min(share, groups[tid].length, remainingToPick);
            finalQuestions.push(...groups[tid].splice(0, toTake));
            remainingToPick -= toTake;
          }
        }
      } else {
        // Legacy: Just take oldest N
        finalQuestions = questions.slice(0, questionCount);
      }
    } else {
      finalQuestions = questions;
    }
    
    console.log(`✓ Loaded ${finalQuestions.length} questions${topicIds ? ` from ${topicIds.length} topic(s)` : categoryFilter ? ` from ${categoryFilter}` : ''}${questionCount ? ` (limited to ${questionCount})` : ''}`);
    
    // Parse JSON fields (options, correct_answers)
    const parsedQuestions = finalQuestions.map(q => ({
      id: q.id,
      stem: q.question_stem,
      stem_hy: q.question_stem_hy || null,
      options: q.options, // Already parsed by Supabase
      options_hy: q.options_hy || null, // Armenian options (same id keys, translated text)
      correct: q.correct_answers, // Already parsed by Supabase
      multi: q.is_multiple_choice,
      rationale: q.rationale,
      rationale_hy: q.rationale_hy || null,
      category: q.category,
      points: q.points || 1,
      displayOrder: q.display_order
    }));
    
    return parsedQuestions;
  } catch (error) {
    console.error('Error loading questions:', error);
    showToast('Failed to load questions', 'error');
    const friendly = isNetworkFailure(error)
      ? 'Network blocked the question request (TLS/SSL). Try disabling VPN/ad blockers or use Chrome.'
      : (error.message || 'Unknown error');
    error.message = `Question load failed: ${friendly}`;
    throw error;
  }
}

async function loadAvailableCategories(testId) {
  try {
    const { data: questions, error } = await db
      .from('test_questions')
      .select('category')
      .eq('test_id', testId)
      .eq('is_active', true);
    
    if (error) throw error;
    
    // Get unique categories
    const categories = [...new Set(questions.map(q => q.category).filter(Boolean))];
    return categories.sort();
  } catch (error) {
    console.error('Error loading categories:', error);
    return [];
  }
}

async function saveTestAttempt(results) {
  try {
    const attemptData = {
      test_id: TEST_CONFIG.testId,
      student_id: getOwnerId(),  // always the authenticated owner
      session_id: testState.sessionId,
      started_at: new Date(testState.startTime).toISOString(),
      completed_at: new Date(testState.endTime).toISOString(),
      time_taken_seconds: Math.floor((testState.endTime - testState.startTime) / 1000),
      score_percent: results.scorePercent,
      correct_count: results.correct,
      incorrect_count: results.incorrect,
      skipped_count: results.skipped,
      total_questions: results.totalQuestions,
      passed: results.passed,
      answers: results.details.map(d => ({
        question_id: d.question.id,
        user_answer: d.userAnswer,
        is_correct: d.isCorrect,
        is_flagged: testState.flagged.has(d.question.id)
      }))
    };
    
    const { data, error } = await db
      .from('test_attempts')
      .insert(attemptData)
      .select()
      .single();
    
    if (error) throw error;
    
    console.log('✓ Test attempt saved:', data.id);
    return data;
  } catch (error) {
    console.error('Error saving test attempt:', error);
    showToast('Warning: Failed to save results to database', 'warning');
    // Don't throw - allow user to still see results and download
    return null;
  }
}

// ============================================
// UTILITY FUNCTIONS
// ============================================

function shuffleArray(array, seed) {
  // Seeded shuffle for consistency across page reloads
  const arr = [...array];
  let currentSeed = seed;
  for (let i = arr.length - 1; i > 0; i--) {
    currentSeed = (currentSeed * 9301 + 49297) % 233280;
    const j = Math.floor((currentSeed / 233280) * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

/**
 * Derives a deterministic shuffle seed from the test ID and selected topic IDs.
 * Every device that opens the same test with the same topics will produce the
 * EXACT same seed → identical question order and answer choice order.
 * Individual student sessions remain independent (separate sessionId, answers, timer).
 *
 * Algorithm: simple djb2-style hash over the combined key string.
 */
function deriveShuffleSeed(testId, topicIds) {
  // Sort topic IDs so selection order doesn't matter
  const key = [testId, ...(topicIds || []).slice().sort()].join('|');
  let hash = 5381;
  for (let i = 0; i < key.length; i++) {
    hash = ((hash << 5) + hash) ^ key.charCodeAt(i);
    hash = hash & 0x7fffffff; // Keep positive 31-bit integer
  }
  // Ensure it's in the range the seeded shuffle expects (>0)
  return (hash % 999983) + 1; // 999983 is prime, result is 1..999983
}

function generateSessionId() {
  return 'test_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

// ============================================
// BILINGUAL SNAPSHOT
// ============================================
// Called ONCE at session creation after shuffling is applied.
// Produces a permanent, frozen representation of the test in both languages.
// The snapshot is stored in testState, localStorage, and (for teacher mode)
// in the teacher_sessions DB row so every device always gets the exact same
// question text and order regardless of when they join or what language they pick.
//
// Key invariant: correct_answers (option id letters a/b/c/d) are ALWAYS in English
// keys and are shared across both language snapshots — correct checking never changes.

function buildBilingualSnapshot(shuffledQuestions) {
  // EN snapshot — canonical source of truth for IDs, order, correct answers
  const en = shuffledQuestions.map(q => ({
    id: q.id,
    stem: q.stem,
    options: q.options,       // [{id:'a',text:'…'},…]  (already shuffled)
    correct: q.correct,       // e.g. ['b']
    multi: q.multi,
    rationale: q.rationale || '',
    category: q.category,
    points: q.points || 1
  }));

  // Fast-path: if no question has any Armenian content at all, skip the HY
  // build loop entirely (saves iterating 300+ questions twice for EN-only tests).
  const hasAnyHyData = shuffledQuestions.some(q => q.stem_hy || q.options_hy);
  if (!hasAnyHyData) {
    return { en, hy: null };
  }

  // HY snapshot — same structure but with Armenian text where available.
  // Falls back to English when a question or option lacks a translation.
  const hy = shuffledQuestions.map(q => {
    // Re-order options_hy to match the already-shuffled English option order
    let hyOptions = null;
    if (q.options_hy && Array.isArray(q.options_hy) && q.options_hy.length > 0) {
      // Build a lookup {id → hy_text} so we can follow the shuffled EN order
      const hyLookup = {};
      q.options_hy.forEach(o => { hyLookup[String(o.id)] = o.text; });
      // Follow the same shuffled order as EN options
      hyOptions = q.options.map(enOpt => ({
        id: enOpt.id,
        text: hyLookup[String(enOpt.id)] || enOpt.text // fallback to EN text
      }));
    }
    return {
      id: q.id,
      stem: q.stem_hy || null,         // null means "not translated yet"
      options: hyOptions || q.options,  // fallback to EN options if no HY version
      correct: q.correct,               // always EN letter keys — language-agnostic
      multi: q.multi,
      rationale: q.rationale_hy || q.rationale || '',
      category: q.category,
      points: q.points || 1,
      _hasTranslation: !!(q.stem_hy && hyOptions)
    };
  });

  // Check if at least one question has a full Armenian translation
  const hasAnyHy = hy.some(q => q._hasTranslation);

  return { en, hy: hasAnyHy ? hy : null };
}

// Apply the active language to the UI language picker
function applyLanguagePicker() {
  const picker = document.getElementById('langPicker');
  if (picker) picker.style.display = 'flex';

  const btnEn = document.getElementById('langBtnEn');
  const btnHy = document.getElementById('langBtnHy');
  if (!btnEn || !btnHy) return;

  const hasHy = !!(testState.snapshot && testState.snapshot.hy);

  // Reset disabled state first
  btnHy.disabled = false;
  btnHy.style.opacity = '';
  btnHy.style.cursor = '';
  btnHy.title = 'Հայերեն';

  if (!hasHy) {
    // No Armenian translations — disable the button and show a tooltip
    btnHy.disabled = true;
    btnHy.title = 'Հայերեն թարգմանություն դեռ հասանելի չէ';
    btnHy.style.opacity = '0.35';
    btnHy.style.cursor = 'not-allowed';
  }

  if (testState.language === 'hy' && hasHy) {
    btnHy.classList.add('active');
    btnEn.classList.remove('active');
  } else {
    btnEn.classList.add('active');
    btnHy.classList.remove('active');
  }
}

// Language switch — called by the picker buttons
function switchLanguage(lang) {
  if (lang === testState.language) return;

  // Guard: if no Armenian snapshot, show a friendly alert and bail
  if (lang === 'hy' && !(testState.snapshot && testState.snapshot.hy)) {
    showNoTranslationAlert();
    return;
  }

  testState.language = lang;
  localStorage.setItem('acnhs_test_lang', lang);

  // Update picker UI
  const btnEn = document.getElementById('langBtnEn');
  const btnHy = document.getElementById('langBtnHy');
  if (btnEn) btnEn.classList.toggle('active', lang === 'en');
  if (btnHy) btnHy.classList.toggle('active', lang === 'hy');

  // Re-render current question in new language
  renderQuestion();
}

// Friendly alert when Armenian translations are not yet added to this test
function showNoTranslationAlert() {
  // Remove any existing alert first
  const existing = document.getElementById('noHyAlertOverlay');
  if (existing) existing.remove();

  const overlay = document.createElement('div');
  overlay.id = 'noHyAlertOverlay';
  overlay.style.cssText = `
    position:fixed;inset:0;z-index:9999;
    display:flex;align-items:center;justify-content:center;
    background:rgba(2,6,23,0.82);padding:20px;
  `;

  overlay.innerHTML = `
    <div style="
      background:#0f172a;border:2px solid rgba(201,168,76,0.45);
      border-radius:20px;padding:40px 36px;max-width:420px;width:100%;
      text-align:center;box-shadow:0 24px 64px rgba(0,0,0,0.55);
      animation:noHyPop 0.2s ease;
    ">
      <div style="display:flex;align-items:center;justify-content:center;width:64px;height:64px;border-radius:16px;background:rgba(201,168,76,0.10);border:1.5px solid rgba(201,168,76,0.3);margin:0 auto 16px;">
        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#c9a84c" stroke-width="1.5"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
      </div>
      <h2 style="
        font-family:'Playfair Display',serif;font-size:24px;font-weight:800;
        color:#f8fafc;margin-bottom:12px;letter-spacing:-0.3px;
      ">Oops! No Translation Yet</h2>
      <p style="
        color:#94a3b8;font-size:15px;line-height:1.65;margin-bottom:28px;
      ">
        Armenian translations haven't been added to this test yet.<br>
        <span style="color:#c9a84c;font-weight:600;">Contact your instructor</span>
        to request them.
      </p>
      <button onclick="document.getElementById('noHyAlertOverlay').remove()" style="
        background:linear-gradient(135deg,#c9a84c,#d4b56a);
        color:#020617;border:none;padding:12px 36px;
        border-radius:10px;font-weight:800;font-size:15px;
        cursor:pointer;letter-spacing:0.3px;
        box-shadow:0 4px 16px rgba(201,168,76,0.3);
        transition:transform 0.15s;
      "
      onmouseover="this.style.transform='translateY(-2px)'"
      onmouseout="this.style.transform='translateY(0)'">
        Got it
      </button>
    </div>
    <style>
      @keyframes noHyPop {
        from { opacity:0; transform:scale(0.92); }
        to   { opacity:1; transform:scale(1); }
      }
    </style>
  `;

  // Close on backdrop click
  overlay.addEventListener('click', e => {
    if (e.target === overlay) overlay.remove();
  });

  document.body.appendChild(overlay);
}

let saveTimer     = null;
let autoSaveTimer = null; // cloud auto-save debounce

// ============================================================
// AUTO-SAVE TO CLOUD  (every answer → debounced 5 s → Supabase)
// ============================================================
// Keeps a live is_in_progress=true row in saved_test_sessions so any
// device logged in as the same owner+role can resume the active session.
// ============================================================
async function autoSaveToCloud() {
  if (!testState.sessionId || !testState.questions || testState.questions.length === 0) return;
  if (!db) { if (!initializeSupabase()) return; }
  if (window.location.protocol === 'file:') return;
  const ownerId = getOwnerId();
  if (!ownerId || ownerId.startsWith('anon_')) return;

  try {
    refreshSupabaseOwner();

    const answeredCount  = Object.keys(testState.answers).length;
    const totalQuestions = testState.questions.length;

    const autoName = (() => {
      const topics = TEST_CONFIG.selectedTopicNames && TEST_CONFIG.selectedTopicNames.length
        ? TEST_CONFIG.selectedTopicNames.slice(0, 2).join(', ')
        : 'Test';
      const dt = new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
      return `${topics} — ${dt}`;
    })();

    const payload = {
      ...(testState.autoSaveDbId ? { id: testState.autoSaveDbId } : {}),
      session_name:           autoName,
      student_id:             ownerId,
      user_role:              SESSION_ROLE.userRole || 'student',
      test_id:                TEST_CONFIG.testId || '',
      session_id:             testState.sessionId,
      shuffle_seed:           testState.shuffleSeed || null,
      current_question_index: testState.currentIndex,
      answers:                testState.answers,
      answer_status:          testState.answerStatus || {},
      flagged_questions:      Array.from(testState.flagged),
      questions:              testState.questions.map(q => ({ id: q.id, topic_id: q.topic_id || null })),
      test_config: {
        testId:             TEST_CONFIG.testId,
        selectedTopicIds:   TEST_CONFIG.selectedTopicIds   || [],
        selectedTopicNames: TEST_CONFIG.selectedTopicNames || [],
        categoryFilter:     TEST_CONFIG.categoryFilter     || null,
        questionCount:      TEST_CONFIG.questionCount      || null,
        shuffleQuestions:   TEST_CONFIG.shuffleQuestions,
        shuffleOptions:     TEST_CONFIG.shuffleOptions
      },
      start_time:             new Date(testState.startTime).toISOString(),
      total_questions:        totalQuestions,
      answered_questions:     answeredCount,
      progress_percent:       Math.round((answeredCount / totalQuestions) * 100),
      is_in_progress:         true,
      last_auto_saved_at:     new Date().toISOString(),
      session_snapshot_en:    null,
      session_snapshot_hy:    null
    };

    const { data, error } = await db
      .from('saved_test_sessions')
      .upsert([payload], { onConflict: 'id' })
      .select('id')
      .single();

    if (!error && data && data.id) {
      testState.autoSaveDbId = data.id;
    }
    if (error) {
      const msg = String(error.message || '');
      if (!msg.includes('saved_test_sessions') && error.code !== '42P01') {
        console.warn('[autoSave] cloud save skipped:', msg);
      }
    }
  } catch (e) {
    console.warn('[autoSave] exception:', e);
  }
}

function saveToLocalStorage() {
  // Debounce to avoid repeated sync writes during rapid interactions
  if (saveTimer) clearTimeout(saveTimer);
  saveTimer = setTimeout(() => {
    const saveData = {
      sessionId: testState.sessionId,
      shuffleSeed: testState.shuffleSeed,
      currentIndex: testState.currentIndex,
      answers: testState.answers,
      answerStatus: {}, // Do NOT persist revealed answers — students re-check on resume
      flagged: Array.from(testState.flagged),
      startTime: testState.startTime,
      questionIds: testState.questions.map(q => q.id),
      testId: TEST_CONFIG.testId,
      selectedTopicIds: TEST_CONFIG.selectedTopicIds || [],
      selectedTopicNames: TEST_CONFIG.selectedTopicNames || []
    };
    // Key is scoped per user so in-progress sessions never bleed between accounts
    try {
      localStorage.setItem('acnhs_test_session_' + getOwnerId(), JSON.stringify(saveData));
    } catch (e) {
      console.warn('Failed to save session to localStorage, possibly quota exceeded:', e);
    }

    // Cloud auto-save — debounced a further 5 s to avoid hammering Supabase
    if (autoSaveTimer) clearTimeout(autoSaveTimer);
    autoSaveTimer = setTimeout(autoSaveToCloud, 5000);
  }, 120);
}

function loadFromLocalStorage() {
  const saved = localStorage.getItem('acnhs_test_session_' + getOwnerId());
  if (saved) {
    try {
      return JSON.parse(saved);
    } catch (e) {
      return null;
    }
  }
  return null;
}

function clearLocalStorage() {
  localStorage.removeItem('acnhs_test_session_' + getOwnerId());
}

function formatTime(seconds) {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

function showToast(message, type = 'info') {
  if (type === 'error') console.error('[Toast]', message);
  else console.log('[Toast]', type, message);

  // Remove any existing toast
  const existing = document.getElementById('_acnhs_toast');
  if (existing) existing.remove();

  const colors = {
    success: { bg: 'rgba(7,27,48,0.97)', border: '#10b981', icon: '✓', label: 'SUCCESS', accent: '#10b981' },
    error:   { bg: 'rgba(7,27,48,0.97)', border: '#ef4444', icon: '✕', label: 'ERROR',   accent: '#ef4444' },
    warning: { bg: 'rgba(7,27,48,0.97)', border: '#f59e0b', icon: '!', label: 'NOTICE',  accent: '#f59e0b' },
    info:    { bg: 'rgba(7,27,48,0.97)', border: '#c9a84c', icon: 'i', label: 'INFO',    accent: '#c9a84c' }
  };
  const c = colors[type] || colors.info;

  const toast = document.createElement('div');
  toast.id = '_acnhs_toast';
  toast.style.cssText = [
    'position:fixed', 'bottom:24px', 'left:50%', 'transform:translateX(-50%) translateY(20px)',
    'z-index:99999', 'min-width:300px', 'max-width:480px',
    `background:${c.bg}`, `border:1.5px solid ${c.border}`,
    'border-radius:12px', 'padding:14px 18px',
    'display:flex', 'align-items:flex-start', 'gap:12px',
    'box-shadow:0 8px 32px rgba(0,0,0,0.5)',
    'opacity:0', 'transition:opacity 0.25s ease, transform 0.25s ease',
    'font-family:Inter,sans-serif'
  ].join(';');

  toast.innerHTML = `
    <div style="flex-shrink:0;width:28px;height:28px;border-radius:50%;background:${c.accent}22;border:1.5px solid ${c.accent};display:flex;align-items:center;justify-content:center;font-weight:700;color:${c.accent};font-size:13px">${c.icon}</div>
    <div style="flex:1;min-width:0">
      <div style="font-size:9px;font-weight:800;letter-spacing:1.5px;color:${c.accent};text-transform:uppercase;margin-bottom:3px">${c.label}</div>
      <div style="font-size:13px;color:#e2e8f0;line-height:1.45;word-break:break-word">${message}</div>
    </div>
    <button onclick="this.parentElement.remove()" style="flex-shrink:0;background:none;border:none;color:#64748b;cursor:pointer;font-size:16px;line-height:1;padding:2px 4px" aria-label="Dismiss">&times;</button>
  `;

  document.body.appendChild(toast);
  requestAnimationFrame(() => {
    toast.style.opacity = '1';
    toast.style.transform = 'translateX(-50%) translateY(0)';
  });

  const duration = type === 'error' ? 7000 : type === 'warning' ? 5000 : 4000;
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(-50%) translateY(20px)';
    setTimeout(() => toast.remove(), 300);
  }, duration);
}

// ============================================
// TEST INITIALIZATION
// ============================================

// ============================================
// SUBJECT & TOPIC SELECTION (MODAL VERSION)
// ============================================

let selectedSubjects = new Set();
let selectedTopics = new Set();
let availableTopics = [];
let allSubjects = [];


// ─── Subject icon: returns an SVG string keyed on subject name ────────────────
function getSubjectIcon(name) {
  const n = (name || '').toLowerCase();
  // Anatomy / body systems
  if (/anatomy|musculoskeletal|skeletal|bone|joint|muscle/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 20V6a2 2 0 0 0-2-2H8a2 2 0 0 0-2 2v14"/><path d="M2 20h20"/><path d="M14 12v.01"/></svg>`;
  if (/cardiovascular|cardiac|heart/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>`;
  if (/neurol|brain|cranial|nerve|neuro/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9.5 2A2.5 2.5 0 0 1 12 4.5v15a2.5 2.5 0 0 1-4.96-.46 2.5 2.5 0 0 1-2.96-3.08 3 3 0 0 1-.34-5.58 2.5 2.5 0 0 1 1.32-4.24 2.5 2.5 0 0 1 1.98-3A2.5 2.5 0 0 1 9.5 2Z"/><path d="M14.5 2A2.5 2.5 0 0 0 12 4.5v15a2.5 2.5 0 0 0 4.96-.46 2.5 2.5 0 0 0 2.96-3.08 3 3 0 0 0 .34-5.58 2.5 2.5 0 0 0-1.32-4.24 2.5 2.5 0 0 0-1.98-3A2.5 2.5 0 0 0 14.5 2Z"/></svg>`;
  if (/respiratory|pulmon|lung/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22V12M12 12C12 7 8 4 4 6c0 5 2 9 8 10"/><path d="M12 12c0-5 4-8 8-6 0 5-2 9-8 10"/></svg>`;
  if (/gastro|digestive|hepatic|liver|intestin|bowel/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a5 5 0 0 1 5 5v3a5 5 0 0 1-5 5 5 5 0 0 1-5-5V7a5 5 0 0 1 5-5Z"/><path d="M7 14v1a5 5 0 0 0 10 0v-1"/></svg>`;
  if (/endocrine|thyroid|diabetes|hormonal/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>`;
  if (/renal|kidney|urin|nephro/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12c0-7 14-7 14 0v6a4 4 0 0 1-4 4h-2a4 4 0 0 1-4-4V8"/><path d="M9 17v.01"/><path d="M15 17v.01"/></svg>`;
  if (/mental|psych|behav|psychiatr/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"/><path d="M12 8v4l3 3"/></svg>`;
  if (/maternal|obstetric|gynec|reproductive|pregnan/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22V12M8 22V18a4 4 0 0 1 8 0v4"/><circle cx="12" cy="8" r="4"/></svg>`;
  if (/pediatric|child|neonat/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>`;
  if (/pharmacol|drug|medication|pharm/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z"/><line x1="8.5" y1="8.5" x2="15.5" y2="15.5"/></svg>`;
  if (/oncol|cancer|tumor/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/></svg>`;
  if (/medical.surgical|surgical|periop|surgery/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>`;
  if (/immunol|autoimmun|infectious|infect/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>`;
  if (/fluid|electrolyte/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"/></svg>`;
  if (/eye|ophthalm|ocular|vision|eent/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></svg>`;
  if (/skin|burn|dermat|integument|wound/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="4"/><path d="M3 9h18M3 15h18M9 3v18"/></svg>`;
  if (/terminol|medical term/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7V4h16v3"/><path d="M9 20h6"/><path d="M12 4v16"/></svg>`;
  if (/fundamentals|basic|nursing principle/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>`;
  if (/delegat|leadership|management/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>`;
  if (/family|community|public health/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>`;
  if (/informed consent|ethics|legal/.test(n))
    return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>`;
  // Default — generic list/document icon
  return `<svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>`;
}

async function showSubjectSelection() {
  const btn = document.getElementById('initialStartBtn');
  btn.innerHTML = '<div class="loading" style="width:20px;height:20px"></div> Loading...';
  btn.disabled = true;

  try {
    const urlParams = new URLSearchParams(window.location.search);
    const testId = urlParams.get('test_id') || '00000000-0000-0000-0000-000000000001';
    TEST_CONFIG.testId = testId;

    if (!db) {
      if (!initializeSupabase()) throw new Error('Cannot connect to database');
    }

    await loadTestConfiguration(testId);

    // Load subjects + topics — cached after first fetch so reopening the modal is instant.
    let subjects, allTopicsRaw;
    if (window._cachedSubjects && window._cachedTopics) {
      subjects     = window._cachedSubjects;
      allTopicsRaw = window._cachedTopics;
      console.log('[SubjectModal] served subjects/topics from cache');
    } else {
      const [
        { data: subjectsData, error: subjectError },
        { data: topicsData,   error: topicError }
      ] = await Promise.all([
        db.from('test_subjects').select('*').eq('is_active', true).order('display_order'),
        db.from('test_topics').select('*').eq('status', 'published').order('subject_id').order('display_order')
      ]);
      if (subjectError) throw subjectError;
      subjects     = subjectsData;
      allTopicsRaw = topicsData;
      window._cachedSubjects = subjects;
      window._cachedTopics   = allTopicsRaw;
    }

    if (!subjects || subjects.length === 0) throw new Error('No subjects available for this test');

    // Build a map: topic_id → question count
    // Use a single Supabase RPC call to get counts grouped by topic_id in one round-trip.
    // Falls back to a lightweight select if the RPC doesn't exist yet.
    // Results are cached on the window object so reopening the modal is instant.
    let topicQuestionCounts = window._cachedTopicCounts || null;
    if (!topicQuestionCounts) {
      topicQuestionCounts = {};
      try {
        // Try RPC first (most efficient — single query, server-side GROUP BY)
        const { data: rpcRows, error: rpcError } = await db.rpc('get_topic_question_counts');
        if (!rpcError && rpcRows) {
          rpcRows.forEach(row => {
            if (row.topic_id) topicQuestionCounts[row.topic_id] = row.question_count;
          });
          console.log(`[Topic Counts] loaded via RPC: ${Object.keys(topicQuestionCounts).length} topics`);
        } else {
          throw rpcError || new Error('RPC unavailable');
        }
      } catch (rpcFallbackErr) {
        // Fallback: fetch only topic_id column with limit 5000 (single request, no loop)
        console.warn('[Topic Counts] RPC not available, using fallback single query');
        const { data: allRows, error: fallbackError } = await db
          .from('test_questions')
          .select('topic_id')
          .eq('is_active', true)
          .limit(5000);
        if (!fallbackError && allRows) {
          allRows.forEach(row => {
            if (row.topic_id) {
              topicQuestionCounts[row.topic_id] = (topicQuestionCounts[row.topic_id] || 0) + 1;
            }
          });
          console.log(`[Topic Counts] loaded via fallback: ${Object.keys(topicQuestionCounts).length} topics`);
        }
      }
      // Cache for this session so reopening the modal is instant
      window._cachedTopicCounts = topicQuestionCounts;
    } else {
      console.log(`[Topic Counts] served from cache: ${Object.keys(topicQuestionCounts).length} topics`);
    }

    allSubjects = subjects;
    availableTopics = allTopicsRaw || [];
    selectedSubjects.clear();
    selectedTopics.clear();

    // Group topics by subject_id
    const topicsBySubject = {};
    availableTopics.forEach(t => {
      if (!topicsBySubject[t.subject_id]) topicsBySubject[t.subject_id] = [];
      topicsBySubject[t.subject_id].push(t);
    });

    const subjectList = document.getElementById('subjectList');
    if (!subjectList) throw new Error('Subject list element not found');

    subjectList.innerHTML = subjects.map((subject, idx) => {
      const topics = topicsBySubject[subject.id] || [];
      const hasTopics = topics.length > 0;
      const iconSvg = getSubjectIcon(subject.name);

      const topicRows = topics.map(topic => {
        const qCount = topicQuestionCounts[topic.id] || 0;
        return `
        <div class="topic-row" id="topic-row-${topic.id}"
             data-topic-name="${topic.name.toLowerCase()}"
             onclick="toggleTopicInline('${topic.id}', '${subject.id}')">
          <input type="checkbox" id="topic-cb-${topic.id}"
            onclick="event.stopPropagation();toggleTopicInline('${topic.id}','${subject.id}')">
          <span class="topic-row-name">${topic.name}</span>
          ${qCount > 0 ? `<span style="margin-left:auto;flex-shrink:0;font-size:10px;font-weight:700;color:#94a3b8;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.10);border-radius:5px;padding:2px 7px;letter-spacing:0.3px">${qCount} Question${qCount !== 1 ? 's' : ''}</span>` : ''}
        </div>
      `;
      }).join('');

      return `
        <div class="subject-row" id="subject-row-${subject.id}"
             data-subject-name="${subject.name.toLowerCase()}"
             data-topic-names="${topics.map(t=>t.name.toLowerCase()).join('|')}">
          <div class="subject-header" onclick="toggleSubject('${subject.id}')">
            <svg class="subject-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <polyline points="9 18 15 12 9 6"/>
            </svg>
            <input type="checkbox" id="subject-cb-${subject.id}"
              onclick="event.stopPropagation(); handleSubjectCheckbox('${subject.id}', this.checked)"
              style="width:18px;height:18px;cursor:pointer;accent-color:var(--gold-primary);flex-shrink:0">
            <div class="subject-icon-pill">${iconSvg}</div>
            <div class="subject-info">
              <div class="subject-info-name">${subject.name}</div>
              ${subject.description ? `<div class="subject-info-meta">${subject.description}</div>` : ''}
            </div>
            ${hasTopics ? `
              <span class="subject-topic-count" id="subject-topic-count-${subject.id}">
                ${topics.length} topic${topics.length !== 1 ? 's' : ''}
              </span>
            ` : ''}
          </div>
          ${hasTopics ? `
            <div class="subject-topics-list" id="topics-list-${subject.id}">
              <div class="subject-topics-select-all" onclick="selectAllTopicsForSubject('${subject.id}', true)">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
                Select all topics
                <span onclick="event.stopPropagation();selectAllTopicsForSubject('${subject.id}', false)"
                  style="margin-left:auto;color:#94a3b8;font-size:10px;font-weight:700;text-transform:uppercase;padding:3px 10px;border-radius:5px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.10);cursor:pointer;letter-spacing:0.4px"
                  onmouseover="this.style.background='rgba(239,68,68,0.15)';this.style.color='#fca5a5'"
                  onmouseout="this.style.background='rgba(255,255,255,0.07)';this.style.color='#94a3b8'">
                  Deselect all
                </span>
              </div>
              ${topicRows}
            </div>
          ` : ''}
        </div>
      `;
    }).join('');

    document.getElementById('subjectModal').classList.remove('hidden');
    btn.innerHTML = 'Start Test';
    btn.disabled = false;
    updateSubjectStats();

  } catch (error) {
    console.error('Error loading subjects:', error);
    btn.innerHTML = 'Start Test';
    btn.disabled = false;
    showToast(error.message || 'Failed to load subjects', 'error');
  }
}

// Toggle the expand/collapse of a subject's topic list.
// Only auto-selects all topics if the subject has NO selections yet.
function toggleSubject(subjectId) {
  const row = document.getElementById(`subject-row-${subjectId}`);
  const cb  = document.getElementById(`subject-cb-${subjectId}`);
  if (!row) return;

  const isExpanding = !row.classList.contains('expanded');
  row.classList.toggle('expanded', isExpanding);

  // Auto-check the subject when user expands it — but ONLY if nothing is selected yet
  if (isExpanding && cb && !cb.checked && !cb.indeterminate) {
    const subjectTopics = availableTopics.filter(t => t.subject_id === subjectId);
    const anySelected = subjectTopics.some(t => selectedTopics.has(t.id));
    if (!anySelected) {
      cb.checked = true;
      handleSubjectCheckbox(subjectId, true);
    }
  }
}

// Called when the subject checkbox is directly clicked
function handleSubjectCheckbox(subjectId, checked) {
  const row = document.getElementById(`subject-row-${subjectId}`);
  if (!row) return;

  if (checked) {
    selectedSubjects.add(subjectId);
    row.classList.add('selected-parent');
    // Auto-expand
    row.classList.add('expanded');
    // Select all topics for this subject
    selectAllTopicsForSubject(subjectId, true);
  } else {
    selectedSubjects.delete(subjectId);
    row.classList.remove('selected-parent');
    // Deselect all topics
    selectAllTopicsForSubject(subjectId, false);
  }
  updateSubjectStats();
}

// Select or deselect all topics belonging to a subject
function selectAllTopicsForSubject(subjectId, select) {
  const subjectTopics = availableTopics.filter(t => t.subject_id === subjectId);
  subjectTopics.forEach(topic => {
    const cb  = document.getElementById(`topic-cb-${topic.id}`);
    const row = document.getElementById(`topic-row-${topic.id}`);
    if (select) {
      selectedTopics.add(topic.id);
      if (cb)  cb.checked = true;
      if (row) row.classList.add('selected');
    } else {
      selectedTopics.delete(topic.id);
      if (cb)  cb.checked = false;
      if (row) row.classList.remove('selected');
    }
  });
  syncSubjectCheckboxState(subjectId);
  updateSubjectStats();
}

// Toggle a single topic checkbox and sync the parent subject state
function toggleTopicInline(topicId, subjectId) {
  const cb  = document.getElementById(`topic-cb-${topicId}`);
  const row = document.getElementById(`topic-row-${topicId}`);
  if (!cb) return;

  cb.checked = !cb.checked;
  if (cb.checked) {
    selectedTopics.add(topicId);
    if (row) row.classList.add('selected');
  } else {
    selectedTopics.delete(topicId);
    if (row) row.classList.remove('selected');
  }
  syncSubjectCheckboxState(subjectId);
  updateSubjectStats();
}

// Sync the parent subject checkbox based on how many of its topics are selected
function syncSubjectCheckboxState(subjectId) {
  const subjectTopics = availableTopics.filter(t => t.subject_id === subjectId);
  const checkedCount  = subjectTopics.filter(t => selectedTopics.has(t.id)).length;
  const cb   = document.getElementById(`subject-cb-${subjectId}`);
  const row  = document.getElementById(`subject-row-${subjectId}`);
  if (!cb) return;

  if (checkedCount === 0) {
    cb.checked = false;
    cb.indeterminate = false;
    selectedSubjects.delete(subjectId);
    if (row) row.classList.remove('selected-parent');
  } else if (checkedCount === subjectTopics.length) {
    cb.checked = true;
    cb.indeterminate = false;
    selectedSubjects.add(subjectId);
    if (row) row.classList.add('selected-parent');
  } else {
    cb.checked = false;
    cb.indeterminate = true; // Some selected — indeterminate state
    selectedSubjects.add(subjectId);
    if (row) row.classList.add('selected-parent');
  }

  // Update the collapsed topic count badge
  const countEl = document.getElementById(`subject-topic-count-${subjectId}`);
  if (countEl) {
    const total = subjectTopics.length;
    if (checkedCount === 0) {
      countEl.textContent = `${total} topic${total !== 1 ? 's' : ''}`;
      countEl.style.color = '#64748b';
    } else {
      countEl.textContent = `${checkedCount} / ${total} selected`;
      countEl.style.color = 'var(--gold-primary, #c9a84c)';
      countEl.style.fontWeight = '700';
    }
  }
}

function updateSubjectStats() {
  const sCount = selectedSubjects.size;
  const tCount = selectedTopics.size;

  // Hidden spans (kept for any other JS that reads them)
  document.getElementById('selectedSubjectsCount').textContent = sCount;
  document.getElementById('selectedTopicsCount').textContent   = tCount;

  // Footer live counters
  const footerS = document.getElementById('footerSubjectsCount');
  const footerT = document.getElementById('footerTopicsCount');
  const footerQ = document.getElementById('footerQuestionsCount');
  if (footerS) footerS.textContent = sCount;
  if (footerT) footerT.textContent = tCount;

  const continueBtn = document.getElementById('continueToTopicsBtn');
  const hasSelection = tCount > 0 || sCount > 0;
  continueBtn.disabled      = !hasSelection;
  continueBtn.style.opacity = hasSelection ? '1' : '0.5';
  continueBtn.style.cursor  = hasSelection ? 'pointer' : 'not-allowed';

  // Live question count
  if (tCount > 0) {
    db.from('test_questions')
      .select('*', { count: 'exact', head: true })
      .eq('is_active', true)
      .in('topic_id', Array.from(selectedTopics))
      .then(({ count, error }) => {
        const val = (!error && count != null) ? count : '—';
        document.getElementById('totalQuestionsCount').textContent = val;
        if (footerQ) footerQ.textContent = val;
      });
  } else {
    document.getElementById('totalQuestionsCount').textContent = '—';
    if (footerQ) footerQ.textContent = '—';
  }
}

// "Start Test →" button in the subject modal
async function startFromSubjectModal() {
  if (selectedTopics.size === 0 && selectedSubjects.size === 0) {
    showToast('Please select at least one subject or topic', 'warning');
    return;
  }

  // User is actively starting a NEW test based on the current modal selection.
  // Don't allow a previously-saved session (possibly for different topics like Cranial Nerves)
  // to bleed into this run.
  clearLocalStorage();

  // If subject selected but no topics explicitly picked, auto-select all its topics
  selectedSubjects.forEach(subjectId => {
    const subjectTopics = availableTopics.filter(t => t.subject_id === subjectId);
    if (subjectTopics.length > 0 && !subjectTopics.some(t => selectedTopics.has(t.id))) {
      subjectTopics.forEach(t => selectedTopics.add(t.id));
    }
  });

  if (selectedTopics.size === 0) {
    showToast('No published topics found for the selected subjects', 'warning');
    return;
  }

  // Read options from the subject modal's controls
  const mixQAToggle   = document.getElementById('mixQAToggle');
  const limitInput    = document.getElementById('questionCountLimit');
  TEST_CONFIG.shuffleQuestions = mixQAToggle ? mixQAToggle.checked : true;
  TEST_CONFIG.shuffleOptions   = mixQAToggle ? mixQAToggle.checked : true;
  TEST_CONFIG.questionCount    = limitInput && limitInput.value ? parseInt(limitInput.value) : null;
  TEST_CONFIG.selectedTopicIds = Array.from(selectedTopics);
  // Store human-readable names so the header title is correct during the test AND after resume
  TEST_CONFIG.selectedTopicNames = TEST_CONFIG.selectedTopicIds
    .map(id => availableTopics.find(t => t.id === id)?.name)
    .filter(Boolean);

  document.getElementById('subjectModal').classList.add('hidden');

  testState.studentId = getOwnerId();

  try {
    document.getElementById('startScreen').style.display = 'none';
    const loadingScreen = document.getElementById('loadingScreen');
    loadingScreen.style.display = 'flex';
    loadingScreen.innerHTML = `
      <div class="start-content">
        <div class="loading" style="width:60px;height:60px;margin:0 auto 24px"></div>
        <p style="color:#cbd5e1;font-size:18px">Loading test questions...</p>
        <p style="color:#94a3b8;font-size:14px;margin-top:12px">${selectedTopics.size} topic(s) selected${TEST_CONFIG.questionCount ? `, limited to ${TEST_CONFIG.questionCount} questions` : ''}</p>
      </div>
    `;

    // If the user came from the subject/topic picker, we always start fresh.
    // Resume is only offered on page-load flows that didn't involve a new selection.
    await initializeNewTest();

    loadingScreen.style.display = 'none';
    document.getElementById('testContainer').style.display = 'block';
    window.addEventListener('beforeunload', handleBeforeUnload);

  } catch (error) {
    console.error('Failed to start test:', error);
    const loadingScreen = document.getElementById('loadingScreen');
    if (loadingScreen) {
      loadingScreen.innerHTML = `
        <div class="start-content">
          <p style="color:#ef4444">Failed to start test: ${error.message}</p>
          <button onclick="location.reload()" class="btn btn-primary" style="margin-top:16px">Try Again</button>
        </div>
      `;
    }
  }
}

async function continueToTopics() {
  // Legacy path — no longer primary, but kept for back-compat
  // Just call the new unified start function
  await startFromSubjectModal();
}

function toggleTopic(topicId) {
  const checkbox = document.getElementById(`topic-${topicId}`);
  checkbox.checked = !checkbox.checked;
  
  if (checkbox.checked) {
    selectedTopics.add(topicId);
  } else {
    selectedTopics.delete(topicId);
  }
  
  // Update visual state
  const card = checkbox.closest('.topic-checkbox-card');
  if (checkbox.checked) {
    card.classList.add('selected');
  } else {
    card.classList.remove('selected');
  }
  
  updateTopicStats();
}

function selectAllTopics() {
  availableTopics.forEach(topic => {
    selectedTopics.add(topic.id);
    const checkbox = document.getElementById(`topic-${topic.id}`);
    if (checkbox) {
      checkbox.checked = true;
      checkbox.closest('.topic-checkbox-card').classList.add('selected');
    }
  });
  updateTopicStats();
}

function deselectAllTopics() {
  selectedTopics.clear();
  availableTopics.forEach(topic => {
    const checkbox = document.getElementById(`topic-${topic.id}`);
    if (checkbox) {
      checkbox.checked = false;
      checkbox.closest('.topic-checkbox-card').classList.remove('selected');
    }
  });
  updateTopicStats();
}

async function updateTopicStats() {
  const countEl = document.getElementById('legacySelectedTopicsCount');
  const qEl     = document.getElementById('legacyTotalQuestionsCount');
  if (countEl) countEl.textContent = selectedTopics.size;

  const startBtn = document.getElementById('startTestBtn');
  if (selectedTopics.size === 0) {
    if (startBtn) { startBtn.disabled = true; startBtn.style.opacity = '0.5'; startBtn.style.cursor = 'not-allowed'; }
    if (qEl) qEl.textContent = '-';
  } else {
    if (startBtn) { startBtn.disabled = false; startBtn.style.opacity = '1'; startBtn.style.cursor = 'pointer'; }
    try {
      const { count, error } = await db
        .from('test_questions')
        .select('*', { count: 'exact', head: true })
        .eq('is_active', true)
        .in('topic_id', Array.from(selectedTopics));
      if (!error && qEl) qEl.textContent = count || 0;
    } catch (_) { if (qEl) qEl.textContent = '?'; }
  }
}

function closeSubjectModal() {
  document.getElementById('subjectModal').classList.add('hidden');
  // Clear search state
  clearSubjectSearch();
  selectedSubjects.clear();
  // Re-render subject list to clear selections
  const cards = document.querySelectorAll('[data-subject-id]');
  cards.forEach(card => {
    card.classList.remove('selected');
    const checkbox = card.querySelector('.topic-checkbox');
    if (checkbox) checkbox.checked = false;
  });
  updateSubjectStats();
}

// ── Subject search / filter ──────────────────────────────────────
function filterSubjectSearch(query) {
  const q = query.trim().toLowerCase();
  const rows = document.querySelectorAll('#subjectList .subject-row');
  const clearBtn = document.getElementById('searchClearBtn');
  const noResults = document.getElementById('subjectNoResults');

  clearBtn && (clearBtn.className = q ? 'search-clear-btn visible' : 'search-clear-btn');

  let anyVisible = false;
  rows.forEach(row => {
    const subjectName = row.dataset.subjectName || '';
    const topicNames  = row.dataset.topicNames  || '';

    if (!q) {
      // No search — show everything, reset all topic rows to visible
      row.classList.remove('search-hidden');
      row.querySelectorAll('.topic-row').forEach(tr => {
        tr.style.display = '';
        tr.style.opacity = '1';
      });
      anyVisible = true;
      return;
    }

    const subjectMatches = subjectName.includes(q);
    const topicMatches   = topicNames.includes(q);

    if (subjectMatches) {
      // Whole subject matches — show it and all its topics
      row.classList.remove('search-hidden');
      row.querySelectorAll('.topic-row').forEach(tr => {
        tr.style.display = '';
        tr.style.opacity = '1';
      });
      anyVisible = true;
    } else if (topicMatches) {
      // Subject doesn't match by name but has matching topics — show subject, hide non-matching topics
      row.classList.remove('search-hidden');
      row.classList.add('expanded'); // auto-expand to show matches
      let matchingTopics = 0;
      row.querySelectorAll('.topic-row').forEach(tr => {
        const topicName = tr.dataset.topicName || '';
        if (topicName.includes(q)) {
          tr.style.display = '';
          tr.style.opacity = '1';
          matchingTopics++;
        } else {
          // Hide non-matching topics completely (not just dim)
          tr.style.display = 'none';
        }
      });
      if (matchingTopics > 0) anyVisible = true;
      else row.classList.add('search-hidden');
    } else {
      // No match at all — hide entire subject row
      row.classList.add('search-hidden');
      row.querySelectorAll('.topic-row').forEach(tr => {
        tr.style.display = '';
        tr.style.opacity = '1';
      });
    }
  });

  if (noResults) noResults.style.display = anyVisible ? 'none' : 'block';
}

function clearSubjectSearch() {
  const input = document.getElementById('subjectSearchInput');
  if (input) { input.value = ''; filterSubjectSearch(''); input.focus(); }
}

function closeTopicModal() {
  document.getElementById('topicModal').classList.add('hidden');
  selectedTopics.clear();
  // Show subject modal again with selections preserved (don't reload)
  document.getElementById('subjectModal').classList.remove('hidden');
}

function toggleMixQA() {
  const toggle = document.getElementById('mixQAToggle');
  if (toggle.checked) {
    showToast('Mix Q/A enabled: Questions and answers will be shuffled', 'success');
  } else {
    showToast('Mix Q/A disabled: Questions and answers will appear in order', 'info');
  }
}

function backToSubjects() {
  closeTopicModal();
}
      loadingWatchdog = null;
    }
    showStartError(error.message || 'Failed to load test');
  }
}

// ============================================
// ENGLISH DISCLAIMER QUESTION
// Always shown as Question 1 for the English subject.
// Not counted in scoring.
// ============================================
const ENGLISH_SUBJECT_ID = '10000000-0000-0000-0000-000000000025';
const ENGLISH_TOPIC_IDS = new Set([
  '20000000-0000-0000-0000-000000000396',
  '20000000-0000-0000-0000-000000000397',
  '20000000-0000-0000-0000-000000000398',
  '20000000-0000-0000-0000-000000000399',
  '20000000-0000-0000-0000-000000000400',
  '20000000-0000-0000-0000-000000000401',
  '20000000-0000-0000-0000-000000000402',
  '20000000-0000-0000-0000-000000000403'
]);

function buildEnglishDisclaimerQuestion() {
  return {
    id: 'english-disclaimer-q0',
    isDisclaimer: true,
    stem: 'Disclaimer\n\nThis assessment is designed primarily to evaluate and strengthen students\' ability to comprehend complex English language structures. The purpose of this test is not to measure advanced medical knowledge or mastery of clinical procedures and conditions.\n\nThe instructor does not expect students to know all medical answers presented in the questions. The medical content included is intentionally basic and foundational. The true objective of this examination is to develop students\' skills in analyzing sentence structure, interpreting context, identifying qualifiers and conditions, recognizing numerical phrasing, and accurately determining what the question is actually asking.\n\nStudents are expected to actively dissect each question stem. As part of the learning process, you should be prepared to translate the question and explain to your instructor — in your own language or in English — what the question is requesting and how the structure guides you toward the correct answer. If the question contains a linguistic "trap" (such as misleading phrasing, layered clauses, double negatives, numerical wording like "two pairs," conditional qualifiers, or embedded modifiers), you should clearly identify and explain how that structure could create confusion and how you logically resolved it.\n\nThis examination is therefore a structured exercise in advanced English comprehension, analytical reasoning, and syntactic interpretation rather than an evaluation of clinical expertise.',
    options: [{ id: 'a', text: 'Got it.' }],
    correct: ['a'],
    multi: false,
    rationale: 'Correct. Now click next question to start the test.',
    category: 'Disclaimer',
    points: 0,
    displayOrder: 0,
    stem_hy: null,
    options_hy: null,
    rationale_hy: null
  };
}

function isEnglishSubject() {
  if (testState.testConfig && testState.testConfig.subject_id === ENGLISH_SUBJECT_ID) {
    return true;
  }
  if (TEST_CONFIG.selectedTopicIds && TEST_CONFIG.selectedTopicIds.length > 0) {
    return TEST_CONFIG.selectedTopicIds.some(id => ENGLISH_TOPIC_IDS.has(id));
  }
  return false;
}

async function initializeNewTest() {
  clearLocalStorage();
  setLoadingStatus('Preparing session...');
  
  testState.sessionId = generateSessionId();
  // Derive a deterministic seed from testId + selected topics so every device
  // opening the same test sees questions and answer choices in the EXACT same order.
  // Each student still gets their own independent session (sessionId, answers, timer).
  testState.shuffleSeed = deriveShuffleSeed(
    TEST_CONFIG.testId,
    TEST_CONFIG.selectedTopicIds || []
  );
  testState.startTime = Date.now();
  
  // Load questions from Supabase with topic filter (new system) or category filter (legacy)
  const topicIds = TEST_CONFIG.selectedTopicIds || null;
  const questions = await loadQuestions(
    TEST_CONFIG.testId, 
    TEST_CONFIG.categoryFilter, 
    TEST_CONFIG.questionCount,
    topicIds
  );

  setLoadingStatus('Finalizing test layout...');
  
  // Shuffle questions if enabled
  if (TEST_CONFIG.shuffleQuestions) {
    testState.questions = shuffleArray(questions, testState.shuffleSeed);
  } else {
    testState.questions = [...questions];
  }
  
  // Shuffle options for each question if enabled (applied to EN options;
  // buildBilingualSnapshot will re-align HY options to the shuffled EN order)
  if (TEST_CONFIG.shuffleOptions) {
    testState.questions = testState.questions.map(q => ({
      ...q,
      options: shuffleArray(q.options, testState.shuffleSeed + q.id.toString().charCodeAt(0))
    }));
  }

  // Prepend the English disclaimer as Question 1 (after shuffle, always first)
  if (isEnglishSubject()) {
    testState.questions = [buildEnglishDisclaimerQuestion(), ...testState.questions];
  }

  // ── Build the frozen bilingual snapshot (once, permanent for this session) ──
  testState.snapshot = buildBilingualSnapshot(testState.questions);
  setLoadingStatus('Preparing interface...');
  console.log('🌐 Bilingual snapshot built:', {
    en: testState.snapshot.en?.length + ' questions',
    hy: testState.snapshot.hy ? testState.snapshot.hy.length + ' questions' : 'no Armenian translations'
  });
  
  // ============================================
  // TEACHER MODE: Create session if teacher
  // ============================================
  if (TEACHER_MODE.enabled && TEACHER_MODE.sessionId) {
    console.log('🎓 Creating teacher session...');
    await createTeacherSession(TEST_CONFIG.testId, testState.questions);
    startSessionHeartbeat();
    showTeacherPanel();
  }
  
  // TEACHER MODE: Subscribe if student
  if (TEACHER_MODE.isStudent && TEACHER_MODE.sessionId) {
    console.log('👨‍🎓 Joining as student...');
    await subscribeToTeacherSession();
  }
  
  // Initialize UI
  document.getElementById('testTitle').textContent = getDisplayTestTitle();
  applyLanguagePicker();
  initializeTimer();
  renderQuestionNavigator();
  renderQuestion();
  saveToLocalStorage();
  
  showToast('Test started. Good luck!', 'success');
}

async function resumeTest(saved) {
  testState.sessionId = saved.sessionId;
  testState.shuffleSeed = saved.shuffleSeed;
  testState.startTime = saved.startTime;
  testState.currentIndex = saved.currentIndex;
  testState.answers = saved.answers;
  testState.answerStatus = saved.answerStatus || {};
  testState.flagged = new Set(saved.flagged);
  
  // Restore selected topic IDs + names so question loading and the header title are both correct
  if (saved.selectedTopicIds && saved.selectedTopicIds.length > 0) {
    TEST_CONFIG.selectedTopicIds = saved.selectedTopicIds;
  }
  if (saved.selectedTopicNames && saved.selectedTopicNames.length > 0) {
    TEST_CONFIG.selectedTopicNames = saved.selectedTopicNames;
  }

  // Load questions from Supabase using the saved topic filter
  const topicIds = TEST_CONFIG.selectedTopicIds || null;
  const questions = await loadQuestions(saved.testId, TEST_CONFIG.categoryFilter, null, topicIds);
  
  // Reconstruct questions with the same deterministic seed — produces identical order on every device
  if (TEST_CONFIG.shuffleQuestions) {
    testState.questions = shuffleArray(questions, saved.shuffleSeed);
  } else {
    testState.questions = [...questions];
  }
  
  if (TEST_CONFIG.shuffleOptions) {
    testState.questions = testState.questions.map(q => ({
      ...q,
      options: shuffleArray(q.options, saved.shuffleSeed + q.id.toString().charCodeAt(0))
    }));
  }

  // Re-prepend English disclaimer if not already present (always first)
  if (isEnglishSubject() && (!testState.questions[0] || testState.questions[0].id !== 'english-disclaimer-q0')) {
    testState.questions = [buildEnglishDisclaimerQuestion(), ...testState.questions];
  }

  // ── Restore bilingual snapshot (preferred from localStorage for speed;
  //    rebuild from freshly loaded questions as fallback) ─────────────────
  const shouldHaveDisclaimer = isEnglishSubject();
  const savedHasDisclaimer = saved.snapshot && saved.snapshot.en &&
    saved.snapshot.en[0] && saved.snapshot.en[0].id === 'english-disclaimer-q0';

  if (saved.snapshot && saved.snapshot.en && (!shouldHaveDisclaimer || savedHasDisclaimer)) {
    testState.snapshot = saved.snapshot;
    console.log('🌐 Bilingual snapshot restored from saved session');
  } else {
    // Fallback: rebuild snapshot from the re-loaded questions
    testState.snapshot = buildBilingualSnapshot(testState.questions);
    console.log('🌐 Bilingual snapshot rebuilt on resume');
  }
  
  document.getElementById('testTitle').textContent = getDisplayTestTitle();
  applyLanguagePicker();
  initializeTimer();
  renderQuestionNavigator();
  renderQuestion();
  
  showToast('Resumed previous session', 'info');
}

// ============================================
// DISPLAY TITLE (TEST + TOPIC)
// ============================================

function getDisplayTestTitle() {
  // Use the stored topic names (set at selection time + persisted in localStorage).
  // This works both during a fresh test AND after page-reload resume — no dependency
  // on availableTopics being populated.
  const names = (TEST_CONFIG.selectedTopicNames && TEST_CONFIG.selectedTopicNames.length)
    ? TEST_CONFIG.selectedTopicNames
    : [];

  // Single topic → show just the topic name (e.g., "Stroke")
  if (names.length === 1) return names[0];

  // Multiple topics → show comma-joined list (e.g., "Stroke, Cranial Nerves")
  if (names.length > 1) return names.join(', ');

  // Fallback: base title from test_configs (shown before any topic is selected)
  return TEST_CONFIG.testTitle || 'Practice Test';
}

function handleBeforeUnload(e) {
  if (testState.startTime && !testState.endTime) {
    e.preventDefault();
    e.returnValue = '';
    return '';
  }
}

// ============================================
// TIMER
// ============================================

function initializeTimer() {
  if (SESSION_ROLE.isTeacher) {
    const timerEl = document.getElementById('timer');
    if (timerEl) timerEl.style.display = 'none';
    return;
  }
  const durationSeconds = TEST_CONFIG.durationMinutes * 60;
  
  testState.timerInterval = setInterval(() => {
    const elapsed = Math.floor((Date.now() - testState.startTime) / 1000);
    const remaining = durationSeconds - elapsed;
    
    if (remaining <= 0) {
      clearInterval(testState.timerInterval);
      showToast('Time\'s up! Submitting test...', 'warning');
      setTimeout(() => submitTest(true), 2000);
      return;
    }
    
    const timerEl = document.getElementById('timer');
    const displayEl = document.getElementById('timerDisplay');
    displayEl.textContent = formatTime(remaining);
    
    // Warning state in last 5 minutes
    if (remaining <= 300) {
      timerEl.classList.add('warning');
    }
  }, 1000);
}

// ============================================
// QUESTION RENDERING
// ============================================

// Debounced wrapper — when called rapidly (e.g. every answer click),
// only the final call within 50ms actually runs the DOM update.
let _navRenderTimer = null;
const _renderQuestionNavigatorDebounced = (function() {
  return function() {
    if (_navRenderTimer) clearTimeout(_navRenderTimer);
    _navRenderTimer = setTimeout(_renderQuestionNavigatorImpl, 50);
  };
})();

function renderQuestionNavigator() {
  _renderQuestionNavigatorDebounced();
}

function _renderQuestionNavigatorImpl() {
  const grid = document.getElementById('questionGrid');
  if (!grid) return;
  const totalQuestions = testState.questions.length;
  const progressText = document.getElementById('progressText');
  
  if (!grid.dataset.built) {
    const frag = document.createDocumentFragment();
    for (let index = 0; index < totalQuestions; index += 1) {
      const btn = document.createElement('div');
      btn.className = 'question-num unanswered';
      btn.textContent = index + 1;
      btn.dataset.index = String(index);
      btn.dataset.computedState = 'unanswered';
      frag.appendChild(btn);
    }
    grid.innerHTML = '';
    grid.appendChild(frag);
    grid.dataset.built = 'true';
    grid.onclick = (event) => {
      const btn = event.target.closest('.question-num');
      if (!btn) return;
      const idx = Number(btn.dataset.index);
      if (!Number.isNaN(idx)) goToQuestion(idx);
    };
  }

  const buttons = grid.children;
  for (let index = 0; index < totalQuestions; index += 1) {
    const q = testState.questions[index];
    const btn = buttons[index];
    if (!btn) continue;

    const isAnswered = testState.answers[q.id];
    const answerStatus = testState.answerStatus[q.id];
    const isFlagged = testState.flagged.has(q.id);
    const isCurrent = index === testState.currentIndex;

    let targetState = 'unanswered';
    if (isCurrent) targetState = 'current';
    else if (isFlagged) targetState = 'flagged';
    else if (answerStatus === 'incorrect') targetState = 'incorrect';
    else if (answerStatus === 'correct') targetState = 'answered';
    else if (isAnswered) targetState = 'answered';

    if (btn.dataset.computedState !== targetState) {
       btn.className = 'question-num ' + targetState;
       btn.dataset.computedState = targetState;
    }
  }
  
  // Scroll so the current question row is visible.
  // Rules:
  //   - Row 1 (questions 1-5) → always scroll back to top (no offset)
  //   - Row 2+ → scroll down so that row is the FIRST visible row
  // This means: no movement for the first 5, then scroll by 1 row per row.
  const currentBtn = buttons[testState.currentIndex];
  if (currentBtn) {
    const COLS = 5; // must match grid-template-columns
    const currentRow = Math.floor(testState.currentIndex / COLS); // 0-based row
    if (currentRow === 0) {
      // First row — always snap back to top
      grid.scrollTo({ top: 0, behavior: 'smooth' });
    } else {
      // Scroll so the start of the current row is at the top of the grid
      if (!grid.dataset.btnHeight) {
        grid.dataset.btnHeight = String(currentBtn.offsetHeight);
      }
      const btnHeight = Number(grid.dataset.btnHeight) || 36;
      const gap = 7; // must match CSS gap
      const rowTop = currentRow * (btnHeight + gap);
      grid.scrollTo({ top: rowTop, behavior: 'smooth' });
    }
  }
  
  // Update progress
  if (progressText) {
    const answered = Object.keys(testState.answers).length;
    progressText.textContent = `${answered} / ${totalQuestions}`;
  }
}

function toggleExtraQuestions() {
  // No-op — all questions now in one scrollable grid
}

function renderQuestion() {
  // ── LANGUAGE-AWARE QUESTION RESOLUTION ─────────────────────────────────
  // Always use the frozen snapshot for text so language switching never
  // changes question/answer order or correct answers.
  // Fall back gracefully: if HY is active but this specific question lacks
  // a translation, show EN text and display the notice banner.
  const baseQuestion = testState.questions[testState.currentIndex]; // carries id, correct, multi, etc.
  
  let displayQuestion; // the object whose .stem / .options we show
  let showNoTranslation = false;

  if (testState.snapshot.en && testState.snapshot.hy && testState.language === 'hy') {
    const hyQ = testState.snapshot.hy[testState.currentIndex];
    if (hyQ && hyQ._hasTranslation) {
      displayQuestion = hyQ;
    } else {
      // This specific question is not translated — fall back to EN silently shown with a banner
      displayQuestion = testState.snapshot.en[testState.currentIndex];
      showNoTranslation = true;
    }
  } else if (testState.snapshot.en) {
    displayQuestion = testState.snapshot.en[testState.currentIndex];
  } else {
    // No snapshot yet (e.g. student loading mid-stream) — use raw question data
    displayQuestion = baseQuestion;
  }

  // Show/hide the no-translation notice
  const noTransNotice = document.getElementById('noTranslationNotice');
  if (noTransNotice) noTransNotice.style.display = showNoTranslation ? 'flex' : 'none';

  // Use the canonical baseQuestion for logic (answers, correct checks, id)
  const question = baseQuestion;
  
  // Update question number
  document.getElementById('questionNumber').textContent = 
    `Question ${testState.currentIndex + 1} of ${testState.questions.length}`;
  
  // Update question type badge
  document.getElementById('questionType').textContent = 
    question.multi ? 'Multiple Answer' : 'Single Answer';
  
  // Update question stem (from active language)
  // Disclaimer question: render with paragraph formatting instead of plain text
  const stemEl = document.getElementById('questionStem');
  if (question.isDisclaimer) {
    const paragraphs = displayQuestion.stem.split('\n\n');
    stemEl.innerHTML = paragraphs.map((p, i) =>
      i === 0
        ? `<strong style="font-size:1.1em;display:block;margin-bottom:12px">${p}</strong>`
        : `<p style="margin:0 0 10px 0;line-height:1.65">${p}</p>`
    ).join('');
  } else {
    stemEl.textContent = displayQuestion.stem;
  }
  
  // Render options (text from active language, id/value always from EN for correct-check)
  const container = document.getElementById('optionsContainer');
  const frag = document.createDocumentFragment();
  
  const inputType = question.multi ? 'checkbox' : 'radio';
  const inputName = 'question_' + question.id;
  
  // displayQuestion.options preserves the same shuffled order with language text swapped
  displayQuestion.options.forEach((option, optIndex) => {
    const letter = String.fromCharCode(65 + optIndex); // A, B, C, D …
    const div = document.createElement('div');
    div.className = 'option';
    
    const input = document.createElement('input');
    input.type = inputType;
    input.name = inputName;
    input.value = String(option.id); // Always EN letter keys (a/b/c/d) — language-agnostic
    input.id = `option_${question.id}_${option.id}`;
    
    // Check if this option was previously selected
    const savedAnswer = testState.answers[question.id];
    if (savedAnswer) {
      if (Array.isArray(savedAnswer)) {
        input.checked = savedAnswer.includes(String(option.id));
      } else {
        input.checked = String(savedAnswer) === String(option.id);
      }
      if (input.checked) div.classList.add('selected');
    }
    
    input.onchange = () => handleAnswerChange(question.id, question.multi);
    
    // Letter badge (A, B, C, D …)
    const letterSpan = document.createElement('span');
    letterSpan.className = 'option-letter';
    letterSpan.textContent = letter;

    const label = document.createElement('label');
    label.htmlFor = input.id;
    label.className = 'option-text';
    label.textContent = option.text; // Language-specific text
    
  div.appendChild(input);
  div.appendChild(letterSpan);
  div.appendChild(label);
  frag.appendChild(div);
    
    // Make entire div clickable
    div.onclick = (e) => {
      if (e.target !== input) {
        input.click();
      }
    };
  });

  container.replaceChildren(frag);
  
  // Update flag button
  const flagBtn = document.getElementById('flagBtn');
  if (testState.flagged.has(question.id)) {
    flagBtn.classList.add('flagged');
  } else {
    flagBtn.classList.remove('flagged');
  }
  
  // Update navigation buttons
  const backBtn = document.getElementById('backBtn');
  backBtn.disabled = !TEST_CONFIG.showBackButton || testState.currentIndex === 0;
  
  // Hide answer feedback and check button when question changes
  document.getElementById('answerFeedback').style.display = 'none';
  document.getElementById('checkAnswerBtn').style.display = 'none';
  
  // STUDENT VIEW: Hide check answer button completely
  if (TEACHER_MODE.isStudent && !TEACHER_MODE.enabled) {
    document.getElementById('checkAnswerBtn').style.display = 'none';
  } else {
    const existingStatus = testState.answerStatus[question.id];
    // Rationale text in the active language (falls back to EN)
    const rationaleText = displayQuestion.rationale || question.rationale || '';

    if (existingStatus) {
      // This question was already checked — re-apply the visual state
      // so correct answers are NOT freshly revealed (just restored to prior state)
      const isCorrect = existingStatus === 'correct';
      const feedbackEl = document.getElementById('answerFeedback');
      feedbackEl.style.display = 'block';

      if (isCorrect) {
        feedbackEl.style.background = 'linear-gradient(135deg, rgba(34,197,94,0.15), rgba(34,197,94,0.05))';
        feedbackEl.style.border = '2px solid var(--success)';
        feedbackEl.style.color = '#15803d';
        feedbackEl.innerHTML = `
          <div style="display:flex;align-items:center;gap:12px">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
            <div>
              <div style="font-size:18px;margin-bottom:4px">${testState.language === 'hy' ? 'Ճիշտ է!' : 'Correct!'}</div>
              ${rationaleText ? `<div style="font-weight:400;font-size:14px;color:#166534;margin-top:8px">${rationaleText}</div>` : ''}
            </div>
          </div>
        `;
      } else {
        feedbackEl.style.background = 'linear-gradient(135deg, rgba(239,68,68,0.15), rgba(239,68,68,0.05))';
        feedbackEl.style.border = '2px solid var(--error)';
        feedbackEl.style.color = '#991b1b';
        feedbackEl.innerHTML = `
          <div style="display:flex;align-items:center;gap:12px">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            <div>
              <div style="font-size:18px;margin-bottom:4px">${testState.language === 'hy' ? 'Սխալ է' : 'Incorrect'}</div>
              ${rationaleText ? `<div style="font-weight:400;font-size:14px;color:#7f1d1d;margin-top:8px"><strong>${testState.language === 'hy' ? 'Բացատրություն' : 'Explanation'}:</strong> ${rationaleText}</div>` : ''}
            </div>
          </div>
        `;
      }

      // Re-apply correct/incorrect option highlighting and disable inputs
      document.querySelectorAll('.option').forEach(opt => {
        const input = opt.querySelector('input');
        const optionId = String(input.value);
        opt.classList.add('disabled');
        input.disabled = true;
        opt.classList.remove('selected');
        if (question.correct.map(String).includes(optionId)) {
          opt.classList.add('correct');
        } else if (input.checked) {
          opt.classList.add('incorrect');
        }
      });

      // Check button should stay hidden — answer already revealed
      document.getElementById('checkAnswerBtn').style.display = 'none';

    } else {
      // Not yet checked — show check button only if an answer is selected
      const savedAnswer = testState.answers[question.id];
      if (savedAnswer && (Array.isArray(savedAnswer) ? savedAnswer.length > 0 : true)) {
        document.getElementById('checkAnswerBtn').style.display = 'inline-flex';
      }
    }
  }
  
  // TEACHER VIEW: Auto-show answer and rationale
  if (TEACHER_MODE.enabled) {
    setTimeout(() => showTeacherAnswerPanel(), 100);
  }
  
  renderQuestionNavigator();
}

function handleAnswerChange(questionId, isMulti) {
  const question = testState.questions.find(q => q.id === questionId);
  const inputName = 'question_' + questionId;
  
  if (isMulti) {
    const checked = Array.from(document.querySelectorAll(`input[name="${inputName}"]:checked`))
      .map(input => input.value);
    testState.answers[questionId] = checked.length > 0 ? checked : null;
  } else {
    const checked = document.querySelector(`input[name="${inputName}"]:checked`);
    testState.answers[questionId] = checked ? checked.value : null;
  }

  delete testState.answerStatus[questionId];
  
  // Update option styling
  document.querySelectorAll('.option').forEach(opt => {
    const input = opt.querySelector('input');
    if (input.checked) {
      opt.classList.add('selected');
    } else {
      opt.classList.remove('selected');
    }
  });
  
  // Show check answer button if question is answered
  const hasAnswer = testState.answers[questionId];
  const checkBtn = document.getElementById('checkAnswerBtn');
  if (hasAnswer && (isMulti ? hasAnswer.length > 0 : true)) {
    checkBtn.style.display = 'inline-flex';
  } else {
    checkBtn.style.display = 'none';
  }
  
  // Hide feedback when answer changes
  document.getElementById('answerFeedback').style.display = 'none';
  
  saveToLocalStorage();
  renderQuestionNavigator();
}

function checkAnswer() {
  // STUDENT VIEW: Prevent checking answers
  if (TEACHER_MODE.isStudent && !TEACHER_MODE.enabled) {
    showToast('Answers not available in Student View', 'warning');
    return;
  }
  
  const question = testState.questions[testState.currentIndex];
  const userAnswer = testState.answers[question.id];
  
  if (!userAnswer) {
    showToast('Please select an answer first', 'warning');
    return;
  }
  
  // Determine if answer is correct
  let isCorrect = false;
  if (question.multi) {
    // Multiple choice: must select ALL correct answers and NO incorrect ones
    const correctSet = new Set(question.correct.map(String)); // Convert to strings
    const userSet = new Set(Array.isArray(userAnswer) ? userAnswer.map(String) : [String(userAnswer)]);
    isCorrect = correctSet.size === userSet.size && 
                [...correctSet].every(id => userSet.has(id));
  } else {
    // Single choice: must match the correct answer
    isCorrect = question.correct.map(String).includes(String(userAnswer));
  }

  testState.answerStatus[question.id] = isCorrect ? 'correct' : 'incorrect';
  saveToLocalStorage();
  
  // Show feedback
  const feedbackEl = document.getElementById('answerFeedback');
  feedbackEl.style.display = 'block';

  // Get rationale in the active language
  let rationaleText = '';
  if (testState.snapshot.en) {
    const activeSnapshot = (testState.language === 'hy' && testState.snapshot.hy)
      ? testState.snapshot.hy
      : testState.snapshot.en;
    const snapQ = activeSnapshot[testState.currentIndex];
    rationaleText = (snapQ && snapQ.rationale) ? snapQ.rationale : (question.rationale || '');
  } else {
    rationaleText = question.rationale || '';
  }
  
  if (isCorrect) {
    feedbackEl.style.background = 'rgba(16,185,129,0.12)';
    feedbackEl.style.border = '1.5px solid rgba(16,185,129,0.45)';
    feedbackEl.style.color = '#6ee7b7';
    feedbackEl.innerHTML = `
      <div style="display:flex;align-items:flex-start;gap:14px">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#34d399" stroke-width="3" style="flex-shrink:0;margin-top:2px">
          <polyline points="20 6 9 17 4 12"/>
        </svg>
        <div>
          <div style="font-size:17px;font-weight:800;color:#a7f3d0;margin-bottom:6px">${testState.language === 'hy' ? 'Ճիշտ է!' : 'Correct!'}</div>
          ${rationaleText ? `<div style="font-weight:400;font-size:14px;color:#6ee7b7;line-height:1.65;margin-top:4px">${rationaleText}</div>` : ''}
        </div>
      </div>
    `;
  } else {
    feedbackEl.style.background = 'rgba(239,68,68,0.12)';
    feedbackEl.style.border = '1.5px solid rgba(239,68,68,0.45)';
    feedbackEl.style.color = '#fca5a5';
    feedbackEl.innerHTML = `
      <div style="display:flex;align-items:flex-start;gap:14px">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#f87171" stroke-width="3" style="flex-shrink:0;margin-top:2px">
          <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
        </svg>
        <div>
          <div style="font-size:17px;font-weight:800;color:#fca5a5;margin-bottom:6px">${testState.language === 'hy' ? 'Սխալ է' : 'Incorrect'}</div>
          ${rationaleText ? `<div style="font-weight:400;font-size:14px;color:#fda4af;line-height:1.65;margin-top:4px"><strong style="color:#fca5a5">${testState.language === 'hy' ? 'Բացատրություն' : 'Explanation'}:</strong> ${rationaleText}</div>` : ''}
        </div>
      </div>
    `;
  }
  
  // Highlight correct and incorrect options
  document.querySelectorAll('.option').forEach(opt => {
    const input = opt.querySelector('input');
    const optionId = String(input.value);
    
    // Disable further changes
    opt.classList.add('disabled');
    input.disabled = true;
    
    // Remove selected class first
    opt.classList.remove('selected');
    
    // Add correct/incorrect classes
    if (question.correct.map(String).includes(optionId)) {
      opt.classList.add('correct');
    } else if (input.checked) {
      opt.classList.add('incorrect');
    }
  });
  
  // Hide check button after checking
  document.getElementById('checkAnswerBtn').style.display = 'none';

  renderQuestionNavigator();
  
  // Scroll to feedback
  feedbackEl.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// ============================================
// NAVIGATION
// ============================================

function goToQuestion(index) {
  // Prevent student from navigating independently
  if (TEACHER_MODE.isStudent && !TEACHER_MODE.enabled) {
    showToast('Navigation controlled by teacher', 'warning');
    return;
  }
  
  testState.currentIndex = index;
  renderQuestion();
  
  // Broadcast to students if teacher
  if (TEACHER_MODE.enabled) {
    broadcastSessionUpdate();
  }
}

function nextQuestion() {
  // Prevent student from navigating independently
  if (TEACHER_MODE.isStudent && !TEACHER_MODE.enabled) {
    showToast('Navigation controlled by teacher', 'warning');
    return;
  }
  
  if (testState.currentIndex < testState.questions.length - 1) {
    testState.currentIndex++;
    renderQuestion();
    
    // Broadcast to students if teacher
    if (TEACHER_MODE.enabled) {
      broadcastSessionUpdate();
    }
  }
}

function previousQuestion() {
  // Prevent student from navigating independently
  if (TEACHER_MODE.isStudent && !TEACHER_MODE.enabled) {
    showToast('Navigation controlled by teacher', 'warning');
    return;
  }
  
  if (testState.currentIndex > 0) {
    testState.currentIndex--;
    renderQuestion();
    
    // Broadcast to students if teacher
    if (TEACHER_MODE.enabled) {
      broadcastSessionUpdate();
    }
  }
}

function toggleFlag() {
  const currentQ = testState.questions[testState.currentIndex];
  if (testState.flagged.has(currentQ.id)) {
    testState.flagged.delete(currentQ.id);
    showToast('Question unflagged', 'info');
  } else {
    testState.flagged.add(currentQ.id);
    showToast('Question flagged for review', 'warning');
  }
  saveToLocalStorage();
  renderQuestion();
}

function clearAnswer() {
  const currentQ = testState.questions[testState.currentIndex];
  delete testState.answers[currentQ.id];
  delete testState.answerStatus[currentQ.id];
  
  // Clear feedback
  document.getElementById('answerFeedback').style.display = 'none';
  document.getElementById('checkAnswerBtn').style.display = 'none';
  
  // Re-enable all options
  document.querySelectorAll('.option').forEach(opt => {
    opt.classList.remove('disabled', 'correct', 'incorrect');
    const input = opt.querySelector('input');
    input.disabled = false;
  });
  
  saveToLocalStorage();
  renderQuestion();
  showToast('Answer cleared', 'info');
}

// ============================================
// SUBMISSION
// ============================================

function showSubmitModal() {
  const answered = Object.keys(testState.answers).length;
  const total = testState.questions.length;
  const unanswered = total - answered;
  
  const warningEl = document.getElementById('submitWarning');
  if (unanswered > 0) {
    warningEl.textContent = `⚠️ You have ${unanswered} unanswered question${unanswered > 1 ? 's' : ''}. Unanswered questions will be marked as incorrect.`;
    warningEl.style.display = 'block';
  } else {
    warningEl.style.display = 'none';
  }
  
  document.getElementById('submitModal').classList.add('active');
}

function closeSubmitModal() {
  document.getElementById('submitModal').classList.remove('active');
}

// Save & Load Test functions (Supabase)
function showSaveModal() {
  const sessionName = `Test Session - ${new Date().toLocaleDateString()}`;
  document.getElementById('saveSessionName').value = sessionName;
  document.getElementById('saveTestModal').classList.add('active');
}

function closeSaveModal() {
  document.getElementById('saveTestModal').classList.remove('active');
}

async function saveTestSession() {
  const sessionName = document.getElementById('saveSessionName').value.trim();
  const saveBtn = document.querySelector('#saveTestModal .btn-primary');
  
  if (!sessionName) {
    showToast('Please enter a session name', 'warning');
    return;
  }

  if (saveBtn) {
    saveBtn.disabled = true;
    saveBtn.textContent = 'Saving...';
  }

  // Always persist to localStorage immediately — this is the guaranteed fallback
  saveToLocalStorage();

  // file:// origin: Supabase is blocked by TLS/CORS — skip cloud entirely
  if (window.location.protocol === 'file:') {
    closeSaveModal();
    if (saveBtn) { saveBtn.disabled = false; saveBtn.textContent = 'Save & Exit'; }
    document.getElementById('testContainer').style.display = 'none';
    document.getElementById('startScreen').style.display = 'flex';
    showToast('Saved locally. Open via localhost:8000 to enable cloud sync.', 'warning');
    return;
  }

  // Helper: attempt the Supabase cloud save with a hard timeout
  const trySaveToCloud = async () => {
    if (!db) {
      if (!initializeSupabase()) throw new Error('db_unavailable');
    }

    // Always refresh the owner header before writing — ensures RLS passes
    // even if the email wasn't available when the client was first built.
    refreshSupabaseOwner();

    const answeredCount = Object.keys(testState.answers).length;
    const totalQuestions = testState.questions.length;
    const progressPercent = Math.round((answeredCount / totalQuestions) * 100);

    const sessionData = {
      // If the auto-save row already exists, promote it to the named save;
      // otherwise fall back to any previously-named row id or let Supabase create one.
      ...(testState.autoSaveDbId
        ? { id: testState.autoSaveDbId }
        : testState.savedSessionDbId
          ? { id: testState.savedSessionDbId }
          : {}),
      session_name: sessionName,
      student_id: getOwnerId(),
      user_role: SESSION_ROLE.userRole || 'student',
      test_id: TEST_CONFIG.testId,
      session_id: testState.sessionId,
      shuffle_seed: testState.shuffleSeed || null,
      current_question_index: testState.currentIndex,
      answers: testState.answers,
      answer_status: testState.answerStatus,
      flagged_questions: Array.from(testState.flagged),
      // ── SLIM PAYLOAD: omit questions + snapshots from cloud saves ──────
      // questions are reloaded from test_questions on resume (they're in the DB).
      // snapshots are rebuilt from questions in buildBilingualSnapshot().
      // Sending them here could be 500KB+ and causes timeouts / row-size errors.
      questions: testState.questions.map(q => ({ id: q.id, topic_id: q.topic_id || null })),
      test_config: {
        testId: TEST_CONFIG.testId,
        selectedTopicIds: TEST_CONFIG.selectedTopicIds || [],
        selectedTopicNames: TEST_CONFIG.selectedTopicNames || [],
        categoryFilter: TEST_CONFIG.categoryFilter || null,
        questionCount: TEST_CONFIG.questionCount || null,
        shuffleQuestions: TEST_CONFIG.shuffleQuestions,
        shuffleOptions: TEST_CONFIG.shuffleOptions
      },
      start_time: new Date(testState.startTime).toISOString(),
      total_questions: totalQuestions,
      answered_questions: answeredCount,
      progress_percent: progressPercent,
      is_in_progress: false,          // manually saved → no longer "in progress"
      last_auto_saved_at: new Date().toISOString(),
      session_snapshot_en: null,
      session_snapshot_hy: null
    };

    // Raise timeout to 12s — Supabase cold-starts can take 3–5s
    const upsertPromise = db
      .from('saved_test_sessions')
      .upsert([sessionData], { onConflict: 'id' })
      .select('id')
      .single();

    const timeoutPromise = new Promise((_, reject) =>
      setTimeout(() => reject(new Error('network_timeout')), 12000)
    );

    const { data, error } = await Promise.race([upsertPromise, timeoutPromise]);

    if (error) throw error;
    return data;
  };

  try {
    const data = await trySaveToCloud();

    if (data && data.id) {
      testState.savedSessionDbId = data.id;
      // The auto-save row was promoted to the named session — clear its reference
      testState.autoSaveDbId = null;
    }

    // Cancel any pending auto-save — the session is now a named save (is_in_progress=false)
    if (autoSaveTimer) { clearTimeout(autoSaveTimer); autoSaveTimer = null; }

    closeSaveModal();
    showToast('Test saved successfully! You can resume it anytime.', 'success');
    
    // Return to start screen immediately (no delay)
    document.getElementById('testContainer').style.display = 'none';
    document.getElementById('startScreen').style.display = 'flex';
    loadSavedSessions();
    if (saveBtn) {
      saveBtn.disabled = false;
      saveBtn.textContent = 'Save & Exit';
    }
    
  } catch (error) {
    const msg = String(error.message || '');
    const isNetworkError = isNetworkFailure(error) || error.message === 'db_unavailable';
    const isMissingTable = msg.includes('saved_test_sessions') || error.code === '42P01';
    const isRlsBlocked = error.code === '42501' || msg.toLowerCase().includes('row-level security');
    const ownerId = getOwnerId();

    if (isNetworkError) {
      // Session is already in localStorage — just close and report
      console.warn('Cloud save unavailable (network/TLS). Session preserved in localStorage.');
      closeSaveModal();
      showToast('Saved locally — cloud sync unavailable. Your progress is safe.', 'warning');
    } else if (isRlsBlocked) {
      console.error('RLS blocked save for owner:', ownerId, error);
      closeSaveModal();
      showToast(`Cloud save blocked (RLS). Owner: ${ownerId}. Please log out/in and try again.`, 'error');
    } else if (isMissingTable) {
      console.error('saved_test_sessions table missing:', error);
      closeSaveModal();
      showToast('Saved locally. (Cloud table missing — run ADD-SAVED-TEST-SESSIONS-TABLE.sql)', 'warning');
    } else {
      console.error('Error saving test session:', error);
      showToast('Cloud save failed. Your progress was saved locally.', 'warning');
      closeSaveModal();
    }

    if (saveBtn) {
      saveBtn.disabled = false;
      saveBtn.textContent = 'Save & Exit';
    }
  }
}

async function loadSavedSessions() {
  try {
    if (!db) {
      if (!initializeSupabase()) {
        showToast('Database not configured. Cannot load saved tests.', 'error');
        return;
      }
    }

    // Refresh owner header so RLS recognises this user
    refreshSupabaseOwner();

    // ── Fetch ALL sessions for this owner+role ────────────────────────────
    // Filter by user_role so teachers never see student sessions and vice-versa.
    // The column may not exist on older deployments — fall back gracefully.
    const role = SESSION_ROLE.userRole || 'student';

    const buildQuery = (roleFilter) => {
      let q = db
        .from('saved_test_sessions')
        .select('*')
        .eq('student_id', getOwnerId());
      if (roleFilter) q = q.eq('user_role', roleFilter);
      return q.order('created_at', { ascending: false });
    };

    const { data: savedSessions, error } = await withTimeout(
      buildQuery(role),
      6000,
      'Loading saved sessions timed out'
    );
    
    if (error) {
      if (isNetworkFailure(error)) {
        console.warn('Saved sessions unavailable (network/TLS). Skipping cloud load.');
        return;
      }
      const isRlsBlocked = error.code === '42501' || String(error.message || '').toLowerCase().includes('row-level security');
      if (isRlsBlocked) {
        showToast(`Saved sessions blocked (RLS). Owner: ${getOwnerId()}`, 'error');
        return;
      }
      console.error('Error loading sessions:', error);
      if (String(error.message || '').includes('saved_test_sessions') || error.code === '42P01') {
        showToast('Missing table. Run ADD-SAVED-TEST-SESSIONS-TABLE.sql in Supabase.', 'error');
      } else {
        showToast(`Failed to load saved sessions: ${error.message}`, 'error');
      }
      return;
    }
    
    const container = document.getElementById('savedSessionsContainer');
    const listContainer = document.getElementById('savedSessionsList');

    // Guard: these elements only exist when the start screen is visible
    if (!container || !listContainer) return;
    
    if (!savedSessions || savedSessions.length === 0) {
      container.style.display = 'none';
      return;
    }
    
    container.style.display = 'block';
    listContainer.innerHTML = '';

    // ── Split: active (in-progress) vs named saved sessions ─────────────────
    const activeSessions = savedSessions.filter(s => s.is_in_progress === true);
    const namedSessions  = savedSessions.filter(s => s.is_in_progress !== true);

    // ── "Resume Active Session" banner (cross-device live sessions) ──────────
    activeSessions.forEach(session => {
      const progress = session.progress_percent || 0;
      const answered = session.answered_questions || 0;
      const total    = session.total_questions || 0;
      const lastSaved = session.last_auto_saved_at
        ? new Date(session.last_auto_saved_at).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })
        : '';

      let topicNames = [];
      try {
        const cfg = typeof session.test_config === 'string'
          ? JSON.parse(session.test_config) : (session.test_config || {});
        if (Array.isArray(cfg.selectedTopicNames) && cfg.selectedTopicNames.length) {
          topicNames = cfg.selectedTopicNames;
        }
      } catch (e) { /* ignore */ }
      if (!topicNames.length) {
        try {
          const qs = typeof session.questions === 'string'
            ? JSON.parse(session.questions) : (session.questions || []);
          topicNames = [...new Set(qs.map(q => q.category).filter(Boolean))];
        } catch (e) { /* ignore */ }
      }
      const topicLabel = topicNames.length
        ? topicNames.slice(0, 2).join(', ') + (topicNames.length > 2 ? ` +${topicNames.length - 2}` : '')
        : 'Active Session';

      const banner = document.createElement('div');
      banner.style.cssText = [
        'background:linear-gradient(135deg,rgba(201,168,76,0.12) 0%,rgba(201,168,76,0.06) 100%)',
        'border:1.5px solid rgba(201,168,76,0.55)',
        'border-radius:16px',
        'padding:18px 22px',
        'margin-bottom:14px',
        'position:relative',
        'overflow:hidden',
        'box-shadow:0 0 24px rgba(201,168,76,0.15),0 4px 20px rgba(0,0,0,0.4)',
      ].join(';');

      banner.innerHTML = `
        <!-- pulsing glow strip -->
        <div style="position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,rgba(201,168,76,0.9),transparent);animation:activePulse 2s ease-in-out infinite"></div>
        <style>@keyframes activePulse{0%,100%{opacity:0.4}50%{opacity:1}}</style>

        <div style="display:flex;align-items:center;justify-content:space-between;gap:14px;flex-wrap:wrap">
          <div style="display:flex;align-items:center;gap:12px;flex:1;min-width:0">
            <!-- live dot -->
            <div style="position:relative;flex-shrink:0">
              <div style="width:12px;height:12px;border-radius:50%;background:#c9a84c;animation:activePulse 1.4s ease-in-out infinite"></div>
              <div style="position:absolute;inset:-4px;border-radius:50%;background:rgba(201,168,76,0.25);animation:activePulse 1.4s ease-in-out infinite"></div>
            </div>
            <div style="min-width:0">
              <div style="display:flex;align-items:center;gap:7px;margin-bottom:3px">
                <span style="font-family:'Inter',sans-serif;font-size:11px;font-weight:800;letter-spacing:0.8px;text-transform:uppercase;color:#c9a84c">Active Session</span>
                ${lastSaved ? `<span style="font-size:10.5px;color:#64748b;font-weight:500">· saved ${lastSaved}</span>` : ''}
              </div>
              <div style="font-family:'Playfair Display',serif;font-size:15px;font-weight:700;color:#f1f5f9;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${topicLabel}</div>
              <div style="margin-top:6px;display:flex;align-items:center;gap:8px">
                <div style="flex:1;max-width:160px;background:rgba(255,255,255,0.08);border-radius:100px;height:5px;overflow:hidden">
                  <div style="background:linear-gradient(90deg,#c9a84c,#d4b56a);height:100%;width:${progress}%;border-radius:100px;box-shadow:0 0 6px rgba(201,168,76,0.5)"></div>
                </div>
                <span style="font-size:12px;color:#94a3b8;font-weight:600">${answered}/${total}</span>
              </div>
            </div>
          </div>

          <button onclick="loadSavedSession('${session.id}')"
            style="flex-shrink:0;background:linear-gradient(135deg,#c9a84c 0%,#d4b56a 100%);color:#020617;border:none;padding:10px 20px;border-radius:10px;font-family:'Inter',sans-serif;font-weight:800;cursor:pointer;font-size:13px;letter-spacing:0.3px;transition:all 0.2s;box-shadow:0 2px 12px rgba(201,168,76,0.30);display:flex;align-items:center;gap:7px;white-space:nowrap"
            onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 6px 20px rgba(201,168,76,0.45)'"
            onmouseout="this.style.transform='translateY(0)';this.style.boxShadow='0 2px 12px rgba(201,168,76,0.30)'">
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>
            Resume
          </button>
        </div>
      `;
      listContainer.appendChild(banner);
    });

    // ── Named saved sessions ─────────────────────────────────────────────────
    if (namedSessions.length === 0 && activeSessions.length > 0) {
      // Only active sessions exist — no named saves to show, that's fine
    }

    namedSessions.forEach((session, idx) => {
      const savedDate = new Date(session.saved_at);
      const progress = session.progress_percent || 0;
      const answered = session.answered_questions || 0;
      const total = session.total_questions || 0;

      // Format date elegantly
      const dateStr = savedDate.toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });
      const timeStr = savedDate.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });

      // Progress status label
      const statusLabel = progress === 0 ? 'Not started' : progress === 100 ? 'Complete' : `${progress}% complete`;
      const statusColor = progress === 100 ? '#10b981' : progress > 50 ? '#c9a84c' : '#94a3b8';

      // ── Extract topic/subject names ──────────────────────────────────────
      // Primary: selectedTopicNames from test_config (always most accurate)
      let topicNames = [];
      try {
        const cfg = typeof session.test_config === 'string'
          ? JSON.parse(session.test_config)
          : (session.test_config || {});
        if (Array.isArray(cfg.selectedTopicNames) && cfg.selectedTopicNames.length) {
          topicNames = cfg.selectedTopicNames;
        }
      } catch (e) { /* ignore */ }

      // Fallback: derive unique categories from the questions array
      if (!topicNames.length) {
        try {
          const qs = typeof session.questions === 'string'
            ? JSON.parse(session.questions)
            : (session.questions || []);
          topicNames = [...new Set(qs.map(q => q.category).filter(Boolean))];
        } catch (e) { /* ignore */ }
      }

      // Cap display to 4 pills + overflow badge
      const MAX_PILLS = 4;
      const visibleTopics = topicNames.slice(0, MAX_PILLS);
      const overflowCount = topicNames.length - visibleTopics.length;

      const topicPillsHtml = visibleTopics.length
        ? visibleTopics.map(name =>
            `<span style="display:inline-flex;align-items:center;background:rgba(201,168,76,0.09);border:1px solid rgba(201,168,76,0.22);color:#c9a84c;padding:3px 9px;border-radius:100px;font-size:11px;font-weight:600;letter-spacing:0.1px;white-space:nowrap;max-width:160px;overflow:hidden;text-overflow:ellipsis" title="${name}">${name}</span>`
          ).join('')
          + (overflowCount > 0
            ? `<span style="display:inline-flex;align-items:center;background:rgba(255,255,255,0.05);border:1px solid rgba(255,255,255,0.10);color:#64748b;padding:3px 9px;border-radius:100px;font-size:11px;font-weight:600">+${overflowCount} more</span>`
            : '')
        : `<span style="font-size:11.5px;color:#475569;font-style:italic">All topics</span>`;

      const card = document.createElement('div');
      card.style.cssText = [
        'background:rgba(15,23,42,0.80)',
        'border:1px solid rgba(201,168,76,0.18)',
        'border-radius:16px',
        'padding:0',
        'overflow:hidden',
        'transition:border-color 0.2s,box-shadow 0.2s,transform 0.2s',
        'box-shadow:0 4px 20px rgba(0,0,0,0.35)',
        'position:relative',
      ].join(';');

      card.onmouseenter = () => {
        card.style.borderColor = 'rgba(201,168,76,0.50)';
        card.style.boxShadow = '0 8px 32px rgba(201,168,76,0.12),0 2px 8px rgba(0,0,0,0.4)';
        card.style.transform = 'translateY(-2px)';
      };
      card.onmouseleave = () => {
        card.style.borderColor = 'rgba(201,168,76,0.18)';
        card.style.boxShadow = '0 4px 20px rgba(0,0,0,0.35)';
        card.style.transform = 'translateY(0)';
      };

      card.innerHTML = `
        <!-- Gold top accent line -->
        <div style="height:2px;background:linear-gradient(90deg,transparent 0%,rgba(201,168,76,0.6) 40%,rgba(201,168,76,0.6) 60%,transparent 100%)"></div>

        <div style="padding:20px 22px 22px">
          <!-- Header row -->
          <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;margin-bottom:14px">
            <div style="flex:1;min-width:0">
              <!-- Session index badge + name -->
              <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px">
                <span style="display:inline-flex;align-items:center;justify-content:center;width:26px;height:26px;border-radius:7px;background:rgba(201,168,76,0.12);border:1px solid rgba(201,168,76,0.28);font-family:'Inter',sans-serif;font-size:11px;font-weight:800;color:#c9a84c;flex-shrink:0">${idx + 1}</span>
                <h4 style="font-family:'Playfair Display',serif;font-size:16px;font-weight:700;color:#f1f5f9;margin:0;letter-spacing:-0.01em;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${session.session_name}</h4>
              </div>
              <!-- Date line -->
              <div style="display:flex;align-items:center;gap:6px;padding-left:36px">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2.5" stroke-linecap="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                <span style="font-size:12px;color:#64748b;font-weight:500;letter-spacing:0.1px">${dateStr} &middot; ${timeStr}</span>
              </div>
            </div>

            <!-- Delete button -->
            <button onclick="deleteSavedSession('${session.id}', event)"
              style="flex-shrink:0;background:transparent;border:1px solid rgba(239,68,68,0.22);color:rgba(239,68,68,0.7);padding:6px 12px;border-radius:8px;font-family:'Inter',sans-serif;font-weight:600;font-size:11.5px;cursor:pointer;transition:all 0.15s;letter-spacing:0.2px;display:flex;align-items:center;gap:5px"
              onmouseover="this.style.background='rgba(239,68,68,0.10)';this.style.borderColor='rgba(239,68,68,0.6)';this.style.color='#f87171'"
              onmouseout="this.style.background='transparent';this.style.borderColor='rgba(239,68,68,0.22)';this.style.color='rgba(239,68,68,0.7)'">
              <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/></svg>
              Delete
            </button>
          </div>

          <!-- Topics / subjects pills -->
          <div style="display:flex;align-items:center;gap:6px;flex-wrap:wrap;padding:10px 12px;background:rgba(255,255,255,0.03);border:1px solid rgba(255,255,255,0.06);border-radius:10px;margin-bottom:16px">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
            ${topicPillsHtml}
          </div>

          <!-- Progress section -->
          <div style="margin-bottom:18px">
            <!-- Labels row -->
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:9px">
              <div style="display:flex;align-items:center;gap:6px">
                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2.5" stroke-linecap="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                <span style="font-size:12px;color:#64748b;font-weight:600;text-transform:uppercase;letter-spacing:0.6px">Progress</span>
              </div>
              <div style="display:flex;align-items:center;gap:8px">
                <span style="font-size:12px;font-weight:700;color:${statusColor};letter-spacing:0.1px">${statusLabel}</span>
                <span style="font-size:13px;font-weight:700;color:#c9a84c">${answered}<span style="color:#475569;font-weight:500">/${total}</span></span>
              </div>
            </div>
            <!-- Progress bar -->
            <div style="background:rgba(255,255,255,0.06);border-radius:100px;height:6px;overflow:hidden;border:1px solid rgba(255,255,255,0.05)">
              <div style="background:linear-gradient(90deg,#c9a84c 0%,#d4b56a 100%);height:100%;width:${progress}%;transition:width 0.5s cubic-bezier(0.4,0,0.2,1);border-radius:100px;box-shadow:0 0 8px rgba(201,168,76,0.4)"></div>
            </div>
          </div>

          <!-- Continue button -->
          <button onclick="loadSavedSession('${session.id}')"
            style="width:100%;background:linear-gradient(135deg,#c9a84c 0%,#d4b56a 100%);color:#020617;border:none;padding:13px 20px;border-radius:10px;font-family:'Inter',sans-serif;font-weight:800;cursor:pointer;font-size:14px;letter-spacing:0.3px;transition:all 0.2s;box-shadow:0 2px 12px rgba(201,168,76,0.25);display:flex;align-items:center;justify-content:center;gap:8px"
            onmouseover="this.style.transform='translateY(-1px)';this.style.boxShadow='0 6px 20px rgba(201,168,76,0.40)'"
            onmouseout="this.style.transform='translateY(0)';this.style.boxShadow='0 2px 12px rgba(201,168,76,0.25)'">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>
            Continue Examination
          </button>
        </div>
      `;

      listContainer.appendChild(card);
    });
    
  } catch (error) {
    console.error('Error loading saved sessions:', error);
  }
}

async function loadSavedSession(sessionId) {
  try {
    if (!db) {
      if (!initializeSupabase()) {
        showToast('Database not configured. Cannot load saved test.', 'error');
        return;
      }
    }

    const { data: session, error } = await db
      .from('saved_test_sessions')
      .select('*')
      .eq('id', sessionId)
      .eq('student_id', getOwnerId())  // enforce ownership at fetch time
      .single();
    
    if (error || !session) {
      console.error('Error loading session:', error);
      if (error && (String(error.message || '').includes('saved_test_sessions') || error.code === '42P01')) {
        showToast('Missing table. Run ADD-SAVED-TEST-SESSIONS-TABLE.sql in Supabase.', 'error');
      } else {
        showToast('Session not found', 'error');
      }
      return;
    }
    
    const parseSessionField = (value, fallback) => {
      if (value === null || value === undefined) return fallback;
      if (typeof value === 'string') {
        try {
          return JSON.parse(value);
        } catch (e) {
          return fallback;
        }
      }
      return value;
    };

  const parsedAnswers = parseSessionField(session.answers, {});
  const parsedAnswerStatus = parseSessionField(session.answer_status, {});
  const parsedFlagged = parseSessionField(session.flagged_questions, []);
  const parsedQuestions = parseSessionField(session.questions, []);

    // Restore test state
    testState.testId = session.test_id;
  testState.sessionId = session.session_id;
  testState.savedSessionDbId = session.id;
    testState.currentIndex = session.current_question_index;
  testState.answers = parsedAnswers || {};
  testState.answerStatus = parsedAnswerStatus || {};
    testState.flagged = new Set(parsedFlagged || []);
    testState.questions = parsedQuestions || [];
    testState.startTime = session.start_time ? new Date(session.start_time).getTime() : Date.now();
    testState.studentId = session.student_id;
    
    // ── RELOAD FULL QUESTIONS FROM DATABASE ──────────────────────────────
    // The session only saved {id, topic_id} stubs to keep the payload slim.
    // We need to fetch the full question bodies and restore the stored order.
    if (testState.questions.length > 0) {
      const loadingScreen = document.getElementById('loadingScreen');
      if (loadingScreen) {
        loadingScreen.style.display = 'flex';
        loadingScreen.innerHTML = `
          <div class="spinner"></div>
          <h2>Loading Session...</h2>
          <p>Restoring question data</p>
        `;
      }

      // Extract all question IDs from the stubs
      const questionIdsToFetch = testState.questions.map(q => q.id);
      
      // Fetch full question data from DB
      const { data: fullQuestionsList, error: qError } = await db
        .from('test_questions')
        .select('id, test_id, question_stem, question_stem_hy, options, options_hy, correct_answers, is_multiple_choice, rationale, rationale_hy, category, display_order, points, is_active, topic_id')
        .in('id', questionIdsToFetch);

      if (qError) {
        console.error('Error fetching full questions for saved session:', qError);
        showToast('Failed to load full question data. Please try again.', 'error');
        return;
      }

      // Map the array into a dictionary for quick lookup by ID
      const fullQMap = {};
      (fullQuestionsList || []).forEach(q => {
        fullQMap[q.id] = {
          id: q.id,
          stem: q.question_stem,
          stem_hy: q.question_stem_hy || null,
          options: q.options,
          options_hy: q.options_hy || null,
          correct: q.correct_answers,
          multi: q.is_multiple_choice,
          rationale: q.rationale,
          rationale_hy: q.rationale_hy || null,
          category: q.category,
          points: q.points || 1,
          displayOrder: q.display_order,
          topic_id: q.topic_id
        };
      });

      // Rebuild testState.questions with full DB records, perfectly matching the saved order
      // (This retains the shuffled order from the exact moment the test started)
      testState.questions = testState.questions.map(stub => {
        if (stub.id === 'english-disclaimer-q0') {
          return buildEnglishDisclaimerQuestion();
        }
        return fullQMap[stub.id];
      }).filter(Boolean);
    }

  // Restore test config
  const parsedConfig = parseSessionField(session.test_config, {});
  Object.assign(TEST_CONFIG, parsedConfig || {});

  // Regenerate the exact shuffle seed used when the session started
  testState.shuffleSeed = deriveShuffleSeed(
    TEST_CONFIG.testId,
    TEST_CONFIG.selectedTopicIds
  );

  // Re-apply options shuffling so the snapshot builds correctly
  if (TEST_CONFIG.shuffleOptions && testState.questions && testState.questions.length > 0) {
    testState.questions = testState.questions.map(q => {
      // If the question is a full object (not just a stub)
      if (q.options) {
        return {
          ...q,
          options: shuffleArray(q.options, testState.shuffleSeed + q.id.toString().charCodeAt(0))
        };
      }
      return q;
    });
  }

  // ── Rebuild the bilingual snapshot from the restored questions ──────────
  // Prefer snapshot columns if they were saved (post-feature sessions),
  // otherwise rebuild from the questions array that was persisted.
  if (session.session_snapshot_en) {
    testState.snapshot = {
      en: session.session_snapshot_en,
      hy: session.session_snapshot_hy || null
    };
    console.log('🌐 Bilingual snapshot restored from saved_test_sessions');
  } else {
    testState.snapshot = buildBilingualSnapshot(testState.questions);
    console.log('🌐 Bilingual snapshot rebuilt from saved questions');
  }
  applyLanguagePicker();
    
    // Show test container
    document.getElementById('startScreen').style.display = 'none';
    const loadingScreen = document.getElementById('loadingScreen');
    if (loadingScreen) loadingScreen.style.display = 'none';
    document.getElementById('testContainer').style.display = 'block';
    
    // Render question
    renderQuestion();
    renderQuestionNavigator();
    
    // Start timer if configured
    if (TEST_CONFIG.timeLimit > 0) {
      startTimer();
    }
    
    showToast('Test resumed successfully!', 'success');
    
  } catch (error) {
    console.error('Error loading saved session:', error);
    showToast('Failed to load session. Please try again.', 'error');
  }
}

// ── Premium confirmation dialog (replaces browser confirm()) ──────────────────
function showDeleteConfirm(message) {
  return new Promise((resolve) => {
    // Remove any existing instance
    const existing = document.getElementById('_deleteConfirmOverlay');
    if (existing) existing.remove();

    const overlay = document.createElement('div');
    overlay.id = '_deleteConfirmOverlay';
    overlay.style.cssText = [
      'position:fixed','inset:0','z-index:99999',
      'display:flex','align-items:center','justify-content:center',
      'background:rgba(2,6,23,0.85)',
      'animation:_dcFadeIn 0.15s ease',
    ].join(';');

    overlay.innerHTML = `
      <style>
        @keyframes _dcFadeIn{from{opacity:0}to{opacity:1}}
        @keyframes _dcSlideUp{from{opacity:0;transform:translateY(12px) scale(0.97)}to{opacity:1;transform:translateY(0) scale(1)}}
      </style>
      <div style="
        background:#0f172a;
        border:1px solid rgba(201,168,76,0.22);
        border-radius:16px;
        padding:28px 28px 24px;
        max-width:380px;
        width:calc(100% - 48px);
        box-shadow:0 24px 60px rgba(0,0,0,0.6),0 0 0 1px rgba(255,255,255,0.04);
        animation:_dcSlideUp 0.18s cubic-bezier(0.34,1.56,0.64,1);
        position:relative;
        overflow:hidden;
      ">
        <!-- Top gold accent -->
        <div style="position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,transparent,rgba(201,168,76,0.5),transparent)"></div>

        <!-- Icon -->
        <div style="display:flex;align-items:center;justify-content:center;width:44px;height:44px;border-radius:12px;background:rgba(239,68,68,0.10);border:1px solid rgba(239,68,68,0.22);margin:0 auto 16px;flex-shrink:0">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#f87171" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/>
          </svg>
        </div>

        <!-- Title -->
        <h4 style="font-family:'Playfair Display',serif;font-size:17px;font-weight:700;color:#f1f5f9;text-align:center;margin:0 0 10px;letter-spacing:-0.01em">Confirm Deletion</h4>

        <!-- Message -->
        <p style="font-size:13.5px;color:#94a3b8;text-align:center;line-height:1.65;margin:0 0 24px;font-weight:400">${message}</p>

        <!-- Buttons -->
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
          <button id="_dcCancel" style="
            background:rgba(255,255,255,0.05);
            border:1px solid rgba(255,255,255,0.12);
            color:#94a3b8;
            padding:11px;
            border-radius:10px;
            font-family:'Inter',sans-serif;
            font-weight:600;
            font-size:13.5px;
            cursor:pointer;
            transition:all 0.15s;
            letter-spacing:0.1px;
          "
          onmouseover="this.style.background='rgba(255,255,255,0.08)';this.style.color='#e2e8f0'"
          onmouseout="this.style.background='rgba(255,255,255,0.05)';this.style.color='#94a3b8'">
            Cancel
          </button>
          <button id="_dcConfirm" style="
            background:rgba(239,68,68,0.12);
            border:1px solid rgba(239,68,68,0.30);
            color:#f87171;
            padding:11px;
            border-radius:10px;
            font-family:'Inter',sans-serif;
            font-weight:700;
            font-size:13.5px;
            cursor:pointer;
            transition:all 0.15s;
            letter-spacing:0.1px;
          "
          onmouseover="this.style.background='rgba(239,68,68,0.22)';this.style.borderColor='rgba(239,68,68,0.55)'"
          onmouseout="this.style.background='rgba(239,68,68,0.12)';this.style.borderColor='rgba(239,68,68,0.30)'">
            Delete
          </button>
        </div>
      </div>
    `;

    document.body.appendChild(overlay);

    const dismiss = (result) => {
      overlay.style.animation = 'none';
      overlay.style.opacity = '0';
      overlay.style.transition = 'opacity 0.12s';
      setTimeout(() => overlay.remove(), 120);
      resolve(result);
    };

    document.getElementById('_dcCancel').onclick = () => dismiss(false);
    document.getElementById('_dcConfirm').onclick = () => dismiss(true);
    overlay.addEventListener('click', (e) => { if (e.target === overlay) dismiss(false); });
    document.addEventListener('keydown', function esc(e) {
      if (e.key === 'Escape') { document.removeEventListener('keydown', esc); dismiss(false); }
    });
  });
}

async function deleteSavedSession(sessionId, event) {
  event.stopPropagation();

  // Premium inline confirmation dialog
  const confirmed = await showDeleteConfirm('Delete this saved session? Your progress will be permanently removed.');
  if (!confirmed) return;

  try {
    const { error } = await db
      .from('saved_test_sessions')
      .delete()
      .eq('id', sessionId)
      .eq('student_id', getOwnerId());  // safety: can only delete own rows
    
    if (error) {
      console.error('Error deleting session:', error);
      showToast('Failed to delete session', 'error');
      return;
    }
    
    // Reload both lists
    loadSavedSessions();
    loadSavedTestsInModal();
    showToast('Session deleted', 'info');
    
  } catch (error) {
    console.error('Error deleting saved session:', error);
    showToast('Failed to delete session', 'error');
  }
}

// Show/Close Saved Tests Modal
async function showSavedTestsModal() {
  document.getElementById('savedTestsModal').classList.add('active');
  await loadSavedTestsInModal();
}

function closeSavedTestsModal() {
  document.getElementById('savedTestsModal').classList.remove('active');
}

async function clearOngoingTest(event) {
  event.stopPropagation();
  const confirmed = await showDeleteConfirm('Delete this ongoing session? Your local progress will be lost.');
  if (!confirmed) return;
  const key = 'acnhs_test_session_' + getOwnerId();
  localStorage.removeItem(key);
  // Re-render the list to reflect the deletion
  loadSavedTestsInModal();
}

async function loadSavedTestsInModal() {
  try {
    // Initialize Supabase if not already done
    if (!db) {
      if (!initializeSupabase()) {
        throw new Error('Cannot connect to database');
      }
    }
    
    const role = SESSION_ROLE.userRole || 'student';
    let modalQuery = db.from('saved_test_sessions')
      .select('*')
      .eq('student_id', getOwnerId())
      .eq('is_in_progress', false)   // modal shows only named/completed saves
      .eq('user_role', role)
      .order('created_at', { ascending: false });

    const { data: savedSessions, error } = await modalQuery;
    
    if (error) {
      console.error('Error loading sessions:', error);
      showToast('Failed to load saved tests', 'error');
    }
    
    const listContainer = document.getElementById('savedTestsList');
    
    // Check for ongoing test in localStorage
    const ongoingTest = loadFromLocalStorage();
    const hasOngoing = ongoingTest && ongoingTest.sessionId;
    const hasSaved = savedSessions && savedSessions.length > 0;
    
    if (!hasOngoing && !hasSaved) {
      listContainer.innerHTML = `
        <div style="text-align:center;padding:56px 20px;display:flex;flex-direction:column;align-items:center;">
          <div style="width:60px;height:60px;background:rgba(201,168,76,0.07);border:1.5px solid rgba(201,168,76,0.2);border-radius:16px;display:flex;align-items:center;justify-content:center;margin-bottom:20px;">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="var(--gold-primary)" stroke-width="1.8">
              <path d="M3 9h18v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V9Z"/>
              <path d="M3 9V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v4"/>
              <line x1="12" y1="3" x2="12" y2="9"/>
            </svg>
          </div>
          <div style="font-family:'Playfair Display',serif;font-size:18px;font-weight:700;color:#e2e8f0;margin-bottom:8px;">No Saved Sessions</div>
          <p style="font-size:13.5px;color:var(--text-muted);margin:0;line-height:1.6;max-width:280px;">Start a test and click "Save for Later" to create a saved session.</p>
        </div>
      `;
      return;
    }
    
    listContainer.innerHTML = '';
    
    // Show ongoing test first if it exists
    if (hasOngoing) {
      const answeredCount = Object.keys(ongoingTest.answers || {}).length;
      const totalQuestions = ongoingTest.questionIds ? ongoingTest.questionIds.length : 0;
      const progress = totalQuestions > 0 ? Math.round((answeredCount / totalQuestions) * 100) : 0;
      const testName = TEST_CONFIG.testTitle || 'Ongoing Test';
      
      const ongoingCard = document.createElement('div');
      ongoingCard.style.cssText = 'background:rgba(201,168,76,0.07);border:1.5px solid rgba(201,168,76,0.35);border-radius:14px;padding:20px;margin-bottom:14px;transition:all 0.15s;';
      ongoingCard.onmouseenter = () => { ongoingCard.style.borderColor = 'rgba(201,168,76,0.6)'; ongoingCard.style.background = 'rgba(201,168,76,0.1)'; };
      ongoingCard.onmouseleave = () => { ongoingCard.style.borderColor = 'rgba(201,168,76,0.35)'; ongoingCard.style.background = 'rgba(201,168,76,0.07)'; };

      ongoingCard.innerHTML = `
        <div style="display:flex;align-items:center;justify-content:space-between;gap:12px;margin-bottom:14px;">
          <div style="display:flex;align-items:center;gap:12px;min-width:0;">
            <div style="width:36px;height:36px;background:rgba(201,168,76,0.15);border:1.5px solid rgba(201,168,76,0.4);border-radius:9px;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--gold-primary)" stroke-width="2.2"><polygon points="5 3 19 12 5 21 5 3"/></svg>
            </div>
            <div style="min-width:0;">
              <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
                <span style="font-size:14px;font-weight:700;color:#f1f5f9;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:220px;">${testName}</span>
                <span style="background:rgba(201,168,76,0.2);border:1px solid rgba(201,168,76,0.4);color:var(--gold-primary);font-size:9px;font-weight:800;padding:2px 8px;border-radius:20px;text-transform:uppercase;letter-spacing:0.8px;flex-shrink:0;">Ongoing</span>
              </div>
              <div style="font-size:11.5px;color:var(--text-muted);margin-top:3px;">${totalQuestions} Questions</div>
            </div>
          </div>
          <button onclick="clearOngoingTest(event)"
            style="flex-shrink:0;background:rgba(239,68,68,0.08);border:1.5px solid rgba(239,68,68,0.25);color:#f87171;padding:5px 12px;border-radius:7px;font-size:11px;font-weight:700;cursor:pointer;transition:all 0.15s;"
            onmouseover="this.style.background='rgba(239,68,68,0.15)';this.style.borderColor='rgba(239,68,68,0.5)'"
            onmouseout="this.style.background='rgba(239,68,68,0.08)';this.style.borderColor='rgba(239,68,68,0.25)'">
            Delete
          </button>
        </div>
        <div style="margin-bottom:14px;">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;">
            <span style="font-size:11px;font-weight:700;letter-spacing:0.7px;text-transform:uppercase;color:var(--text-muted);">Progress</span>
            <span style="font-size:12px;font-weight:700;color:var(--gold-light);">${answeredCount}/${totalQuestions} (${progress}%)</span>
          </div>
          <div style="background:rgba(255,255,255,0.06);border-radius:6px;height:6px;overflow:hidden;">
            <div style="background:linear-gradient(90deg,var(--gold-primary),var(--gold-light));height:100%;width:${progress}%;border-radius:6px;transition:width 0.4s ease;"></div>
          </div>
        </div>
        <button onclick="handleResumeOngoingTest()"
          style="width:100%;background:linear-gradient(135deg,var(--gold-primary),var(--gold-light));color:var(--navy-deep);border:none;padding:11px;border-radius:9px;font-weight:800;cursor:pointer;font-size:13.5px;letter-spacing:0.2px;transition:all 0.15s;"
          onmouseover="this.style.opacity='0.9';this.style.transform='translateY(-1px)'"
          onmouseout="this.style.opacity='1';this.style.transform='translateY(0)'">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" style="flex-shrink:0"><polygon points="5,3 19,12 5,21"/></svg>
          Continue Ongoing Test
        </button>
      `;
      
      listContainer.appendChild(ongoingCard);
    }
    
    // Show saved database sessions
    if (hasSaved) {
      savedSessions.forEach((session) => {
        const savedDate = new Date(session.saved_at);
        const progress = session.progress_percent || 0;
        
        const card = document.createElement('div');
        card.style.cssText = 'background:var(--navy-light);border:1.5px solid var(--navy-border);border-radius:14px;padding:18px 20px;margin-bottom:12px;transition:all 0.15s;';
        card.onmouseenter = () => { card.style.borderColor = 'rgba(201,168,76,0.4)'; card.style.background = 'rgba(201,168,76,0.04)'; };
        card.onmouseleave = () => { card.style.borderColor = 'var(--navy-border)'; card.style.background = 'var(--navy-light)'; };

        card.innerHTML = `
          <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:12px;">
            <div style="min-width:0;">
              <div style="font-size:14px;font-weight:700;color:#f1f5f9;margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:300px;">${session.session_name}</div>
              <div style="font-size:11.5px;color:var(--text-muted);">Saved ${savedDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })} · ${savedDate.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}</div>
            </div>
            <button onclick="deleteSavedSession('${session.id}', event)"
              style="flex-shrink:0;background:rgba(239,68,68,0.08);border:1.5px solid rgba(239,68,68,0.25);color:#f87171;padding:5px 12px;border-radius:7px;font-size:11px;font-weight:700;cursor:pointer;transition:all 0.15s;"
              onmouseover="this.style.background='rgba(239,68,68,0.15)';this.style.borderColor='rgba(239,68,68,0.5)'"
              onmouseout="this.style.background='rgba(239,68,68,0.08)';this.style.borderColor='rgba(239,68,68,0.25)'">
              Delete
            </button>
          </div>
          <div style="margin-bottom:14px;">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;">
              <span style="font-size:11px;font-weight:700;letter-spacing:0.7px;text-transform:uppercase;color:var(--text-muted);">Progress</span>
              <span style="font-size:12px;font-weight:700;color:var(--gold-light);">${session.answered_questions}/${session.total_questions} (${progress}%)</span>
            </div>
            <div style="background:rgba(255,255,255,0.06);border-radius:6px;height:6px;overflow:hidden;">
              <div style="background:linear-gradient(90deg,var(--gold-primary),var(--gold-light));height:100%;width:${progress}%;border-radius:6px;transition:width 0.4s ease;"></div>
            </div>
          </div>
          <button onclick="loadSavedSessionFromModal('${session.id}')"
            style="width:100%;background:linear-gradient(135deg,var(--gold-primary),var(--gold-light));color:var(--navy-deep);border:none;padding:10px;border-radius:9px;font-weight:800;cursor:pointer;font-size:13px;letter-spacing:0.2px;transition:all 0.15s;"
            onmouseover="this.style.opacity='0.9';this.style.transform='translateY(-1px)'"
            onmouseout="this.style.opacity='1';this.style.transform='translateY(0)'">
            Continue Test
          </button>
        `;
        
        listContainer.appendChild(card);
      });
    }
    
  } catch (error) {
    console.error('Error loading saved sessions in modal:', error);
    showToast('Failed to load saved tests', 'error');
  }
}

async function resumeOngoingTest() {
  try {
    console.log('📂 Resuming ongoing test...');
    
    // Close modals
    closeSavedTestsModal();
    const subjectModal = document.getElementById('subjectModal');
    if (subjectModal) {
      subjectModal.classList.add('hidden');
    }
    
    // Get the saved test from localStorage
    const saved = loadFromLocalStorage();
    if (!saved) {
      console.error('❌ No saved test found in localStorage');
      showToast('No ongoing test found', 'error');
      return;
    }
    
    console.log('✓ Found saved test:', saved);
    
    // Initialize Supabase if needed
    if (!db) {
      console.log('🔌 Initializing Supabase...');
      if (!initializeSupabase()) {
        showToast('Cannot connect to database', 'error');
        return;
      }
    }
    
    // Show loading
    document.getElementById('startScreen').style.display = 'none';
    const loadingScreen = document.getElementById('loadingScreen');
    loadingScreen.style.display = 'flex';
    loadingScreen.innerHTML = `
      <div class="start-content">
        <div class="loading" style="width:60px;height:60px;margin:0 auto 24px"></div>
        <p style="color:#cbd5e1;font-size:18px">Resuming your test...</p>
      </div>
    `;
    
    // Load test configuration
    TEST_CONFIG.testId = saved.testId;
    console.log('📖 Loading test configuration for:', saved.testId);
    await loadTestConfiguration(saved.testId);
    
    // Resume the test state
    console.log('🔄 Restoring test state...');
    await resumeTest(saved);
    
    // Hide loading screen, show test container
    loadingScreen.style.display = 'none';
    document.getElementById('testContainer').style.display = 'block';
    
    // Prevent accidental page leave
    window.addEventListener('beforeunload', handleBeforeUnload);
    
    console.log('✅ Test resumed successfully');
    showToast('Resumed ongoing test', 'success');
    
  } catch (error) {
    console.error('❌ Failed to resume test:', error);
    showToast('Failed to resume test: ' + error.message, 'error');
    
    // Show error on loading screen
    const loadingScreen = document.getElementById('loadingScreen');
    if (loadingScreen) {
      loadingScreen.style.display = 'flex';
      loadingScreen.innerHTML = `
        <div class="start-content">
          <h1 style="color:white;margin-bottom:16px">Error</h1>
          <p style="color:#cbd5e1;font-size:18px;margin-bottom:32px">${error.message || 'Failed to resume test'}</p>
          <button class="btn btn-primary" onclick="location.reload()">Try Again</button>
        </div>
      `;
    }
    document.getElementById('startScreen').style.display = 'none';
    document.getElementById('testContainer').style.display = 'none';
  }
}

// Wrapper function to handle async onclick
function handleResumeOngoingTest() {
  resumeOngoingTest().catch(error => {
    console.error('❌ Error in handleResumeOngoingTest:', error);
    showToast('Failed to resume test', 'error');
  });
}

function closeSubjectModal() {
  const modal = document.getElementById('subjectModal');
  if (modal) {
    modal.classList.add('hidden');
  }
}

async function loadSavedSessionFromModal(sessionId) {
  closeSavedTestsModal();
  closeSubjectModal();
  await loadSavedSession(sessionId);
}

// Resume test modal functions
let resumeTestResolver = null;

function showResumeTestModal() {
  return new Promise((resolve) => {
    resumeTestResolver = resolve;
    document.getElementById('resumeTestModal').classList.add('active');
  });
}

function closeResumeModal(shouldResume) {
  document.getElementById('resumeTestModal').classList.remove('active');
  if (resumeTestResolver) {
    resumeTestResolver(shouldResume);
    resumeTestResolver = null;
  }
}

function submitTest(autoSubmit = false) {
  closeSubmitModal();
  
  testState.endTime = Date.now();
  clearInterval(testState.timerInterval);
  window.removeEventListener('beforeunload', handleBeforeUnload);

  // Cancel any pending auto-saves
  if (autoSaveTimer) { clearTimeout(autoSaveTimer); autoSaveTimer = null; }

  // Mark the auto-save row as complete so it won't show as "resume" on other devices
  if (testState.autoSaveDbId && db) {
    db.from('saved_test_sessions')
      .update({ is_in_progress: false, last_auto_saved_at: new Date().toISOString() })
      .eq('id', testState.autoSaveDbId)
      .then(() => {})
      .catch(() => {});
    testState.autoSaveDbId = null;
  }
  
  // Calculate results
  const results = calculateResults();
  
  // Save to Supabase (async, non-blocking)
  saveTestAttempt(results).then(attempt => {
    if (attempt) {
      console.log('Test attempt saved with ID:', attempt.id);
    }
  });

  // Save permanent grade record and load history
  saveTestGrade(results).then(history => {
    renderGradesCard(history, results.scorePercent);
  });
  
  // Hide test container
  document.getElementById('testContainer').style.display = 'none';
  
  // Show results
  displayResults(results);
  
  clearLocalStorage();
  
  if (autoSubmit) {
    showToast('Test auto-submitted due to time limit', 'info');
  }
}

function calculateResults() {
  let correct = 0;
  let incorrect = 0;
  let skipped = 0;
  
  const details = testState.questions.map(q => {
    // Skip the English disclaimer question from scoring
    if (q.isDisclaimer) {
      return {
        question: q,
        userAnswer: testState.answers[q.id] || null,
        correctAnswer: q.correct,
        isCorrect: true,
        status: 'correct',
        isDisclaimer: true
      };
    }

    const userAnswer = testState.answers[q.id];
    let isCorrect = false;
    let status = 'skipped';
    
    if (userAnswer !== null && userAnswer !== undefined) {
      // Normalize both sides to sorted string arrays for reliable comparison
      const userSet = new Set(Array.isArray(userAnswer) ? userAnswer.map(String) : [String(userAnswer)]);
      const correctSet = new Set(q.correct.map(String));

      isCorrect = correctSet.size === userSet.size &&
                  [...correctSet].every(id => userSet.has(id));
      
      if (isCorrect) {
        correct++;
        status = 'correct';
      } else {
        incorrect++;
        status = 'incorrect';
      }
    } else {
      skipped++;
    }
    
    return {
      question: q,
      userAnswer: userAnswer,
      correctAnswer: q.correct,
      isCorrect: isCorrect,
      status: status
    };
  });
  
  const totalQuestions = testState.questions.filter(q => !q.isDisclaimer).length;
  const answeredQuestions = correct + incorrect; // only questions the student actually answered
  const scorePercent = answeredQuestions > 0 ? Math.round((correct / answeredQuestions) * 100) : 0;
  const passed = scorePercent >= TEST_CONFIG.passingScorePercent;
  const timeUsed = Math.floor((testState.endTime - testState.startTime) / 1000);
  
  return {
    correct,
    incorrect,
    skipped,
    totalQuestions,
    answeredQuestions,
    scorePercent,
    passed,
    timeUsed,
    details
  };
}

function displayResults(results) {
  const screen = document.getElementById('resultsScreen');
  
  document.getElementById('scoreDisplay').textContent = results.scorePercent + '%';
  document.getElementById('correctCount').textContent = results.correct;
  document.getElementById('incorrectCount').textContent = results.incorrect;
  document.getElementById('skippedCount').textContent = results.skipped;
  document.getElementById('timeUsed').textContent = formatTime(results.timeUsed);

  // Show grading basis note
  const basedOnEl = document.getElementById('scoreBasedOn');
  if (basedOnEl) {
    if (results.skipped > 0) {
      basedOnEl.textContent = `Score based on ${results.answeredQuestions} answered question${results.answeredQuestions !== 1 ? 's' : ''} (${results.skipped} skipped)`;
    } else {
      basedOnEl.textContent = '';
    }
  }
  
  const badge = document.getElementById('passBadge');
  if (results.passed) {
    badge.textContent = '✓ PASS';
    badge.className = 'pass-badge pass';
  } else {
    badge.textContent = '✗ FAIL';
    badge.className = 'pass-badge fail';
  }
  
  screen.style.display = 'block';
  
  // Store results for review
  window.testResults = results;
}

function showReview() {
  if (!TEST_CONFIG.allowReview) {
    showToast('Review mode is not enabled for this test', 'warning');
    return;
  }
  
  const container = document.getElementById('reviewContainer');
  container.innerHTML = '<h2>Answer Review</h2>';
  const frag = document.createDocumentFragment();
  
  window.testResults.details.forEach((detail, index) => {
    const q = detail.question;
    const div = document.createElement('div');
    div.className = 'review-question';
    
    let statusBadge = '';
    if (detail.status === 'correct') {
      statusBadge = '<span class="review-status correct">✓ Correct</span>';
    } else if (detail.status === 'incorrect') {
      statusBadge = '<span class="review-status incorrect">✗ Incorrect</span>';
    } else {
      statusBadge = '<span class="review-status skipped">— Skipped</span>';
    }
    
    let html = `
      <div class="review-header">
        <div class="question-number">Question ${index + 1}</div>
        ${statusBadge}
      </div>
      <div class="review-stem">${q.stem}</div>
    `;
    
    q.options.forEach(opt => {
      const optId = String(opt.id);
      const isCorrect = q.correct.map(String).includes(optId);
      const isUserAnswer = detail.userAnswer !== null && detail.userAnswer !== undefined &&
        (Array.isArray(detail.userAnswer)
          ? detail.userAnswer.map(String).includes(optId)
          : String(detail.userAnswer) === optId);
      
      let className = 'review-option';
      let prefix = '';
      
      if (isCorrect) {
        className += ' correct-answer';
        prefix = '✓ ';
      }
      if (isUserAnswer && !isCorrect) {
        className += ' user-incorrect';
        prefix = '✗ ';
      }
      
      html += `<div class="${className}">${prefix}${opt.text}</div>`;
    });
    
    if (q.rationale) {
      html += `<div class="rationale"><strong>Rationale:</strong> ${q.rationale}</div>`;
    }
    
    div.innerHTML = html;
    frag.appendChild(div);
  });
  container.replaceChildren(frag);
  
  container.style.display = 'block';
  container.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function downloadResults() {
  const data = {
    testTitle: TEST_CONFIG.testTitle,
    studentSession: testState.sessionId,
    completedAt: new Date(testState.endTime).toISOString(),
    timeUsed: formatTime(Math.floor((testState.endTime - testState.startTime) / 1000)),
    score: window.testResults.scorePercent + '%',
    passed: window.testResults.passed,
    correct: window.testResults.correct,
    incorrect: window.testResults.incorrect,
    skipped: window.testResults.skipped,
    total: window.testResults.totalQuestions,
    answers: window.testResults.details.map((d, i) => ({
      questionNumber: i + 1,
      question: d.question.stem,
      userAnswer: d.userAnswer || 'Not answered',
      correctAnswer: d.correctAnswer,
      isCorrect: d.isCorrect
    }))
  };
  
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `ACNHS_Test_Results_${testState.sessionId}.json`;
  a.click();
  URL.revokeObjectURL(url);
  
  showToast('Results downloaded successfully', 'success');
}

// ============================================
// COLD CALL PICKER — TEACHER ONLY
// ============================================
// Loads students by group from Supabase `students` table
// (field: `group`). Cycles through every student in random
// order before any repeats. Persists cycle state per group
// in memory for the page session.
// ============================================

const coldCallState = {
  groups: [],            // [{id, name}] — loaded once
  selectedGroup: null,   // currently selected group name
  students: [],          // full student list for current group
  queue: [],             // remaining students not yet called this round
  calledThisRound: [],   // students already called this round
  lastPicked: null,      // last student shown
  isLoading: false,
  isRolling: false,
  cycleComplete: false,
  // Cache: groupName → student array
  studentCache: new Map(),
  // ── Analytics ────────────────────────────────────────────────
  sessionId: null,         // UUID of current cold_call_sessions row
  sessionStarted: false,
  // Map: student.id → { name, correct: 0, wrong: 0, questions: [] }
  analytics: new Map(),
  currentPickAnswered: false  // whether correct/wrong has been pressed for the current pick
};

// ─── Initialise (called on DOMContentLoaded) ─────────────────────────────────
function initColdCallPicker() {
  if (!SESSION_ROLE.isTeacher) return;
  // Panel starts hidden — nothing to do until teacher opens it
}

// ─── Load distinct groups from the `students` table ──────────────────────────
async function coldCallLoadGroups() {
  const select = document.getElementById('ccGroupSelect');
  if (!select) return;
  select.innerHTML = '<option value="">⏳ Loading groups…</option>';

  try {
    const db = initSupabase();
    // Fetch distinct group values from students that have a group assigned
    const { data, error } = await db
      .from('students')
      .select('group')
      .not('group', 'is', null)
      .order('group', { ascending: true });

    if (error) throw error;

    // De-duplicate
    const groupSet = new Set();
    (data || []).forEach(row => {
      if (row.group && row.group.trim()) groupSet.add(row.group.trim());
    });

    coldCallState.groups = Array.from(groupSet).sort();

    if (coldCallState.groups.length === 0) {
      select.innerHTML = '<option value="">No groups found in database</option>';
      return;
    }

    select.innerHTML = '<option value="">— Select a group —</option>' +
      coldCallState.groups.map(g =>
        `<option value="${g.replace(/"/g,'&quot;')}">${g}</option>`
      ).join('');

  } catch (err) {
    console.error('coldCallLoadGroups error:', err);
    select.innerHTML = '<option value="">⚠️ Failed to load groups</option>';
  }
}

// ─── Group selection changed ─────────────────────────────────────────────────
async function onColdCallGroupChange() {
  const select = document.getElementById('ccGroupSelect');
  if (!select) return;
  const group = select.value;

  coldCallState.selectedGroup = group || null;
  coldCallState.students = [];
  coldCallState.queue = [];
  coldCallState.calledThisRound = [];
  coldCallState.lastPicked = null;
  coldCallState.cycleComplete = false;

  coldCallUpdateUI();

  if (!group) return;

  // Load students for selected group
  await coldCallLoadStudentsForGroup(group);
  coldCallStartNewCycle();
  coldCallUpdateUI();
}

// ─── Load students for a specific group (with caching) ───────────────────────
async function coldCallLoadStudentsForGroup(groupName) {
  // Return cached list if available
  if (coldCallState.studentCache.has(groupName)) {
    coldCallState.students = [...coldCallState.studentCache.get(groupName)];
    return;
  }

  const nameDisplay = document.getElementById('ccNameDisplay');
  if (nameDisplay) {
    nameDisplay.innerHTML = '<div class="cc-rolling-dots"><span>·</span><span>·</span><span>·</span></div>';
  }

  try {
    const db = initSupabase();
    const { data, error } = await db
      .from('students')
      .select('id, full_name, student_id')
      .eq('group', groupName)
      .order('full_name', { ascending: true });

    if (error) throw error;

    const students = (data || []).filter(s => s.full_name && s.full_name.trim());
    coldCallState.studentCache.set(groupName, students);
    coldCallState.students = [...students];

  } catch (err) {
    console.error('coldCallLoadStudentsForGroup error:', err);
    coldCallState.students = [];
    showToast('Failed to load students for group', 'error');
  }
}

// ─── Start a fresh cycle (shuffle the full student list) ─────────────────────
function coldCallStartNewCycle() {
  if (coldCallState.students.length === 0) return;
  // Fisher-Yates shuffle
  const arr = [...coldCallState.students];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  coldCallState.queue = arr;
  coldCallState.calledThisRound = [];
  coldCallState.cycleComplete = false;
  coldCallState.lastPicked = null;
}

// ─── Pick the next student ────────────────────────────────────────────────────
async function coldCallPickStudent() {
  if (!SESSION_ROLE.isTeacher) return;
  if (coldCallState.isRolling) return;
  if (!coldCallState.selectedGroup) return;

  // If no students loaded yet, bail
  if (coldCallState.students.length === 0) {
    showToast('No students in this group', 'warning');
    return;
  }

  // If queue is empty, start a new cycle
  if (coldCallState.queue.length === 0) {
    coldCallStartNewCycle();
    // Brief "cycle complete" feedback already shown; now continue picking
  }

  // Pop from front of queue
  const student = coldCallState.queue.shift();
  coldCallState.calledThisRound.push(student);
  coldCallState.lastPicked = student;

  // Animate
  await coldCallAnimatePick(student.full_name);

  // Check if this was the last student in the round
  if (coldCallState.queue.length === 0) {
    coldCallState.cycleComplete = true;
  }

  coldCallUpdateUI();
}

// ─── Rolling animation then reveal the name ──────────────────────────────────
function coldCallAnimatePick(finalName) {
  return new Promise(resolve => {
    coldCallState.isRolling = true;
    coldCallState.currentPickAnswered = false;
    const display = document.getElementById('ccNameDisplay');
    const pickBtn = document.getElementById('ccPickBtn');
    if (pickBtn) pickBtn.disabled = true;

    // Show rolling dots
    display.className = 'cc-name-display rolling';
    display.innerHTML = '<div class="cc-rolling-dots"><span>·</span><span>·</span><span>·</span></div>';

    // After 700ms show the name + correct/wrong buttons
    setTimeout(() => {
      display.className = 'cc-name-display revealed';
      display.innerHTML = `
        <div class="cc-called-label">
          <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
          Called on
        </div>
        <div class="cc-name-text animate-in">${escapeHtml(finalName)}</div>
        <div class="cc-answer-btns" id="ccAnswerBtns">
          <button class="cc-correct-btn" id="ccCorrectBtn" onclick="coldCallRecordAnswer(true)">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg>
            Correct
          </button>
          <button class="cc-wrong-btn" id="ccWrongBtn" onclick="coldCallRecordAnswer(false)">
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            Wrong
          </button>
        </div>
      `;
      coldCallState.isRolling = false;
      if (pickBtn) pickBtn.disabled = false;
      resolve();
    }, 700);
  });
}

// ─── Get current question stem (first 200 chars) ─────────────────────────────
function coldCallGetCurrentQuestionStem() {
  try {
    if (!testState || !testState.questions || testState.questions.length === 0) return null;
    const idx = testState.currentQuestionIndex || 0;
    const q = testState.questions[idx];
    if (!q) return null;
    const stem = q.stem || '';
    return stem.substring(0, 200);
  } catch(e) { return null; }
}

// ─── Ensure a session row exists in Supabase ─────────────────────────────────
async function coldCallEnsureSession() {
  if (coldCallState.sessionId) return coldCallState.sessionId;
  try {
    const sdb = initSupabase();
    const subjectName = (testState && testState.testConfig && testState.testConfig.subject_name)
      ? testState.testConfig.subject_name : null;
    const { data, error } = await sdb.from('cold_call_sessions').insert({
      teacher_email: SESSION_ROLE.userEmail || 'unknown',
      group_name: coldCallState.selectedGroup || 'Unknown',
      subject_name: subjectName,
      session_date: new Date().toISOString().split('T')[0],
      started_at: new Date().toISOString()
    }).select('id').single();
    if (error) throw error;
    coldCallState.sessionId = data.id;
    coldCallState.sessionStarted = true;
    return data.id;
  } catch(e) {
    console.error('coldCallEnsureSession error:', e);
    return null;
  }
}

// ─── Record correct / wrong answer ───────────────────────────────────────────
async function coldCallRecordAnswer(isCorrect) {
  if (coldCallState.currentPickAnswered) return;
  coldCallState.currentPickAnswered = true;

  const student = coldCallState.lastPicked;
  if (!student) return;

  // Update local analytics map
  const key = student.id || student.full_name;
  if (!coldCallState.analytics.has(key)) {
    coldCallState.analytics.set(key, { name: student.full_name, id: student.id, correct: 0, wrong: 0, questions: [] });
  }
  const rec = coldCallState.analytics.get(key);
  if (isCorrect) rec.correct++; else rec.wrong++;
  const stem = coldCallGetCurrentQuestionStem();
  if (stem) rec.questions.push({ stem, correct: isCorrect });

  // Update UI — replace buttons with badge
  const answerBtns = document.getElementById('ccAnswerBtns');
  if (answerBtns) {
    answerBtns.outerHTML = `
      <div class="cc-answered-badge ${isCorrect ? 'correct' : 'wrong'}">
        ${isCorrect
          ? '<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="20 6 9 17 4 12"/></svg> Correct'
          : '<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg> Wrong'}
      </div>`;
  }

  // Show End Session button
  const endRow = document.getElementById('ccEndSessionRow');
  if (endRow) endRow.style.display = 'block';

  // Persist to Supabase (fire-and-forget)
  coldCallEnsureSession().then(sessionId => {
    if (!sessionId) return;
    const sdb = initSupabase();
    sdb.from('cold_call_responses').insert({
      session_id: sessionId,
      student_id: String(student.id || ''),
      student_name: student.full_name,
      question_stem: stem,
      question_order: testState ? (testState.currentQuestionIndex || 0) : 0,
      is_correct: isCorrect
    }).then(({ error }) => {
      if (error) console.error('coldCallRecordAnswer save error:', error);
    });
  });
}

// ─── Update all UI elements ───────────────────────────────────────────────────
function coldCallUpdateUI() {
  const pickBtn      = document.getElementById('ccPickBtn');
  const progressLabel = document.getElementById('ccProgressLabel');
  const progressFrac = document.getElementById('ccProgressFraction');
  const progressFill = document.getElementById('ccProgressFill');
  const cycleBadge   = document.getElementById('ccCycleBadge');
  const resetBtn     = document.getElementById('ccResetBtn');
  const display      = document.getElementById('ccNameDisplay');

  const total = coldCallState.students.length;
  const called = coldCallState.calledThisRound.length;

  if (!coldCallState.selectedGroup || total === 0) {
    // No group or no students
    if (progressLabel) progressLabel.textContent = total === 0 && coldCallState.selectedGroup
      ? 'No students in this group'
      : 'No group selected';
    if (progressFrac) progressFrac.textContent = '—';
    if (progressFill) progressFill.style.width = '0%';
    if (pickBtn) pickBtn.disabled = true;
    if (cycleBadge) cycleBadge.style.display = 'none';
    if (resetBtn) resetBtn.style.display = 'none';
    if (display && !coldCallState.selectedGroup) {
      display.className = 'cc-name-display';
      display.innerHTML = '<div class="cc-idle-text">Select a group to begin</div>';
    }
    return;
  }

  const pct = total > 0 ? Math.round((called / total) * 100) : 0;
  if (progressLabel) progressLabel.textContent = `Round progress`;
  if (progressFrac) progressFrac.textContent = `${called} / ${total}`;
  if (progressFill) progressFill.style.width = pct + '%';

  // Cycle-complete badge
  if (coldCallState.cycleComplete) {
    if (cycleBadge) cycleBadge.style.display = 'flex';
    // Auto-hide after 2.5s and start new cycle
    setTimeout(() => {
      if (cycleBadge) cycleBadge.style.display = 'none';
      coldCallStartNewCycle();
      coldCallUpdateUI();
    }, 2500);
  } else {
    if (cycleBadge) cycleBadge.style.display = 'none';
  }

  // Show reset button once at least one student has been called
  if (resetBtn) resetBtn.style.display = called > 0 ? 'inline-block' : 'none';

  // Pick button
  if (pickBtn && !coldCallState.isRolling) pickBtn.disabled = false;

  // If no one has been picked yet, set the idle state on the display
  if (!coldCallState.lastPicked && display && !display.classList.contains('rolling') && !display.classList.contains('revealed')) {
    display.className = 'cc-name-display';
    display.innerHTML = `<div class="cc-idle-text">Press "Pick a Student" to begin</div>`;
  }
}

// ─── Reset cycle manually ────────────────────────────────────────────────────
function coldCallReset() {
  coldCallStartNewCycle();
  coldCallState.currentPickAnswered = false;
  const display = document.getElementById('ccNameDisplay');
  if (display) {
    display.className = 'cc-name-display';
    display.innerHTML = '<div class="cc-idle-text">Cycle reset — press Pick to start</div>';
  }
  coldCallUpdateUI();
}

// ─── End Session → save totals + show stats ──────────────────────────────────
async function coldCallEndSession() {
  // Update ended_at and total_picks on the session row
  if (coldCallState.sessionId) {
    try {
      const sdb = initSupabase();
      const totalPicks = coldCallState.analytics.size > 0
        ? Array.from(coldCallState.analytics.values()).reduce((s, r) => s + r.correct + r.wrong, 0)
        : 0;
      await sdb.from('cold_call_sessions').update({
        ended_at: new Date().toISOString(),
        total_picks: totalPicks
      }).eq('id', coldCallState.sessionId);
    } catch(e) { console.error('coldCallEndSession save error:', e); }
  }
  coldCallShowStats();
}

// ─── Build and show the stats modal ──────────────────────────────────────────
function coldCallShowStats() {
  const modal = document.getElementById('coldCallStatsModal');
  if (!modal) return;

  const entries = Array.from(coldCallState.analytics.values());

  // Sort by % correct desc
  entries.sort((a, b) => {
    const pctA = (a.correct + a.wrong) > 0 ? a.correct / (a.correct + a.wrong) : 0;
    const pctB = (b.correct + b.wrong) > 0 ? b.correct / (b.correct + b.wrong) : 0;
    return pctB - pctA;
  });

  // Subtitle
  const subtitle = document.getElementById('ccStatsSubtitle');
  if (subtitle) {
    const d = new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
    subtitle.textContent = `${coldCallState.selectedGroup || 'Group'} · ${d}`;
  }

  // Top & weakest highlights
  const highlights = document.getElementById('ccStatsHighlights');
  if (highlights && entries.length > 0) {
    const top = entries[0];
    const weak = entries[entries.length - 1];
    const topPct  = (top.correct + top.wrong) > 0 ? Math.round(top.correct  / (top.correct  + top.wrong)  * 100) : 0;
    const weakPct = (weak.correct + weak.wrong) > 0 ? Math.round(weak.correct / (weak.correct + weak.wrong) * 100) : 0;
    const isSame = top.name === weak.name;

    highlights.innerHTML = `
      <div style="flex:1;background:rgba(16,185,129,0.07);border:1px solid rgba(16,185,129,0.22);border-radius:10px;padding:14px 16px">
        <div style="font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:0.7px;color:#34d399;margin-bottom:6px">⭐ Top Student</div>
        <div style="font-size:15px;font-weight:700;color:#f1f5f9;margin-bottom:2px">${escapeHtml(top.name)}</div>
        <div style="font-size:12px;color:#64748b">${top.correct} correct · ${top.wrong} wrong · <strong style="color:#34d399">${topPct}%</strong></div>
      </div>
      ${!isSame ? `
      <div style="flex:1;background:rgba(239,68,68,0.07);border:1px solid rgba(239,68,68,0.22);border-radius:10px;padding:14px 16px">
        <div style="font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:0.7px;color:#f87171;margin-bottom:6px">📉 Needs Support</div>
        <div style="font-size:15px;font-weight:700;color:#f1f5f9;margin-bottom:2px">${escapeHtml(weak.name)}</div>
        <div style="font-size:12px;color:#64748b">${weak.correct} correct · ${weak.wrong} wrong · <strong style="color:#f87171">${weakPct}%</strong></div>
      </div>` : ''}
    `;
  } else if (highlights) {
    highlights.innerHTML = '<div style="color:#64748b;font-size:13px;padding:8px 0">No answers recorded yet.</div>';
  }

  // Per-student table
  const table = document.getElementById('ccStatsTable');
  if (table) {
    if (entries.length === 0) {
      table.innerHTML = '<div style="color:#475569;font-size:13px;text-align:center;padding:20px">No responses recorded in this session.</div>';
    } else {
      table.innerHTML = entries.map((e, idx) => {
        const total = e.correct + e.wrong;
        const pct = total > 0 ? Math.round(e.correct / total * 100) : 0;
        const barColor = pct >= 70 ? '#34d399' : pct >= 40 ? '#f59e0b' : '#f87171';
        return `
          <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid rgba(255,255,255,0.05)">
            <div style="width:22px;text-align:center;font-size:11px;font-weight:700;color:#475569">${idx + 1}</div>
            <div style="flex:1;min-width:0">
              <div style="font-size:13px;font-weight:600;color:#e2e8f0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${escapeHtml(e.name)}</div>
              <div style="height:4px;background:rgba(255,255,255,0.07);border-radius:2px;margin-top:5px;overflow:hidden">
                <div style="height:100%;width:${pct}%;background:${barColor};border-radius:2px;transition:width 0.4s"></div>
              </div>
            </div>
            <div style="text-align:right;flex-shrink:0">
              <div style="font-size:13px;font-weight:700;color:${barColor}">${pct}%</div>
              <div style="font-size:10px;color:#475569">${e.correct}✓ ${e.wrong}✗</div>
            </div>
          </div>`;
      }).join('');
    }
  }

  // Show modal as flex
  modal.style.display = 'flex';
}

// ─── Close stats modal ───────────────────────────────────────────────────────
function coldCallCloseStats() {
  const modal = document.getElementById('coldCallStatsModal');
  if (modal) modal.style.display = 'none';
}

// ─── Start a brand-new session (clear analytics state) ───────────────────────
function coldCallStartNewSession() {
  coldCallCloseStats();
  coldCallState.sessionId = null;
  coldCallState.sessionStarted = false;
  coldCallState.analytics = new Map();
  coldCallState.currentPickAnswered = false;
  const endRow = document.getElementById('ccEndSessionRow');
  if (endRow) endRow.style.display = 'none';
  coldCallStartNewCycle();
  const display = document.getElementById('ccNameDisplay');
  if (display) {
    display.className = 'cc-name-display';
    display.innerHTML = '<div class="cc-idle-text">New session started — press Pick to begin</div>';
  }
  coldCallUpdateUI();
}

// ═══════════════════════════════════════════════════════════════
// TEST GRADES SYSTEM
// ═══════════════════════════════════════════════════════════════

// ─── Grade scale ─────────────────────────────────────────────
function gradeFromPercent(pct) {
  if (pct >= 90) return 'A';
  if (pct >= 80) return 'B';
  if (pct >= 70) return 'C';
  if (pct >= 60) return 'D';
  return 'F';
}

function gradeColor(letter) {
  return { A: '#34d399', B: '#38bdf8', C: '#fbbf24', D: '#fb923c', F: '#f87171' }[letter] || '#94a3b8';
}

// ─── Build the test title from available config ───────────────
function buildTestTitle() {
  // Prefer explicitly stored title from config
  if (testState.testConfig && testState.testConfig.title && testState.testConfig.title.trim()) {
    return testState.testConfig.title.trim();
  }
  if (TEST_CONFIG.testTitle && TEST_CONFIG.testTitle.trim()) {
    return TEST_CONFIG.testTitle.trim();
  }
  // Fall back to topic names
  const topics = TEST_CONFIG.selectedTopicNames || [];
  if (topics.length > 0) {
    return 'Test on ' + topics.slice(0, 3).join(', ') + (topics.length > 3 ? '…' : '');
  }
  return 'Practice Test';
}

function buildAnsweredSnapshot() {
  const snapshot = (testState.snapshot && testState.snapshot.en) ? testState.snapshot.en : [];
  const answersMap = testState.answers || {};

  return snapshot.reduce((acc, q, idx) => {
    const rawAnswer = answersMap[q.id];
    if (!rawAnswer || (Array.isArray(rawAnswer) && rawAnswer.length === 0)) return acc;

    const answerIds = Array.isArray(rawAnswer) ? rawAnswer : [rawAnswer];
    const options = Array.isArray(q.options) ? q.options : [];
    const answerDetails = answerIds.map(id => {
      const match = options.find(o => String(o.id) === String(id));
      return {
        id,
        text: match ? match.text : String(id)
      };
    });

    acc.push({
      index: idx + 1,
      id: q.id,
      stem: q.stem,
      answers: answerDetails
    });
    return acc;
  }, []);
}

// ─── Persist grade to Supabase; return full history ──────────
async function saveTestGrade(results) {
  try {
    const sdb = initSupabase();
    const ownerId     = getOwnerId();
    const letter      = gradeFromPercent(results.scorePercent);
    const title       = buildTestTitle();
    const topics      = (TEST_CONFIG.selectedTopicNames || []).join(', ') || null;
    const studentName = SESSION_ROLE.userName ||
      sessionStorage.getItem('userName') || localStorage.getItem('userName') ||
      sessionStorage.getItem('teacherName') || localStorage.getItem('teacherName') || null;
    const studentEmail = sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail') ||
      sessionStorage.getItem('teacherEmail') || localStorage.getItem('teacherEmail') || null;

    // INSERT — never update, always append
    const { error: insertErr } = await sdb.from('test_grade_history').insert({
      owner_id:        ownerId,
      student_name:    studentName,
      student_email:   studentEmail,
      test_title:      title,
      topics:          topics,
      test_id:         TEST_CONFIG.testId || null,
      answered_snapshot: buildAnsweredSnapshot(),
      score_percent:   results.scorePercent,
      letter_grade:    letter,
      correct_count:   results.correct,
      incorrect_count: results.incorrect,
      total_questions: results.totalQuestions,
      taken_at:        new Date().toISOString()
    });
    if (insertErr) throw insertErr;

    // Fetch full history for this student (newest first)
    const { data: history, error: fetchErr } = await sdb
      .from('test_grade_history')
      .select('*')
      .eq('owner_id', ownerId)
      .order('taken_at', { ascending: false });

    if (fetchErr) throw fetchErr;
    return history || [];
  } catch (e) {
    console.error('saveTestGrade error:', e);
    return null;
  }
}

// ─── Render the grade history card on the results screen ──────
function renderGradesCard(history, currentPercent) {
  const content = document.getElementById('gradesContent');
  if (!content) return;

  if (!history || history.length === 0) {
    content.innerHTML = '<div style="color:#475569;font-size:13px;text-align:center;padding:16px 0">No grade history found.</div>';
    return;
  }

  // Cumulative average of ALL recorded percentages
  const avg = Math.round(history.reduce((s, r) => s + r.score_percent, 0) / history.length);
  const avgLetter = gradeFromPercent(avg);

  // Format date helper
  const fmt = iso => {
    const d = new Date(iso);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  // ── Average summary row ──
  let html = `
    <div class="grade-avg-row">
      <div class="grade-avg-letter ${avgLetter}">${avgLetter}</div>
      <div style="flex:1">
        <div style="font-size:12px;font-weight:700;text-transform:uppercase;letter-spacing:0.5px;color:#64748b;margin-bottom:3px">Cumulative Average</div>
        <div style="font-size:22px;font-weight:900;color:#f1f5f9;line-height:1">${avg}%</div>
        <div style="font-size:11px;color:#475569;margin-top:3px">${history.length} test attempt${history.length !== 1 ? 's' : ''} recorded</div>
      </div>
    </div>`;

  // ── History table ──
  html += `
    <table class="grade-history-table">
      <thead>
        <tr>
          <th>#</th>
          <th>Test</th>
          <th>Date</th>
          <th style="text-align:center">Score</th>
          <th style="text-align:center">Grade</th>
        </tr>
      </thead>
      <tbody>`;

  history.forEach((row, idx) => {
    const isCurrent = (idx === 0); // newest = just submitted
    const gl = row.letter_grade;
    html += `
      <tr class="${isCurrent ? 'current-attempt' : ''}">
        <td style="color:#475569;font-size:11px">${history.length - idx}</td>
        <td style="max-width:200px">
          <div style="font-weight:600;color:#e2e8f0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${escapeHtml(row.test_title)}</div>
          ${row.topics ? `<div style="font-size:10px;color:#475569;margin-top:1px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${escapeHtml(row.topics)}</div>` : ''}
        </td>
        <td style="white-space:nowrap;color:#64748b;font-size:11.5px">${fmt(row.taken_at)}</td>
        <td style="text-align:center;font-weight:700;color:${gradeColor(gl)}">${row.score_percent}%</td>
        <td style="text-align:center"><span class="grade-letter-pill ${gl}">${gl}</span></td>
      </tr>`;
  });

  html += '</tbody></table>';
  content.innerHTML = html;
}

// ─── Toggle grades card open/closed ──────────────────────────
function toggleGradesCard() {
  const body    = document.getElementById('gradesCardBody');
  const chevron = document.getElementById('gradesChevron');
  if (!body) return;
  const isOpen = body.style.display !== 'none';
  body.style.display    = isOpen ? 'none' : 'block';
  if (chevron) chevron.style.transform = isOpen ? 'rotate(-90deg)' : 'rotate(0deg)';
}

// ─── Teacher: open grade history modal for ALL students ───────
let _allGradeHistory = [];
async function openGradeHistoryModal() {
  const modal = document.getElementById('gradeHistoryModal');
  if (!modal) return;
  modal.style.display = 'flex';
  const body = document.getElementById('gradeModalBody');
  body.innerHTML = '<div style="text-align:center;color:#475569;font-size:13px;padding:30px 0">Loading…</div>';

  try {
    const sdb = initSupabase();
    const { data, error } = await sdb
      .from('test_grade_history')
      .select('*')
      .order('taken_at', { ascending: false });
    if (error) throw error;
    _allGradeHistory = data || [];
    renderGradeModalTable(_allGradeHistory);
  } catch(e) {
    body.innerHTML = `<div style="text-align:center;color:#f87171;font-size:13px;padding:30px 0">Failed to load: ${e.message}</div>`;
  }
}

function filterGradeModalTable() {
  const q = (document.getElementById('gradeModalSearch')?.value || '').toLowerCase().trim();
  if (!q) { renderGradeModalTable(_allGradeHistory); return; }
  renderGradeModalTable(_allGradeHistory.filter(r =>
    (r.student_name || '').toLowerCase().includes(q) ||
    (r.student_email || '').toLowerCase().includes(q) ||
    (r.owner_id || '').toLowerCase().includes(q)
  ));
}

function renderGradeModalTable(rows) {
  const body = document.getElementById('gradeModalBody');
  if (!rows || rows.length === 0) {
    body.innerHTML = '<div style="text-align:center;color:#475569;font-size:13px;padding:30px 0">No records found.</div>';
    return;
  }

  // Group by owner_id → compute per-student average
  const byStudent = {};
  rows.forEach(r => {
    if (!byStudent[r.owner_id]) byStudent[r.owner_id] = { name: r.student_name || r.owner_id, email: r.student_email || '', rows: [] };
    byStudent[r.owner_id].rows.push(r);
  });

  const fmt = iso => new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });

  let html = '';
  Object.values(byStudent).forEach(student => {
    const avg = Math.round(student.rows.reduce((s, r) => s + r.score_percent, 0) / student.rows.length);
    const avgL = gradeFromPercent(avg);
    html += `
      <div style="margin-bottom:18px;background:rgba(255,255,255,0.02);border:1px solid rgba(255,255,255,0.07);border-radius:10px;overflow:hidden">
        <div style="padding:12px 14px;display:flex;align-items:center;gap:12px;border-bottom:1px solid rgba(255,255,255,0.06)">
          <div class="grade-avg-letter ${avgL}" style="width:40px;height:40px;font-size:18px;border-radius:9px">${avgL}</div>
          <div style="flex:1">
            <div style="font-size:14px;font-weight:700;color:#e2e8f0">${escapeHtml(student.name)}</div>
            <div style="font-size:11px;color:#475569">${escapeHtml(student.email)} · ${student.rows.length} attempt${student.rows.length !== 1 ? 's' : ''} · avg <strong style="color:${gradeColor(avgL)}">${avg}%</strong></div>
          </div>
        </div>
        <table class="grade-history-table" style="margin:0">
          <thead><tr>
            <th>Test</th><th>Date</th>
            <th style="text-align:center">Score</th><th style="text-align:center">Grade</th>
          </tr></thead>
          <tbody>`;

    student.rows.forEach(row => {
      const gl = row.letter_grade;
      html += `
        <tr>
          <td>
            <div style="font-weight:600;color:#e2e8f0">${escapeHtml(row.test_title)}</div>
            ${row.topics ? `<div style="font-size:10px;color:#475569">${escapeHtml(row.topics)}</div>` : ''}
          </td>
          <td style="white-space:nowrap;color:#64748b;font-size:11.5px">${fmt(row.taken_at)}</td>
          <td style="text-align:center;font-weight:700;color:${gradeColor(gl)}">${row.score_percent}%</td>
          <td style="text-align:center"><span class="grade-letter-pill ${gl}">${gl}</span></td>
        </tr>`;
    });

    html += '</tbody></table></div>';
  });

  body.innerHTML = html;
  document.getElementById('gradeModalSubtitle').textContent = `${rows.length} total attempt${rows.length !== 1 ? 's' : ''} · ${Object.keys(byStudent).length} student${Object.keys(byStudent).length !== 1 ? 's' : ''}`;
}

function closeGradeHistoryModal() {
  const modal = document.getElementById('gradeHistoryModal');
  if (modal) modal.style.display = 'none';
}

// ─── Minimal HTML escaper ────────────────────────────────────────────────────
function escapeHtml(str) {
  return String(str)
    .replace(/&/g,'&amp;')
    .replace(/</g,'&lt;')
    .replace(/>/g,'&gt;')
    .replace(/"/g,'&quot;')
    .replace(/'/g,'&#39;');
}

// ============================================
// INITIALIZATION
// ============================================

document.addEventListener('DOMContentLoaded', () => {
  // ── Auth gate & role detection ─────────────────────────────────────────
  initSessionRole();
  applySessionRole();

  // ── STUDENT HARDENING — runs immediately after role is resolved ────────
  // Locks down features that must NEVER be accessible to students, even via
  // browser console, DevTools injection, or direct API calls.
  if (!SESSION_ROLE.isTeacher) {

    // 1. Replace revealAllAnswers on the window object with a silent no-op.
    //    Even if a student types revealAllAnswers() in DevTools they get nothing.
    window.revealAllAnswers = function _revealAllBlocked() {
      console.warn('[ACNHS] revealAllAnswers() is not available in student mode.');
    };

    // 2. MutationObserver: destroy any #revealAllModal that gets injected into
    //    the DOM regardless of how it arrives (XSS, paste attack, extension, etc).
    const _revealGuard = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        for (const node of mutation.addedNodes) {
          if (node.nodeType !== 1) continue;
          // Catch the modal itself OR any wrapper that contains it
          if (node.id === 'revealAllModal' ||
              node.querySelector?.('#revealAllModal')) {
            const target = node.id === 'revealAllModal'
              ? node : node.querySelector('#revealAllModal');
            if (target) {
              target.remove();
              console.warn('[ACNHS] Blocked revealAllModal injection (student session).');
            }
          }
        }
      }
    });
    _revealGuard.observe(document.body, { childList: true, subtree: true });

    // 3. Block all teacher_sessions DB access at the JS layer.
    //    Override the teacher-session functions with no-ops so no student
    //    can reach the teacher_sessions table even via the console.
    const _teacherFnBlocked = (name) => function() {
      console.warn(`[ACNHS] ${name}() is not available in student mode.`);
      return Promise.resolve(null);
    };
    window.createTeacherSession    = _teacherFnBlocked('createTeacherSession');
    window.broadcastSessionUpdate  = _teacherFnBlocked('broadcastSessionUpdate');
    window.sendSessionHeartbeat    = _teacherFnBlocked('sendSessionHeartbeat');
    window.endTeacherSession       = _teacherFnBlocked('endTeacherSession');
    window.startSessionHeartbeat   = _teacherFnBlocked('startSessionHeartbeat');
    // subscribeToTeacherSession / loadTeacherSessionState are kept available
    // for student VIEW (following a teacher session), but teacher WRITE paths
    // are locked above.
  }
  // ── END STUDENT HARDENING ──────────────────────────────────────────────

  // Initialize Supabase first, then immediately stamp the role header so
  // ALL subsequent DB queries carry both x-owner-id and x-owner-role.
  initializeSupabase();
  refreshSupabaseOwner();   // re-sets headers now that SESSION_ROLE is fully resolved
  
  // Apply logo using centralized function
  if (typeof window.applyAcnshLogo === 'function') {
    window.applyAcnshLogo();
    console.log('✅ Logo applied via applyAcnshLogo()');
  } else {
    console.warn('⚠️ applyAcnshLogo() not available');
  }
  
  initColdCallPicker();

  // Defer loadSavedSessions until the browser is idle — it's not needed
  // before the user can see and interact with the page, so don't block
  // the initial render with a Supabase round-trip.
  if ('requestIdleCallback' in window) {
    requestIdleCallback(() => loadSavedSessions(), { timeout: 3000 });
  } else {
    setTimeout(() => loadSavedSessions(), 800);
  }
});
