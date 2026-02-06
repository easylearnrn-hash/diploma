/**
 * Email History Migration Script
 * Migrates all emails from OLD Supabase (zlvnxvrzotamhpezqedr) to NEW Supabase (eyhksbiceueoiamwnqpr)
 */

const https = require('https');

// OLD Supabase Project (source)
const OLD_SUPABASE_URL = 'https://zlvnxvrzotamhpezqedr.supabase.co';
const OLD_SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUyMTE3NjksImV4cCI6MjA1MDc4Nzc2OX0.w_JulQw0KHZ_s3fAuGCpYCnq8j5HoJCTxXyJIHmBDQs';

// NEW Supabase Project (destination)
const NEW_SUPABASE_URL = 'https://eyhksbiceueoiamwnqpr.supabase.co';
const NEW_SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5aGtzYmljZXVlb2lhbXducXByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4NTIwOTAsImV4cCI6MjA4NDQyODA5MH0.1G3RZLKLJvIR8U9Cvmner3kUIxDtUfFYkHpzUUbnbq8';

function httpsRequest(url, options, body = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(url, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(data) });
        } catch (e) {
          resolve({ status: res.statusCode, data: data });
        }
      });
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function fetchFromOldSupabase() {
  console.log('📥 Fetching emails from OLD Supabase...');
  
  const url = `${OLD_SUPABASE_URL}/rest/v1/email_history?select=*&order=created_at.asc`;
  
  const response = await httpsRequest(url, {
    method: 'GET',
    headers: {
      'apikey': OLD_SUPABASE_KEY,
      'Authorization': `Bearer ${OLD_SUPABASE_KEY}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (response.status !== 200) {
    console.error('❌ Failed to fetch from OLD Supabase:', response.data);
    return [];
  }
  
  console.log(`✅ Fetched ${response.data.length} emails from OLD Supabase`);
  return response.data;
}

async function insertToNewSupabase(emails) {
  if (emails.length === 0) {
    console.log('⚠️  No emails to migrate');
    return { success: 0, failed: 0 };
  }
  
  console.log(`📤 Migrating ${emails.length} emails to NEW Supabase...`);
  
  let success = 0;
  let failed = 0;
  
  // Process in batches of 50
  const batchSize = 50;
  for (let i = 0; i < emails.length; i += batchSize) {
    const batch = emails.slice(i, i + batchSize);
    console.log(`\n🔄 Processing batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(emails.length / batchSize)} (${batch.length} emails)...`);
    
    // Prepare emails for insertion (remove id, let Supabase generate new ones)
    const emailsToInsert = batch.map(email => {
      const { id, ...emailWithoutId } = email;
      return emailWithoutId;
    });
    
    const url = `${NEW_SUPABASE_URL}/rest/v1/email_history`;
    
    try {
      const response = await httpsRequest(url, {
        method: 'POST',
        headers: {
          'apikey': NEW_SUPABASE_KEY,
          'Authorization': `Bearer ${NEW_SUPABASE_KEY}`,
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal'
        }
      }, JSON.stringify(emailsToInsert));
      
      if (response.status === 201) {
        success += batch.length;
        console.log(`   ✅ Inserted ${batch.length} emails`);
      } else {
        failed += batch.length;
        console.error(`   ❌ Failed to insert batch:`, response.data);
      }
    } catch (error) {
      failed += batch.length;
      console.error(`   ❌ Error inserting batch:`, error.message);
    }
    
    // Small delay between batches to avoid rate limiting
    if (i + batchSize < emails.length) {
      await new Promise(resolve => setTimeout(resolve, 500));
    }
  }
  
  return { success, failed };
}

async function checkExistingEmails() {
  console.log('🔍 Checking existing emails in NEW Supabase...');
  
  const url = `${NEW_SUPABASE_URL}/rest/v1/email_history?select=count`;
  
  try {
    const response = await httpsRequest(url, {
      method: 'GET',
      headers: {
        'apikey': NEW_SUPABASE_KEY,
        'Authorization': `Bearer ${NEW_SUPABASE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'count=exact'
      }
    });
    
    // Extract count from Content-Range header would be better, but let's use length
    const count = Array.isArray(response.data) ? response.data.length : 0;
    console.log(`📊 Found ${count} existing emails in NEW Supabase`);
    return count;
  } catch (error) {
    console.error('⚠️  Could not check existing emails:', error.message);
    return 0;
  }
}

async function main() {
  console.log('\n📧 ===== EMAIL MIGRATION SCRIPT =====\n');
  console.log('Source: OLD Supabase (zlvnxvrzotamhpezqedr)');
  console.log('Destination: NEW Supabase (eyhksbiceueoiamwnqpr)\n');
  
  try {
    // Check existing emails in NEW database
    await checkExistingEmails();
    
    // Fetch all emails from OLD Supabase
    const emails = await fetchFromOldSupabase();
    
    if (emails.length === 0) {
      console.log('\n✅ No emails to migrate!');
      return;
    }
    
    // Show sample of what will be migrated
    console.log('\n📋 Sample emails to migrate:');
    emails.slice(0, 3).forEach((email, idx) => {
      console.log(`   ${idx + 1}. ${email.sender} → ${email.recipient}: "${email.subject}" (${email.status})`);
    });
    if (emails.length > 3) {
      console.log(`   ... and ${emails.length - 3} more`);
    }
    
    console.log('\n⏳ Starting migration in 3 seconds...');
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Insert emails into NEW Supabase
    const result = await insertToNewSupabase(emails);
    
    // Summary
    console.log('\n\n📊 ===== MIGRATION SUMMARY =====');
    console.log(`✅ Successfully migrated: ${result.success} emails`);
    console.log(`❌ Failed: ${result.failed} emails`);
    console.log(`📈 Total processed: ${emails.length} emails`);
    
    if (result.success > 0) {
      console.log('\n🎉 Migration complete! Check your email system to see the migrated emails.');
      console.log('👉 Open: http://localhost:8000/email-system.html');
    }
    
  } catch (error) {
    console.error('\n❌ Migration failed:', error.message);
    console.error(error);
    process.exit(1);
  }
}

main();
