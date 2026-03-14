#!/usr/bin/env python3
"""
standardize-layout.py
=====================
Injects css/note-layout.css into every student note HTML file that
doesn't already have it, ensuring a consistent container width, dark
theme, and typography across all 314 notes.

What it does:
  1. For notes WITHOUT a container / note-body (82 subdirectory files):
       • Adds  <link rel="stylesheet" href="../css/note-layout.css">  into <head>
  2. For notes WITH .container or .note-body (178 files):
       • Same link injection — the stylesheet's :has() rules normalise the container
  3. For pdf24_ (PDF-converted) Cardiovascular notes (22 files):
       • Injects link + wraps the raw PDF <body> content with .acnhs-pdf-wrapper
         and an .acnhs-pdf-header banner showing the title and a back link
  4. Root-level fundamentals notes (32 files):
       • Same as case 1/2 but with  href="css/note-layout.css"  (no ../)

Files already containing 'note-layout.css' are skipped (idempotent).

Usage:
  python3 standardize-layout.py
"""

import os
import re
import sys

BASE = os.path.dirname(os.path.abspath(__file__))

# ── Note subdirectories ──────────────────────────────────────────────────────
NOTE_DIRS = [
    'Autoimmune & Infectious Disorders',
    'BurnsSkin',
    'Cancer',
    'Cardiovascular System',
    'EENT',
    'Endocrine System',
    'EyeDisorders',
    'Fluids, Electrolytes & Nutrition',
    'Gastrointestinal & Hepatic System',
    'Infections',
    'Maternal Health',
    'MedSurg',
    'MusculoskeletalDisorders',
    'Neurology',
    'Pediatrics',
    'Pharmacology',
    'PsychoSocialAspects',
    'Renal System',
    'ReproductiveHealth',
    'Respiratory System',
]

# Root-level fundamentals notes
FUNDAMENTALS = [
    'amputation-nursing.html',
    'blood-products-administration-nursing.html',
    'bmi-calculation-nursing.html',
    'client-positioning-nursing.html',
    'complementary-alternative-medicine-nursing.html',
    'delegation-nursing-nclex.html',
    'documentation-informatics-nursing.html',
    'elimination-intake-output-nursing.html',
    'emergency-triage-tag-colors-nursing.html',
    'family-dynamics-nursing.html',
    'fundamentals-nursing-nclex.html',
    'head-to-toe-assessment-nursing.html',
    'hygiene-grooming-nursing-nclex.html',
    'informed-consent-nursing.html',
    'maslows-hierarchy-nursing.html',
    'nursing-calculations-nclex.html',
    'nursing-diagnosis-nclex.html',
    'nutrition-feeding-nursing-nclex.html',
    'oxygenation-basics-nursing-nclex.html',
    'pain-assessment-nursing-nclex.html',
    'physical-assessment-nursing.html',
    'physical-exam-bowel-sounds-nursing.html',
    'precautions-nursing.html',
    'sbar-communication-nursing.html',
    'scope-of-practice-nursing.html',
    'skin-integrity-pressure-injuries-nclex.html',
    'sleep-sensory-needs-nclex.html',
    'tube-care-nursing.html',
    'vital-signs-interpretation-nursing.html',
]

SKIP_FILES = {'note-viewer.html', 'hub.html', 'login.html', 'student-dashboard.html',
              'admin-home.html', 'admin-applications.html', 'index.html'}

MARKER = 'note-layout.css'


# ── Helpers ──────────────────────────────────────────────────────────────────

def read(path):
    with open(path, 'r', encoding='utf-8', errors='replace') as f:
        return f.read()

