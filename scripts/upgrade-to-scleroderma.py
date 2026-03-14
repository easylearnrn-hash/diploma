#!/usr/bin/env python3
"""
Upgrade all old-pattern HTML notes to the Scleroderma design system.

Changes made to each file:
  1.  Replace entire <style> block with the full Scleroderma CSS
  2.  Add med-abbr-tooltip CSS link (and remove old link if present)
  3.  Remove the outer <div class="page"> wrapper
  4.  Convert the old h1 + subtitle pattern to note-header / note-tag / note-subtitle
  5.  Map old card colour classes: success→green, warning→gold, danger→red
  6.  Convert .nclex-tip divs to <div class="alert gold"> blocks
  7.  Add disease-popup JS inline before </body>
  8.  Add med-abbr-tooltip script link before </body>
  9.  Fix font reference to 'Inter' + max-width to 860px

Usage:
    python3 scripts/upgrade-to-scleroderma.py
"""

import os
import re
import sys

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

FILES_TO_UPGRADE = [
    # Infections
    "Infections/Anthrax.html",
    "Infections/C-Difficile.html",
    "Infections/Chickenpox-Varicella.html",
    "Infections/HIV.html",
    "Infections/Hepatitis.html",
    "Infections/Infections-Master-Overview.html",
    "Infections/Infections-Overview.html",
    "Infections/Lyme-Disease.html",
    "Infections/Meningitis.html",
    "Infections/Mumps.html",
    "Infections/Rubella.html",
    "Infections/Rubeola-Measles.html",
    "Infections/SARS-Covid.html",
    # Pharmacology
    "Pharmacology/ACE-Inhibitors.html",
    "Pharmacology/ARBs.html",
    "Pharmacology/Autoimmune-Inflammatory-Medications.html",
    "Pharmacology/Beta-Blockers.html",
    "Pharmacology/Burns-Dermatology-Medications.html",
    "Pharmacology/Calcium-Channel-Blockers.html",
    "Pharmacology/Drug-Dosage-Math.html",
    "Pharmacology/EENT-Medications.html",
    "Pharmacology/Emergency-Shock-Surgical-Medications.html",
    "Pharmacology/Endocrine-Medications.html",
    "Pharmacology/Fluids-Electrolytes-IV-Therapy.html",
    "Pharmacology/Gastrointestinal-Medications.html",
    "Pharmacology/General-Pharmacology.html",
    "Pharmacology/High-Alert-Medications.html",
    "Pharmacology/Infectious-Diseases-Medications.html",
    "Pharmacology/Maternal-Health-Medications.html",
    "Pharmacology/Medication-Calculation-Administration.html",
    "Pharmacology/Mental-Health-Medications.html",
    "Pharmacology/Nursing-Common-Medications.html",
    "Pharmacology/Pediatric-Medications.html",
    "Pharmacology/Renal-Urinary-Medications.html",
    "Pharmacology/Respiratory-Medications.html",
]

