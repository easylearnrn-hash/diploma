#!/bin/bash

# 🚀 Quick Start Script for Admin Dashboard

echo "=============================================="
echo "🎓 ACNHS Admin Dashboard - Quick Start"
echo "=============================================="
echo ""

# Check if Python server is running
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo "✅ Server is already running on port 8000"
else
    echo "🚀 Starting Python server..."
    python3 start-server.py &
    sleep 2
    echo "✅ Server started on http://localhost:8000"
fi

echo ""
echo "=============================================="
echo "📋 QUICK ACCESS LINKS"
echo "=============================================="
echo ""
echo "🔐 Admin Login:"
echo "   http://localhost:8000/login.html"
echo "   Email: Hrachfilm@gmail.com"
echo "   Password: Demirchyan36!"
echo ""
echo "🏠 Admin Dashboard:"
echo "   http://localhost:8000/admin-home.html"
echo ""
echo "📊 Applications & Waiting List:"
echo "   http://localhost:8000/admin-applications.html"
echo ""
echo "=============================================="
echo "⚠️  IMPORTANT: Before using Waiting List"
echo "=============================================="
echo ""
echo "You MUST run this SQL in Supabase first:"
echo ""
echo "1. Go to: https://supabase.com/dashboard"
echo "2. Select project: zlvnxvrzotamhpezqedr"
echo "3. Click: SQL Editor"
echo "4. Copy SQL from: SETUP-REGISTRATIONS-TABLE.md"
echo "5. Click: Run"
echo ""
echo "=============================================="
echo "✨ Ready! Open browser and login as admin"
echo "=============================================="
echo ""
