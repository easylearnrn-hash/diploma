/**
 * Comprehensive Email History Check
 * Checks all emails with grouping by status and direction
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
          // Try to extract count from content-range header
          const contentRange = res.headers['content-range'];
          let count = null;
          if (contentRange) {
            const match = contentRange.match(/\/(\d+)$/);
            if (match) count = parseInt(match[1], 10);
          }
          resolve({ 
            status: res.statusCode, 
            data: parsed,
            count: count || (Array.isArray(parsed) ? parsed.length : 0)
          });
        } catch (e) {
          resolve({ status: res.statusCode, data: data, count: 0 });
        }
      });
    });
    req.on('error', reject);
    req.end();
  });
}

async function main() {
  console.log('\n📧 ===== COMPREHENSIVE EMAIL CHECK =====\n');
  console.log('Database: NEW Supabase (eyhksbiceueoiamwnqpr)\n');
  
  try {
    // Get total count with exact count
    console.log('📊 Fetching email statistics...\n');
    
    const url = new URL(`${NEW_SUPABASE_URL}/rest/v1/email_history`);
    url.searchParams.append('select', '*');
    url.searchParams.append('order', 'sent_at.desc');
    
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
    const totalCount = response.count;
    
    console.log(`✅ Total emails in database: ${totalCount}\n`);
    
    if (emails.length === 0) {
      console.log('⚠️  No emails found!');
      console.log('\n💡 This could mean:');
      console.log('   1. Emails are in a different table');
      console.log('   2. RLS policies are blocking access');
      console.log('   3. Database connection issue');
      return;
    }
    
    // Group by status
    const statusGroups = emails.reduce((acc, email) => {
      const status = email.status || 'unknown';
      if (!acc[status]) acc[status] = [];
      acc[status].push(email);
      return acc;
    }, {});
    
    console.log('📊 Emails by Status:');
    Object.entries(statusGroups).forEach(([status, group]) => {
      console.log(`   ${status}: ${group.length}`);
    });
    console.log('');
    
    // Check for received vs sent
    const received = emails.filter(e => e.status === 'received');
    const sent = emails.filter(e => e.status === 'sent');
    
    console.log('📬 Direction Breakdown:');
    console.log(`   📤 Sent: ${sent.length}`);
    console.log(`   📥 Received: ${received.length}`);
    console.log('');
    
    // Show latest emails from each direction
    console.log('📋 Latest 5 SENT emails:');
    sent.slice(0, 5).forEach((email, idx) => {
      const date = new Date(email.sent_at).toLocaleString();
      console.log(`   ${idx + 1}. To: ${email.recipient}`);
      console.log(`      Subject: "${email.subject.substring(0, 60)}..."`);
      console.log(`      Date: ${date}`);
      if (email.resend_id) console.log(`      Resend ID: ${email.resend_id}`);
      console.log('');
    });
    
    if (received.length > 0) {
      console.log('\n📋 Latest 5 RECEIVED emails:');
      received.slice(0, 5).forEach((email, idx) => {
        const date = new Date(email.sent_at).toLocaleString();
        console.log(`   ${idx + 1}. From: ${email.sender}`);
        console.log(`      To: ${email.recipient}`);
        console.log(`      Subject: "${email.subject.substring(0, 60)}..."`);
        console.log(`      Date: ${date}`);
        console.log('');
      });
    } else {
      console.log('\n⚠️  No RECEIVED emails found.');
      console.log('   Webhook might not be capturing incoming emails yet.');
    }
    
    // Check date range
    const dates = emails.map(e => new Date(e.sent_at).getTime()).filter(d => !isNaN(d));
    if (dates.length > 0) {
      const oldest = new Date(Math.min(...dates));
      const newest = new Date(Math.max(...dates));
      console.log('\n📅 Date Range:');
      console.log(`   Oldest: ${oldest.toLocaleString()}`);
      console.log(`   Newest: ${newest.toLocaleString()}`);
    }
    
    // Check for webhook-received emails (should have specific format)
    const webhookEmails = emails.filter(e => 
      e.resend_id && e.status === 'received'
    );
    
    if (webhookEmails.length > 0) {
      console.log(`\n✅ Found ${webhookEmails.length} webhook-received emails`);
    } else {
      console.log('\n⚠️  No webhook-received emails found yet');
      console.log('   Check if webhook is properly configured in Resend dashboard');
    }
    
    console.log('\n\n👉 View in browser: http://localhost:8000/email-system.html');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error(error);
  }
}

main();