# ─── Full Scleroderma CSS block (injected as inline <style>) ─────────────────
SCLERODERMA_CSS = """    :root {
      --bg: #020d1a; --surface: #071228; --surface2: #0b1c35;
      --border: rgba(201,168,76,0.15); --gold: #c9a84c; --gold-light: #e8c96a;
      --text: #e8eaf0; --text-muted: #7a8aaa; --text-dim: #4a5a7a;
      --red: #f87171; --green: #4ade80; --blue: #60a5fa;
      --purple: #c084fc; --orange: #fb923c; --yellow: #facc15; --radius: 12px;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: var(--bg); color: var(--text);
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      font-size: 14px; line-height: 1.7;
      padding: 24px 20px 60px; max-width: 860px; margin: 0 auto;
    }
    /* ── Header ───────────────────────────────── */
    .note-header { border-bottom: 1px solid var(--border); padding-bottom: 20px; margin-bottom: 28px; }
    .note-tag {
      display: inline-flex; align-items: center; gap: 6px;
      font-size: 10px; font-weight: 800; letter-spacing: 1.2px; text-transform: uppercase;
      color: var(--gold); background: rgba(201,168,76,0.10);
      border: 1px solid rgba(201,168,76,0.22); border-radius: 20px;
      padding: 4px 12px; margin-bottom: 12px;
    }
    h1 { font-size: 26px; font-weight: 800; color: #fff; letter-spacing: -0.5px; line-height: 1.25; margin-bottom: 8px; }
    .note-subtitle { font-size: 13px; color: var(--text-muted); font-weight: 500; }
    /* ── Headings ─────────────────────────────── */
    h2 {
      font-size: 16px; font-weight: 800; color: var(--gold-light); letter-spacing: 0.2px;
      margin: 32px 0 14px; padding-bottom: 8px; border-bottom: 1px solid var(--border);
      display: flex; align-items: center; gap: 8px;
    }
    h3 { font-size: 14px; font-weight: 700; color: var(--blue); margin: 20px 0 8px; }
    h4 { font-size: 13px; font-weight: 700; color: var(--text); margin: 14px 0 6px; }
    p { margin-bottom: 10px; }
    ul, ol { padding-left: 20px; margin-bottom: 12px; }
    li { margin-bottom: 5px; }
    /* ── Cards ────────────────────────────────── */
    .card {
      background: var(--surface); border: 1px solid var(--border);
      border-radius: var(--radius); padding: 16px 18px; margin-bottom: 16px;
    }
    .card.gold  { border-color: rgba(201,168,76,0.40); background: rgba(201,168,76,0.06); }
    .card.red   { border-color: rgba(248,113,113,0.40); background: rgba(248,113,113,0.06); }
    .card.blue  { border-color: rgba(96,165,250,0.40); background: rgba(96,165,250,0.06); }
    .card.green { border-color: rgba(74,222,128,0.40); background: rgba(74,222,128,0.06); }
    .card.purple{ border-color: rgba(192,132,252,0.40); background: rgba(192,132,252,0.06); }
    .card-label {
      font-size: 9px; font-weight: 900; letter-spacing: 1.2px; text-transform: uppercase;
      opacity: 0.7; margin-bottom: 8px;
    }
    /* ── Compare grid ─────────────────────────── */
    .compare-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; }
    @media (max-width: 560px) { .compare-grid { grid-template-columns: 1fr; } }
    /* ── Badges ───────────────────────────────── */
    .badge {
      display: inline-block; font-size: 10px; font-weight: 800;
      letter-spacing: 0.8px; text-transform: uppercase;
      padding: 2px 8px; border-radius: 20px; margin: 2px 3px 2px 0;
    }
    .badge-red    { background: rgba(248,113,113,0.15); color: var(--red);    border: 1px solid rgba(248,113,113,0.30); }
    .badge-blue   { background: rgba(96,165,250,0.15);  color: var(--blue);   border: 1px solid rgba(96,165,250,0.30); }
    .badge-gold   { background: rgba(201,168,76,0.15);  color: var(--gold);   border: 1px solid rgba(201,168,76,0.30); }
    .badge-green  { background: rgba(74,222,128,0.15);  color: var(--green);  border: 1px solid rgba(74,222,128,0.30); }
    .badge-purple { background: rgba(192,132,252,0.15); color: var(--purple); border: 1px solid rgba(192,132,252,0.30); }
    .badge-orange { background: rgba(251,146,60,0.15);  color: var(--orange); border: 1px solid rgba(251,146,60,0.30); }
    /* ── Mini table ───────────────────────────── */
    .mini-table { width: 100%; border-collapse: collapse; margin-bottom: 16px; font-size: 13px; }
    .mini-table th {
      background: var(--surface2); color: var(--text-muted);
      font-size: 10px; font-weight: 800; letter-spacing: 0.8px; text-transform: uppercase;
      padding: 8px 12px; text-align: left; border: 1px solid var(--border);
    }
    .mini-table td { padding: 8px 12px; border: 1px solid var(--border); vertical-align: top; }
    .mini-table tr:nth-child(even) td { background: rgba(255,255,255,0.02); }
    /* ── Alert boxes ──────────────────────────── */
    .alert {
      display: flex; gap: 12px; align-items: flex-start;
      border-radius: var(--radius); padding: 14px 16px; margin: 16px 0;
      border: 1px solid transparent;
    }
    .alert.red    { background: rgba(248,113,113,0.08); border-color: rgba(248,113,113,0.30); }
    .alert.gold   { background: rgba(201,168,76,0.08);  border-color: rgba(201,168,76,0.30); }
    .alert.blue   { background: rgba(96,165,250,0.08);  border-color: rgba(96,165,250,0.30); }
    .alert.green  { background: rgba(74,222,128,0.08);  border-color: rgba(74,222,128,0.30); }
    .alert-icon { font-size: 18px; flex-shrink: 0; margin-top: 1px; }
    .alert-body { flex: 1; }
    .alert-title { font-size: 12px; font-weight: 800; letter-spacing: 0.5px; text-transform: uppercase; margin-bottom: 4px; }
    .alert.red  .alert-title { color: var(--red); }
    .alert.gold .alert-title { color: var(--gold); }
    .alert.blue .alert-title { color: var(--blue); }
    .alert.green .alert-title { color: var(--green); }
    /* ── Divider ──────────────────────────────── */
    .divider { border: none; border-top: 1px solid var(--border); margin: 28px 0; }
    /* ── Mnemonic box (kept for backwards compat) ─ */
    .mnemonic {
      background: rgba(96,165,250,0.08); border: 1px solid rgba(96,165,250,0.25);
      border-radius: var(--radius); padding: 12px 16px; margin: 12px 0;
      font-size: 13px; text-align: center;
    }
    .mnemonic strong { color: var(--blue); font-size: 14px; }
    /* ── Highlight box (kept for backwards compat) ─ */
    .highlight-box {
      background: rgba(248,113,113,0.08); border: 1px solid rgba(248,113,113,0.30);
      border-radius: var(--radius); padding: 12px 16px; margin: 10px 0;
    }
    /* ── Acronym grid ─────────────────────────── */
    .acronym-grid { display: grid; grid-template-columns: 36px 1fr; gap: 6px 12px; align-items: center; }
    .acronym-letter {
      width: 36px; height: 36px; border-radius: 8px;
      background: rgba(201,168,76,0.15); border: 1px solid rgba(201,168,76,0.30);
      display: flex; align-items: center; justify-content: center;
      font-size: 18px; font-weight: 900; color: var(--gold);
    }
    /* ── Disease link popups ──────────────────── */
    .disease-link {
      cursor: pointer;
      border-bottom: none !important;
      text-decoration: none !important;
      color: inherit !important;
    }
    #disease-popup {
      position: fixed; z-index: 99998;
      background: linear-gradient(135deg, #0c1a32 0%, #0f2040 100%);
      border: 1px solid rgba(201,168,76,0.35);
      border-radius: 12px;
      padding: 16px 18px;
      max-width: 320px; min-width: 220px;
      box-shadow: 0 16px 48px rgba(0,0,0,0.7), 0 0 0 1px rgba(201,168,76,0.08);
      font-family: 'Inter', sans-serif;
      font-size: 13px; line-height: 1.5;
      color: #e8edf5;
      opacity: 0; transform: translateY(-6px);
      transition: opacity 0.18s ease, transform 0.18s ease;
      pointer-events: none;
    }
    #disease-popup.visible { opacity: 1; transform: translateY(0); pointer-events: auto; }
    #disease-popup-title {
      font-size: 12px; font-weight: 800; letter-spacing: 0.6px; text-transform: uppercase;
      color: var(--gold); margin-bottom: 6px;
    }
    #disease-popup-desc { color: #c8d0e0; margin-bottom: 8px; }
    #disease-popup-location {
      font-size: 11px; color: var(--text-muted);
      border-top: 1px solid rgba(201,168,76,0.15); padding-top: 7px; margin-top: 6px;
    }
    #disease-popup-close {
      position: absolute; top: 8px; right: 10px;
      font-size: 16px; cursor: pointer; color: var(--text-muted); line-height: 1;
      background: none; border: none; padding: 2px 4px;
    }
    #disease-popup-close:hover { color: var(--gold); }"""

