/**
 * ACNHS LOCALSTORAGE → SUPABASE MIGRATION HELPER
 * Run this in browser console on admin-hub.html to migrate existing data
 * 
 * INSTRUCTIONS:
 * 1. First run MIGRATE-ALL-TO-SUPABASE.sql in Supabase SQL Editor
 * 2. Open admin-hub.html in browser
 * 3. Open DevTools console (Cmd+Option+I)
 * 4. Copy this entire file and paste into console
 * 5. Run: await migrateAllToSupabase()
 */

async function migrateAllToSupabase() {
  console.log('🚀 Starting migration from localStorage to Supabase...\n');
  
  const db = window.db || window.supabase;
  if (!db) {
    console.error('❌ Supabase client not found! Make sure you are on admin-hub.html');
    return;
  }

  let successCount = 0;
  let errorCount = 0;

  // ============================================================================
  // MIGRATE STUDENT GROUPS
  // ============================================================================
  
  console.log('📦 Migrating Student Groups...');
  const studentGroupsStr = localStorage.getItem('studentGroups');
  
  if (studentGroupsStr) {
    try {
      const groups = JSON.parse(studentGroupsStr);
      console.log(`   Found ${groups.length} groups in localStorage`);
      
      for (const group of groups) {
        const { error } = await db
          .from('student_groups')
          .upsert({
            id: group.id,
            name: group.name,
            semester: group.semester,
            student_ids: group.studentIds || group.students || [],
            created_at: group.created_at,
            updated_at: group.updated_at
          }, {
            onConflict: 'id'
          });
        
        if (error) {
          console.error(`   ❌ Failed to migrate group "${group.name}":`, error.message);
          errorCount++;
        } else {
          console.log(`   ✅ Migrated group: ${group.name}`);
          successCount++;
        }
      }
    } catch (err) {
      console.error('   ❌ Error parsing student groups:', err);
      errorCount++;
    }
  } else {
    console.log('   ℹ️  No student groups found in localStorage');
  }

  // ============================================================================
  // MIGRATE COURSE ENROLLMENTS
  // ============================================================================
  
  console.log('\n📚 Migrating Course Enrollments...');
  const enrollmentsStr = localStorage.getItem('COURSE_ENROLLMENTS');
  
  if (enrollmentsStr) {
    try {
      const enrollments = JSON.parse(enrollmentsStr);
      const keys = Object.keys(enrollments);
      console.log(`   Found ${keys.length} course enrollments in localStorage`);
      
      for (const enrollmentKey of keys) {
        const enrolledGroupIds = enrollments[enrollmentKey];
        const [semester, courseCode] = enrollmentKey.split('_');
        
        const { error } = await db
          .from('course_enrollments')
          .upsert({
            enrollment_key: enrollmentKey,
            semester: semester,
            course_code: courseCode,
            enrolled_group_ids: enrolledGroupIds || []
          }, {
            onConflict: 'enrollment_key'
          });
        
        if (error) {
          console.error(`   ❌ Failed to migrate enrollment "${enrollmentKey}":`, error.message);
          errorCount++;
        } else {
          console.log(`   ✅ Migrated enrollment: ${enrollmentKey} (${enrolledGroupIds.length} groups)`);
          successCount++;
        }
      }
    } catch (err) {
      console.error('   ❌ Error parsing course enrollments:', err);
      errorCount++;
    }
  } else {
    console.log('   ℹ️  No course enrollments found in localStorage');
  }

  // ============================================================================
  // MIGRATE COURSE GRADES
  // ============================================================================
  
  console.log('\n📊 Migrating Course Grades...');
  const gradesStr = localStorage.getItem('COURSE_GRADES');
  
  if (gradesStr) {
    try {
      const courseGrades = JSON.parse(gradesStr);
      const keys = Object.keys(courseGrades);
      console.log(`   Found ${keys.length} course grade sets in localStorage`);
      
      for (const enrollmentKey of keys) {
        const studentGrades = courseGrades[enrollmentKey];
        const [semester, courseCode] = enrollmentKey.split('_');
        
        // studentGrades is an object: { studentId: { gradeItems: [...] } }
        for (const [studentId, gradeData] of Object.entries(studentGrades)) {
          const { error } = await db
            .from('course_grade_items')
            .upsert({
              student_id: studentId,
              enrollment_key: enrollmentKey,
              semester: semester,
              course_code: courseCode,
              grade_items: JSON.stringify(gradeData.gradeItems || []),
              final_percentage: gradeData.finalPercentage || null,
              letter_grade: gradeData.letterGrade || null
            }, {
              onConflict: 'student_id,enrollment_key'
            });
          
          if (error) {
            console.error(`   ❌ Failed to migrate grades for student ${studentId}:`, error.message);
            errorCount++;
          } else {
            console.log(`   ✅ Migrated grades: ${enrollmentKey} - Student ${studentId}`);
            successCount++;
          }
        }
      }
    } catch (err) {
      console.error('   ❌ Error parsing course grades:', err);
      errorCount++;
    }
  } else {
    console.log('   ℹ️  No course grades found in localStorage');
  }

  // ============================================================================
  // SUMMARY
  // ============================================================================
  
  console.log('\n' + '='.repeat(60));
  console.log('🎉 MIGRATION COMPLETE');
  console.log('='.repeat(60));
  console.log(`✅ Successful migrations: ${successCount}`);
  console.log(`❌ Failed migrations: ${errorCount}`);
  console.log('\n📋 Next Steps:');
  console.log('1. Verify data in Supabase Dashboard');
  console.log('2. Update admin-hub.html to use Supabase functions');
  console.log('3. Test all features (groups, enrollments, grades)');
  console.log('4. Clear localStorage (optional): localStorage.clear()');
  console.log('='.repeat(60));
}

// Auto-run if called from console
console.log('✅ Migration script loaded!');
console.log('📝 To migrate data, run: await migrateAllToSupabase()');
