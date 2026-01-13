# 📝 PDF to HTML Conversion Instructions

## Overview
This document outlines the exact specifications for converting nursing study PDF notes into beautifully formatted, professional HTML documents.

---

## 🎨 Design Philosophy

Create clean, modern, and visually appealing study materials that are:
- **Easy to read** with clear hierarchy
- **Color-coded** for different types of information
- **Professional** yet engaging
- **Print-friendly** with PDF export capability

---

## 🏗️ HTML Structure Requirements

### 1. **Document Setup**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Topic Name] - NCLEX RN</title>
```

### 2. **Header Section**
- Must include a gradient header (`doc-header` class)
- Background: Dark gradient (`linear-gradient(135deg, #0f172a, #1e3a5f)`)
- Contains:
  - Title with emoji icon
  - "Generate PDF" button (teal/turquoise color: `#2dd4bf`)
- Positioned at the very top, extending edge-to-edge

### 3. **Main Container**
- Max-width: `900px`
- White background with subtle shadow
- Rounded corners (`border-radius: 16px`)
- Centered with auto margins
- Padding: `40px`

---

## 🎨 Color Palette

### Primary Colors
- **Dark Navy Blue**: `#0f172a` (headers, strong text)
- **Teal/Turquoise**: `#2dd4bf` (accents, borders, buttons)
- **Light Background**: `#f8fafc` (page background)
- **White**: `#ffffff` (content boxes)

### Text Colors
- **Primary Text**: `#1e293b`
- **Secondary Text**: `#475569`
- **Heading Text**: `#0f172a`
- **Subheading Text**: `#334155`

### Alert Box Colors
- **Success/Tip (Green)**: 
  - Background: `#ecfdf5`
  - Border: `#10b981`
  - Text: `#059669`

- **Alert/Warning (Red)**:
  - Background: `#fef2f2`
  - Border: `#ef4444`
  - Text: `#dc2626`

- **Highlight (Yellow/Orange)**:
  - Background: `#fef3c7`
  - Border: `#f59e0b`
  - Text: `#d97706`

- **Info/Example (Blue)**:
  - Background: `#f0f9ff`
  - Border: `#0ea5e9`
  - Text: `#0c4a6e`

---

## 📦 Content Box Types

### 1. **Overview Box** (Dark Gradient)
- Use at the beginning for topic overview
- Dark gradient background
- White text
- Contains main definitions and key focus areas
- Often includes bullet lists

```html
<div class="overview">
  <p><strong>Main definition</strong>...</p>
  <p><strong>The focus is on:</strong></p>
  <ul>
    <li>Point 1</li>
    <li>Point 2</li>
  </ul>
</div>
```

### 2. **Tip Box** (Green)
- Use for helpful reminders and key takeaways
- Light green background with green left border
- Icon: 🧠 (or relevant emoji)

```html
<div class="tip">
  <strong>🧠 Remember:</strong>
  <p>Key point here...</p>
</div>
```

### 3. **Alert Box** (Red)
- Use for critical warnings, dangers, or urgent information
- Light red background with red left border
- Use for safety concerns, contraindications, risks

```html
<div class="alert">
  <strong>⚠️ CRITICAL:</strong>
  <p>Important warning...</p>
</div>
```

### 4. **Highlight Box** (Yellow/Orange)
- Use for important clinical notes or exam tips
- Light yellow background with orange border
- Use for "Important:" or "Note:" information

```html
<div class="highlight-box">
  <p><strong>🧠 Important:</strong> Key clinical note...</p>
</div>
```

---

## 📊 Tables

### Styling Requirements
- Full width (`100%`)
- Dark navy header row (`#0f172a` background, white text)
- Subtle borders between rows (`#e2e8f0`)
- Hover effect on rows (light gray background)
- Rounded corners with box shadow
- Left-aligned text

### When to Use Tables
- Medication charts (type, use, examples, side effects)
- Assessment criteria (area, what to check)
- Therapeutic communication examples (technique, example)
- Comparison charts

```html
<table>
  <thead>
    <tr>
      <th>Column 1</th>
      <th>Column 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Bold item</strong></td>
      <td>Description</td>
    </tr>
  </tbody>
</table>
```

---

## 📝 Typography

### Headings

**H2 - Main Sections**
- Font-size: `1.5rem`
- Bold (`700` weight)
- Turquoise bottom border (`3px solid #2dd4bf`)
- Include emoji icons
- Margin-top: `40px`

**H3 - Subsections**
- Font-size: `1.2rem`
- Bold (`700` weight)
- UPPERCASE with letter-spacing
- Color: `#334155`
- Margin-top: `24px`

### Body Text
- Font-family: `'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`
- Line-height: `1.7`
- Color: `#475569`

### Strong Text
- Color: `#0f172a`
- Weight: `700`

---

## 🔤 Content Formatting Rules

### 1. **Use Emojis Strategically**
- Include relevant emojis in section headers
- Examples: 🧠 (mental health), 💊 (medications), 🚨 (safety), 💬 (communication)
- Adds visual interest and improves scannability

### 2. **Bullet Lists**
- Use for symptoms, signs, interventions, key points
- Indent with `margin-left: 24px`
- Adequate spacing between items (`margin-bottom: 10px`)

### 3. **Bold Important Terms**
- Wrap key medical terms in `<strong>` tags
- Examples: diagnoses, medication names, critical concepts

### 4. **Use Em Dash (—) for Explanations**
- Format: `Term — explanation`
- Example: `Crisis — moment of breakdown/loss of coping`

---

## 🎯 Section Organization

### Typical Document Structure:
1. **Header** (with title and PDF button)
2. **Overview Box** (definition and key focus)
3. **Main Content Sections** (numbered with H2)
   - Each section can include:
     - Subsections (H3)
     - Tables
     - Tip boxes
     - Alert boxes
     - Bullet lists
4. **High-Yield Tips Section** (at the end)
   - Often in an alert box
   - Critical exam preparation points

---

## 💡 Special Elements

### 1. **PDF Generation Button**
- Located in header
- Turquoise background (`#2dd4bf`)
- Includes JavaScript for html2pdf.js library
- Hover effect with transform and shadow
- Shows loading states (⏳, ✅, ❌)

### 2. **Inline Code**
- Use `<code>` tags for technical terms or abbreviations
- Light gray background (`#f1f5f9`)
- Red text (`#dc2626`)
- Monospace font

### 3. **Examples**
- Use italics for quoted examples
- Format in table cells or tip boxes
- Example: `"Can you tell me more about that?"`

---

## 📱 Responsive Design

### Requirements:
- Mobile-friendly viewport meta tag
- Flexible padding that adjusts on smaller screens
- Max-width container ensures readability on large screens
- Tables should scroll horizontally if needed on mobile

---

## 🔧 Technical Requirements

### Required Libraries:
```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
```

### PDF Generation Settings:
```javascript
{
  margin: 10,
  filename: '[Topic-Name]-NCLEX-RN.pdf',
  image: { type: 'jpeg', quality: 0.98 },
  html2canvas: { scale: 2, useCORS: true },
  jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
}
```

---

## ✅ Conversion Checklist

When converting a PDF to HTML, ensure:

- [ ] Header with gradient background and PDF button
- [ ] Proper emoji usage in headings
- [ ] Overview box at the beginning (if applicable)
- [ ] Color-coded boxes (tips, alerts, highlights) appropriately used
- [ ] Tables formatted with dark header and hover effects
- [ ] All medical terms properly bolded
- [ ] Subsections in uppercase H3 format
- [ ] Turquoise underline on all H2 headings
- [ ] Adequate spacing between sections
- [ ] Bullet lists for symptoms/signs/interventions
- [ ] High-yield tips section at the end (if applicable)
- [ ] PDF generation script included
- [ ] Responsive design with proper viewport settings

---

## 🎨 Style Guide Summary

**DO:**
✅ Use consistent spacing and alignment
✅ Include visual hierarchy with colors and sizing
✅ Add emojis to make content engaging
✅ Use tables for structured information
✅ Highlight critical information with colored boxes
✅ Keep content scannable with bullet points
✅ Use strong tags for medical terminology

**DON'T:**
❌ Overcrowd content without spacing
❌ Use too many different colors
❌ Make text blocks too long without breaks
❌ Forget responsive design considerations
❌ Omit the PDF generation functionality
❌ Use inconsistent heading styles

---

## 📄 Template Files

Reference file: `mental-health-notes.html`
Location: `/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA/`

This file serves as the master template for all future PDF to HTML conversions.

---

## 🚀 Quick Start Command

To convert a PDF:
1. Extract text content from PDF
2. Structure content into sections
3. Apply the HTML template
4. Add appropriate color-coded boxes
5. Format tables for structured data
6. Include emojis in headers
7. Test PDF generation button
8. Verify responsive design

---

**Last Updated**: January 13, 2026
**Version**: 1.0
**Status**: Active Template