# ─── Disease popup JS (inline, no external file needed) ──────────────────────
DISEASE_POPUP_JS = """
<div id="disease-popup" role="tooltip" aria-hidden="true">
  <button id="disease-popup-close" onclick="closeDiseasePopup()" aria-label="Close">✕</button>
  <div id="disease-popup-title"></div>
  <div id="disease-popup-desc"></div>
  <div id="disease-popup-location"></div>
</div>
<script>
// ── Disease Registry ───────────────────────────────────────────────────────
const DISEASE_REGISTRY = {
  // Neurological
  "stroke": { title: "Stroke (CVA)", desc: "Sudden interruption of cerebral blood flow. Ischemic (clot) or hemorrhagic (bleed). FAST: Face drooping, Arm weakness, Speech difficulty, Time to call.", loc: "📂 Neurology → Stroke.html" },
  "cva": { title: "CVA – Stroke", desc: "Cerebrovascular accident — sudden brain ischemia or hemorrhage causing focal neurological deficits.", loc: "📂 Neurology → Stroke.html" },
  "multiple sclerosis": { title: "Multiple Sclerosis (MS)", desc: "Autoimmune demyelinating disease of the CNS. Relapsing-remitting or progressive. Key: fatigue, optic neuritis, Uhthoff's phenomenon.", loc: "📂 Neurology → Multiple-Sclerosis.html" },
  "ms": { title: "Multiple Sclerosis", desc: "Autoimmune CNS demyelination. See full note for types, symptoms, and DMTs.", loc: "📂 Neurology → Multiple-Sclerosis.html" },
  "parkinson": { title: "Parkinson's Disease", desc: "Dopamine deficiency in substantia nigra. TRAP: Tremor, Rigidity, Akinesia, Postural instability.", loc: "📂 Neurology → Parkinsons-Disease.html" },
  "parkinson's": { title: "Parkinson's Disease", desc: "Dopamine deficiency causing TRAP symptoms. Levodopa/Carbidopa is the cornerstone treatment.", loc: "📂 Neurology → Parkinsons-Disease.html" },
  "seizure": { title: "Seizure Disorders", desc: "Abnormal electrical activity in the brain. Types: focal, generalized (tonic-clonic, absence). Safety during ictal phase is the nursing priority.", loc: "📂 Neurology → Seizure-Disorders.html" },
  "epilepsy": { title: "Epilepsy / Seizure Disorders", desc: "Recurrent seizures due to chronic neurological condition. AEDs are first-line treatment.", loc: "📂 Neurology → Seizure-Disorders.html" },
  "increased icp": { title: "Increased ICP", desc: "Intracranial pressure >15 mmHg. Cushing's Triad: hypertension + bradycardia + irregular respirations = late sign.", loc: "📂 Neurology → Increased-ICP.html" },
  "scleroderma": { title: "Scleroderma (Systemic Sclerosis)", desc: "Autoimmune fibrosis of skin and organs. CREST syndrome: Calcinosis, Raynaud's, Esophageal dysmotility, Sclerodactyly, Telangiectasia.", loc: "📂 Neurology → Scleroderma.html" },
  "cerebral palsy": { title: "Cerebral Palsy", desc: "Non-progressive motor disorder from prenatal/perinatal brain injury. Spastic type is most common.", loc: "📂 Neurology → Cerebral-Palsy.html" },
  "vertigo": { title: "Vertigo / Ménière's Disease", desc: "Peripheral vertigo from inner ear dysfunction. Ménière's triad: episodic vertigo + tinnitus + sensorineural hearing loss.", loc: "📂 Neurology → Vertigo-Menieres.html" },
  "meniere": { title: "Ménière's Disease", desc: "Endolymphatic hydrops causing recurrent attacks of vertigo, tinnitus, and low-frequency hearing loss.", loc: "📂 Neurology → Vertigo-Menieres.html" },
  "spinal cord injury": { title: "Spinal Cord Injury", desc: "Complete or incomplete cord damage. Neurogenic shock vs. spinal shock. Key levels: C4 (ventilator-dependent), T4 (nipple line), L4 (knees).", loc: "📂 Neurology → Spinal-Cord-Injury.html" },
  "sci": { title: "Spinal Cord Injury", desc: "Traumatic or non-traumatic cord damage with motor/sensory/autonomic deficits.", loc: "📂 Neurology → Spinal-Cord-Injury.html" },
  "cerebral aneurysm": { title: "Cerebral Aneurysm", desc: "Bulging weak spot in cerebral artery. Rupture → subarachnoid hemorrhage. 'Thunderclap headache' is classic presentation.", loc: "📂 Neurology → Cerebral-Aneurysms.html" },
  // Infections
  "meningitis": { title: "Meningitis", desc: "Inflammation of the meninges. Bacterial is an emergency: IV antibiotics STAT. Classic triad: headache + stiff neck + fever. Kernig's + Brudzinski's signs.", loc: "📂 Infections → Meningitis.html" },
  "hiv": { title: "HIV / AIDS", desc: "Human Immunodeficiency Virus attacking CD4+ T-cells. AIDS defined by CD4 <200 or AIDS-defining illness. ART is lifelong treatment.", loc: "📂 Infections → HIV.html" },
  "aids": { title: "AIDS", desc: "Acquired Immunodeficiency Syndrome — late-stage HIV with CD4 <200/μL or AIDS-defining illness.", loc: "📂 Infections → HIV.html" },
  "hepatitis": { title: "Hepatitis", desc: "Liver inflammation from viral infection. A+E: fecal-oral (HAV vaccine). B+C+D: bloodborne. HBV: vaccine available. HCV: no vaccine, curable with DAAs.", loc: "📂 Infections → Hepatitis.html" },
  "hepatitis b": { title: "Hepatitis B (HBV)", desc: "Bloodborne liver virus. Acute → chronic → cirrhosis → HCC. 3-dose vaccine series. Antiviral: tenofovir/entecavir.", loc: "📂 Infections → Hepatitis.html" },
  "hepatitis c": { title: "Hepatitis C (HCV)", desc: "Most common bloodborne infection in US. Curable with 8–12 weeks of DAA therapy (sofosbuvir). No vaccine.", loc: "📂 Infections → Hepatitis.html" },
  "tuberculosis": { title: "Tuberculosis (TB)", desc: "Mycobacterium tuberculosis — airborne. Active vs. latent TB. Airborne precautions (N95). First-line: RIPE (Rifampin, Isoniazid, Pyrazinamide, Ethambutol).", loc: "📂 Infections → (see Pharmacology → Infectious Diseases)" },
  "tb": { title: "Tuberculosis", desc: "Airborne bacterial infection. RIPE therapy for active TB. Test: TST or IGRA. Airborne isolation required.", loc: "📂 Infections / Pharmacology → Infectious-Diseases-Medications.html" },
  "c. diff": { title: "C. difficile (C. diff)", desc: "Clostridium difficile colitis after antibiotic use. Contact precautions. Treat with oral vancomycin or fidaxomicin. Hand hygiene with soap (not alcohol).", loc: "📂 Infections → C-Difficile.html" },
  "c difficile": { title: "C. difficile", desc: "Antibiotic-associated colitis. Contact isolation. Oral vancomycin / fidaxomicin. Soap and water handwashing — alcohol doesn't kill spores.", loc: "📂 Infections → C-Difficile.html" },
  "anthrax": { title: "Anthrax", desc: "Bacillus anthracis — bioterrorism agent. Inhalation anthrax is most lethal. Treat with ciprofloxacin or doxycycline.", loc: "📂 Infections → Anthrax.html" },
  "lyme disease": { title: "Lyme Disease", desc: "Borrelia burgdorferi via Ixodes tick. Bull's-eye rash (erythema migrans). Early: doxycycline. Late: IV ceftriaxone.", loc: "📂 Infections → Lyme-Disease.html" },
  "chickenpox": { title: "Chickenpox (Varicella)", desc: "Varicella-zoster virus. Airborne + contact precautions. Contagious before rash appears. Treat: acyclovir (immunocompromised). Vaccine: live attenuated VZV.", loc: "📂 Infections → Chickenpox-Varicella.html" },
  "varicella": { title: "Varicella (Chickenpox)", desc: "VZV infection. Itchy vesicular rash in crops. Airborne precautions until all lesions are crusted.", loc: "📂 Infections → Chickenpox-Varicella.html" },
  "mumps": { title: "Mumps", desc: "Paramyxovirus. Parotitis (parotid gland swelling). Droplet precautions. MMR vaccine prevents.", loc: "📂 Infections → Mumps.html" },
  "rubella": { title: "Rubella (German Measles)", desc: "Togavirus. Mild rash; dangerous in pregnancy (congenital rubella syndrome). MMR vaccine.", loc: "📂 Infections → Rubella.html" },
  "measles": { title: "Rubeola (Measles)", desc: "Paramyxovirus. Koplik's spots + maculopapular rash. Airborne precautions. MMR vaccine.", loc: "📂 Infections → Rubeola-Measles.html" },
  "rubeola": { title: "Rubeola (Measles)", desc: "Highly contagious airborne virus. 3 Cs: Cough, Coryza, Conjunctivitis + Koplik spots.", loc: "📂 Infections → Rubeola-Measles.html" },
  "covid": { title: "COVID-19 / SARS-CoV-2", desc: "Novel coronavirus causing respiratory illness. ARDS risk. Standard + droplet + contact precautions (airborne for AGPs). Vaccines: mRNA-based.", loc: "📂 Infections → SARS-Covid.html" },
  "sars": { title: "SARS-CoV-2 / COVID-19", desc: "Severe Acute Respiratory Syndrome coronavirus. Cytokine storm, ARDS, coagulopathy complications.", loc: "📂 Infections → SARS-Covid.html" },
  // Pharmacology cross-references
  "heart failure": { title: "Heart Failure (HF)", desc: "Reduced cardiac output. HFrEF vs HFpEF. Key drugs: ACE inhibitors, ARBs, beta-blockers, diuretics, sacubitril/valsartan.", loc: "📂 Pharmacology → Beta-Blockers.html, ACE-Inhibitors.html" },
  "hypertension": { title: "Hypertension", desc: "BP ≥130/80 mmHg. First-line: ACE inhibitors/ARBs, CCBs, thiazides. Hypertensive emergency: BP >180/120 + organ damage.", loc: "📂 Pharmacology → ACE-Inhibitors.html, ARBs.html, Beta-Blockers.html" },
  "diabetes": { title: "Diabetes Mellitus", desc: "Type 1 (absolute insulin deficiency) vs Type 2 (insulin resistance). Monitor for hypo/hyperglycemia. Key: insulin types, metformin, HbA1c.", loc: "📂 Pharmacology → Endocrine-Medications.html" },
  "asthma": { title: "Asthma", desc: "Chronic inflammatory airway disease. Short-acting β2 agonists (albuterol) for rescue; inhaled corticosteroids for control.", loc: "📂 Pharmacology → Respiratory-Medications.html" },
  "copd": { title: "COPD", desc: "Chronic Obstructive Pulmonary Disease — emphysema + chronic bronchitis. Pink puffer vs blue bloater. Avoid high-flow O2.", loc: "📂 Pharmacology → Respiratory-Medications.html" },
};

let _popupTimeout = null;

function showDiseasePopup(el, key) {
  const data = DISEASE_REGISTRY[key];
  if (!data) return;
  const popup = document.getElementById('disease-popup');
  document.getElementById('disease-popup-title').textContent = data.title;
  document.getElementById('disease-popup-desc').textContent = data.desc;
  document.getElementById('disease-popup-location').textContent = '📍 Found in: ' + data.loc;
  popup.setAttribute('aria-hidden', 'false');

  // Position near the clicked element
  const rect = el.getBoundingClientRect();
  const scrollY = window.scrollY || window.pageYOffset;
  const scrollX = window.scrollX || window.pageXOffset;
  let top = rect.bottom + scrollY + 8;
  let left = rect.left + scrollX;
  // Keep within viewport
  const popW = 320;
  if (left + popW > window.innerWidth - 16) left = window.innerWidth - popW - 16 + scrollX;
  if (left < 8) left = 8;
  popup.style.top = top + 'px';
  popup.style.left = left + 'px';

  clearTimeout(_popupTimeout);
  popup.classList.add('visible');
  // Auto-close after 8 seconds
  _popupTimeout = setTimeout(closeDiseasePopup, 8000);
}

function closeDiseasePopup() {
  const popup = document.getElementById('disease-popup');
  popup.classList.remove('visible');
  popup.setAttribute('aria-hidden', 'true');
}

// Close on outside click
document.addEventListener('click', function(e) {
  if (!e.target.classList.contains('disease-link') && !document.getElementById('disease-popup').contains(e.target)) {
    closeDiseasePopup();
  }
});

// Wire up all disease links
document.querySelectorAll('.disease-link').forEach(function(el) {
  const key = (el.dataset.disease || el.textContent).toLowerCase().trim();
  el.addEventListener('click', function(e) {
    e.stopPropagation();
    showDiseasePopup(el, key);
  });
});
</script>"""

