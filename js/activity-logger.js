/**
 * User Activity Logger - Centralized Logging System
 * Tracks all user actions across the admin system
 * 
 * Usage:
 * import { logActivity } from './js/activity-logger.js';
 * await logActivity('update', 'application', 'Changed status to Accepted', { targetId: '123', targetName: 'John Doe' });
 */

// Initialize Supabase client (assumes supabase-config.js is loaded)
function getSupabaseClient() {
  if (typeof initSupabase === 'function') {
    return initSupabase();
  }
  return null;
}

// Get current user info from session/localStorage
function getCurrentUserInfo() {
  return {
    userId: sessionStorage.getItem('userId') || localStorage.getItem('userId'),
    userEmail: sessionStorage.getItem('userEmail') || localStorage.getItem('userEmail'),
    userName: sessionStorage.getItem('userName') || localStorage.getItem('userName'),
    sessionId: sessionStorage.getItem('sessionId') || generateSessionId()
  };
}

// Generate a session ID if one doesn't exist
function generateSessionId() {
  const sessionId = 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
  sessionStorage.setItem('sessionId', sessionId);
  return sessionId;
}

// Get client information
function getClientInfo() {
  return {
    userAgent: navigator.userAgent,
    timestamp: new Date().toISOString(),
    pageUrl: window.location.href,
    pagePath: window.location.pathname
  };
}

/**
 * Log a user activity
 * @param {string} actionType - Type of action: 'create', 'update', 'delete', 'view', 'send', 'export', 'login', 'logout'
 * @param {string} actionCategory - Category: 'application', 'student', 'email', 'user', 'document', 'system'
 * @param {string} description - Human-readable description of the action
 * @param {object} options - Additional options
 * @param {string} options.targetId - ID of the affected record
 * @param {string} options.targetName - Name/identifier of the target
 * @param {object} options.oldValue - Previous state (for updates)
 * @param {object} options.newValue - New state (for updates/creates)
 * @param {object} options.metadata - Additional context data
 */
async function logActivity(actionType, actionCategory, description, options = {}) {
  try {
    const db = getSupabaseClient();
    if (!db) {
      console.warn('⚠️ Activity Logger: Supabase client not available');
      return { success: false, error: 'No database connection' };
    }

    const userInfo = getCurrentUserInfo();
    const clientInfo = getClientInfo();

    // Don't log if no user is logged in
    if (!userInfo.userEmail) {
      console.warn('⚠️ Activity Logger: No user logged in');
      return { success: false, error: 'No user logged in' };
    }

    const logEntry = {
      // Don't set user_id - it has a foreign key constraint to admin_users
      // We only use email-based auth, not the admin_users table
      user_email: userInfo.userEmail,
      user_name: userInfo.userName || userInfo.userEmail,
      action_type: actionType,
      action_category: actionCategory,
      action_description: description,
      target_type: options.targetType || actionCategory,
      target_id: options.targetId || null,
      target_name: options.targetName || null,
      old_value: options.oldValue ? JSON.stringify(options.oldValue) : null,
      new_value: options.newValue ? JSON.stringify(options.newValue) : null,
      user_agent: clientInfo.userAgent,
      session_id: userInfo.sessionId,
      created_at: clientInfo.timestamp,
      metadata: {
        page_url: clientInfo.pageUrl,
        page_path: clientInfo.pagePath,
        ...options.metadata
      }
    };

    // Log to console in development
    console.log('📝 Activity Log:', {
      action: `${actionType.toUpperCase()} ${actionCategory}`,
      description,
      user: userInfo.userEmail,
      target: options.targetName || options.targetId,
      timestamp: clientInfo.timestamp
    });

    // Save to database
    const { data, error } = await db
      .from('user_activity_log')
      .insert([logEntry])
      .select();

    if (error) {
      console.error('❌ Activity Logger: Failed to save log', error);
      return { success: false, error: error.message };
    }

    console.log('✅ Activity logged successfully:', data[0].id);
    return { success: true, data: data[0] };

  } catch (error) {
    console.error('❌ Activity Logger: Exception', error);
    return { success: false, error: error.message };
  }
}

/**
 * Get activity logs for a specific user
 * @param {string} userId - User ID to get logs for
 * @param {object} options - Filter options
 * @param {number} options.limit - Maximum number of logs to return (default: 100)
 * @param {string} options.actionType - Filter by action type
 * @param {string} options.actionCategory - Filter by category
 * @param {Date} options.startDate - Filter logs after this date
 * @param {Date} options.endDate - Filter logs before this date
 */
