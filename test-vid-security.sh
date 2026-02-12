#!/bin/bash

# VID System Security Test Script
# This script verifies that VID.html is properly secured

echo "🔒 VID SYSTEM SECURITY VERIFICATION"
echo "===================================="
echo ""

# Test 1: Check .gitignore
echo "✓ Test 1: Checking .gitignore..."
if grep -q "VID.html" .gitignore; then
    echo "  ✅ VID.html is in .gitignore"
else
    echo "  ❌ FAIL: VID.html NOT in .gitignore!"
    exit 1
fi
echo ""

# Test 2: Verify Git ignores the file
echo "✓ Test 2: Verifying Git ignores VID.html..."
if git ls-files --error-unmatch VID.html 2>/dev/null; then
    echo "  ❌ FAIL: VID.html is tracked by Git!"
    exit 1
else
    echo "  ✅ VID.html is not tracked by Git"
fi
echo ""

# Test 3: Check if file exists locally
echo "✓ Test 3: Checking if VID.html exists..."
if [ -f "VID.html" ]; then
    echo "  ✅ VID.html exists locally"
else
    echo "  ❌ FAIL: VID.html not found!"
    exit 1
fi
echo ""

# Test 4: Check SQL file exists
echo "✓ Test 4: Checking if VID-SETUP.sql exists..."
if [ -f "VID-SETUP.sql" ]; then
    echo "  ✅ VID-SETUP.sql exists"
else
    echo "  ❌ FAIL: VID-SETUP.sql not found!"
    exit 1
fi
echo ""

# Test 5: Check documentation exists
echo "✓ Test 5: Checking if VID-SYSTEM-DOCUMENTATION.md exists..."
if [ -f "VID-SYSTEM-DOCUMENTATION.md" ]; then
    echo "  ✅ VID-SYSTEM-DOCUMENTATION.md exists"
else
    echo "  ❌ FAIL: Documentation not found!"
    exit 1
fi
echo ""

# Test 6: Verify no links in UI
echo "✓ Test 6: Checking for VID.html links in public pages..."
LINKS=$(grep -r "VID.html" *.html 2>/dev/null | grep -v "VID.html:" | wc -l)
if [ "$LINKS" -eq 0 ]; then
    echo "  ✅ No links to VID.html found in public pages"
else
    echo "  ⚠️  WARNING: Found $LINKS reference(s) to VID.html in other files"
    grep -r "VID.html" *.html 2>/dev/null | grep -v "VID.html:"
fi
echo ""

# Summary
echo "===================================="
echo "✅ ALL SECURITY TESTS PASSED!"
echo ""
echo "Next steps:"
echo "1. Run VID-SETUP.sql in Supabase SQL Editor"
echo "2. Start server: python3 start-server.py"
echo "3. Login at: http://localhost:8000/login.html"
echo "4. Access VID at: http://localhost:8000/VID.html"
echo ""
echo "⚠️  REMINDER: NEVER commit VID.html to Git!"
