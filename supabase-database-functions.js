/**
 * SUPABASE DATABASE FUNCTIONS FOR ADMIN-HUB.HTML
 * 
 * Add these functions to admin-hub.html to replace localStorage with Supabase
 * Insert BEFORE the existing localStorage functions
 * 
 * USAGE: Copy this entire file and paste into <script> section of admin-hub.html
 */

// ============================================================================
// STUDENT GROUPS - Supabase Functions
// ============================================================================

/**
 * Load all student groups from Supabase
 * Replaces: loadStudentGroups()
 */
async function loadStudentGroupsFromDB() {
  try {
    const { data, error } = await db
      .from('student_groups')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;

    // Convert student_ids array to studentIds for backwards compatibility
    studentGroups = (data || []).map(group => ({
      ...group,
      studentIds: group.student_ids || []
    }));

    return studentGroups;
  } catch (error) {
    console.error('Error loading student groups:', error);
    showToast('Failed to load student groups', 'error');
    return [];
  }
}

/**
 * Save a student group to Supabase
 * @param {Object} group - Group object with id, name, semester, studentIds
 */
async function saveStudentGroupToDB(group) {
  try {
    const { data, error } = await db
      .from('student_groups')
      .upsert({
        id: group.id,
        name: group.name,
        semester: group.semester,
        student_ids: group.studentIds || [],
        created_at: group.created_at || new Date().toISOString(),
        updated_at: new Date().toISOString()
      }, {
        onConflict: 'id'
      })
      .select()
      .single();

    if (error) throw error;

    console.log('✅ Student group saved:', group.name);
    return { success: true, data };
  } catch (error) {
    console.error('Error saving student group:', error);
    showToast('Failed to save group', 'error');
    return { success: false, error };
  }
}

/**
 * Delete a student group from Supabase
 * @param {string} groupId - Group ID to delete
 */
async function deleteStudentGroupFromDB(groupId) {
  try {
    const { error } = await db
      .from('student_groups')
      .delete()
      .eq('id', groupId);

    if (error) throw error;

    console.log('✅ Student group deleted:', groupId);
    return { success: true };
  } catch (error) {
    console.error('Error deleting student group:', error);
    showToast('Failed to delete group', 'error');
    return { success: false, error };
  }
}

// ============================================================================
// COURSE ENROLLMENTS - Supabase Functions
// ============================================================================

/**
 * Load all course enrollments from Supabase
 * Returns object in same format as localStorage: { "Semester 1_NUR101": ["group1", "group2"] }
 */
async function loadCourseEnrollmentsFromDB() {
  try {
    const { data, error } = await db
      .from('course_enrollments')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;

    // Convert to localStorage format
    const enrollments = {};
    (data || []).forEach(enrollment => {
      enrollments[enrollment.enrollment_key] = enrollment.enrolled_group_ids || [];
    });

    return enrollments;
  } catch (error) {
    console.error('Error loading course enrollments:', error);
    showToast('Failed to load enrollments', 'error');
    return {};
  }
}

/**
 * Save course enrollment to Supabase
 * @param {string} enrollmentKey - Format: "Semester 1_NUR101"
 * @param {string[]} enrolledGroupIds - Array of group IDs
 */
async function saveCourseEnrollmentToDB(enrollmentKey, enrolledGroupIds) {
  try {
    const [semester, courseCode] = enrollmentKey.split('_');
    
    const { data, error } = await db
      .from('course_enrollments')
      .upsert({
        enrollment_key: enrollmentKey,
        semester: semester,
        course_code: courseCode,
        enrolled_group_ids: enrolledGroupIds || [],
        updated_at: new Date().toISOString()
      }, {
        onConflict: 'enrollment_key'
      })
      .select()
      .single();

    if (error) throw error;

    console.log('✅ Course enrollment saved:', enrollmentKey);
    return { success: true, data };
  } catch (error) {
    console.error('Error saving course enrollment:', error);
    showToast('Failed to save enrollment', 'error');
    return { success: false, error };
  }
}

// ============================================================================
// COURSE GRADES - Supabase Functions
// ============================================================================

/**
 * Load all course grade items from Supabase
 * Returns object in same format as localStorage
 */
async function loadCourseGradesFromDB() {
  try {
    const { data, error } = await db
      .from('course_grade_items')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;

    // Convert to localStorage format: { "Semester 1_NUR101": { studentId: { gradeItems: [...] } } }
    const courseGrades = {};
    (data || []).forEach(item => {
      if (!courseGrades[item.enrollment_key]) {
        courseGrades[item.enrollment_key] = {};
      }
      
      courseGrades[item.enrollment_key][item.student_id] = {
        gradeItems: JSON.parse(item.grade_items || '[]'),
        finalPercentage: item.final_percentage,
        letterGrade: item.letter_grade
      };
    });

    return courseGrades;
  } catch (error) {
    console.error('Error loading course grades:', error);
    showToast('Failed to load grades', 'error');
    return {};
  }
}

/**
 * Save course grade items to Supabase
 * @param {string} enrollmentKey - Format: "Semester 1_NUR101"
 * @param {string} studentId - Student UUID or ACNHS ID
 * @param {Object} gradeData - { gradeItems: [], finalPercentage, letterGrade }
 */