# ─── Tooltip script link ───────────────────────────────────────────────────
TOOLTIP_LINKS = """  <link rel="stylesheet" href="../css/med-abbr-tooltip.css">
  <script src="../js/med-abbr-tooltip.js" defer></script>"""

# ─── Mapping: old card class → new card class ────────────────────────────────
CARD_CLASS_MAP = [
    (r'class="card\s+success"', 'class="card green"'),
    (r'class="card\s+warning"', 'class="card gold"'),
    (r'class="card\s+danger"',  'class="card red"'),
    (r'class="card\s+info"',    'class="card blue"'),
    # also handle reversed order
    (r'class="success\s+card"', 'class="card green"'),
    (r'class="warning\s+card"', 'class="card gold"'),
    (r'class="danger\s+card"',  'class="card red"'),
]

# ─── Mapping: old table → mini-table ─────────────────────────────────────────
def upgrade_tables(html):
    """Add class='mini-table' to all <table> tags that don't have a class already."""
    return re.sub(r'<table(?!\s+class)', '<table class="mini-table"', html)


def convert_nclex_tips(html):
    """Convert .nclex-tip divs to .alert.gold blocks."""
    # Match: <div class="nclex-tip"><strong>TEXT</strong>CONTENT</div>
    def replacer(m):
        inner = m.group(1)
        # Extract the strong title if present
        title_match = re.match(r'\s*<strong[^>]*>(.*?)</strong>(.*)', inner, re.DOTALL)
        if title_match:
            icon_title = title_match.group(1).strip()
            # Strip leading emoji from title
            icon_match = re.match(r'^([^\w\s]{1,3})\s*(.*)', icon_title)
            if icon_match:
                icon = icon_match.group(1)
                title_text = icon_match.group(2)
            else:
                icon = '💡'
                title_text = icon_title
            body = title_match.group(2).strip()
            return (f'\n<div class="alert gold">\n'
                    f'  <div class="alert-icon">{icon}</div>\n'
                    f'  <div class="alert-body">\n'
                    f'    <div class="alert-title">{title_text}</div>\n'
                    f'    <p>{body}</p>\n'
                    f'  </div>\n'
                    f'</div>\n')
        else:
            return (f'\n<div class="alert gold">\n'
                    f'  <div class="alert-icon">💡</div>\n'
                    f'  <div class="alert-body">\n'
                    f'    <p>{inner.strip()}</p>\n'
                    f'  </div>\n'
                    f'</div>\n')
    return re.sub(r'<div\s+class="nclex-tip">(.*?)</div>', replacer, html, flags=re.DOTALL)


