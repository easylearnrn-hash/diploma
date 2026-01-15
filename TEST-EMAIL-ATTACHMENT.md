# Debug Script - Test Email with Attachment

## To test if attachments are working, run this in browser console on email-system.html:

```javascript
// Test sending email with attachment
async function testEmailWithAttachment() {
  const testPayload = {
    to: "Hrachfilm@gmail.com",
    subject: "TEST - Email with photo attachment",
    html: "<p>This is a test email with a photo. The photo should display properly.</p><img src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==' alt='test'/>",
    from: "admissions@acnhs.am",
    fromName: "ACNHS Test"
  };

  try {
    const response = await fetch('https://zlvnxvrzotamhpezqedr.supabase.co/functions/v1/send-email', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsdm54dnJ6b3RhbWhwZXpxZWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUyMTE3NjksImV4cCI6MjA1MDc4Nzc2OX0.w_JulQw0KHZ_s3fAuGCpYCnq8j5HoJCTxXyJIHmBDQs'
      },
      body: JSON.stringify(testPayload)
    });

    const result = await response.json();
    console.log('✅ Test email sent:', result);
    console.log('📧 Check your Gmail: Hrachfilm@gmail.com');
  } catch (error) {
    console.error('❌ Error sending test email:', error);
  }
}

// Run the test
testEmailWithAttachment();
```

## Expected Result:
- Email should arrive in Gmail
- Photo should display inline (not broken)
- If photo is broken, the base64 extraction isn't working

## Check Edge Function Logs:
```bash
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
supabase functions logs send-email --project-ref zlvnxvrzotamhpezqedr --tail
```

Look for these lines in logs:
- `✅ Extracted X base64 images and converted to attachments`
- `Adding X attachment(s) to email`
