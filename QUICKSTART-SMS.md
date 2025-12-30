# Quick Start: Twilio SMS Integration

## 🎯 5-Minute Setup

### 1. Get Twilio Credentials (2 minutes)
```bash
# Sign up at https://www.twilio.com/try-twilio
# Go to Console: https://console.twilio.com/
# Copy these three values:
# - Account SID: ACxxxxxxxxx
# - Auth Token: xxxxxxxxx
# - Phone Number: +1XXXXXXXXXX
```

### 2. Get Supabase Credentials (2 minutes)
```bash
# Sign up at https://supabase.com
# Create new project
# Go to Settings > API
# Copy these values:
# - Project URL: https://xxxxx.supabase.co
# - Anon/Public Key: eyJhbGc...
# - Service Role Key: eyJhbGc...
```

### 3. Install Supabase CLI (30 seconds)
```bash
npm install -g supabase
# or
brew install supabase/tap/supabase
```

### 4. Deploy (30 seconds)
```bash
cd /path/to/DIPLOMA

# Login
supabase login

# Link project (replace with your project ref)
supabase link --project-ref your-project-ref

# Set secrets
supabase secrets set TWILIO_ACCOUNT_SID=ACxxxxx
supabase secrets set TWILIO_AUTH_TOKEN=your_token
supabase secrets set TWILIO_PHONE_NUMBER=+1XXXXXXXXXX
supabase secrets set SUPABASE_URL=https://xxxxx.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_key

# Deploy functions
supabase functions deploy send-sms
supabase functions deploy send-verification-sms
supabase functions deploy verify-sms-code
```

### 5. Set Up Database (30 seconds)
```bash
# Go to Supabase Dashboard > SQL Editor
# Run the SQL from: supabase/schema.sql
```

### 6. Test It! (30 seconds)
```bash
# Open sms-demo.html
# Update SUPABASE_URL and SUPABASE_ANON_KEY
# Test with your phone number
```

## 🎉 Done!

You now have a fully functional SMS system integrated with your application!

## 📱 Usage Examples

### Basic SMS
```javascript
const smsService = new SMSService(SUPABASE_URL, SUPABASE_ANON_KEY);
await smsService.sendSMS('+15551234567', 'Hello from Armenian College!', 'notification');
```

### Verification Code
```javascript
// Send code
await smsService.sendVerificationCode('+15551234567', 'admission');

// Verify code
await smsService.verifyCode('+15551234567', '123456', 'admission');
```

### Admission Notification
```javascript
await smsService.sendAdmissionNotification('+15551234567', 'John Doe', 'accepted');
```

## 💡 Pro Tips

1. **Free Trial**: Twilio gives $15.50 credit (~1,900 SMS)
2. **Test First**: Use your own phone number for testing
3. **Rate Limiting**: Implement to prevent abuse
4. **Logs**: Check `supabase functions logs send-sms`
5. **Monitor**: Track usage in Twilio Console

## 🔗 Full Documentation

See **TWILIO-SMS-SETUP.md** for complete details.

## 🆘 Troubleshooting

**Can't send SMS?**
- Check Twilio credentials in secrets
- Verify phone number format (+1XXXXXXXXXX)
- Check Twilio account has credit

**Function errors?**
- Run: `supabase functions logs send-sms --follow`
- Check all secrets are set: `supabase secrets list`

**CORS errors?**
- Functions already include CORS headers
- Use correct Supabase URL and keys

## 📊 Cost Calculator

- 100 SMS/month: ~$0.79
- 1,000 SMS/month: ~$7.90
- 10,000 SMS/month: ~$79.00

Plus $1.15/month for phone number.

---

**Ready to send your first SMS!** 🚀📱
