/**
 * ACNHS Portal Alert Engine
 * Shared across all student portal pages
 * Handles fetching, scheduling, display logic, and response tracking
 * 
 * Usage: Include this script on every portal page:
 * <script src="js/supabase-config.js"></script>
 * <script src="js/alerts.js"></script>
 * 
 * The engine auto-initializes on page load.
 */

(function() {
  'use strict';

  // ==========================================
  // CONFIGURATION
  // ==========================================
  const ALERT_CONFIG = {
    checkInterval: 30000, // Re-check for new alerts every 30 seconds
    animationDuration: 300,
    timezone: 'Asia/Yerevan'
  };

  const SESSION_DISMISS_PREFIX = 'acnhs_alert_dismissed_';

  // Global state
  let currentStudent = null;
  let alertQueue = [];
  let isShowingAlert = false;
  let supabase = null;

  // ==========================================
  // INITIALIZATION
  // ==========================================
  async function initAlertEngine() {
    try {
      // Initialize Supabase
      supabase = initSupabase();
      if (!supabase) {
        console.warn('Alert engine: Supabase not initialized');
        return;
      }

      // Get current student from session
      currentStudent = await getCurrentStudent();
      if (!currentStudent) {
        console.log('Alert engine: No student logged in');
        return;
      }

      console.log('Alert engine initialized for student:', currentStudent.id);

      // Check for alerts immediately
      await checkAndShowAlerts();

      // Set up periodic checking
      setInterval(checkAndShowAlerts, ALERT_CONFIG.checkInterval);

    } catch (error) {
      console.error('Alert engine initialization error:', error);
    }
  }

  // ==========================================
  // GET CURRENT STUDENT SESSION
  // ==========================================
  async function getCurrentStudent() {
    try {
      // First try sessionStorage (most portal pages store student info here)
      const studentData = sessionStorage.getItem('studentData');
      if (studentData) {
        const parsed = JSON.parse(studentData);
        if (parsed.id) return parsed;
      }

      // Try localStorage as fallback
      const storedStudent = localStorage.getItem('currentStudent');
      if (storedStudent) {
        const parsed = JSON.parse(storedStudent);
        if (parsed.id) return parsed;
      }

      // If no stored data, try to get from students table by email in session
      const userEmail = sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail');
      if (userEmail) {
        const { data, error } = await supabase
          .from('students')
          .select('id, student_id, full_name, email')
          .eq('email', userEmail)
          .single();
        
        if (data && !error) {
          return data;
        }
      }

      return null;
    } catch (error) {
      console.error('Error getting current student:', error);
      return null;
    }
  }

  // ==========================================
  // MAIN ALERT CHECK & DISPLAY LOGIC
  // ==========================================
  async function checkAndShowAlerts() {
    if (isShowingAlert) return; // Don't interrupt current alert
    if (!currentStudent) return;

    try {
      // Fetch active alerts
      const { data: alerts, error } = await supabase
        .from('portal_alerts')
        .select('*')
        .eq('is_active', true)
        .order('created_at', { ascending: false });

      if (error) throw error;
      if (!alerts || alerts.length === 0) return;

      // Filter alerts that apply to this student
      const applicableAlerts = alerts.filter(alert => {
        return isAlertTargetedToStudent(alert, currentStudent.id);
      });

      if (applicableAlerts.length === 0) return;

      // Evaluate each alert's schedule and display rules
      for (const alert of applicableAlerts) {
        const shouldShow = await shouldShowAlert(alert, currentStudent.id);
        if (shouldShow) {
          await showAlert(alert);
          break; // Only show one alert at a time
        }
      }

    } catch (error) {
      console.error('Error checking alerts:', error);
    }
  }

  // ==========================================
  // TARGETING CHECK
  // ==========================================
  function isAlertTargetedToStudent(alert, studentId) {
    if (alert.target_type === 'all') {
      return true;
    }

    if (alert.target_type === 'individual') {
      const targetIds = Array.isArray(alert.target_student_ids) 
        ? alert.target_student_ids 
        : [];
      return targetIds.includes(studentId);
    }

    return false;
  }

  // ==========================================
  // SCHEDULE & DISPLAY RULES EVALUATION
  // ==========================================
  async function shouldShowAlert(alert, studentId) {
    try {
      // Use new JSON rules if available, fallback to old columns
      const frequencyRules = alert.frequency_rules || {};
      const scheduleRules = alert.schedule_rules || {};
      const targetingRules = alert.targeting_rules || {};
      const triggerRules = alert.trigger_rules || {};
      const interactionRules = alert.interaction_rules || {};

      // 0. Page-specific rules
      if (!doesAlertMatchPage(triggerRules)) {
        return false;
      }

      // 0b. Session dismissal rule
      const allowSessionRepeat = interactionRules.allow_session_repeat === true;
      if (!allowSessionRepeat && isDismissedThisSession(alert.id)) {
        return false;
      }

      // 1. Check schedule rules (date/time windows)
      if (!isWithinScheduleWindow(scheduleRules, alert)) {
        return false;
      }

      // 2. Check if student has already responded (blocks re-display)
      if (interactionRules.required_response || alert.requires_response) {
        const { data: responses } = await supabase
          .from('portal_alert_responses')
          .select('id')
          .eq('alert_id', alert.id)
          .eq('student_id', studentId)
          .limit(1);

        if (responses && responses.length > 0) {
          return false; // Already responded
        }
      }

      // 3. Check frequency rules
      const { data: impressions } = await supabase
        .from('portal_alert_impressions')
        .select('*')
        .eq('alert_id', alert.id)
        .eq('student_id', studentId)
        .order('shown_at', { ascending: false });

      const impressionCount = impressions ? impressions.length : 0;

      // Use new frequency_rules if available, fallback to old display_mode
      const capType = frequencyRules.cap_type || alert.display_mode || 'once_ever';

      switch (capType) {
        case 'once_ever':
          return impressionCount === 0;

        case 'times_limit':
          const maxDisplays = frequencyRules.max_displays || alert.max_displays || 1;
          return impressionCount < maxDisplays;

        case 'daily':
        case 'daily_first_login':
          return !hasImpressionToday(impressions);

        case 'weekly':
          return !hasImpressionThisWeek(impressions);

        case 'cooldown':
          if (impressionCount === 0) return true;
          const lastImpression = new Date(impressions[0].shown_at);
          const hoursSince = (Date.now() - lastImpression) / (1000 * 60 * 60);
          return hoursSince >= (frequencyRules.cooldown_hours || 24);

        case 'until_response':
          return impressionCount === 0 || impressionCount < (frequencyRules.max_displays || 5);

        case 'every_load':
          return true;

        default:
          return impressionCount === 0;
      }

    } catch (error) {
      console.error('Error evaluating alert rules:', error);
      return false;
    }
  }

  // ==========================================
  // DATE WINDOW CHECKS (Updated for new JSON rules)
  // ==========================================
  function isWithinScheduleWindow(scheduleRules, alert) {
    const now = new Date();
    const localDate = getTodayLocalDate();
    const dayOfMonth = now.getDate();

    // Use new schedule_rules if available, fallback to old date_rule_type
    const recurrenceType = scheduleRules.recurrence_type || alert.date_rule_type || 'always';

    switch (recurrenceType) {
      case 'always':
        return true;

      case 'one_time':
      case 'date_range':
        const startDate = scheduleRules.start_datetime || alert.start_date;
        const endDate = scheduleRules.end_datetime || alert.end_date;
        if (!startDate || !endDate) return true;
        return localDate >= startDate.split('T')[0] && localDate <= endDate.split('T')[0];

      case 'monthly':
        const monthlyPattern = scheduleRules.monthly_pattern;
        if (monthlyPattern && monthlyPattern.day_range) {
          const [start, end] = monthlyPattern.day_range;
          return dayOfMonth >= start && dayOfMonth <= end;
        }
        // Fallback to old columns
        if (alert.monthly_start_day && alert.monthly_end_day) {
          return dayOfMonth >= alert.monthly_start_day && dayOfMonth <= alert.monthly_end_day;
        }
        return true;

      case 'weekly':
        const weeklyPattern = scheduleRules.weekly_pattern;
        if (weeklyPattern && weeklyPattern.days) {
          const dayName = now.toLocaleDateString('en-US', { weekday: 'lowercase' });
          return weeklyPattern.days.includes(dayName);
        }
        return true;

      case 'daily':
        const dailyPattern = scheduleRules.daily_pattern;
        if (dailyPattern && dailyPattern.every_n_days) {
          // Check if today is within the interval
          // For simplicity, always show (can be enhanced with start date tracking)
          return true;
        }
        return true;

      case 'custom_dates':
        const customDates = scheduleRules.custom_dates || alert.custom_dates || [];
        return customDates.includes(localDate);

      default:
        return true;
    }
  }

  // Remove old isWithinDateWindow function and replace with isWithinScheduleWindow
  function isWithinDateWindow(alert) {
    // Fallback for old column-based alerts
    return isWithinScheduleWindow({}, alert);
  }

  function hasImpressionToday(impressions) {
    if (!impressions || impressions.length === 0) return false;
    const today = getTodayLocalDate();
    return impressions.some(imp => imp.shown_date_local === today);
  }

  function hasImpressionThisWeek(impressions) {
    if (!impressions || impressions.length === 0) return false;
    const now = new Date();
    const weekStart = new Date(now);
    weekStart.setDate(now.getDate() - now.getDay()); // Sunday of current week
    weekStart.setHours(0, 0, 0, 0);
    
    return impressions.some(imp => {
      const impDate = new Date(imp.shown_at);
      return impDate >= weekStart;
    });
  }

  function getTodayLocalDate() {
    // Return YYYY-MM-DD in local timezone
    const now = new Date();
    return now.toISOString().split('T')[0];
  }

  // ==========================================
  // DISPLAY ALERT MODAL
  // ==========================================
  async function showAlert(alert) {
    isShowingAlert = true;

    // Create modal HTML
    const modal = createAlertModal(alert);
    document.body.appendChild(modal);

    // Animate in
    requestAnimationFrame(() => {
      modal.classList.add('show');
    });

    // Record impression
    await recordImpression(alert.id, currentStudent.id);

    // Setup event listeners
    setupAlertEventListeners(modal, alert);
  }

  // ==========================================
  // TEMPLATE VARIABLE REPLACEMENT
  // ==========================================
  function replaceTemplateVariables(message, student) {
    if (!message || !student) return message;

    const now = new Date();
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 
                    'July', 'August', 'September', 'October', 'November', 'December'];
    
    const variables = {
      '{student_name}': student.full_name || 'Student',
      '{student_id}': student.student_id || 'N/A',
      '{email}': student.email || '',
      '{month}': months[now.getMonth()],
      '{year}': now.getFullYear().toString(),
      '{date}': now.toLocaleDateString('en-US'),
      '{group}': student.enrollment_group || student.group || 'N/A'
    };

    let result = message;
    for (const [variable, value] of Object.entries(variables)) {
      result = result.replace(new RegExp(escapeRegex(variable), 'g'), value);
    }

    return result;
  }

  function escapeRegex(string) {
    return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  function createAlertModal(alert) {
    const severityIcons = {
      info: '📘',
      success: '✅',
      warn: '⚠️',
      critical: '🚨'
    };

    const severityColors = {
      info: '#3b82f6',
      success: '#10b981',
      warn: '#f59e0b',
      critical: '#ef4444'
    };

    const modal = document.createElement('div');
    modal.className = 'acnhs-alert-overlay';
    modal.id = `alert-${alert.id}`;
    modal.dataset.alertId = alert.id;

    const needsResponse = alert.requires_response && alert.response_type === 'yes_no';
    
    // Replace template variables in message and title
    const personalizedTitle = replaceTemplateVariables(alert.title, currentStudent);
    const personalizedMessage = replaceTemplateVariables(alert.message_html, currentStudent);

    modal.innerHTML = `
      <div class="acnhs-alert-modal" style="border-top: 4px solid ${severityColors[alert.severity]}">
        <div class="acnhs-alert-header">
          ${!needsResponse ? '<button class="acnhs-alert-close" aria-label="Close">&times;</button>' : ''}
          <div style="display: flex; flex-direction: column; align-items: center; width: 100%;">
            <div class="acnhs-alert-icon" style="background: ${severityColors[alert.severity]}20; color: ${severityColors[alert.severity]}">
              ${severityIcons[alert.severity]}
            </div>
            <h3 class="acnhs-alert-title">${escapeHtml(personalizedTitle)}</h3>
          </div>
        </div>
        <div class="acnhs-alert-body">
          ${personalizedMessage}
        </div>
        ${needsResponse ? `
          <div class="acnhs-alert-actions">
            <button class="acnhs-alert-btn acnhs-alert-btn-yes" data-answer="yes">
              ${escapeHtml(alert.yes_label)}
            </button>
            <button class="acnhs-alert-btn acnhs-alert-btn-no" data-answer="no">
              ${escapeHtml(alert.no_label)}
            </button>
          </div>
        ` : ''}
      </div>
    `;

    return modal;
  }

  function setupAlertEventListeners(modal, alert) {
    const alertId = alert.id;
    const needsResponse = alert.requires_response && alert.response_type === 'yes_no';

    // Close button (X)
    const closeBtn = modal.querySelector('.acnhs-alert-close');
    if (closeBtn) {
      closeBtn.addEventListener('click', () => dismissAlert(modal, alert));
    }

    // Close button (footer)
    const closeBtnFooter = modal.querySelector('.acnhs-alert-btn-close');
    if (closeBtnFooter) {
      closeBtnFooter.addEventListener('click', () => dismissAlert(modal, alert));
    }

    // Yes/No response buttons
    if (needsResponse) {
      const yesBtn = modal.querySelector('[data-answer="yes"]');
      const noBtn = modal.querySelector('[data-answer="no"]');

      if (yesBtn) {
        yesBtn.addEventListener('click', async () => {
          await recordResponse(alertId, currentStudent.id, 'yes');
            dismissAlert(modal, alert);
        });
      }

      if (noBtn) {
        noBtn.addEventListener('click', async () => {
          await recordResponse(alertId, currentStudent.id, 'no');
            dismissAlert(modal, alert);
        });
      }
    }

    // Click outside to close (only if no response required)
    if (!needsResponse) {
      modal.addEventListener('click', (e) => {
        if (e.target === modal) {
          dismissAlert(modal, alert);
        }
      });
    }
  }

  function dismissAlert(modal, alert) {
    if (alert && !alert.interaction_rules?.allow_session_repeat) {
      markDismissedThisSession(alert.id);
    }
    modal.classList.remove('show');
    setTimeout(() => {
      modal.remove();
      isShowingAlert = false;
    }, ALERT_CONFIG.animationDuration);
  }

  function normalizePageValue(value) {
    return (value || '').trim().replace(/^\//, '');
  }

  function getCurrentPageVariants() {
    const rawPath = window.location.pathname || '';
    const normalizedPath = normalizePageValue(rawPath);
    const fileName = normalizedPath.split('/').pop() || normalizedPath;
    const variants = new Set();
    if (normalizedPath) {
      variants.add(normalizedPath);
      variants.add(`/${normalizedPath}`);
    }
    if (fileName) {
      variants.add(fileName);
      variants.add(`/${fileName}`);
    }
    return variants;
  }

  function doesAlertMatchPage(triggerRules) {
    const pages = triggerRules?.pages_whitelist || [];
    if (!Array.isArray(pages) || pages.length === 0) {
      return true;
    }

    const currentVariants = getCurrentPageVariants();
    return pages.some((page) => {
      const normalized = normalizePageValue(page);
      return currentVariants.has(normalized) || currentVariants.has(`/${normalized}`);
    });
  }

  function isDismissedThisSession(alertId) {
    try {
      return sessionStorage.getItem(`${SESSION_DISMISS_PREFIX}${alertId}`) === 'true';
    } catch (error) {
      return false;
    }
  }

  function markDismissedThisSession(alertId) {
    try {
      sessionStorage.setItem(`${SESSION_DISMISS_PREFIX}${alertId}`, 'true');
    } catch (error) {
      console.warn('Unable to persist session dismissal state:', error);
    }
  }

  // ==========================================
  // DATABASE WRITES
  // ==========================================
  async function recordImpression(alertId, studentId) {
    try {
      const impressionData = {
        alert_id: alertId,
        student_id: studentId,
        shown_date_local: getTodayLocalDate(),
        page_path: window.location.pathname,
        shown_at: new Date().toISOString()
      };

      // Use upsert to handle duplicate impressions gracefully
      // This updates shown_at if the record already exists
      const { error } = await supabase
        .from('portal_alert_impressions')
        .upsert(impressionData, {
          onConflict: 'alert_id,student_id,shown_date_local',
          ignoreDuplicates: false // Update the timestamp
        });

      if (error) {
        // In some environments RLS blocks anon writes (401/42501).
        // Don't break alert UX or spam error noise for expected policy denials.
        if (error.code === '42501') {
          console.warn('Impression write skipped by RLS policy.');
          return;
        }
        console.error('Error recording impression:', error);
      }
    } catch (error) {
      console.error('Error recording impression:', error);
    }
  }

  async function recordResponse(alertId, studentId, answer) {
    try {
      const { error } = await supabase
        .from('portal_alert_responses')
        .insert({
          alert_id: alertId,
          student_id: studentId,
          answer: answer,
          page_path: window.location.pathname,
          answered_at: new Date().toISOString()
        });

      if (error) console.error('Error recording response:', error);
    } catch (error) {
      console.error('Error recording response:', error);
    }
  }

  // ==========================================
  // UTILITIES
  // ==========================================
  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  // ==========================================
  // AUTO-INITIALIZE ON PAGE LOAD
  // ==========================================
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAlertEngine);
  } else {
    initAlertEngine();
  }

  // ==========================================
  // INJECT STYLES (auto-included)
  // ==========================================
  const styles = `
    .acnhs-alert-overlay {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(11, 22, 41, 0.9);
      backdrop-filter: blur(8px);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 999999;
      opacity: 0;
      transition: opacity 0.3s ease;
      padding: 40px 20px;
    }

    .acnhs-alert-overlay.show {
      opacity: 1;
    }

    .acnhs-alert-modal {
      background: linear-gradient(135deg, #0f1f3a 0%, #162844 100%);
      border-radius: 20px;
      box-shadow: 0 25px 70px rgba(0, 0, 0, 0.6);
      max-width: 580px;
      width: 100%;
      margin: auto;
      overflow: hidden;
      transform: scale(0.95) translateY(-20px);
      transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
      border: 1px solid rgba(255, 255, 255, 0.1);
      position: relative;
    }

    .acnhs-alert-overlay.show .acnhs-alert-modal {
      transform: scale(1) translateY(0);
    }

    .acnhs-alert-header {
      padding: 28px 40px 24px 40px;
      border-bottom: 1px solid rgba(255, 255, 255, 0.08);
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 16px;
      position: relative;
      text-align: center;
    }

    .acnhs-alert-icon {
      width: 56px;
      height: 56px;
      border-radius: 14px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 28px;
      flex-shrink: 0;
      margin: 0 auto 12px;
    }

    .acnhs-alert-title {
      font-family: 'Inter', sans-serif;
      font-size: 22px;
      font-weight: 700;
      color: #e2e8f0;
      margin: 0;
      text-align: center;
      width: 100%;
      padding: 0 50px;
    }

    .acnhs-alert-close {
      position: absolute;
      top: 12px;
      right: 12px;
      width: 36px;
      height: 36px;
      border-radius: 10px;
      background: rgba(255, 255, 255, 0.05);
      border: 1px solid rgba(255, 255, 255, 0.1);
      color: #94a3b8;
      font-size: 26px;
      line-height: 1;
      cursor: pointer;
      transition: all 0.2s ease;
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 10;
    }

    .acnhs-alert-close:hover {
      background: rgba(239, 68, 68, 0.2);
      border-color: #ef4444;
      color: #ef4444;
      transform: scale(1.05);
    }

    .acnhs-alert-body {
      padding: 32px 36px;
      color: #cbd5e1;
      font-family: 'Inter', sans-serif;
      font-size: 15px;
      line-height: 1.8;
      text-align: left;
    }

    .acnhs-alert-body p {
      margin: 0 0 16px 0;
    }

    .acnhs-alert-body p:last-child {
      margin-bottom: 0;
    }

    .acnhs-alert-body strong {
      color: #e2e8f0;
      font-weight: 600;
    }

    .acnhs-alert-body em {
      color: #94a3b8;
      font-style: italic;
    }

    .acnhs-alert-body ul {
      margin: 16px 0;
      padding-left: 24px;
    }

    .acnhs-alert-body li {
      margin-bottom: 10px;
    }

    .acnhs-alert-actions {
      padding: 24px 36px 28px;
      display: flex;
      gap: 14px;
      justify-content: center;
      border-top: 1px solid rgba(255, 255, 255, 0.08);
    }

    .acnhs-alert-btn {
      padding: 14px 32px;
      border-radius: 12px;
      font-family: 'Inter', sans-serif;
      font-size: 15px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s ease;
      border: none;
      outline: none;
      min-width: 120px;
    }

    .acnhs-alert-btn-yes {
      background: linear-gradient(135deg, #2dd4bf 0%, #14b8a6 100%);
      color: white;
      box-shadow: 0 4px 12px rgba(45, 212, 191, 0.3);
    }

    .acnhs-alert-btn-yes:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(45, 212, 191, 0.4);
    }

    .acnhs-alert-btn-no {
      background: rgba(148, 163, 184, 0.15);
      color: #cbd5e1;
      border: 1px solid rgba(148, 163, 184, 0.3);
    }

    .acnhs-alert-btn-no:hover {
      background: rgba(148, 163, 184, 0.25);
      border-color: rgba(148, 163, 184, 0.5);
    }

    .acnhs-alert-btn-close {
      background: rgba(45, 212, 191, 0.15);
      color: #2dd4bf;
      border: 1px solid rgba(45, 212, 191, 0.3);
    }

    .acnhs-alert-btn-close:hover {
      background: rgba(45, 212, 191, 0.25);
      border-color: rgba(45, 212, 191, 0.5);
    }

    @media (max-width: 640px) {
      .acnhs-alert-modal {
        max-width: 100%;
        margin: 0 10px;
      }

      .acnhs-alert-header {
        padding: 20px;
      }

      .acnhs-alert-body {
        padding: 20px;
        font-size: 14px;
      }

      .acnhs-alert-actions {
        flex-direction: column;
        padding: 16px 20px 20px;
      }

      .acnhs-alert-btn {
        width: 100%;
      }
    }

    @media (prefers-reduced-motion: reduce) {
      .acnhs-alert-overlay,
      .acnhs-alert-modal,
      .acnhs-alert-btn {
        transition: none;
      }
    }
  `;

  // Inject styles into page
  const styleSheet = document.createElement('style');
  styleSheet.textContent = styles;
  document.head.appendChild(styleSheet);

  // Expose API for manual checking (optional)
  window.ACNHSAlerts = {
    checkNow: checkAndShowAlerts,
    getCurrentStudent: getCurrentStudent
  };

})();
