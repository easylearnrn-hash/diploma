// ═══════════════════════════════════════════════════════════════════════════
// SUPABASE CONFIGURATION DIAGNOSTIC SCRIPT
// Copy and paste this entire script into your browser console
// ═══════════════════════════════════════════════════════════════════════════

(async function diagnoseSupabaseConfig() {
  console.log('\n🔍 SUPABASE CONFIGURATION DIAGNOSTIC REPORT\n');
  console.log('═'.repeat(80));
  
  const results = {
    errors: [],
    warnings: [],
    info: []
  };

  // ─────────────────────────────────────────────────────────────────────────
  // 1. CHECK SUPABASE CLIENT INSTANCE
  // ─────────────────────────────────────────────────────────────────────────
  console.log('\n📦 1. SUPABASE CLIENT INSTANCE');
  console.log('─'.repeat(80));
  
  if (typeof supabase !== 'undefined' && supabase) {
    console.log('✅ Global supabase client exists');
    console.log('   Type:', typeof supabase);
    
    // Extract URL from client
    try {
      const clientUrl = supabase.supabaseUrl || 
                       supabase.rest?.url || 
                       (supabase.realtime?.endPoint?.replace('/realtime/v1', ''));
      
      if (clientUrl) {
        console.log('   📍 URL:', clientUrl);
        results.info.push(`Supabase URL: ${clientUrl}`);
        
        if (clientUrl.includes('zlvnxvrzotamhpezqedr')) {
          console.log('   ⚠️  OLD PROJECT DETECTED: zlvnxvrzotamhpezqedr');
          results.errors.push('Using OLD Supabase project (zlvnxvrzotamhpezqedr)');
        } else if (clientUrl.includes('eyhksbiceueoiamwnqpr')) {
          console.log('   ✅ NEW PROJECT: eyhksbiceueoiamwnqpr');
          results.info.push('Using NEW Supabase project (eyhksbiceueoiamwnqpr)');
        } else {
          console.log('   ❓ UNKNOWN PROJECT');
          results.warnings.push(`Unknown Supabase project: ${clientUrl}`);
        }
      }
    } catch (e) {
      console.warn('   ⚠️  Could not extract URL from client:', e.message);
    }
  } else {
    console.log('❌ No global supabase client found');
    results.errors.push('Global supabase client not initialized');
  }

  // Check for multiple instances
  if (typeof sbClient !== 'undefined' && sbClient) {
    console.log('✅ sbClient instance exists');
    try {
      const sbUrl = sbClient.supabaseUrl || sbClient.rest?.url;
      if (sbUrl) {
        console.log('   📍 sbClient URL:', sbUrl);
      }
    } catch (e) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. CHECK SUPABASE CONFIG FILE
  // ─────────────────────────────────────────────────────────────────────────
  console.log('\n⚙️  2. CONFIGURATION (window.SUPABASE_CONFIG)');
  console.log('─'.repeat(80));
  
  if (typeof SUPABASE_CONFIG !== 'undefined' && SUPABASE_CONFIG) {
    console.log('✅ SUPABASE_CONFIG found');
    console.log('   URL:', SUPABASE_CONFIG.url);
    console.log('   Key:', SUPABASE_CONFIG.anonKey ? `${SUPABASE_CONFIG.anonKey.substring(0, 20)}...` : 'NOT SET');
    
    if (SUPABASE_CONFIG.url.includes('zlvnxvrzotamhpezqedr')) {
      console.log('   ⚠️  OLD PROJECT in config');
      results.errors.push('SUPABASE_CONFIG points to OLD project');
    } else if (SUPABASE_CONFIG.url.includes('eyhksbiceueoiamwnqpr')) {
      console.log('   ✅ NEW PROJECT in config');
      results.info.push('SUPABASE_CONFIG correctly set to NEW project');
    }
  } else {
    console.log('❌ SUPABASE_CONFIG not found');
    results.warnings.push('SUPABASE_CONFIG not defined');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. SCAN ALL LOADED SCRIPTS
  // ─────────────────────────────────────────────────────────────────────────
  console.log('\n📜 3. LOADED SCRIPTS SCAN');
  console.log('─'.repeat(80));
  
  const scripts = Array.from(document.querySelectorAll('script[src]'));
  const supabaseScripts = scripts.filter(s => s.src.includes('supabase'));
  
  console.log(`Found ${supabaseScripts.length} Supabase-related scripts:`);
  supabaseScripts.forEach((script, i) => {
    console.log(`   ${i + 1}. ${script.src}`);
  });

  // Check for config script
  const configScript = scripts.find(s => s.src.includes('supabase-config.js'));
  if (configScript) {
    console.log('✅ supabase-config.js loaded from:', configScript.src);
  } else {
    console.log('⚠️  supabase-config.js not found in loaded scripts');
    results.warnings.push('supabase-config.js not loaded');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. CHECK INLINE SCRIPT TAGS
  // ─────────────────────────────────────────────────────────────────────────
  console.log('\n🔎 4. INLINE SCRIPTS SCAN');
  console.log('─'.repeat(80));
  
  const inlineScripts = Array.from(document.querySelectorAll('script:not([src])'));
  let oldProjectInlineCount = 0;
  let newProjectInlineCount = 0;
  
  inlineScripts.forEach((script, i) => {
    const content = script.textContent || script.innerHTML;
    if (content.includes('zlvnxvrzotamhpezqedr')) {
      oldProjectInlineCount++;
      console.log(`⚠️  Script #${i + 1} contains OLD project reference (zlvnxvrzotamhpezqedr)`);
      console.log(`   Preview: ${content.substring(0, 100)}...`);
    }
    if (content.includes('eyhksbiceueoiamwnqpr')) {
      newProjectInlineCount++;
    }
  });
  
  console.log(`\nInline scripts summary:`);
  console.log(`   OLD project references: ${oldProjectInlineCount}`);
  console.log(`   NEW project references: ${newProjectInlineCount}`);
  
  if (oldProjectInlineCount > 0) {
    results.errors.push(`Found ${oldProjectInlineCount} inline script(s) with OLD project URLs`);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. TEST DATABASE CONNECTION
  // ─────────────────────────────────────────────────────────────────────────
  console.log('\n🔌 5. DATABASE CONNECTION TEST');
  console.log('─'.repeat(80));
  
  if (typeof supabase !== 'undefined' && supabase) {
    try {
      console.log('Testing connection to students table...');
      const { data, error } = await supabase
        .from('students')
        .select('id')
        .limit(1);
      
      if (error) {
        console.log('❌ Connection test failed:', error.message);
        results.errors.push(`DB test failed: ${error.message}`);
      } else {
        console.log('✅ Successfully connected to database');
        console.log('   Retrieved:', data ? `${data.length} row(s)` : 'no data');
        results.info.push('Database connection working');
      }
    } catch (e) {
      console.log('❌ Connection error:', e.message);
      results.errors.push(`Connection error: ${e.message}`);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 6. CHECK NETWORK REQUESTS
  // ─────────────────────────────────────────────────────────────────────────
  console.log('\n🌐 6. RECENT NETWORK REQUESTS');
  console.log('─'.repeat(80));
  console.log('To check network requests:');
  console.log('1. Open Network tab in DevTools');
  console.log('2. Filter by "supabase"');
  console.log('3. Look for requests to:');
  console.log('   ❌ OLD: https://zlvnxvrzotamhpezqedr.supabase.co');
  console.log('   ✅ NEW: https://eyhksbiceueoiamwnqpr.supabase.co');

  // Try to access performance entries
  if (window.performance && performance.getEntriesByType) {
    const resources = performance.getEntriesByType('resource');
    const supabaseRequests = resources.filter(r => 
      r.name.includes('supabase.co') || r.name.includes('supabase')
    );
    
    const oldRequests = supabaseRequests.filter(r => r.name.includes('zlvnxvrzotamhpezqedr'));
    const newRequests = supabaseRequests.filter(r => r.name.includes('eyhksbiceueoiamwnqpr'));
    
    console.log(`\nPerformance timeline summary:`);
    console.log(`   Total Supabase requests: ${supabaseRequests.length}`);
    console.log(`   OLD project requests: ${oldRequests.length}`);
    console.log(`   NEW project requests: ${newRequests.length}`);
    
    if (oldRequests.length > 0) {
      console.log('\n⚠️  Recent requests to OLD project:');
      oldRequests.slice(0, 5).forEach(r => {
        console.log(`   - ${r.name}`);
      });
      results.errors.push(`Found ${oldRequests.length} request(s) to OLD project`);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 7. CHECK LOCALSTORAGE
  // ─────────────────────────────────────────────────────────────────────────
  console.log('\n💾 7. LOCALSTORAGE SCAN');
  console.log('─'.repeat(80));
  
  const localStorageKeys = Object.keys(localStorage);
  const supabaseKeys = localStorageKeys.filter(k => k.includes('supabase'));
  
  console.log(`Found ${supabaseKeys.length} Supabase-related keys in localStorage:`);
  supabaseKeys.forEach(key => {
    const value = localStorage.getItem(key);
    console.log(`   ${key}: ${value ? value.substring(0, 50) + '...' : 'empty'}`);
    
    if (value && value.includes('zlvnxvrzotamhpezqedr')) {
      console.log('   ⚠️  Contains OLD project reference');
      results.warnings.push(`localStorage key "${key}" references OLD project`);
    }
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 8. FINAL SUMMARY
  // ─────────────────────────────────────────────────────────────────────────
  console.log('\n' + '═'.repeat(80));
  console.log('📊 DIAGNOSTIC SUMMARY');
  console.log('═'.repeat(80));
  
  if (results.errors.length === 0 && results.warnings.length === 0) {
    console.log('\n✅ ALL CHECKS PASSED!');
    console.log('Your application is correctly using the NEW Supabase project.');
  } else {
    if (results.errors.length > 0) {
      console.log('\n❌ ERRORS FOUND:');
      results.errors.forEach((err, i) => {
        console.log(`   ${i + 1}. ${err}`);
      });
    }
    
    if (results.warnings.length > 0) {
      console.log('\n⚠️  WARNINGS:');
      results.warnings.forEach((warn, i) => {
        console.log(`   ${i + 1}. ${warn}`);
      });
    }
  }
  
  if (results.info.length > 0) {
    console.log('\nℹ️  INFO:');
    results.info.forEach((info, i) => {
      console.log(`   ${i + 1}. ${info}`);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 9. RECOMMENDATIONS
  // ─────────────────────────────────────────────────────────────────────────
  if (results.errors.length > 0) {
    console.log('\n💡 RECOMMENDED ACTIONS:');
    console.log('─'.repeat(80));
    
    if (results.errors.some(e => e.includes('OLD project'))) {
      console.log('1. Check js/supabase-config.js - ensure URL is:');
      console.log('   https://eyhksbiceueoiamwnqpr.supabase.co');
      console.log('\n2. Search all HTML files for "zlvnxvrzotamhpezqedr"');
      console.log('\n3. Clear browser cache and hard reload (Cmd+Shift+R)');
      console.log('\n4. Check for cached service workers:');
      console.log('   - Open DevTools > Application > Service Workers');
      console.log('   - Unregister any active workers');
    }
  }

  console.log('\n' + '═'.repeat(80));
  console.log('✨ Diagnostic complete!\n');
  
  return {
    errors: results.errors,
    warnings: results.warnings,
    info: results.info,
    passed: results.errors.length === 0 && results.warnings.length === 0
  };
})();
