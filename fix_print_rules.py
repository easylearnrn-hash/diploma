import sys

with open('notes.html', 'r', encoding='utf-8') as f:
    content = f.read()

old_css = """/* Hide redundant UI components */
.pdf-page-container nav,
.pdf-page-container header.site-header,
.pdf-page-container footer,
.pdf-page-container .back-btn,
.pdf-page-container .fab,
.pdf-page-container [id*="guard"],
.pdf-page-container [class*="watermark"] { display: none !important; }

/* ── PRINT MEDIA RULES ── */
@page { size: A4; margin: 0; }
@media print {
  body { background: #fff !important; padding: 0 !important; margin: 0 !important; }
  .pdf-page-container {
     width: auto !important;
     min-height: auto !important;
     margin: 0 !important;
     box-shadow: none !important;
     border: none !important;
     page-break-after: always !important;
     break-after: page !important;
     padding: 15mm !important;
  }
  .print-btn-bar { display: none !important; }
  * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
}"""

new_css = """/* Hide redundant UI components */
.pdf-page-container nav,
.pdf-page-container header.site-header,
.pdf-page-container footer,
.pdf-page-container .back-btn,
.pdf-page-container .fab,
.pdf-page-container [id*="guard"],
.pdf-page-container [class*="watermark"] { display: none !important; }

/* Advanced page break handling */
table, tr, img, .card, .section, .callout, .step-block, .info-box, .alert-box {
  break-inside: avoid !important;
  page-break-inside: avoid !important;
}

.page-break {
  break-before: page;
  page-break-before: always;
}

.no-print {
  display: none !important;
}

/* ── PRINT MEDIA RULES ── */
@page { 
  size: A4; 
  margin: 18mm; 
}

@media print {
  html, body { 
    margin: 0 !important; 
    padding: 0 !important; 
    width: 210mm !important; 
    background: #fff !important; 
  }
  
  .pdf-page-container {
    width: 174mm !important; /* A4 minus 18mm margins */
    min-height: auto !important;
    margin: 0 auto !important;
    box-shadow: none !important;
    border: none !important;
    padding: 0 !important; 
    page-break-after: always !important;
    break-after: page !important;
  }

  .print-btn-bar { display: none !important; }
  * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
}"""

content = content.replace(old_css, new_css)

with open('notes.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("Replaced!")