async function getUserActivityLogs(userId, options = {}) {
  try {
    const db = getSupabaseClient();
    if (!db) {
      console.warn('⚠️ Activity Logger: Supabase client not available');
      return { success: false, error: 'No database connection' };
    }

    let query = db
      .from('user_activity_log')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    // Apply filters
    if (options.actionType) {
      query = query.eq('action_type', options.actionType);
    }

    if (options.actionCategory) {
      query = query.eq('action_category', options.actionCategory);
    }

    if (options.startDate) {
      query = query.gte('created_at', options.startDate.toISOString());
    }

    if (options.endDate) {
      query = query.lte('created_at', options.endDate.toISOString());
    }

    // Apply limit
    const limit = options.limit || 100;
    query = query.limit(limit);

    const { data, error } = await query;

    if (error) {
      console.error('❌ Activity Logger: Failed to fetch logs', error);
      return { success: false, error: error.message };
    }

    return { success: true, data, count: data.length };

  } catch (error) {
    console.error('❌ Activity Logger: Exception', error);
    return { success: false, error: error.message };
  }
}

/**
 * Get activity logs by user email (for users without UUID)
 */
async function getUserActivityLogsByEmail(userEmail, options = {}) {
  try {
    const db = getSupabaseClient();
    if (!db) {
      return { success: false, error: 'No database connection' };
    }

    let query = db
      .from('user_activity_log')
      .select('*')
      .eq('user_email', userEmail)
      .order('created_at', { ascending: false });

    if (options.actionType) query = query.eq('action_type', options.actionType);
    if (options.actionCategory) query = query.eq('action_category', options.actionCategory);
    if (options.startDate) query = query.gte('created_at', options.startDate.toISOString());
    if (options.endDate) query = query.lte('created_at', options.endDate.toISOString());

    const limit = options.limit || 100;
    query = query.limit(limit);

    const { data, error } = await query;

    if (error) {
      console.error('❌ Activity Logger: Failed to fetch logs', error);
      return { success: false, error: error.message };
    }

    return { success: true, data, count: data.length };

  } catch (error) {
    console.error('❌ Activity Logger: Exception', error);
    return { success: false, error: error.message };
  }
}

/**
 * Get all activity logs (admin only)
 */
async function getAllActivityLogs(options = {}) {
  try {
    const db = getSupabaseClient();
    if (!db) {
      return { success: false, error: 'No database connection' };
    }

    let query = db
      .from('user_activity_log')
      .select('*')
      .order('created_at', { ascending: false });

    if (options.actionType) query = query.eq('action_type', options.actionType);
    if (options.actionCategory) query = query.eq('action_category', options.actionCategory);
    if (options.startDate) query = query.gte('created_at', options.startDate.toISOString());
    if (options.endDate) query = query.lte('created_at', options.endDate.toISOString());

    const limit = options.limit || 500;
    query = query.limit(limit);

    const { data, error } = await query;

    if (error) {
      console.error('❌ Activity Logger: Failed to fetch logs', error);
      return { success: false, error: error.message };
    }

    return { success: true, data, count: data.length };

  } catch (error) {
    console.error('❌ Activity Logger: Exception', error);
    return { success: false, error: error.message };
  }
}

// Action type and category constants for consistency
const ACTION_TYPES = {
  CREATE: 'create',
  UPDATE: 'update',
  DELETE: 'delete',
  VIEW: 'view',
  SEND: 'send',
  EXPORT: 'export',
  LOGIN: 'login',
  LOGOUT: 'logout',
  DOWNLOAD: 'download',
  PRINT: 'print',
  APPROVE: 'approve',
  REJECT: 'reject',
  RESTORE: 'restore'
};

const ACTION_CATEGORIES = {
  APPLICATION: 'application',
  STUDENT: 'student',
  EMAIL: 'email',
  USER: 'user',
  DOCUMENT: 'document',
  SYSTEM: 'system',
  TRANSCRIPT: 'transcript',
  REPORT: 'report',
  SETTINGS: 'settings'
};

// Export functions and constants
if (typeof window !== 'undefined') {
  window.logActivity = logActivity;
  window.getUserActivityLogs = getUserActivityLogs;
  window.getUserActivityLogsByEmail = getUserActivityLogsByEmail;
  window.getAllActivityLogs = getAllActivityLogs;
  window.ACTION_TYPES = ACTION_TYPES;
  window.ACTION_CATEGORIES = ACTION_CATEGORIES;
}
