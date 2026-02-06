/**
 * Check for specific recent emails
 * Looking for alekevin@gmail.com enrollment emails
 */

const https = require('https');

const NEW_SUPABASE_URL = 'https://eyhksbiceueoiamwnqpr.supabase.co';
const NEW_SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5aGtzYmljZXVlb2lhbXducXByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4NTIwOTAsImV4cCI6MjA4NDQyODA5MH0.1G3RZLKLJvIR8U9Cvmner3kUIxDtUfFYkHpzUUbnbq8';

function httpsRequest(hostname, path, options) {
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
    req.end();
  });
}

async function main() {
  console.log('\n🔍 ===== CHECKING FOR RECENT EMAILS =====\n');
  
  try {
    // Check for emails to alekevin@gmail.com
    console.log('Looking for emails to: alekevin@gmail.com\n');
    
    const url = new URL(`${NEW_SUPABASE_URL}/rest/v1/email_history`);
    url.searchParams.append('select', '*');
    url.searchParams.append('recipient', 'eq.alekevin@gmail.com');
    url.searchParams.append('order', 'sent_at.desc');
    
    const response = await httpsRequest(
      url.hostname,
      url.pathname + url.search,
      {
        method: 'GET',
        headers: {
          'apikey': NEW_SUPABASE_KEY,
          'Authorization': `Bearer ${NEW_SUPABASE_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    if (response.status !== 200) {
      console.error('❌ Failed:', response.data);
      return;
    }
    
    const emails = response.data;
    
    console.log(`✅ Found ${emails.length} emails to alekevin@gmail.com\n`);
    
    if (emails.length === 0) {
      console.log('⚠️  No emails found in NEW Supabase database!');
      console.log('\n💡 This means the enrollment emails sent via Resend were NOT saved to the database.');
      console.log('\n🔧 Possible causes:');
      console.log('   1. send-email function failed to save to database');
      console.log('   2. Database insert error (check Edge Function logs)');
      console.log('   3. RLS policy blocking the insert');
      console.log('\n📋 Next steps:');
      console.log('   - Check Edge Function logs in Supabase dashboard');
      console.log('   - Or send a test email to see real-time errors');
      return;
    }
    
    // Show all emails to this recipient
    console.log('📧 Emails in database:\n');
    emails.forEach((email, idx) => {
      const date = new Date(email.sent_at).toLocaleString();
      console.log(`${idx + 1}. Subject: "${email.subject}"`);
      console.log(`   Sent: ${date}`);
      console.log(`   Status: ${email.status}`);
      if (email.resend_id) console.log(`   Resend ID: ${email.resend_id}`);
      console.log('');
    });
    
    // Check for enrollment-related emails
    const enrollmentEmails = emails.filter(e => 
      e.subject.toLowerCase().includes('enrollment') ||
      e.subject.toLowerCase().includes('welcome')
    );
    
    if (enrollmentEmails.length > 0) {
      console.log(`✅ Found ${enrollmentEmails.length} enrollment-related emails`);
    } else {
      console.log('⚠️  No enrollment welcome emails found');
      console.log('   The 3 emails you see in Resend are missing from the database');
    }
    
    // Check most recent emails (last hour)
    console.log('\n\n📅 Checking all emails from last 2 hours...\n');
    
    const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString();
    const recentUrl = new URL(`${NEW_SUPABASE_URL}/rest/v1/email_history`);
    recentUrl.searchParams.append('select', 'recipient,subject,sent_at,status');
    recentUrl.searchParams.append('sent_at', `gte.${twoHoursAgo}`);
    recentUrl.searchParams.append('order', 'sent_at.desc');
    
    const recentResponse = await httpsRequest(
      recentUrl.hostname,
      recentUrl.pathname + recentUrl.search,
      {
        method: 'GET',
        headers: {
          'apikey': NEW_SUPABASE_KEY,
          'Authorization': `Bearer ${NEW_SUPABASE_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    const recentEmails = recentResponse.data;
    console.log(`Found ${recentEmails.length} emails in last 2 hours:\n`);
    
    if (recentEmails.length > 0) {
      recentEmails.forEach((email, idx) => {
        const date = new Date(email.sent_at).toLocaleString();
        console.log(`${idx + 1}. ${email.recipient} - "${email.subject.substring(0, 50)}..." (${date})`);
      });
    } else {
      console.log('⚠️  No emails sent in last 2 hours according to database');
      console.log('   But Resend shows 3 emails sent "about 1 hour ago"');
      console.log('   → Database logging is BROKEN');
    }
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
  }
}

main();
