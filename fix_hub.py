import re

with open('hub.html', 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Hoist the variables to fix TDZ
text = text.replace('let _finalExamDateRaw = null; // stored when DB fetch succeeds', '')
text = text.replace('let _finalExamTimeRaw = null;', '')
text = text.replace('let currentStudentId = null;', 'let currentStudentId = null;\n    let _finalExamDateRaw = null;\n    let _finalExamTimeRaw = null;')

# 2. Relocate the finalExamDateBanner
banner_match = re.search(r'(<div id="finalExamDateBanner".*?TAP TO VIEW DETAILS</div>\n                  </div>)', text, re.DOTALL)
if banner_match:
    banner_html = banner_match.group(1)
    # Remove it from its original place
    text = text.replace(banner_html, '')
    
    # Adjust its margin-top style so it looks good when not in the class schedule
    banner_html = banner_html.replace('margin-top:16px;', '')
    banner_html = banner_html.replace('padding:16px 14px;', 'padding:16px 18px;')
    banner_html = banner_html.replace('<div style="font-size:11px;font-weight:900;text-transform:uppercase;letter-spacing:.14em;color:var(--gold-400);margin-bottom:8px;">Final Exam Date</div>', '<div style="font-size:11px;font-weight:900;text-transform:uppercase;letter-spacing:.14em;color:var(--gold-400);margin-bottom:8px;">🎓 Final Exam Date</div>')
    
    # Insert it directly into .stack BEFORE .carousel-container
    stack_anchor = '<div class="stack">\n\n          <div class="carousel-container">'
    new_stack = f'<div class="stack">\n\n          <!-- Final Exam Banner — lives OUTSIDE the carousel so overflow:hidden never clips it -->\n          {banner_html}\n\n          <div class="carousel-container">'
    
    text = text.replace(stack_anchor, new_stack)

with open('hub.html', 'w', encoding='utf-8') as f:
    f.write(text)
