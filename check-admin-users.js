// Check admin_users in NEW Supabase project
// Run this with: node check-admin-users.js

const { createClient } = require('@supabase/supabase-js');

const NEW_URL = 'https://eyhksbiceueoiamwnqpr.supabase.co';
const NEW_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5aGtzYmljZXVlb2lhbXducXByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4NTIwOTAsImV4cCI6MjA4NDQyODA5MH0.1G3RZLKLJvIR8U9Cvmner3kUIxDtUfFYkHpzUUbnbq8';

const supabase = createClient(NEW_URL, NEW_KEY);

async function checkAdminUsers() {
  console.log('🔍 Checking admin_users table in NEW Supabase...\n');
  
  try {
    const { data, error } = await supabase
      .from('admin_users')
      .select('*')
      .order('email');
    
    if (error) {
      console.log('❌ Error:', error.message);
      console.log('   Code:', error.code);
      console.log('   Hint:', error.hint);
      return;
    }
    
    if (!data || data.length === 0) {
      console.log('⚠️  No admin users found in the table!');
      console.log('   The admin_users table may be empty.\n');
      return;
    }
    
    console.log(`✅ Found ${data.length} admin user(s):\n`);
    data.forEach((user, i) => {
      console.log(`${i + 1}. ${user.email}`);
      console.log(`   Name: ${user.full_name || 'N/A'}`);
      console.log(`   Role: ${user.role || 'N/A'}`);
      console.log(`   Created: ${user.created_at || 'N/A'}`);
      console.log('');
    });
    
    // Check for specific missing user
    const hasMissingUser = data.some(u => u.email === 'hrach@acnhs.am');
    console.log(`\n🔍 Checking for hrach@acnhs.am: ${hasMissingUser ? '✅ Found' : '❌ Missing'}`);
    
  } catch (e) {
    console.log('❌ Unexpected error:', e.message);
  }
}

checkAdminUsers();
