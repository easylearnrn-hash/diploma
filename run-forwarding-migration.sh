#!/bin/bash
# Run Email Forwarding Migration
# This script executes the SQL migration to add forwarding columns

echo "🚀 Running Email Forwarding Migration..."
echo ""

# Check if supabase CLI is available
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found"
    echo "Please install it: brew install supabase/tap/supabase"
    exit 1
fi

# Run the migration
supabase db execute \
  --project-ref zlvnxvrzotamhpezqedr \
  --file ADD-EMAIL-FORWARDING-COLUMNS.sql

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Migration completed successfully!"
    echo "📧 Email forwarding is now ready to use"
    echo ""
    echo "Next steps:"
    echo "1. Open http://localhost:8000/email-system.html"
    echo "2. Click '⤴️ Forwarding' button"
    echo "3. Enable forwarding and enter your email"
else
    echo ""
    echo "❌ Migration failed"
    echo ""
    echo "Alternative method:"
    echo "1. Open https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/editor"
    echo "2. Click 'SQL Editor' → 'New Query'"
    echo "3. Copy contents of ADD-EMAIL-FORWARDING-COLUMNS.sql"
    echo "4. Paste and click 'Run'"
fi
