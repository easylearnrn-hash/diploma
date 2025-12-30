# Twilio + Supabase Edge Functions SMS Integration

Complete setup for sending SMS to US phone numbers using Twilio and Supabase Edge Functions.

## 📋 Prerequisites

1. **Supabase Account** - [Sign up at supabase.com](https://supabase.com)
2. **Twilio Account** - [Sign up at twilio.com](https://www.twilio.com/try-twilio)
3. **Supabase CLI** - Install with: `npm install -g supabase`

## 🚀 Setup Instructions

### Step 1: Twilio Setup

1. **Create Twilio Account**
   - Go to [twilio.com](https://www.twilio.com/try-twilio)
   - Sign up for a free trial account (includes $15.50 credit)

2. **Get Your Twilio Credentials**
   - Go to [Twilio Console](https://console.twilio.com/)
   - Copy your **Account SID**
   - Copy your **Auth Token**

3. **Get a Phone Number**
   - In Twilio Console, go to Phone Numbers > Manage > Buy a number
   - Choose a US phone number with SMS capabilities
   - Copy your phone number (format: +1XXXXXXXXXX)

### Step 2: Supabase Setup

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Create a new project
   - Save your project URL and keys

2. **Get Supabase Keys**
   - Go to Project Settings > API
   - Copy **Project URL**
   - Copy **anon/public key**
   - Copy **service_role key** (⚠️ Keep this secret!)

3. **Set Up Database**
   - Go to SQL Editor in Supabase Dashboard
   - Run the SQL from `supabase/schema.sql`
   - This creates the necessary tables for verification codes

### Step 3: Configure Environment Variables

1. **Login to Supabase CLI**
   ```bash
   supabase login
   ```

2. **Link Your Project**
   ```bash
   cd /path/to/DIPLOMA
   supabase link --project-ref your-project-ref
   ```

3. **Set Secrets** (use your actual values)
   ```bash
   # Set Twilio credentials
   supabase secrets set TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxx
   supabase secrets set TWILIO_AUTH_TOKEN=your_auth_token_here
   supabase secrets set TWILIO_PHONE_NUMBER=+1XXXXXXXXXX
   
   # Set Supabase credentials
   supabase secrets set SUPABASE_URL=https://xxxxx.supabase.co
   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   ```

4. **Verify Secrets**
   ```bash
   supabase secrets list
   ```

### Step 4: Deploy Edge Functions

```bash
# Navigate to project directory
cd /path/to/DIPLOMA

# Deploy all functions
supabase functions deploy send-sms
supabase functions deploy send-verification-sms
supabase functions deploy verify-sms-code
```

### Step 5: Test the Functions

#### Test from Command Line

```bash
# Test send-sms function
curl -i --location --request POST \
  'https://your-project-ref.supabase.co/functions/v1/send-sms' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "to": "+15551234567",
    "message": "Test message from Armenian College of Nursing",
    "type": "notification"
  }'

# Test send-verification-sms function
curl -i --location --request POST \
  'https://your-project-ref.supabase.co/functions/v1/send-verification-sms' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "phoneNumber": "+15551234567",
    "purpose": "admission"
  }'

# Test verify-sms-code function
curl -i --location --request POST \
  'https://your-project-ref.supabase.co/functions/v1/verify-sms-code' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "phoneNumber": "+15551234567",
    "code": "123456",
    "purpose": "admission"
  }'
```

## 💻 Using in Your Application

### 1. Add Configuration to Your HTML

```html
<!-- In your HTML head -->
<script src="js/sms-service.js"></script>
<script>
  // Initialize SMS Service
  const smsService = new SMSService(
    'https://your-project-ref.supabase.co',  // Your Supabase URL
    'your-anon-key-here'                      // Your Supabase Anon Key
  );
</script>
```

### 2. Example: Send Admission Notification

```javascript
// Send admission notification
async function notifyStudent() {
  const result = await smsService.sendAdmissionNotification(
    '+15551234567',
    'John Doe',
    'accepted'
  );
  
  if (result.success) {
    console.log('SMS sent successfully!');
  } else {
    console.error('Failed to send SMS:', result.error);
  }
}
```

### 3. Example: Send and Verify Code

```javascript
// Send verification code
async function sendCode() {
  const phoneNumber = document.getElementById('phone').value;
  const formatted = smsService.formatUSPhoneNumber(phoneNumber);
  
  const result = await smsService.sendVerificationCode(formatted, 'admission');
  
  if (result.success) {
    alert('Verification code sent! Check your phone.');
  } else {
    alert('Error: ' + result.error);
  }
}

// Verify code
async function verifyCode() {
  const phoneNumber = document.getElementById('phone').value;
  const code = document.getElementById('code').value;
  const formatted = smsService.formatUSPhoneNumber(phoneNumber);
  
  const result = await smsService.verifyCode(formatted, code, 'admission');
  
  if (result.success && result.verified) {
    alert('Phone verified successfully!');
    // Proceed with admission form
  } else {
    alert('Invalid or expired code');
  }
}
```

### 4. Example: Integration with Admission Form

```html
<!-- Add to admission-form.html -->
<div class="form-group">
  <label for="phone">Phone Number</label>
  <input type="tel" id="phone" placeholder="+1 (555) 123-4567" required>
  <button type="button" onclick="sendVerificationCode()">Send Code</button>
</div>

<div class="form-group" id="verification-section" style="display:none;">
  <label for="verification-code">Verification Code</label>
  <input type="text" id="verification-code" maxlength="6" placeholder="000000">
  <button type="button" onclick="verifyPhoneNumber()">Verify</button>
</div>

<script>
async function sendVerificationCode() {
  const phone = document.getElementById('phone').value;
  const formatted = smsService.formatUSPhoneNumber(phone);
  
  const result = await smsService.sendVerificationCode(formatted, 'admission');
  
  if (result.success) {
    document.getElementById('verification-section').style.display = 'block';
    alert('Code sent! Check your phone.');
  } else {
    alert('Error: ' + result.error);
  }
}

async function verifyPhoneNumber() {
  const phone = document.getElementById('phone').value;
  const code = document.getElementById('verification-code').value;
  const formatted = smsService.formatUSPhoneNumber(phone);
  
  const result = await smsService.verifyCode(formatted, code, 'admission');
  
  if (result.success) {
    alert('Phone verified! ✓');
    // Continue with form submission
  } else {
    alert('Invalid code. Please try again.');
  }
}
</script>
```

## 📱 SMS Use Cases

### 1. Admission Notifications
```javascript
smsService.sendAdmissionNotification('+15551234567', 'John Doe', 'accepted');
```

### 2. Class Reminders
```javascript
smsService.sendClassReminder('+15551234567', 'Fundamentals of Nursing', 'tomorrow at 9 AM');
```

### 3. Exam Reminders
```javascript
smsService.sendExamReminder('+15551234567', 'NCLEX Preparation Exam', 'Friday, Jan 10');
```

### 4. Custom Messages
```javascript
smsService.sendSMS(
  '+15551234567',
  'Your clinical rotation starts Monday. Please review the handbook.',
  'notification'
);
```

## 🔒 Security Best Practices

1. **Never expose service role key** - Only use in Edge Functions
2. **Use anon key in frontend** - It's safe for client-side use
3. **Implement rate limiting** - Prevent SMS abuse
4. **Validate phone numbers** - Always format and validate
5. **Store secrets securely** - Use Supabase secrets, not .env files in repo

## 💰 Cost Considerations

### Twilio Pricing (US)
- **SMS sending**: $0.0079 per message
- **Phone number**: $1.15/month
- **Free trial**: $15.50 credit (good for ~1,900 messages)

### Supabase Pricing
- **Free tier**: 500,000 Edge Function invocations/month
- **Pro tier**: $25/month (2 million invocations)

### Example Costs
- **100 students/month**: ~$0.79/month
- **1,000 students/month**: ~$7.90/month
- **10,000 notifications/month**: ~$79/month

## 🛠️ Troubleshooting

### Common Issues

1. **"Invalid phone number"**
   - Use format: +1XXXXXXXXXX
   - Use `smsService.formatUSPhoneNumber()` to auto-format

2. **"Failed to send SMS"**
   - Check Twilio credentials in secrets
   - Verify phone number has SMS capability
   - Check Twilio account balance

3. **"Function not found"**
   - Redeploy: `supabase functions deploy send-sms`
   - Check function name matches exactly

4. **CORS errors**
   - Edge Functions include CORS headers by default
   - Check that you're using correct Supabase URL

### View Logs

```bash
# View function logs
supabase functions logs send-sms --follow
supabase functions logs send-verification-sms --follow
```

### Check Twilio Logs
- Go to [Twilio Console > Monitor > Logs](https://console.twilio.com/us1/monitor/logs/sms)
- View detailed delivery status and errors

## 📚 Additional Resources

- [Twilio SMS Documentation](https://www.twilio.com/docs/sms)
- [Supabase Edge Functions Guide](https://supabase.com/docs/guides/functions)
- [Supabase Secrets Management](https://supabase.com/docs/guides/functions/secrets)

## 🎯 Next Steps

1. ✅ Complete setup following steps above
2. ✅ Test with your phone number
3. ✅ Integrate with admission form
4. ✅ Add error handling and user feedback
5. ✅ Monitor usage and costs
6. ✅ Implement rate limiting if needed

## 📞 Support

For issues with:
- **Twilio**: [Twilio Support](https://support.twilio.com/)
- **Supabase**: [Supabase Discord](https://discord.supabase.com/)
- **This Integration**: Check function logs and test with curl commands

---

**Armenian College of Nursing - SMS Integration**  
Ready to send SMS notifications to students! 🎓📱
