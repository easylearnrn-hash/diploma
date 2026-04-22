import re

with open("index.html", "r") as f:
    html = f.read()

faq_to_insert = """
  <button type="button" class="faq-item" onclick="toggleFAQ(this)">
        <div class="faq-question">
          <div class="faq-q-icon">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
            </svg>
          </div>
          <h3>Does the curriculum meet California Board of Registered Nursing (CA BRN) requirements?</h3>
          <div class="faq-toggle">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
          </div>
        </div>
        <div class="faq-answer">
          <div>
            <p><strong>Structurally, yes.</strong> The ACNHS curriculum is purposefully designed to align with the core educational frameworks required by the California Board of Registered Nursing (CA BRN) for international graduates.</p>
            <p>Specifically, the CA BRN mandates that international applicants must have completed <strong>concurrent theory and clinical practice</strong> in five core areas: <strong>Medical-Surgical, Obstetrics/Maternity, Pediatrics, Mental Health/Psychiatrics, and Gerontology</strong>.</p>
            <p>The ACNHS curriculum explicitly integrates concurrent clinical practice across all these requisite domains. While the California BRN independently evaluates each applicant's transcript, our program structure is engineered to satisfy their stringent concurrency and content requirements.</p>
          </div>
        </div>
  </button>
"""

# Find the end of the FAQ section or place it after the first 3 FAQs. Let's look for a good spot to insert.
target = "  <button type=\"button\" class=\"faq-item\" onclick=\"toggleFAQ(this)\">"
parts = html.split(target)

# We will put it right after the 2nd FAQ basically.
if len(parts) > 3:
    new_html = parts[0] + target + parts[1] + target + parts[2] + faq_to_insert + target + parts[3]
    for i in range(4, len(parts)):
        new_html += target + parts[i]
    with open("index.html", "w") as f:
        f.write(new_html)
    print("Inserted FAQ successfully.")
else:
    print("Could not find FAQ insertion point.")
