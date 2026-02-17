#!/bin/bash

# ============================================
# BCRYPT PASSWORD SECURITY - QUICK DEPLOY
# ============================================
# This script automates the deployment of bcrypt password security
# for the ACNHS Teacher System

set -e  # Exit on error

PROJECT_REF="zlvnxvrzotamhpezqedr"
FUNCTION_NAME="hash-password"
FUNCTION_DIR="supabase/functions/hash-password"

echo ""
echo "🔐 ============================================"
echo "   BCRYPT PASSWORD SECURITY DEPLOYMENT"
echo "   ============================================"
echo ""
echo "⚠️  WARNING: This will secure teacher passwords"
echo "   Currently stored passwords are PLAIN TEXT!"
echo ""
echo "📋 Deployment Steps:"
echo "   1. Deploy hash-password Edge Function"
echo "   2. Test the Edge Function"
echo "   3. Guide you through database migration"
echo "   4. Guide you through password resets"
echo ""
read -p "Press ENTER to continue or CTRL+C to cancel..."

# ============================================
# STEP 1: Check Supabase CLI
# ============================================
echo ""
echo "📦 Step 1: Checking Supabase CLI..."
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found!"
    echo ""
    echo "Install with:"
    echo "  brew install supabase/tap/supabase"
    echo ""
    echo "Or see: https://supabase.com/docs/guides/cli"
    exit 1
fi
echo "✅ Supabase CLI found: $(supabase --version)"

# ============================================
# STEP 2: Check Login Status
# ============================================
echo ""
echo "🔑 Step 2: Checking Supabase login..."
if ! supabase projects list &> /dev/null; then
    echo "⚠️  Not logged in to Supabase"
    echo ""
    echo "Logging in now..."
    supabase login
else
    echo "✅ Already logged in to Supabase"
fi

# ============================================
# STEP 3: Deploy Edge Function
# ============================================
echo ""
echo "🚀 Step 3: Deploying hash-password Edge Function..."
echo ""
echo "Function location: $FUNCTION_DIR"
echo "Project: $PROJECT_REF"
echo ""

cd "$FUNCTION_DIR"
supabase functions deploy "$FUNCTION_NAME" --project-ref "$PROJECT_REF"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Edge Function deployed successfully!"
else
    echo ""
    echo "❌ Edge Function deployment failed!"
    echo "Check the error above and try again."
    exit 1
fi

# Return to root directory
cd -

# ============================================
# STEP 4: Test Edge Function
# ============================================
echo ""
echo "🧪 Step 4: Testing Edge Function..."
echo ""
echo "⚠️  We need your Supabase ANON_KEY to test"
echo ""
echo "Get it from:"
echo "  https://supabase.com/dashboard/project/$PROJECT_REF/settings/api"
echo ""
read -p "Paste your ANON_KEY here (or press ENTER to skip test): " ANON_KEY

if [ -n "$ANON_KEY" ]; then
    echo ""
    echo "Testing HASH action..."
    
    HASH_RESPONSE=$(curl -s -X POST \
        "https://$PROJECT_REF.supabase.co/functions/v1/$FUNCTION_NAME" \
        -H "Authorization: Bearer $ANON_KEY" \
        -H "Content-Type: application/json" \
        -d '{"action":"hash","password":"TestPassword123!"}')
    
    if echo "$HASH_RESPONSE" | grep -q "hash"; then
        echo "✅ HASH action works!"
        HASH_VALUE=$(echo "$HASH_RESPONSE" | grep -o '\$2[ab]\$[0-9]*\$[A-Za-z0-9./]*')
        echo "   Generated hash: ${HASH_VALUE:0:20}..."
        
        echo ""
        echo "Testing VERIFY action..."
        
        VERIFY_RESPONSE=$(curl -s -X POST \
            "https://$PROJECT_REF.supabase.co/functions/v1/$FUNCTION_NAME" \
            -H "Authorization: Bearer $ANON_KEY" \
            -H "Content-Type: application/json" \
            -d "{\"action\":\"verify\",\"password\":\"TestPassword123!\",\"hash\":\"$HASH_VALUE\"}")
        
        if echo "$VERIFY_RESPONSE" | grep -q '"match":true'; then
            echo "✅ VERIFY action works!"
        else
            echo "❌ VERIFY action failed!"
            echo "Response: $VERIFY_RESPONSE"
        fi
    else
        echo "❌ HASH action failed!"
        echo "Response: $HASH_RESPONSE"
    fi
else
    echo "⚠️  Skipping function test"
    echo "   You can test manually later using curl"
fi

