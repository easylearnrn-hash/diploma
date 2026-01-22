// PASTE THIS INTO CONSOLE TO CHECK CURRENT STATE
console.log('🔍 Supabase Client Status:\n');
console.log('1. Library loaded?', typeof window.supabase !== 'undefined');
console.log('2. createClient available?', typeof window.supabase?.createClient === 'function');
console.log('3. Global client (supabase)?', typeof supabase);
console.log('4. Has .from() method?', typeof supabase?.from === 'function');
console.log('5. initSupabase function?', typeof initSupabase === 'function');
console.log('6. SUPABASE_CONFIG?', typeof SUPABASE_CONFIG !== 'undefined');
console.log('\n💡 Issue: Global "supabase" is the library, not the client instance.');
console.log('   Use: const client = initSupabase(); client.from("students")...');
console.log('   Or: window.supabase = initSupabase(); // to override global');