def upgrade_header(html):
    """
    Convert old pattern:
      <div class="page">
        <h1>EMOJI Title</h1>
        <p class="subtitle">subtitle text</p>
    To new:
      (no .page wrapper)
      <div class="note-header">
        <div class="note-tag">TOPIC · SUBTOPIC</div>
        <h1>EMOJI Title</h1>
        <p class="note-subtitle">subtitle text</p>
      </div>
    """
    # Infer topic from <title> tag
    title_match = re.search(r'<title>(.*?)</title>', html)
    page_title = title_match.group(1).strip() if title_match else 'Notes'

    # Determine category tag from filepath (handled in caller)
    # For now use page_title as the tag base
    words = page_title.replace(' – ', ' · ').replace(' - ', ' · ')
    note_tag = f'📚 {words}'

    # Find h1 content
    h1_match = re.search(r'<h1[^>]*>(.*?)</h1>', html, re.DOTALL)
    if not h1_match:
        return html
    h1_content = h1_match.group(1).strip()

    # Find subtitle (p.subtitle or p class="subtitle")
    sub_match = re.search(r'<p[^>]*class="subtitle"[^>]*>(.*?)</p>', html, re.DOTALL)
    subtitle_html = ''
    if sub_match:
        subtitle_html = f'\n  <p class="note-subtitle">{sub_match.group(1).strip()}</p>'
        html = html.replace(sub_match.group(0), '', 1)

    # Replace the h1
    new_header = (f'<div class="note-header">\n'
                  f'  <div class="note-tag">{note_tag}</div>\n'
                  f'  <h1>{h1_content}</h1>{subtitle_html}\n'
                  f'</div>')
    html = html.replace(h1_match.group(0), new_header, 1)

    # Remove the outer .page wrapper (opening tag only — closing </div> is trickier)
    html = re.sub(r'<div\s+class="page"\s*>\s*', '', html)

    return html


