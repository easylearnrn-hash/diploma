#!/bin/bash
# Check Edge Function logs for send-email function
# This will show us if emails are being sent but not saved

echo "🔍 Checking send-email Edge Function logs..."
echo "================================================"
echo ""

supabase functions logs send-email --project-ref zlvnxvrzotamhpezqedr --tail

# To see last 50 entries instead:
# supabase functions logs send-email --project-ref zlvnxvrzotamhpezqedr --limit 50
