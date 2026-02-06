/**
 * Email History Import from Resend
 * Fetches all sent emails from Resend API and imports them to NEW Supabase
 */

const https = require('https');

// Resend API Key
const RESEND_API_KEY = 're_XAWzoABQ_JEFQTya8NiHdwb4MRgEtcT3X';

// NEW Supabase Project (destination)
const NEW_SUPABASE_URL = 'https://eyhksbiceueoiamwnqpr.supabase.co';
const NEW_SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5aGtzYmljZXVlb2lhbXducXByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4NTIwOTAsImV4cCI6MjA4NDQyODA5MH0.1G3RZLKLJvIR8U9Cvmner3kUIxDtUfFYkHpzUUbnbq8';

function httpsRequest(hostname, path, options, body = null) {
  return new Promise((resolve, reject) => {
    const reqOptions = {
      hostname,
      path,
      method: options.method || 'GET',
      headers: options.headers || {}
    };
    
    const req = https.request(reqOptions, (res) => {
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

async function fetchFromResend() {
  console.log('📥 Fetching sent emails from Resend API...');
  
  try {
    const response = await httpsRequest('api.resend.com', '/emails', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (response.status !== 200) {
      console.error('❌ Failed to fetch from Resend:', response.data);
      return [];
    }
    
    const emails = response.data.data || [];
    console.log(`✅ Fetched ${emails.length} emails from Resend`);
    return emails;
  } catch (error) {
    console.error('❌ Error fetching from Resend:', error.message);
    return [];
  }
}

async function fetchEmailDetails(emailId) {
  try {
    const response = await httpsRequest('api.resend.com', `/emails/${emailId}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (response.status === 200) {
      return response.data;
    }
    return null;
  } catch (error) {
    console.error(`   ⚠️  Could not fetch details for ${emailId}:`, error.message);
    return null;
  }
}

async function insertToNewSupabase(emails) {
  if (emails.length === 0) {
    console.log('⚠️  No emails to import');
    return { success: 0, failed: 0 };
  }
  
  console.log(`\n📤 Importing ${emails.length} emails to NEW Supabase...`);
  
  let success = 0;
  let failed = 0;
  let skipped = 0;
  
  for (let i = 0; i < emails.length; i++) {
    const email = emails[i];
    const progress = `[${i + 1}/${emails.length}]`;
    
    // Check if email already exists by resend_id
    const checkUrl = new URL(`${NEW_SUPABASE_URL}/rest/v1/email_history`);
    checkUrl.searchParams.append('resend_id', `eq.${email.id}`);
    checkUrl.searchParams.append('select', 'id');
    
    try {
      const checkResponse = await httpsRequest(
        checkUrl.hostname,
        checkUrl.pathname + checkUrl.search,
        {
          method: 'GET',
          headers: {
            'apikey': NEW_SUPABASE_KEY,
            'Authorization': `Bearer ${NEW_SUPABASE_KEY}`,
            'Content-Type': 'application/json'
          }
        }
      );
      
      if (checkResponse.data && checkResponse.data.length > 0) {
        console.log(`   ${progress} ⏭️  Skipped (already exists): ${email.to[0]}`);
        skipped++;
        continue;
      }
    } catch (error) {
      console.error(`   ${progress} ⚠️  Error checking existence:`, error.message);
    }
    
    // Fetch full email details
    console.log(`   ${progress} 🔍 Fetching details for ${email.to[0]}...`);
    const details = await fetchEmailDetails(email.id);
    
    if (!details) {
      failed++;
      continue;
    }
    
    // Prepare email for insertion
    const emailToInsert = {
      recipient: Array.isArray(email.to) ? email.to[0] : email.to,
      sender: email.from || 'admissions@acnhs.am',
      subject: email.subject || '(No Subject)',
      body: details.text || details.html?.replace(/<[^>]*>/g, '').substring(0, 500) || '',
      html_body: details.html || null,
      status: 'sent',
      sent_at: email.created_at || new Date().toISOString(),
      resend_id: email.id
    };
    
    // Insert to NEW Supabase
    try {
      const insertUrl = new URL(`${NEW_SUPABASE_URL}/rest/v1/email_history`);
      const insertResponse = await httpsRequest(
        insertUrl.hostname,
        insertUrl.pathname,
        {
          method: 'POST',
          headers: {
            'apikey': NEW_SUPABASE_KEY,
            'Authorization': `Bearer ${NEW_SUPABASE_KEY}`,
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal'
          }
        },
        JSON.stringify(emailToInsert)
      );
      
      if (insertResponse.status === 201) {
        success++;
        console.log(`   ${progress} ✅ Imported: ${emailToInsert.recipient} - "${emailToInsert.subject}"`);
      } else {
        failed++;
        console.error(`   ${progress} ❌ Failed to insert:`, insertResponse.data);
      }
    } catch (error) {
      failed++;
      console.error(`   ${progress} ❌ Error inserting:`, error.message);
    }
    
    // Small delay to avoid rate limiting
    if (i < emails.length - 1) {
      await new Promise(resolve => setTimeout(resolve, 200));
    }
  }
  
  return { success, failed, skipped };
}

async function main() {
  console.log('\n📧 ===== EMAIL IMPORT FROM RESEND =====\n');
  console.log('Source: Resend API');
  console.log('Destination: NEW Supabase (eyhksbiceueoiamwnqpr)\n');
  
  try {
    // Fetch all emails from Resend
    const emails = await fetchFromResend();
    
    if (emails.length === 0) {
      console.log('\n✅ No emails found in Resend!');
      return;
    }
    
    // Show sample of what will be imported
    console.log('\n📋 Emails found in Resend:');
    emails.slice(0, 5).forEach((email, idx) => {
      const to = Array.isArray(email.to) ? email.to[0] : email.to;
      console.log(`   ${idx + 1}. To: ${to} | Subject: "${email.subject}" | Status: ${email.last_event || 'sent'}`);
    });
    if (emails.length > 5) {
      console.log(`   ... and ${emails.length - 5} more`);
    }
    
    console.log('\n⏳ Starting import in 3 seconds...');
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Import emails into NEW Supabase
    const result = await insertToNewSupabase(emails);
    
    // Summary
    console.log('\n\n📊 ===== IMPORT SUMMARY =====');
    console.log(`✅ Successfully imported: ${result.success} emails`);
    console.log(`⏭️  Skipped (already exist): ${result.skipped} emails`);
    console.log(`❌ Failed: ${result.failed} emails`);
    console.log(`📈 Total processed: ${emails.length} emails`);
    
    if (result.success > 0) {
      console.log('\n🎉 Import complete! Check your email system to see the imported emails.');
      console.log('👉 Open: http://localhost:8000/email-system.html');
    }
    
  } catch (error) {
    console.error('\n❌ Import failed:', error.message);
    console.error(error);
    process.exit(1);
  }
}

main();
