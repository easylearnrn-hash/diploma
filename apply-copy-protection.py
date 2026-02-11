#!/usr/bin/env python3
"""
Apply comprehensive copy protection to all 29 nursing note HTML files.
This script adds CSS user-select: none and JavaScript event blocking.
"""

import os
import re

# All 29 note files from admin-hub.html HARDCODED_NOTES
NOTE_FILES = [
    'fundamentals-nursing-nclex.html',
    'informed-consent-nursing.html',
    'scope-of-practice-nursing.html',
    'delegation-nursing-nclex.html',
    'family-dynamics-nursing.html',
    'maslows-hierarchy-nursing.html',
    'sbar-communication-nursing.html',
    'precautions-nursing.html',
    'vital-signs-interpretation-nursing.html',
    'physical-exam-bowel-sounds-nursing.html',
    'physical-assessment-nursing.html',
    'head-to-toe-assessment-nursing.html',
    'nursing-diagnosis-nclex.html',
    'documentation-informatics-nursing.html',
    'client-positioning-nursing.html',
    'tube-care-nursing.html',
    'blood-products-administration-nursing.html',
    'amputation-nursing.html',
    'nursing-calculations-nclex.html',
    'bmi-calculation-nursing.html',
    'complementary-alternative-medicine-nursing.html',
    'emergency-triage-tag-colors-nursing.html',
    'hygiene-grooming-nursing-nclex.html',
    'elimination-intake-output-nursing.html',
    'nutrition-feeding-nursing-nclex.html',
    'oxygenation-basics-nursing-nclex.html',
    'pain-assessment-nursing-nclex.html',
    'skin-integrity-pressure-injuries-nclex.html',
    'sleep-sensory-needs-nclex.html'
]

CSS_PROTECTION = """    * {
      user-select: none;
      -webkit-user-select: none;
      -moz-user-select: none;
      -webkit-touch-callout: none;
    }"""

JS_PROTECTION = """  <script>
    // Comprehensive copy protection for student notes
    
    // Prevent copy event
    document.addEventListener('copy', (e) => {
      e.preventDefault();
      e.clipboardData.setData('text/plain', '');
      return false;
    });
    
    // Prevent cut event
    document.addEventListener('cut', (e) => {
      e.preventDefault();
      return false;
    });
    
    // Prevent right-click context menu
    document.addEventListener('contextmenu', (e) => {
      e.preventDefault();
      return false;
    });
    
    // Prevent text selection
    document.addEventListener('selectstart', (e) => {
      e.preventDefault();
      return false;
    });
    
    // Prevent keyboard shortcuts (Cmd/Ctrl + C, X, A, P)
    document.addEventListener('keydown', (e) => {
      if ((e.metaKey || e.ctrlKey) && ['c', 'C', 'x', 'X', 'a', 'A', 'p', 'P'].includes(e.key)) {
        e.preventDefault();
        return false;
      }
    });
  </script>"""

def add_copy_protection(filepath):
    """Add copy protection to a single HTML file."""
    
    if not os.path.exists(filepath):
        print(f"❌ File not found: {filepath}")
        return False
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    modified = False
    
    # Check if CSS protection already exists
    if 'user-select: none' not in content:
        # Find the <style> tag and add protection
        style_pattern = r'(<style>)'
        if re.search(style_pattern, content):
            content = re.sub(style_pattern, r'\1\n' + CSS_PROTECTION, content, count=1)
            modified = True
            print(f"  ✓ Added CSS protection")
        else:
            print(f"  ⚠️  No <style> tag found")
    else:
        print(f"  • CSS protection already exists")
    
    # Check if JS protection already exists
    if 'Comprehensive copy protection' not in content:
        # Find </body> tag and add protection before it
        body_pattern = r'(</body>)'
        if re.search(body_pattern, content):
            content = re.sub(body_pattern, JS_PROTECTION + r'\n\1', content, count=1)
            modified = True
            print(f"  ✓ Added JavaScript protection")
        else:
            print(f"  ⚠️  No </body> tag found")
    else:
        print(f"  • JavaScript protection already exists")
    
    # Write back if modified
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✅ File updated successfully\n")
        return True
    else:
        print(f"  ℹ️  No changes needed\n")
        return False

def main():
    """Apply copy protection to all note files."""
    
    print("=" * 60)
    print("APPLYING COPY PROTECTION TO ALL 29 NURSING NOTE FILES")
    print("=" * 60)
    print()
    
    success_count = 0
    already_protected = 0
    not_found = 0
    
    for filename in NOTE_FILES:
        print(f"Processing: {filename}")
        
        if not os.path.exists(filename):
            print(f"  ❌ File not found\n")
            not_found += 1
            continue
        
        result = add_copy_protection(filename)
        if result:
            success_count += 1
        else:
            already_protected += 1
    
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"✅ Files updated: {success_count}")
    print(f"ℹ️  Already protected: {already_protected}")
    print(f"❌ Files not found: {not_found}")
    print(f"📋 Total files: {len(NOTE_FILES)}")
    print()
    
    if success_count > 0:
        print("🎉 Copy protection applied successfully!")
        print("Next steps:")
        print("  1. Review changes in a few files")
        print("  2. Test copy protection in browser")
        print("  3. Commit changes: git add *.html")
        print(f"  4. Commit: git commit -m 'Add copy protection to all {len(NOTE_FILES)} note files'")
    else:
        print("ℹ️  All files already have copy protection.")

if __name__ == '__main__':
    main()