def replace_style_block(html):
    """Replace the entire <style>...</style> block with the Scleroderma CSS."""
    return re.sub(
        r'<style>.*?</style>',
        f'<style>\n{SCLERODERMA_CSS}\n  </style>',
        html,
        count=1,
        flags=re.DOTALL
    )


def inject_tooltip_links(html):
    """Add tooltip CSS+JS after no-copy.js script tag. Avoid duplicating."""
    if 'med-abbr-tooltip.css' in html:
        return html  # already present
    # Insert after the no-copy.js script tag
    html = re.sub(
        r'(<script src="../js/no-copy\.js"></script>)',
        r'\1\n' + TOOLTIP_LINKS,
        html
    )
    # If no-copy.js not present, insert after <meta viewport>
    if 'med-abbr-tooltip.css' not in html:
        html = re.sub(
            r'(<meta name="viewport"[^>]*>)',
            r'\1\n' + TOOLTIP_LINKS,
            html
        )
    return html


def inject_disease_popup(html):
    """Add the disease popup HTML+JS before </body>. Avoid duplicating."""
    if 'disease-popup' in html:
        return html  # already present
    html = html.replace('</body>', DISEASE_POPUP_JS + '\n</body>', 1)
    return html


def add_no_copy_if_missing(html):
    """Ensure no-copy.js is in <head>."""
    if 'no-copy.js' not in html:
        html = re.sub(
            r'(<head>)',
            r'\1\n  <script src="../js/no-copy.js"></script>',
            html
        )
    return html


