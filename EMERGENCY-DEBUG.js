// 🚨 EMERGENCY FULL DIAGNOSTIC - PASTE IN CONSOLE NOW
console.clear();
console.log('🚨🚨🚨 EMERGENCY FULL DIAGNOSTIC 🚨🚨🚨');
console.log('========================================\n');

(async function emergencyDiag() {
  const results = {};
  
  // TEST 1: Supabase connection
  console.log('TEST 1: Supabase Connection');
  results.supabaseExists = typeof db !== 'undefined';
  console.log('  db exists:', results.supabaseExists);
  if (!results.supabaseExists) {
    console.error('  ❌ FATAL: Supabase client not found!');
    return;
  }
  console.log('  ✅ Supabase client loaded\n');

  // TEST 2: Check student_groups table
  console.log('TEST 2: student_groups Table Query');
  try {
    const { data: sgData, error: sgError } = await db
      .from('student_groups')
      .select('*');
    
    results.studentGroupsError = sgError;
    results.studentGroupsData = sgData;
    results.studentGroupsCount = sgData ? sgData.length : 0;
    
    if (sgError) {
      console.error('  ❌ Error:', sgError.message);
    } else {
      console.log('  ✅ Query SUCCESS');
      console.log('  Found', results.studentGroupsCount, 'groups');
      console.log('  Data:', sgData);
    }
  } catch (e) {
    console.error('  ❌ Exception:', e.message);
    results.studentGroupsException = e;
  }
  console.log('');

  // TEST 3: Check students table
  console.log('TEST 3: students Table Query');
  try {
    const { data: studData, error: studError } = await db
      .from('students')
      .select('id, full_name, group, enrollment_status');
    
    results.studentsError = studError;
    results.studentsData = studData;
    results.studentsTotal = studData ? studData.length : 0;
    results.studentsWithGroup = studData ? studData.filter(s => s.group).length : 0;
    
    if (studError) {
      console.error('  ❌ Error:', studError.message);
    } else {
      console.log('  ✅ Query SUCCESS');
      console.log('  Total students:', results.studentsTotal);
      console.log('  Students with group:', results.studentsWithGroup);
      
      const groupCounts = {};
      studData.filter(s => s.group).forEach(s => {
        groupCounts[s.group] = (groupCounts[s.group] || 0) + 1;
      });
      console.log('  Groups breakdown:', groupCounts);
      console.log('  Sample students:', studData.filter(s => s.group).slice(0, 3));
    }
  } catch (e) {
    console.error('  ❌ Exception:', e.message);
    results.studentsException = e;
  }
  console.log('');

  // TEST 4: Check global variables
  console.log('TEST 4: Global Variables');
  results.studentGroupsVar = typeof studentGroups !== 'undefined' ? studentGroups : 'undefined';
  results.allStudentsVar = typeof allStudents !== 'undefined' ? allStudents : 'undefined';
  results.studentGroupsLength = Array.isArray(studentGroups) ? studentGroups.length : 'N/A';
  results.allStudentsLength = Array.isArray(allStudents) ? allStudents.length : 'N/A';
  
  console.log('  studentGroups:', results.studentGroupsVar);
  console.log('  studentGroups.length:', results.studentGroupsLength);
  console.log('  allStudents:', results.allStudentsVar === 'undefined' ? 'undefined' : 'defined');
  console.log('  allStudents.length:', results.allStudentsLength);
  console.log('');

  // TEST 5: Check functions
  console.log('TEST 5: Function Availability');
  results.loadStudentGroupsExists = typeof loadStudentGroups === 'function';
  results.renderGroupsTableExists = typeof renderGroupsTable === 'function';
  results.buildGroupsFromStudentsExists = typeof buildGroupsFromStudents === 'function';
  
  console.log('  loadStudentGroups:', results.loadStudentGroupsExists ? '✅' : '❌');
  console.log('  renderGroupsTable:', results.renderGroupsTableExists ? '✅' : '❌');
  console.log('  buildGroupsFromStudents:', results.buildGroupsFromStudentsExists ? '✅' : '❌');
  console.log('');

  // TEST 6: Check DOM
  console.log('TEST 6: DOM Elements');
  const container = document.getElementById('groupsTableContainer');
  results.containerExists = !!container;
  results.containerHTML = container ? container.innerHTML.substring(0, 100) : 'N/A';
  results.containerShowsEmpty = container ? container.innerHTML.includes('No Student Groups Yet') : false;
  
  console.log('  groupsTableContainer:', results.containerExists ? '✅' : '❌');
  console.log('  Shows empty state:', results.containerShowsEmpty ? 'YES ⚠️' : 'NO');
  console.log('');

  // TEST 7: localStorage
  console.log('TEST 7: localStorage Cache');
  const cached = localStorage.getItem('studentGroups');
  results.cachedGroups = cached ? JSON.parse(cached) : null;
  console.log('  Cached groups:', results.cachedGroups ? results.cachedGroups.length : 'None');
  if (results.cachedGroups) {
    console.log('  Cached data:', results.cachedGroups);
  }
  console.log('');

  // TEST 8: Try to call loadStudentGroups
  console.log('TEST 8: Manual loadStudentGroups() Call');
  if (results.loadStudentGroupsExists) {
    try {
      console.log('  Calling loadStudentGroups()...');
      const loadResult = await loadStudentGroups();
      console.log('  ✅ Function returned:', loadResult);
      console.log('  studentGroups after call:', studentGroups);
      console.log('  studentGroups.length:', studentGroups ? studentGroups.length : 'null');
    } catch (e) {
      console.error('  ❌ Exception:', e.message);
      console.error('  Stack:', e.stack);
    }
  } else {
    console.error('  ❌ Function not available');
  }
  console.log('');

  // TEST 9: Manual construction
  console.log('TEST 9: Manual Group Construction');
  if (results.studentsData && results.studentsWithGroup > 0) {
    const manualMap = new Map();
    results.studentsData.filter(s => s.group).forEach(s => {
      if (!manualMap.has(s.group)) {
        manualMap.set(s.group, {
          id: s.group.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
          name: s.group,
          semester: 'Spring 2026',
          studentIds: [],
          created_at: new Date().toISOString()
        });
      }
      manualMap.get(s.group).studentIds.push(s.id);
    });
    
    const manualGroups = Array.from(manualMap.values());
    console.log('  ✅ Manually built', manualGroups.length, 'groups');
    console.log('  Groups:', manualGroups);
    
    // FORCE SET
    console.log('\n  🔧 FORCING studentGroups = manualGroups');
    window.studentGroups = manualGroups;
    studentGroups = manualGroups;
    console.log('  studentGroups now:', studentGroups);
    
    // FORCE RENDER
    if (results.renderGroupsTableExists) {
      console.log('  🔧 FORCING renderGroupsTable()');
      renderGroupsTable();
      console.log('  ✅ Render called');
    }
  }
  console.log('');

  // TEST 10: Check what view is active
  console.log('TEST 10: Active View Check');
  const activeView = sessionStorage.getItem('adminHubView');
  const groupsSection = document.getElementById('groupsSection');
  results.activeView = activeView;
  results.groupsSectionVisible = groupsSection ? groupsSection.style.display : 'N/A';
  
  console.log('  Active view:', activeView);
  console.log('  Groups section display:', results.groupsSectionVisible);
  console.log('');

  // FINAL SUMMARY
  console.log('========================================');
  console.log('🔍 DIAGNOSTIC COMPLETE');
  console.log('========================================');
  console.log('SUMMARY:');
  console.log('  - Supabase working:', results.supabaseExists ? '✅' : '❌');
  console.log('  - student_groups table rows:', results.studentGroupsCount);
  console.log('  - Students with groups:', results.studentsWithGroup);
  console.log('  - studentGroups var length:', results.studentGroupsLength);
  console.log('  - Container shows empty:', results.containerShowsEmpty ? '⚠️ YES' : '✅ NO');
  console.log('  - Active view:', results.activeView);
  console.log('\n📋 Full Results Object:');
  console.log(results);
  
  return results;
})();