def write(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def inject_link(content, href):
    """Insert <link> to note-layout.css just before </head>."""
    link_tag = f'<link rel="stylesheet" href="{href}">'
    close_head = re.search(r'</head>', content, re.IGNORECASE)
    if close_head:
        pos = close_head.start()
        return content[:pos] + link_tag + '\n' + content[pos:]
    # No </head> — inject at top
    return link_tag + '\n' + content

def extract_pdf_title(content, filepath=''):
    """Try to extract a human-readable title from a pdf24_ file."""
    # Prefer the filename — it's always the most accurate title
    if filepath:
        fname = os.path.basename(filepath)
        # Strip .html
        title = re.sub(r'\.html?$', '', fname, flags=re.IGNORECASE)
        # Remove leading emoji / numbers like "4. 🚨 "
        title = re.sub(r'^[\d\.\s🚨❤️⚡💉💔🚨🦠🧊🧪🩸🫀]+', '', title).strip()
        if title:
            return title
    # Fallback: try <title> tag (sometimes blank in pdf24_ files)
    m = re.search(r'<title[^>]*>(.*?)</title>', content, re.IGNORECASE | re.DOTALL)
    if m:
        t = m.group(1).strip()
        if t:
            return t
    return 'Cardiovascular Note'

def wrap_pdf24_body(content, back_href, filepath=''):
    """Wrap the raw pdf24 body content with .acnhs-pdf-wrapper + header."""
    title = extract_pdf_title(content, filepath)
    folder_name = 'Cardiovascular System'

    header_html = (
        f'<div class="acnhs-pdf-wrapper">\n'
        f'<div class="acnhs-pdf-header">\n'
        f'  <div class="acnhs-pdf-header-left">\n'
        f'    <span class="acnhs-pdf-tag">❤️ {folder_name}</span>\n'
        f'    <span class="acnhs-pdf-title">{title}</span>\n'
        f'  </div>\n'
        f'  <a href="{back_href}hub.html" class="acnhs-pdf-back">← Hub</a>\n'
        f'</div>\n'
    )
    close_wrapper = '\n</div><!-- /.acnhs-pdf-wrapper -->\n'

    # Inject after <body>
    body_open = re.search(r'<body[^>]*>', content, re.IGNORECASE)
    body_close = re.search(r'</body>', content, re.IGNORECASE)

    if body_open and body_close:
        after_body_open = body_open.end()
        before_body_close = body_close.start()
        return (
            content[:after_body_open]
            + '\n' + header_html
            + content[after_body_open:before_body_close]
            + close_wrapper
            + content[before_body_close:]
        )
    return content


# ── Processing ────────────────────────────────────────────────────────────────

def process_note(fpath, href, is_pdf24=False):
    """Process a single note file. Returns True if modified."""
    content = read(fpath)
    if MARKER in content:
        return False  # already done

    modified = inject_link(content, href)

    if is_pdf24:
        # Also add the inline style needed for the wrapper container to work
        # and wrap the body content
        prefix = re.match(r'(\.\.\/)+|', href).group(0)  # e.g. '../'
        modified = wrap_pdf24_body(modified, prefix, fpath)

    write(fpath, modified)
    return True


def main():
    injected = 0
    skipped = 0
    errors = 0

    all_files = []

    # Subdirectory notes
    for nd in NOTE_DIRS:
        dp = os.path.join(BASE, nd)
        if not os.path.isdir(dp):
            continue
        is_cv = (nd == 'Cardiovascular System')
        for fname in sorted(os.listdir(dp)):
            if not fname.lower().endswith('.html') or fname in SKIP_FILES:
                continue
            fpath = os.path.join(dp, fname)
            try:
                content = read(fpath)
            except Exception as e:
                print(f'  ❌ READ ERROR: {os.path.relpath(fpath, BASE)} — {e}', file=sys.stderr)
                errors += 1
                continue
            is_pdf24 = 'pdf24_' in content
            all_files.append((fpath, '../css/note-layout.css', is_pdf24))

    # Root-level fundamentals
    for fname in FUNDAMENTALS:
        fpath = os.path.join(BASE, fname)
        if os.path.isfile(fpath):
            all_files.append((fpath, 'css/note-layout.css', False))

    print(f'Processing {len(all_files)} note files...')

    for fpath, href, is_pdf24 in all_files:
        rel = os.path.relpath(fpath, BASE)
        try:
            if process_note(fpath, href, is_pdf24):
                label = '(pdf24 + wrap)' if is_pdf24 else ''
                print(f'  ✅ {rel} {label}')
                injected += 1
            else:
                print(f'  ⏭  {rel}  (already done)')
                skipped += 1
        except Exception as e:
            print(f'  ❌ ERROR: {rel} — {e}', file=sys.stderr)
            errors += 1

    print()
    print(f'Done. Injected: {injected}  |  Skipped: {skipped}  |  Errors: {errors}')


if __name__ == '__main__':
    main()
