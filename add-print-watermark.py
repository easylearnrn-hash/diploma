#!/usr/bin/env python3
"""
Add a large watermark seal to all nursing note HTML files for printing.
The watermark appears ONLY when printing (using @media print).
"""

import os
import re

# All 29 note files
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

PRINT_WATERMARK_CSS = """
    /* Print Watermark - Only visible when printing */
    @media print {
      .print-watermark {
        display: block !important;
      }
    }

    .print-watermark {
      display: none;
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%) rotate(-45deg);
      font-size: 120px;
      font-weight: 900;
      color: rgba(15, 23, 42, 0.08);
      text-transform: uppercase;
      letter-spacing: 20px;
      white-space: nowrap;
      pointer-events: none;
      z-index: 9999;
      font-family: 'Inter', sans-serif;
    }"""

WATERMARK_HTML = """  <!-- Print Watermark -->
  <div class="print-watermark">
    ARMENIAN COLLEGE<br>OF NURSES
  </div>"""

def add_watermark(filepath):
    """Add print watermark to a single HTML file."""
    
    if not os.path.exists(filepath):
        print(f"❌ File not found: {filepath}")
        return False
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False
    
    # Check if watermark CSS already exists
    if 'print-watermark' not in content:
        # Add CSS before </style>
        style_close_pattern = r'(</style>)'
        if re.search(style_close_pattern, content):
            content = re.sub(style_close_pattern, PRINT_WATERMARK_CSS + r'\n  \1', content, count=1)
            modified = True
            print(f"  ✓ Added watermark CSS")
        else:
            print(f"  ⚠️  No </style> tag found")
    else:
        print(f"  • Watermark CSS already exists")
    
    # Check if watermark HTML already exists
    if 'ARMENIAN COLLEGE' not in content:
        # Add HTML after opening <body> tag
        body_open_pattern = r'(<body[^>]*>)'
        if re.search(body_open_pattern, content):
            content = re.sub(body_open_pattern, r'\1\n' + WATERMARK_HTML, content, count=1)
            modified = True
            print(f"  ✓ Added watermark HTML")
        else:
            print(f"  ⚠️  No <body> tag found")
    else:
        print(f"  • Watermark HTML already exists")
    
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
    """Apply print watermark to all note files."""
    
    print("=" * 60)
    print("ADDING PRINT WATERMARK TO ALL 29 NURSING NOTE FILES")
    print("=" * 60)
    print()
    print("Watermark: 'ARMENIAN COLLEGE OF NURSES'")
    print("Visibility: Print only (@media print)")
    print("Style: Large, rotated -45°, semi-transparent")
    print()
    
    success_count = 0
    already_added = 0
    not_found = 0
    
    for filename in NOTE_FILES:
        print(f"Processing: {filename}")
        
        if not os.path.exists(filename):
            print(f"  ❌ File not found\n")
            not_found += 1
            continue
        
        result = add_watermark(filename)
        if result:
            success_count += 1
        else:
            already_added += 1
    
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"✅ Files updated: {success_count}")
    print(f"ℹ️  Already had watermark: {already_added}")
    print(f"❌ Files not found: {not_found}")
    print(f"📋 Total files: {len(NOTE_FILES)}")
    print()
    
    if success_count > 0:
        print("🎉 Print watermark added successfully!")
        print("Next steps:")
        print("  1. Test by opening a note and using Print Preview (Cmd+P)")
        print("  2. Verify watermark appears in background")
        print("  3. Commit changes: git add *-nursing*.html *-nclex.html")
        print(f"  4. Commit: git commit -m 'Add print watermark to all {len(NOTE_FILES)} note files'")
    else:
        print("ℹ️  All files already have print watermark.")

if __name__ == '__main__':
    main()