def upgrade_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        html = f.read()

    # Skip files already upgraded
    if '--surface2' in html and 'note-header' in html and 'mini-table' in html:
        print(f'  SKIP (already upgraded): {os.path.basename(filepath)}')
        return

    original = html

    # 1. Ensure no-copy.js present
    html = add_no_copy_if_missing(html)

    # 2. Replace style block
    html = replace_style_block(html)

    # 3. Inject tooltip links
    html = inject_tooltip_links(html)

    # 4. Upgrade header (h1 → note-header, subtitle, remove .page wrapper)
    html = upgrade_header(html)

    # 5. Map card colour classes
    for pattern, replacement in CARD_CLASS_MAP:
        html = re.sub(pattern, replacement, html)

    # 6. Convert nclex-tip → alert.gold
    html = convert_nclex_tips(html)

    # 7. Upgrade tables
    html = upgrade_tables(html)

    # 8. Remove leftover closing </div> from old .page wrapper
    # (The page wrapper had exactly one div wrapping everything - remove the last bare </div> before </body>)
    # Use a careful regex: remove the last </div> that is directly followed by optional whitespace + content-protection script or </body>
    html = re.sub(
        r'</div>\s*(\n\s*<script src="../js/content-protection\.js"></script>\s*\n\s*</body>)',
        r'\1',
        html
    )

    # 9. Inject disease popup before </body>
    html = inject_disease_popup(html)

    if html != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(html)
        print(f'  ✅ Upgraded: {os.path.basename(filepath)}')
    else:
        print(f'  ⚠️  No changes: {os.path.basename(filepath)}')


def main():
    print(f'\n🔄 Upgrading notes to Scleroderma design system...\n{"─"*54}')
    errors = 0
    for rel_path in FILES_TO_UPGRADE:
        full_path = os.path.join(BASE, rel_path)
        if not os.path.exists(full_path):
            print(f'  ❌ NOT FOUND: {rel_path}')
            errors += 1
            continue
        try:
            upgrade_file(full_path)
        except Exception as e:
            print(f'  ❌ ERROR {rel_path}: {e}')
            errors += 1

    print(f'\n{"─"*54}')
    print(f'Done. {len(FILES_TO_UPGRADE) - errors}/{len(FILES_TO_UPGRADE)} files processed.')
    if errors:
        print(f'⚠️  {errors} error(s) — check output above.')
    return errors


if __name__ == '__main__':
    sys.exit(main())
