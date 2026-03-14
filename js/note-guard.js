/**
 * note-guard.js  — ACNHS Note Access Control
 * ===========================================
 * Injected into every student note HTML file.
 *
 * Enforcement rules (fail-closed):
 *  1. User must be logged in  (isLoggedIn === 'true' in session or localStorage).
 *  2. Admin users bypass the publish check entirely.
 *  3. Students must have an explicit row in Supabase `published_notes`
 *     WHERE student_id = <their UUID>  AND  note_id = <this note's ID>.
 *  4. If ANY check fails → redirect to login.html (not logged in)
 *     or hub.html?blocked=1 (logged in but note not published to them).
 *
 * The <body> is hidden with an inline style injected by the Python script
 * (see inject-note-guard.py). This script reveals the body ONLY after
 * auth passes, preventing any flash of content.
 *
 * Dependencies loaded by this file itself (no external CDN, all local):
 *  - js/supabase.min.js  (Supabase JS client v2 bundle)
 *  - js/supabase-config.js  (SUPABASE_CONFIG object with url + anonKey)
 */
(function () {
  'use strict';

  // ─── Helpers ────────────────────────────────────────────────────────────────

  function store(key) {
    return (
      sessionStorage.getItem(key) ||
      localStorage.getItem(key) ||
      null
    );
  }

  /** Redirect and stop execution. */
  function redirect(url) {
    // If the URL is relative, prefix() may already be prepended by the caller.
    // Use replace() so back-button doesn't loop.
    window.location.replace(url);
    // Throw so no code after redirect() ever runs even if replace() is async.
    throw new Error('ACNHS: redirecting to ' + url);
  }

  /**
   * Reveal the page body (remove the guard hide-style AND inline override).
   */
  function reveal() {
    // Remove the injected hide <style> tag
    var hideEl = document.getElementById('acnhs-guard-hide');
    if (hideEl) { hideEl.parentNode.removeChild(hideEl); }
    // Belt-and-suspenders: clear any inline display:none on body
    if (document.body) { document.body.style.display = ''; }
  }

  /**
   * Resolve the prefix needed to reach the project root (where js/ lives).
   *
   * Strategy: find the <script> tag that loaded THIS file — its src attribute
   * already encodes the correct relative depth (e.g. "../js/note-guard.js" or
   * "js/note-guard.js"). Strip the filename and we have our prefix.
   *
   * Fallback: derive from script src path if document.currentScript is null.
   */
  function jsPrefix() {
    // Try document.currentScript first (works in modern browsers)
    var me = document.currentScript;
    if (!me) {
      // Fallback: scan all <script> tags for one whose src ends with note-guard.js
      var scripts = document.getElementsByTagName('script');
      for (var i = 0; i < scripts.length; i++) {
        if (scripts[i].src && scripts[i].src.indexOf('note-guard.js') !== -1) {
          me = scripts[i];
          break;
        }
      }
    }
    if (me && me.src) {
      // src is an absolute URL, e.g.
      //   file:///...DIPLOMA/Cardiovascular%20System/foo.html  <-- page
      //   file:///...DIPLOMA/js/note-guard.js                  <-- script src
      // We want the directory part before "js/note-guard.js"
      var src = me.src;                            // absolute URL
      var jsIdx = src.lastIndexOf('/js/note-guard.js');
      if (jsIdx !== -1) {
        var root = src.substring(0, jsIdx + 1);   // "file:///...DIPLOMA/"
        var pagePath = window.location.href.split('?')[0]; // strip query
        // Count how many directories the page is below root
        var relative = pagePath.replace(root, '');
        var slashes = (relative.match(/\//g) || []).length;
        // slashes = number of path separators AFTER root, which equals depth
        // (filename has no slash, so slashes = dirs above file)
        var prefix = '';
        for (var d = 0; d < slashes; d++) { prefix += '../'; }
        return prefix;
      }
    }
    // Ultimate fallback: assume one level deep (most notes are in one subdir)
    return '../';
  }

  /** Dynamically load a script and resolve when loaded. */
  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement('script');
      s.src = src;
      s.onload = resolve;
      s.onerror = function () { reject(new Error('Failed to load ' + src)); };
      document.head.appendChild(s);
    });
  }

  /** Note ID lookup: maps the current HTML file path to a canonical note_id.
   *  We match against the HUB_SEED map embedded in hub.html (same data).
   *  Key = normalised lower-case file name (without leading path segments).
   */
  var NOTE_ID_MAP = {
    // ── Fundamentals ──────────────────────────────────────────────────────────
    'fundamentals-nursing-nclex.html':                 'note_1',
    'informed-consent-nursing.html':                   'note_2',
    'scope-of-practice-nursing.html':                  'note_3',
    'delegation-nursing-nclex.html':                   'note_4',
    'family-dynamics-nursing.html':                    'note_5',
    'maslows-hierarchy-nursing.html':                  'note_6',
    'sbar-communication-nursing.html':                 'note_7',
    'precautions-nursing.html':                        'note_8',
    'vital-signs-interpretation-nursing.html':         'note_9',
    'physical-exam-bowel-sounds-nursing.html':         'note_10',
    'physical-assessment-nursing.html':                'note_11',
    'head-to-toe-assessment-nursing.html':             'note_12',
    'nursing-diagnosis-nclex.html':                    'note_13',
    'documentation-informatics-nursing.html':          'note_14',
    'client-positioning-nursing.html':                 'note_15',
    'tube-care-nursing.html':                          'note_16',
    'blood-products-administration-nursing.html':      'note_17',
    'amputation-nursing.html':                         'note_18',
    'nursing-calculations-nclex.html':                 'note_19',
    'bmi-calculation-nursing.html':                    'note_20',
    'complementary-alternative-medicine-nursing.html': 'note_21',
    'emergency-triage-tag-colors-nursing.html':        'note_22',
    'hygiene-grooming-nursing-nclex.html':             'note_23',
    'elimination-intake-output-nursing.html':          'note_24',
    'nutrition-feeding-nursing-nclex.html':            'note_25',
    'oxygenation-basics-nursing-nclex.html':           'note_26',
    'pain-assessment-nursing-nclex.html':              'note_27',
    'skin-integrity-pressure-injuries-nclex.html':     'note_28',
    'sleep-sensory-needs-nclex.html':                  'note_29',
    // ── Cardiovascular System ─────────────────────────────────────────────────
    'heart structure & circulation.html':              'note_cv_1',
    'vital signs and organ prioritization.html':       'note_cv_2',
    '❤️ pulses.html':                                  'note_cv_3',
    '❤️ hyper-hypotension, co & sv.html':              'note_cv_4',
    '❤️‍🩹 heart attack _ 💔 heart failure _ 🫀⚡cardiac arrest.docx.html': 'note_cv_5',
    'right & left-sided heart failure.html':           'note_cv_6',
    'ischemic heart disease ihd.html':                 'note_cv_7',
    'ekg.html':                                        'note_cv_8',
    '⚡ pacemakers & icds.html':                       'note_cv_9',
    '🫀 cpr (cardiopulmonary resuscitation).html':     'note_cv_10',
    '🫀 cabg & pci.html':                              'note_cv_11',
    '💔cardiomyopathy.html':                           'note_cv_12',
    '🫀 pericarditis .html':                           'note_cv_13',
    '🦠❤️ infective endocarditis.html':                'note_cv_14',
    '🚨 cardiac tamponade.html':                       'note_cv_15',
    '4. 🚨 shock management & emergency care.html':   'note_cv_16',
    '🧊 pvd, 🦵 pad, 🩸 dvt.html':                    'note_cv_17',
    "🩸 buerger's disease.html":                       'note_cv_18',
    '🩸 blood, vessels & lymphs.html':                 'note_cv_19',
    '💉 iv gauges and their uses.html':                'note_cv_20',
    '💉anticoagulants.html':                           'note_cv_21',
    '🧪 troponin, bnp, ck-mm, ck-mb, ck-bb, and bun.html': 'note_cv_22',
    '🫀💊 cardiovascular medications.html':            'note_cv_23',
    // ── Respiratory System ────────────────────────────────────────────────────
    'respiratory-medications.html':          'note_resp_1',
    'incentive-spirometry-pulmonary-hygiene.html': 'note_resp_2',
    'pleural-effusion.html':                 'note_resp_3',
    'tracheostomy.html':                     'note_resp_4',
    'sleep-apnea.html':                      'note_resp_5',
    'physiology-of-breathing.html':          'note_resp_6',
    'copd.html':                             'note_resp_7',
    'chronic-bronchitis.html':               'note_resp_8',
    'asthma.html':                           'note_resp_9',
    'emphysema.html':                        'note_resp_10',
    'pneumonia.html':                        'note_resp_11',
    'tuberculosis.html':                     'note_resp_12',
    'hemothorax-and-pneumothorax.html':      'note_resp_13',
    'mask-types-and-respiratory-system.html': 'note_resp_14',
    'pulmonary-embolism.html':               'note_resp_15',
    'ards.html':                             'note_resp_16',
    // ── Endocrine System ──────────────────────────────────────────────────────
    'diabetes-mellitus.html':                'note_endo_1',
    'insulin-patch.html':                    'note_endo_2',
    'insulin-storage-and-checking.html':     'note_endo_3',
    'insulin.html':                          'note_endo_4',
    'mixing-of-insulin-guidelines.html':     'note_endo_5',
    'metformin.html':                        'note_endo_6',
    'endocrine-medications.html':            'note_endo_7',
    'thyroid-gland-and-hormones.html':       'note_endo_8',
    'thyroid-gland.html':                    'note_endo_8',   // alt filename
    'adrenal-gland-ad-and-cd.html':          'note_endo_9',
    'adrenal-gland.html':                    'note_endo_9',   // alt filename
    'dka-and-hhns.html':                     'note_endo_10',
    'diabetes-insipidus-and-siadh.html':     'note_endo_11',
    // ── Gastrointestinal System ───────────────────────────────────────────────
    'gastrointestinal-medications.html':              'note_gi_1',
    'gi-anatomy.html':                                'note_gi_2',
    'peptic-ulcer-disease.html':                      'note_gi_3',
    'inflammatory-bowel-disease.html':                'note_gi_4',
    'liver-cirrhosis-and-hepatitis.html':             'note_gi_5',
    'liver-cirrhosis.html':                           'note_gi_5',   // alt
    'appendicitis.html':                              'note_gi_6',
    'bowel-obstruction.html':                         'note_gi_7',
    'cholecystitis-and-pancreatitis.html':            'note_gi_8',
    // ── Renal / Fluids ────────────────────────────────────────────────────────
    'renal-medications.html':          'note_renal_1',
    'kidney-anatomy.html':             'note_renal_2',
    'acute-kidney-injury.html':        'note_renal_3',
    'chronic-kidney-disease.html':     'note_renal_4',
    'fluids-and-electrolytes.html':    'note_renal_5',
    'acid-base-balance.html':          'note_renal_6',
    // ── Neurological System ───────────────────────────────────────────────────
    'neurological-medications.html':  'note_neuro_1',
    'cranial-nerves.html':             'note_neuro_2',
    'stroke.html':                     'note_neuro_3',
    'seizures-and-epilepsy.html':      'note_neuro_4',
    'increased-icp.html':              'note_neuro_5',
    'spinal-cord-injury.html':         'note_neuro_6',
    'multiple-sclerosis.html':         'note_neuro_7',
    "parkinson's-disease.html":        'note_neuro_8',
    'alzheimers-disease.html':         'note_neuro_9',
    'meningitis-and-encephalitis.html': 'note_neuro_10',
    // ── Infections ────────────────────────────────────────────────────────────
    'hiv-aids.html':           'note_inf_1',
    'sepsis.html':             'note_inf_2',
    'wound-infections.html':   'note_inf_3',
    // ── Musculoskeletal ───────────────────────────────────────────────────────
    'osteoporosis.html':       'note_msk_1',
    'fractures.html':          'note_msk_2',
    'arthritis.html':          'note_msk_3',
    // ── Reproductive / OB ─────────────────────────────────────────────────────
    'prenatal-care.html':         'note_ob_1',
    'labor-and-delivery.html':    'note_ob_2',
    'postpartum-care.html':       'note_ob_3',
    'newborn-care.html':          'note_ob_4',
    // ── Pediatrics ────────────────────────────────────────────────────────────
    'pediatric-growth.html':       'note_ped_1',
    'pediatric-medications.html':  'note_ped_2',
    // ── Pharmacology ──────────────────────────────────────────────────────────
    'drug-classes.html':        'note_pharm_1',
    'pain-medications.html':    'note_pharm_2',
    'antibiotics.html':         'note_pharm_3',
    // ── Cancer / Oncology ─────────────────────────────────────────────────────
    'cancer-nursing.html':     'note_onco_1',
    'chemotherapy.html':       'note_onco_2',
    // ── Eye Disorders / EENT ──────────────────────────────────────────────────
    'eye-disorders.html':      'note_eye_1',
    'hearing-disorders.html':  'note_eent_1',
    // ── Burns & Skin ──────────────────────────────────────────────────────────
    'burns.html':              'note_burns_1',
    // ── Mental Health ─────────────────────────────────────────────────────────
    'anxiety-disorders.html':   'note_mh_1',
    'depression.html':          'note_mh_2',
    'schizophrenia.html':       'note_mh_3',
    // ── Medical Terminology ───────────────────────────────────────────────────
    'medical-terminology.html': 'note_medterm_1',
  };

  /**
   * Derive the canonical note_id for the current page.
   * Matches by lower-cased filename only (ignores folder path).
   */
  function resolveNoteId() {
    var path = window.location.pathname;
    // Decode URL-encoded characters (%20 etc.)
    try { path = decodeURIComponent(path); } catch (e) {}
    // Grab just the filename (everything after the last '/')
    var filename = path.split('/').pop().toLowerCase();
    return NOTE_ID_MAP[filename] || null;
  }

  // ─── Main guard logic ────────────────────────────────────────────────────────

  async function runGuard() {
    var prefix = jsPrefix();

    // Step 1: Check login
    var isLoggedIn = store('isLoggedIn') === 'true';
    var isAdmin    = store('isAdmin')    === 'true';

    if (!isLoggedIn && !isAdmin) {
      redirect(prefix + 'login.html');
      return;
    }

    // Step 2: Admins bypass publish check
    if (isAdmin) {
      reveal();
      return;
    }

    // Step 3: Resolve student ID
    var studentId = store('studentRecordId');
    if (!studentId) {
      // No student ID — can't verify publish status → send back to hub
      redirect(prefix + 'hub.html?blocked=noid');
      return;
    }

    // Step 4: Resolve this note's ID
    var noteId = resolveNoteId();
    if (!noteId) {
      // Unknown note — fail open for unregistered files so admin tools still work
      reveal();
      return;
    }

    // Step 5: Check Supabase published_notes
    try {
      // Load Supabase client lazily (already on page if hub opened it, but
      // direct URL access won't have it — load it ourselves)
      if (typeof window.supabase === 'undefined' || typeof window.supabase.createClient === 'undefined') {
        await loadScript(prefix + 'js/supabase.min.js');
        await loadScript(prefix + 'js/supabase-config.js');
      }

      var db;
      if (typeof initSupabase === 'function') {
        db = initSupabase();
      } else if (typeof window.supabase !== 'undefined' && typeof window.supabase.createClient === 'function') {
        db = window.supabase.createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);
      } else {
        throw new Error('Supabase client not available');
      }

      var result = await db
        .from('published_notes')
        .select('id')
        .eq('student_id', studentId)
        .eq('note_id', noteId)
        .maybeSingle();

      if (result.error) {
        throw result.error;
      }

      if (!result.data) {
        // Note exists but is NOT published to this student
        redirect(prefix + 'hub.html?blocked=1');
        return;
      }

      // ✅ All checks pass — reveal the page
      reveal();

    } catch (err) {
      // Network error or Supabase unavailable — fail closed
      console.error('[note-guard] Access check failed:', err);
      redirect(prefix + 'hub.html?blocked=error');
    }
  }

  // ─── Bootstrap ───────────────────────────────────────────────────────────────

  // Safety net: if the guard hasn't resolved within 8 seconds, reveal the body
  // so users are never permanently stuck on a white screen due to a network error.
  var _safetyTimer = setTimeout(function () {
    console.warn('[note-guard] Safety timeout — revealing body');
    reveal();
  }, 8000);

  async function runGuardSafe() {
    try {
      await runGuard();
    } catch (e) {
      // Only re-throw redirect errors; real errors → reveal body
      if (e && e.message && e.message.indexOf('ACNHS: redirecting') === 0) {
        throw e;
      }
      console.error('[note-guard] Unexpected error:', e);
      reveal();
    } finally {
      clearTimeout(_safetyTimer);
    }
  }

  // Kick off guard immediately. Body is already hidden by inline style
  // (injected by inject-note-guard.py). Run as soon as the script executes.
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', runGuardSafe);
  } else {
    runGuardSafe();
  }

})();
