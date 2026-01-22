// Paste this into your browser console to check admin users
(async () => {
  console.log('🔍 Checking admin_users in NEW Supabase...\n');
  
  // Make sure we have a client
  if (!window.sbClient && !window.supabase) {
    console.log('❌ No Supabase client found. Initialize first:');
    console.log('   window.supabase = initSupabase();');
    return;
  }
  
  const client = window.sbClient || window.supabase;
  
  try {
    const { data, error } = await client
      .from('admin_users')
      .select('*')
      .order('email');
    
    if (error) {
      console.log('❌ Error querying admin_users:', error.message);
      console.log('   Code:', error.code);
      console.log('   Hint:', error.hint);
      
      if (error.code === '42P01') {
        console.log('\n⚠️  admin_users table does not exist!');
        console.log('   Run CREATE-ADMIN-USERS-TABLE.sql in Supabase');
      }
      return;
    }
    
    if (!data || data.length === 0) {
      console.log('⚠️  admin_users table is empty!');
      console.log('   No staff accounts configured.\n');
      return;
    }
    
    console.log(`✅ Found ${data.length} admin user(s):\n`);
    data.forEach((user, i) => {
      console.log(`${i + 1}. ${user.email}`);
      console.log(`   Name: ${user.full_name || 'N/A'}`);
      console.log(`   Role: ${user.role || 'N/A'}`);
      console.log(`   Permissions:`, Object.keys(user.permissions || {}).filter(k => user.permissions[k]).join(', '));
      console.log('');
    });
    
    // Check for specific users
    const expectedUsers = [
      'hrach@acnhs.am',
      'Hrachfilm@gmail.com',
      'hrachfilm@gmail.com'
    ];
    
    console.log('\n📋 Checking for expected admin accounts:');
    expectedUsers.forEach(email => {
      const exists = data.some(u => u.email.toLowerCase() === email.toLowerCase());
      console.log(`   ${exists ? '✅' : '❌'} ${email}`);
    });
    
    const missingUsers = expectedUsers.filter(email => 
      !data.some(u => u.email.toLowerCase() === email.toLowerCase())
    );
    
    if (missingUsers.length > 0) {
      console.log('\n⚠️  Missing admin accounts:', missingUsers.join(', '));
      console.log('   Run ADD-MISSING-ADMIN-USERS.sql to add them');
    } else {
      console.log('\n✅ All expected admin accounts present!');
    }
    
  } catch (e) {
    console.log('❌ Error:', e.message);
  }
})();