async function saveCourseGradeToDB(enrollmentKey, studentId, gradeData) {
  try {
    const [semester, courseCode] = enrollmentKey.split('_');
    
    const { data, error } = await db
      .from('course_grade_items')
      .upsert({
        student_id: studentId,
        enrollment_key: enrollmentKey,
        semester: semester,
        course_code: courseCode,
        grade_items: JSON.stringify(gradeData.gradeItems || []),
        final_percentage: gradeData.finalPercentage || null,
        letter_grade: gradeData.letterGrade || null,
        updated_at: new Date().toISOString()
      }, {
        onConflict: 'student_id,enrollment_key'
      })
      .select()
      .single();

    if (error) throw error;

    console.log('✅ Course grade saved:', enrollmentKey, studentId);
    return { success: true, data };
  } catch (error) {
    console.error('Error saving course grade:', error);
    showToast('Failed to save grade', 'error');
    return { success: false, error };
  }
}

// ============================================================================
// ATTENDANCE - Supabase Functions
// ============================================================================

/**
 * Load attendance records for a student/course
 * @param {string} studentId - Student UUID or ACNHS ID
 * @param {string} courseCode - Course code (e.g., "NUR101")
 * @param {string} semester - Semester (e.g., "Semester 1")
 */
async function loadAttendanceRecords(studentId, courseCode, semester) {
  try {
    const { data, error } = await db
      .from('attendance_records')
      .select('*')
      .eq('student_id', studentId)
      .eq('course_code', courseCode)
      .eq('semester', semester)
      .order('session_date', { ascending: false });

    if (error) throw error;

    return { success: true, data: data || [] };
  } catch (error) {
    console.error('Error loading attendance:', error);
    return { success: false, error, data: [] };
  }
}

/**
 * Save attendance record to Supabase
 * @param {Object} record - { studentId, courseCode, semester, sessionDate, sessionType, status, notes, recordedBy }
 */
async function saveAttendanceRecord(record) {
  try {
    const { data, error } = await db
      .from('attendance_records')
      .upsert({
        student_id: record.studentId,
        course_code: record.courseCode,
        semester: record.semester,
        session_date: record.sessionDate,
        session_type: record.sessionType,
        status: record.status,
        notes: record.notes || null,
        recorded_by: record.recordedBy || sessionStorage.getItem('adminEmail') || 'admin',
        updated_at: new Date().toISOString()
      }, {
        onConflict: 'student_id,course_code,session_date,session_type'
      })
      .select()
      .single();

    if (error) throw error;

    console.log('✅ Attendance saved:', record.studentId, record.sessionDate);
    return { success: true, data };
  } catch (error) {
    console.error('Error saving attendance:', error);
    showToast('Failed to save attendance', 'error');
    return { success: false, error };
  }
}

/**
 * Get attendance statistics for a student
 * @param {string} studentId - Student UUID or ACNHS ID
 * @param {string} courseCode - Course code
 * @param {string} semester - Semester
 */
async function getAttendanceStats(studentId, courseCode, semester) {
  try {
    const { data, error } = await db
      .from('attendance_records')
      .select('status, session_type')
      .eq('student_id', studentId)
      .eq('course_code', courseCode)
      .eq('semester', semester);

    if (error) throw error;

    const records = data || [];
    
    const stats = {
      total: records.length,
      present: records.filter(r => r.status === 'present').length,
      absent: records.filter(r => r.status === 'absent').length,
      late: records.filter(r => r.status === 'late').length,
      excused: records.filter(r => r.status === 'excused').length,
      theoryAbsences: records.filter(r => r.session_type === 'theory' && r.status === 'absent').length,
      clinicalAbsences: records.filter(r => r.session_type === 'clinical' && r.status === 'absent').length
    };

    stats.attendanceRate = stats.total > 0 
      ? ((stats.present + stats.excused) / stats.total * 100).toFixed(1) 
      : 0;

    return { success: true, stats };
  } catch (error) {
    console.error('Error calculating attendance stats:', error);
    return { success: false, error, stats: null };
  }
}

// ============================================================================
// TOAST NOTIFICATION HELPER
// ============================================================================

function showToast(message, type = 'info') {
  // If toast system exists in admin-hub, use it
  if (typeof window.showNotification === 'function') {
    window.showNotification(message, type);
    return;
  }

  // Fallback to console
  const emoji = {
    success: '✅',
    error: '❌',
    warning: '⚠️',
    info: 'ℹ️'
  }[type] || 'ℹ️';
  
  console.log(`${emoji} ${message}`);
}

// ============================================================================
// INITIALIZATION
// ============================================================================

console.log('✅ Supabase database functions loaded');
console.log('📋 Available functions:');
console.log('   - loadStudentGroupsFromDB()');
console.log('   - saveStudentGroupToDB(group)');
console.log('   - deleteStudentGroupFromDB(groupId)');
console.log('   - loadCourseEnrollmentsFromDB()');
console.log('   - saveCourseEnrollmentToDB(key, groupIds)');
console.log('   - loadCourseGradesFromDB()');
console.log('   - saveCourseGradeToDB(key, studentId, gradeData)');
console.log('   - loadAttendanceRecords(studentId, course, semester)');
console.log('   - saveAttendanceRecord(record)');
console.log('   - getAttendanceStats(studentId, course, semester)');
