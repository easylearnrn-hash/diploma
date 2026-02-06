/**
 * Check Email History in NEW Supabase
 * Shows current email history in the NEW database
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
          const parsed = JSON.parse(data);
          resolve({ 
            status: res.statusCode, 
            data: parsed,
            count: res.headers['content-range']?.split('/')[1] || null
          });
        } catch (e) {
          resolve({ status: res.statusCode, data: data, count: null });
        }
      });
    });
    req.on('error', reject);
    req.end();
  });
}

async function main() {
  console.log('\n📧 ===== EMAIL HISTORY CHECK =====\n');
  console.log('Checking: NEW Supabase (eyhksbiceueoiamwnqpr)\n');
  
  try {
    const url = new URL(`${NEW_SUPABASE_URL}/rest/v1/email_history`);
    url.searchParams.append('select', '*');
    url.searchParams.append('order', 'sent_at.desc');
    url.searchParams.append('limit', '50');
    
    const response = await httpsRequest(
      url.hostname,
      url.pathname + url.search,
      {
        method: 'GET',
        headers: {
          'apikey': NEW_SUPABASE_KEY,
          'Authorization': `Bearer ${NEW_SUPABASE_KEY}`,
          'Content-Type': 'application/json',
          'Prefer': 'count=exact'
        }
      }
    );
    
    if (response.status !== 200) {
      console.error('❌ Failed to fetch emails:', response.data);
      return;
    }
    
    const emails = response.data;
    const totalCount = response.count || emails.length;
    
    console.log(`📊 Total emails in database: ${totalCount}\n`);
    
    if (emails.length === 0) {
      console.log('⚠️  No emails found in NEW Supabase database.');
      console.log('\n💡 This is expected if you just migrated to the NEW project.');
      console.log('   New emails will be saved automatically when you send them.');
      return;
    }
    
    console.log(`📋 Latest ${Math.min(emails.length, 10)} emails:\n`);
    
    emails.slice(0, 10).forEach((email, idx) => {
      const date = new Date(email.sent_at).toLocaleString();
      const preview = email.subject.substring(0, 50);
      console.log(`${idx + 1}. ${email.sender} → ${email.recipient}`);
      console.log(`   📝 "${preview}${email.subject.length > 50 ? '...' : ''}"`);
      console.log(`   📅 ${date} | Status: ${email.status}`);
      if (email.resend_id) {
        console.log(`   🆔 Resend ID: ${email.resend_id}`);
      }
      console.log('');
    });
    
    // Group by status
    const statusCounts = emails.reduce((acc, email) => {
      acc[email.status] = (acc[email.status] || 0) + 1;
      return acc;
    }, {});
    
    console.log('\n📊 Email Status Summary:');
    Object.entries(statusCounts).forEach(([status, count]) => {
      console.log(`   ${status}: ${count}`);
    });
    
    console.log('\n✅ Email history is accessible!');
    console.log('👉 View in browser: http://localhost:8000/email-system.html');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error(error);
  }
}

main();
