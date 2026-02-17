// COMPREHENSIVE STUDENT GROUPS DEBUGGING SCRIPT
// Copy and paste this entire script into your browser console on admin-hub.html

console.log('🔍 ========================================');
console.log('🔍 STUDENT GROUPS COMPREHENSIVE DEBUG');
console.log('🔍 ========================================');

async function debugStudentGroups() {
  try {
    console.log('\n📌 STEP 1: Check Supabase Connection');
    console.log('Supabase client:', typeof db !== 'undefined' ? '✅ Available' : '❌ NOT FOUND');
    if (typeof db === 'undefined') {
      console.error('❌ CRITICAL: Supabase client (db) not initialized!');
      return;
    }

    console.log('\n📌 STEP 2: Check student_groups table directly');
    const { data: groupsData, error: groupsError } = await db
      .from('student_groups')
      .select('*')
      .order('created_at', { ascending: false });
    
    console.log('Query result:', { 
      error: groupsError, 
      dataLength: groupsData ? groupsData.length : 0,
      data: groupsData 
    });

    if (groupsError) {
      console.error('❌ student_groups query error:', groupsError);
    } else {
      console.log('✅ student_groups query SUCCESS');
      console.log(`Found ${groupsData.length} groups:`, groupsData);
    }

    console.log('\n📌 STEP 3: Check students.group field');
    const { data: studentsData, error: studentsError } = await db
      .from('students')
      .select('id, full_name, group')
      .not('group', 'is', null);
    
    console.log('Students query result:', { 
      error: studentsError, 
      dataLength: studentsData ? studentsData.length : 0,
      data: studentsData 
    });

    if (studentsError) {
      console.error('❌ students query error:', studentsError);
    } else {
      console.log('✅ students query SUCCESS');
      console.log(`Found ${studentsData.length} students with groups:`, studentsData);
      
      // Count students per group
      const groupCounts = {};
      studentsData.forEach(s => {
        groupCounts[s.group] = (groupCounts[s.group] || 0) + 1;
      });
      console.log('Students per group:', groupCounts);
    }

    console.log('\n📌 STEP 4: Check global studentGroups variable');
    console.log('typeof studentGroups:', typeof studentGroups);
    console.log('studentGroups value:', studentGroups);
    console.log('studentGroups.length:', studentGroups ? studentGroups.length : 'N/A');

    console.log('\n📌 STEP 5: Check allStudents variable');
    console.log('typeof allStudents:', typeof allStudents);
    console.log('allStudents.length:', allStudents ? allStudents.length : 'N/A');
    if (allStudents && allStudents.length > 0) {
      const studentsWithGroup = allStudents.filter(s => s.group);
      console.log(`Students with group field: ${studentsWithGroup.length}/${allStudents.length}`);
      console.log('Sample students with groups:', studentsWithGroup.slice(0, 5));
    }

    console.log('\n📌 STEP 6: Check loadStudentGroups function');
    console.log('typeof loadStudentGroups:', typeof loadStudentGroups);
    if (typeof loadStudentGroups === 'function') {
      console.log('Calling loadStudentGroups()...');
      const result = await loadStudentGroups();
      console.log('loadStudentGroups() returned:', result);
      console.log('studentGroups after loadStudentGroups():', studentGroups);
    } else {
      console.error('❌ loadStudentGroups function not found!');
    }

    console.log('\n📌 STEP 7: Check buildGroupsFromStudents function');
    console.log('typeof buildGroupsFromStudents:', typeof buildGroupsFromStudents);
    if (typeof buildGroupsFromStudents === 'function') {
      console.log('Calling buildGroupsFromStudents()...');
      await buildGroupsFromStudents();
      console.log('studentGroups after buildGroupsFromStudents():', studentGroups);
    } else {
      console.error('❌ buildGroupsFromStudents function not found!');
    }

    console.log('\n📌 STEP 8: Check DOM elements');
    const container = document.getElementById('groupsTableContainer');
    console.log('groupsTableContainer element:', container ? '✅ Found' : '❌ Not found');
    if (container) {
      console.log('Container innerHTML length:', container.innerHTML.length);
      console.log('Container shows empty state?', container.innerHTML.includes('No Student Groups Yet'));
    }

    console.log('\n📌 STEP 9: Test renderGroupsTable function');
    console.log('typeof renderGroupsTable:', typeof renderGroupsTable);
    if (typeof renderGroupsTable === 'function') {
      console.log('Calling renderGroupsTable()...');
      renderGroupsTable();
      console.log('renderGroupsTable() completed');
    } else {
      console.error('❌ renderGroupsTable function not found!');
    }

    console.log('\n📌 STEP 10: Check localStorage cache');
    const cachedGroups = localStorage.getItem('studentGroups');
    console.log('localStorage studentGroups:', cachedGroups ? JSON.parse(cachedGroups) : 'null');

    console.log('\n📌 STEP 11: Manual group construction test');
    if (studentsData && studentsData.length > 0) {
      const testGroupMap = new Map();
      studentsData.forEach(student => {
        const groupName = student.group;
        if (!groupName) return;
        if (!testGroupMap.has(groupName)) {
          testGroupMap.set(groupName, {
            id: groupName.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
            name: groupName,
            semester: 'Spring 2026',
            studentIds: [],
            students: []
          });
        }
        const group = testGroupMap.get(groupName);
        group.studentIds.push(student.id);
        group.students.push(student.full_name);
      });
      
      const manualGroups = Array.from(testGroupMap.values());
      console.log('✅ Manually constructed groups:', manualGroups);
      
      console.log('\n🔧 ATTEMPTING TO FIX: Setting studentGroups manually...');
      studentGroups = manualGroups;
      console.log('studentGroups is now:', studentGroups);
      
      console.log('🔧 Re-rendering table...');
      if (typeof renderGroupsTable === 'function') {
        renderGroupsTable();
      }
    }

    console.log('\n📌 STEP 12: Check RLS policies (requires anon key check)');
    console.log('Current Supabase auth user:', await db.auth.getUser());

    console.log('\n🔍 ========================================');
    console.log('🔍 DEBUG COMPLETE - Review logs above');
    console.log('🔍 ========================================');

  } catch (error) {
    console.error('💥 DEBUG SCRIPT ERROR:', error);
    console.error('Stack trace:', error.stack);
  }
}

// Run the debug
debugStudentGroups();
