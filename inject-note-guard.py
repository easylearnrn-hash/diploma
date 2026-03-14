#!/usr/bin/env python3
"""
inject-note-guard.py
====================
Injects the ACNHS note access-control guard into every student note HTML file.

What it does to each file:
  1. Adds  <style>body{display:none!important}</style>  inside <head>
     (hides the page instantly before any content is rendered).
  2. Inserts  <script src="...js/note-guard.js"></script>  just before </body>
     (runs the Supabase auth + publish check, then reveals body on pass).

Files already processed (containing 'note-guard.js') are skipped.

Usage:
  python3 inject-note-guard.py
"""

import os
import re
import sys

# ─── Configuration ────────────────────────────────────────────────────────────

DIPLOMA_DIR = os.path.dirname(os.path.abspath(__file__))

# Subdirectories that contain student notes
NOTE_DIRS = [
    'Cardiovascular System',
    'Respiratory System',
    'Endocrine System',
    'Gastrointestinal System',
    'Renal System',
    'Neurological System',
    'Infections',
    'Musculoskeletal Disorders',
    'Reproductive Health',
    'Pediatrics',
    'Cancer',
    'Eye Disorders',
    'Burns & Skin',
    'Mental Health',
    'Medical Terminology',
    'EENT',
    'Fluids & Electrolytes',
    'Psycho-Social Aspects',
    'Community Health',
    'Pharmacology',
    'Human Anatomy',
    'Medical-Surgical Care',
    'Drug Classes',
]

# Also scan root-level fundamentals notes (flat .html files in DIPLOMA_DIR
# that match the fundamentals list — they live at the root, not a subfolder).
# We detect them by checking if they're in the HUB_SEED fundamentals list.
FUNDAMENTALS_FILES = {
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
    'sleep-sensory-needs-nclex.html',
}

# Files to NEVER touch (admin pages, public pages, etc.)
SKIP_FILES = {
    'admin-home.html',
    'admin-applications.html',
    'admin-hub.html',
    'admission-form.html',
    'login.html',
    'hub.html',
    'student-dashboard.html',
    'about.html',
    'academic-catalog.html',
    'acceptance-letter.html',
    'verify-transcript.html',
    'note-viewer.html',
    'index.html',
}

GUARD_MARKER   = 'note-guard.js'
HIDE_STYLE     = '<style id="acnhs-guard-hide">body{display:none!important}</style>'
HIDE_MARKER    = 'acnhs-guard-hide'   # detect already-injected hide style

# ─── Helpers ──────────────────────────────────────────────────────────────────

def depth_prefix(filepath):
    """
    Return the relative path prefix (e.g. '../') needed to reach the root
    js/ folder from the given file's directory.
    """
    rel = os.path.relpath(os.path.dirname(filepath), DIPLOMA_DIR)
    if rel == '.':
        return ''   # file is in root
    parts = rel.split(os.sep)
    return '../' * len(parts)


def inject_file(filepath):
    """
    Inject the hide-style into <head> and the guard script before </body>.
    Returns True if the file was modified, False if skipped.
    """
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()

    # Skip if already injected
    if GUARD_MARKER in content:
        return False

    prefix = depth_prefix(filepath)
    script_tag = f'<script src="{prefix}js/note-guard.js"></script>'

    modified = content

    # 1. Insert hide-style into <head> (after opening <head> tag if present,
    #    otherwise before the first <style> or <body> tag, or prepend to file).
    if HIDE_MARKER not in modified:
        head_match = re.search(r'<head[^>]*>', modified, re.IGNORECASE)
        if head_match:
            pos = head_match.end()
            modified = modified[:pos] + '\n' + HIDE_STYLE + modified[pos:]
        else:
            # No <head> tag — try before <body>
            body_match = re.search(r'<body[^>]*>', modified, re.IGNORECASE)
            if body_match:
                pos = body_match.start()
                modified = modified[:pos] + HIDE_STYLE + '\n' + modified[pos:]
            else:
                # No structure at all — prepend
                modified = HIDE_STYLE + '\n' + modified

    # 2. Insert guard script just before </body>
    close_body = re.search(r'</body>', modified, re.IGNORECASE)
    if close_body:
        pos = close_body.start()
        modified = modified[:pos] + script_tag + '\n' + modified[pos:]
    else:
        # No </body> — append at end of file
        modified = modified.rstrip() + '\n' + script_tag + '\n'

    if modified == content:
        return False   # nothing changed

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(modified)

    return True


# ─── Main ─────────────────────────────────────────────────────────────────────

def collect_note_files():
    """Return list of all note HTML file paths to process."""
    files = []

    # Subfolder notes
    for note_dir in NOTE_DIRS:
        dir_path = os.path.join(DIPLOMA_DIR, note_dir)
        if not os.path.isdir(dir_path):
            continue
        for fname in os.listdir(dir_path):
            if fname.lower().endswith('.html') and fname not in SKIP_FILES:
                files.append(os.path.join(dir_path, fname))

    # Root-level fundamentals notes
    for fname in FUNDAMENTALS_FILES:
        fpath = os.path.join(DIPLOMA_DIR, fname)
        if os.path.isfile(fpath):
            files.append(fpath)

    # Generic sweep: any HTML inside a subdirectory not already captured
    for entry in os.scandir(DIPLOMA_DIR):
        if entry.is_dir() and entry.name not in {
            'js', 'css', 'img', 'fonts', 'vid', '.git',
            'supabase', 'node_modules', '__pycache__',
        }:
            for root, _, filenames in os.walk(entry.path):
                for fname in filenames:
                    if fname.lower().endswith('.html') and fname not in SKIP_FILES:
                        fpath = os.path.join(root, fname)
                        if fpath not in files:
                            files.append(fpath)

    return sorted(set(files))


def main():
    files = collect_note_files()
    print(f'Found {len(files)} candidate note file(s).')

    injected = 0
    skipped  = 0
    errors   = 0

    for fpath in files:
        try:
            rel = os.path.relpath(fpath, DIPLOMA_DIR)
            if inject_file(fpath):
                print(f'  ✅ {rel}')
                injected += 1
            else:
                print(f'  ⏭  {rel}  (already has guard)')
                skipped += 1
        except Exception as exc:
            print(f'  ❌ ERROR: {os.path.relpath(fpath, DIPLOMA_DIR)} — {exc}',
                  file=sys.stderr)
            errors += 1

    print()
    print(f'Done. Injected: {injected}  |  Skipped (already done): {skipped}  |  Errors: {errors}')


if __name__ == '__main__':
    main()