# ============================================
# STEP 5: Database Migration Instructions
# ============================================
echo ""
echo "📊 Step 5: Database Migration"
echo ""
echo "⚠️  CRITICAL: The next step will remove plain text passwords!"
echo ""
echo "Before running the migration, SAVE these current passwords:"
echo ""
echo "Username: test.teacher"
echo "Password: Teacher123!"
echo ""
echo "Username: maria.vardanyan"
echo "Password: 010581188"
echo ""
echo "You'll need these to reset passwords in Step 6."
echo ""
read -p "Have you saved these passwords? (y/N): " SAVED_PASSWORDS

if [ "$SAVED_PASSWORDS" != "y" ] && [ "$SAVED_PASSWORDS" != "Y" ]; then
    echo ""
    echo "❌ Please save the passwords above before continuing!"
    echo "   Run this script again when ready."
    exit 1
fi

echo ""
echo "📝 Now run the database migration:"
echo ""
echo "1. Open Supabase SQL Editor:"
echo "   https://supabase.com/dashboard/project/$PROJECT_REF/editor"
echo ""
echo "2. Copy the contents of: SECURE-TEACHER-PASSWORDS.sql"
echo ""
echo "3. Paste into the SQL Editor"
echo ""
echo "4. Click 'Run' button"
echo ""
echo "5. Check the output for success messages"
echo ""
read -p "Press ENTER when you've run the migration..."

# ============================================
# STEP 6: Password Reset Instructions
# ============================================
echo ""
echo "🔑 Step 6: Reset Teacher Passwords"
echo ""
echo "The migration removed plain text passwords."
echo "Now you need to reset them using Admin Hub:"
echo ""
echo "1. Start the server:"
echo "   python3 start-server.py"
echo ""
echo "2. Open Admin Hub:"
echo "   http://localhost:8000/admin-hub.html"
echo ""
echo "3. Login as admin (hrachfilm@gmail.com)"
echo ""
echo "4. Go to 'Teachers' section"
echo ""
echo "5. Reset passwords for:"
echo ""
echo "   Teacher: Test Teacher (test.teacher)"
echo "   → Click edit icon"
echo "   → Set password: Teacher123!"
echo "   → Click 'Save Changes'"
echo "   → Console should show: ✅ Password hashed successfully"
echo ""
echo "   Teacher: Maria Vardanyan (maria.vardanyan)"
echo "   → Click edit icon"
echo "   → Set password: 010581188"
echo "   → Click 'Save Changes'"
echo "   → Console should show: ✅ Password hashed successfully"
echo ""
read -p "Press ENTER when you've reset both passwords..."

# ============================================
# STEP 7: Test Teacher Login
# ============================================
echo ""
echo "🧪 Step 7: Test Teacher Login"
echo ""
echo "Verify that teachers can login:"
echo ""
echo "1. Open Teacher Login:"
echo "   http://localhost:8000/teacher"
echo ""
echo "2. Test with test.teacher:"
echo "   Username: test.teacher"
echo "   Password: Teacher123!"
echo "   → Should login successfully"
echo "   → Check console for: ✅ Password verified successfully"
echo ""
echo "3. Test with maria.vardanyan:"
echo "   Username: maria.vardanyan"
echo "   Password: 010581188"
echo "   → Should login successfully"
echo ""
read -p "Did both teachers login successfully? (y/N): " LOGIN_SUCCESS

if [ "$LOGIN_SUCCESS" != "y" ] && [ "$LOGIN_SUCCESS" != "Y" ]; then
    echo ""
    echo "❌ Login test failed!"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check browser console for errors"
    echo "  2. Verify Edge Function is deployed:"
    echo "     supabase functions list --project-ref $PROJECT_REF"
    echo "  3. Check that passwords are hashed in database:"
    echo "     SELECT username, LEFT(password_hash, 10) FROM teachers;"
    echo ""
    echo "See: BCRYPT-PASSWORD-SECURITY-DEPLOYMENT.md"
    exit 1
fi

# ============================================
# DEPLOYMENT COMPLETE
# ============================================
echo ""
echo "🎉 ============================================"
echo "   DEPLOYMENT COMPLETE!"
echo "   ============================================"
echo ""
echo "✅ Edge Function deployed"
echo "✅ Database migration run"
echo "✅ Passwords hashed with bcrypt"
echo "✅ Plain text passwords removed"
echo "✅ Teachers can login securely"
echo ""
echo "📊 Security Status:"
echo "   Before: Plain text passwords (INSECURE)"
echo "   After:  Bcrypt hashed (PRODUCTION READY)"
echo ""
echo "🔒 Your teacher system is now SECURE!"
echo ""
echo "📚 For more details, see:"
echo "   - BCRYPT-PASSWORD-SECURITY-DEPLOYMENT.md (full guide)"
echo "   - PASSWORD-SECURITY-COMPLETE.md (summary)"
echo ""
echo "✨ Thank you for securing your system!"
echo ""
