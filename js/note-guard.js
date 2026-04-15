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
    'fundamentals-nursing-nclex.html':                'note_1',
    'informed-consent-nursing.html':                  'note_2',
    'scope-of-practice-nursing.html':                 'note_3',
    'delegation-nursing-nclex.html':                  'note_4',
    'family-dynamics-nursing.html':                   'note_5',
    'maslows-hierarchy-nursing.html':                 'note_6',
    'sbar-communication-nursing.html':                'note_7',
    'precautions-nursing.html':                       'note_8',
    'vital-signs-interpretation-nursing.html':        'note_9',
    'physical-exam-bowel-sounds-nursing.html':        'note_10',
    'physical-assessment-nursing.html':               'note_11',
    'head-to-toe-assessment-nursing.html':            'note_12',
    'nursing-diagnosis-nclex.html':                   'note_13',
    'documentation-informatics-nursing.html':         'note_14',
    'client-positioning-nursing.html':                'note_15',
    'tube-care-nursing.html':                         'note_16',
    'blood-products-administration-nursing.html':     'note_17',
    'amputation-nursing.html':                        'note_18',
    'nursing-calculations-nclex.html':                'note_19',
    'bmi-calculation-nursing.html':                   'note_20',
    'complementary-alternative-medicine-nursing.html': 'note_21',
    'emergency-triage-tag-colors-nursing.html':       'note_22',
    'hygiene-grooming-nursing-nclex.html':            'note_23',
    'elimination-intake-output-nursing.html':         'note_24',
    'nutrition-feeding-nursing-nclex.html':           'note_25',
    'oxygenation-basics-nursing-nclex.html':          'note_26',
    'pain-assessment-nursing-nclex.html':             'note_27',
    'skin-integrity-pressure-injuries-nclex.html':    'note_28',
    'sleep-sensory-needs-nclex.html':                 'note_29',
    'heart-structure-and-circulation.html':           'note_cv_1',
    'vital-signs.html':                               'note_cv_2',
    'pulses.html':                                    'note_cv_3',
    'hypertension-hypotension-co-sv.html':            'note_cv_4',
    'heart-attack-heart-failure-cardiac-arrest.html': 'note_cv_5',
    'right-left-heart-failure.html':                  'note_cv_6',
    'ischemic-heart-disease.html':                    'note_cv_7',
    'ekg.html':                                       'note_cv_8',
    'pacemakers-and-icds.html':                       'note_cv_9',
    'cpr.html':                                       'note_cv_10',
    'cabg-and-pci.html':                              'note_cv_11',
    'cardiomyopathy.html':                            'note_cv_12',
    'pericarditis.html':                              'note_cv_13',
    'infective-endocarditis.html':                    'note_cv_14',
    'cardiac-tamponade.html':                         'note_cv_15',
    'shock-management.html':                          'note_cv_16',
    'pvd-pad-dvt.html':                               'note_cv_17',
    'blood-vessels-and-lymphs.html':                  'note_cv_19',
    'iv-gauges-and-their-uses.html':                  'note_cv_20',
    'anticoagulants.html':                            'note_cv_21',
    'cardiac-biomarkers.html':                        'note_cv_22',
    'cardiovascular-medications.html':                'note_cv_23',
    'respiratory-medications.html':                   'note_resp_1',
    'incentive-spirometry-pulmonary-hygiene.html':    'note_resp_2',
    'pleural-effusion.html':                          'note_resp_3',
    'tracheostomy.html':                              'note_resp_4',
    'sleep-apnea.html':                               'note_resp_5',
    'physiology-of-breathing.html':                   'note_resp_6',
    'copd.html':                                      'note_resp_7',
    'chronic-bronchitis.html':                        'note_resp_8',
    'asthma.html':                                    'note_resp_9',
    'emphysema.html':                                 'note_resp_10',
    'pneumonia.html':                                 'note_resp_11',
    'tuberculosis.html':                              'note_resp_12',
    'hemothorax-and-pneumothorax.html':               'note_resp_13',
    'mask-types-and-respiratory-system.html':         'note_resp_14',
    'pulmonary-embolism.html':                        'note_resp_15',
    'ards.html':                                      'note_resp_16',
    'diabetes-mellitus.html':                         'note_endo_1',
    'insulin-patch.html':                             'note_endo_2',
    'insulin-storage-and-checking.html':              'note_endo_3',
    'insulin.html':                                   'note_endo_4',
    'mixing-of-insulin-guidelines.html':              'note_endo_5',
    'metformin.html':                                 'note_endo_6',
    'endocrine-medications.html':                     'note_endo_7',
    'thyroid-gland-and-hormones.html':                'note_endo_8',
    'thyroid-gland.html':                             'note_endo_9',
    'parathyroid-disorders.html':                     'note_endo_10',
    'diabetes-insipidus-and-siadh.html':              'note_endo_11',
    'adrenal-gland-ad-and-cd.html':                   'note_endo_12',
    'dka-and-hhns.html':                              'note_endo_13',
    'ng-tube-and-tpn.html':                           'note_gi_1',
    'vitamins-and-minerals.html':                     'note_gi_2',
    'digestive-system.html':                          'note_gi_3',
    'dumping-syndrome.html':                          'note_gi_4',
    'gastrointestinal-medications.html':              'note_gi_5',
    'roux-en-y-gastric-bypass.html':                  'note_gi_6',
    'physical-examination-sounds.html':               'note_gi_7',
    'liver-cirrhosis.html':                           'note_gi_8',
    'lactose-intolerance.html':                       'note_gi_9',
    'vegan-vegetarian-diets.html':                    'note_gi_10',
    'peritonitis-and-sepsis.html':                    'note_gi_11',
    'lead-poisoning.html':                            'note_gi_12',
    'botulism.html':                                  'note_gi_13',
    'abdominal-quadrants.html':                       'note_gi_14',
    'gastroesophageal-issues.html':                   'note_gi_15',
    'central-line-vs-picc-line.html':                 'note_gi_16',
    'colonoscopy.html':                               'note_gi_17',
    'physical-exam-and-bowel-sounds.html':            'note_gi_18',
    'portal-vein.html':                               'note_gi_19',
    'colostomy.html':                                 'note_gi_20',
    'b-vitamins.html':                                'note_gi_21',
    'metabolic-syndrome.html':                        'note_gi_22',
    'phenylketonuria-pku.html':                       'note_gi_23',
    'celiac-disease.html':                            'note_gi_24',
    'gerd.html':                                      'note_gi_25',
    'pud-and-gastritis.html':                         'note_gi_26',
    'gastric-and-peptic-ulcers.html':                 'note_gi_27',
    'cholecystitis-and-cholelithiasis.html':          'note_gi_28',
    'pancreatitis.html':                              'note_gi_29',
    'alcoholism.html':                                'note_gi_30',
    'pyloric-stenosis.html':                          'note_gi_31',
    'intussusception.html':                           'note_gi_32',
    'hirschsprung-disease.html':                      'note_gi_33',
    'ulcerative-colitis.html':                        'note_gi_34',
    'crohns-disease.html':                            'note_gi_35',
    'irritable-bowel-syndrome.html':                  'note_gi_36',
    'diverticulosis-and-diverticulitis.html':         'note_gi_37',
    'sbo-vs-lbo.html':                                'note_gi_38',
    'lower-gi-obstruction.html':                      'note_gi_39',
    'appendicitis.html':                              'note_gi_40',
    'cystic-fibrosis.html':                           'note_gi_41',
    'epiglottitis.html':                              'note_gi_42',
    'pheochromocytoma.html':                          'note_renal_1',
    'urinary-tract-infections.html':                  'note_renal_2',
    'urine-sample-collection.html':                   'note_renal_3',
    'pyelonephritis.html':                            'note_renal_4',
    'wilms-tumor.html':                               'note_renal_5',
    'glomerulonephritis.html':                        'note_renal_6',
    'hemolytic-uremic-syndrome.html':                 'note_renal_7',
    'nephrotic-syndrome.html':                        'note_renal_8',
    'polycystic-kidney-disease.html':                 'note_renal_9',
    'renal-urinary-medications.html':                 'note_renal_10',
    'urinary-catheters-and-cbi.html':                 'note_renal_11',
    'dialysis-disequilibrium-syndrome.html':          'note_renal_12',
    'urinary-incontinence.html':                      'note_renal_13',
    'kidney-anatomy.html':                            'note_renal_14',
    'cystitis.html':                                  'note_renal_15',
    'renal-calculi.html':                             'note_renal_16',
    'acute-kidney-injury.html':                       'note_renal_17',
    'chronic-kidney-disease.html':                    'note_renal_18',
    'dialysis.html':                                  'note_renal_19',
    'iv-fluids-and-medications.html':                 'note_fen_1',
    'electrolyte-imbalances.html':                    'note_fen_2',
    'iv-therapy-and-complications.html':              'note_fen_3',
    'acid-base-balance-and-abgs.html':                'note_fen_4',
    'menstrual-cycle-and-hormones.html':              'note_mh_1',
    'reproductive-anatomy-and-fertilization.html':    'note_mh_2',
    'organ-disorders-cancer-womens-health.html':      'note_mh_3',
    'naegeles-rule-antepartum-complications.html':    'note_mh_4',
    'gdm-and-gestational-hypertension.html':          'note_mh_5',
    'intrapartum-care-leopold-veal-chop.html':        'note_mh_6',
    'placenta-previa-and-abruption.html':             'note_mh_7',
    'postpartum-and-newborn-care.html':               'note_mh_8',
    'torch-infections-and-medications.html':          'note_mh_9',
    'medical-terminology.html':                       'note_mt_1',
    'lupus.html':                                     'note_auto_1',
    'autoimmune-diseases.html':                       'note_auto_2',
    'autoimmune-medications.html':                    'note_auto_3',
    'gbs.html':                                       'note_auto_4',
    'myasthenia-gravis.html':                         'note_auto_5',
    'immunodeficiency.html':                          'note_auto_6',
    'rheumatoid-arthritis.html':                      'note_auto_7',
    'scleroderma.html':                               'note_neuro_1',
    'orientation.html':                               'note_neuro_2',
    'clonus.html':                                    'note_neuro_3',
    '12-cranial-nerves.html':                         'note_neuro_4',
    'autonomic-nervous-system.html':                  'note_neuro_5',
    'cerebral-palsy.html':                            'note_neuro_6',
    'glasgow-coma-scale.html':                        'note_neuro_7',
    'neuro-imaging-diagnostics.html':                 'note_neuro_8',
    'spinal-cord-injury.html':                        'note_neuro_9',
    'stroke.html':                                    'note_neuro_10',
    'sympathetic-vs-parasympathetic.html':            'note_neuro_11',
    'seizure-disorders.html':                         'note_neuro_12',
    'increased-icp.html':                             'note_neuro_13',
    'cerebral-aneurysms.html':                        'note_neuro_14',
    'multiple-sclerosis.html':                        'note_neuro_15',
    'parkinsons-disease.html':                        'note_neuro_16',
    'spinal-cord-injury-full.html':                   'note_neuro_17',
    'vertigo-menieres.html':                          'note_neuro_18',
    'encephalitis.html':                              'note_neuro_19',
    'tbi-concussion.html':                            'note_neuro_20',
    'brain-tumors.html':                              'note_neuro_21',
    'trigeminal-neuralgia.html':                      'note_neuro_22',
    'hydrocephalus.html':                             'note_neuro_23',
    'autonomic-dysreflexia.html':                     'note_neuro_24',
    'chickenpox-varicella.html':                      'note_infect_1',
    'lyme-disease.html':                              'note_infect_2',
    'anthrax.html':                                   'note_infect_3',
    'c-difficile.html':                               'note_infect_4',
    'hepatitis.html':                                 'note_infect_5',
    'infections-overview.html':                       'note_infect_6',
    'mumps.html':                                     'note_infect_7',
    'rubella.html':                                   'note_infect_8',
    'rubeola-measles.html':                           'note_infect_9',
    'meningitis.html':                                'note_infect_10',
    'hiv.html':                                       'note_infect_11',
    'sars-covid.html':                                'note_infect_12',
    'infections-master-overview.html':                'note_infect_13',
    'general-pharmacology.html':                      'note_pharm_1',
    'medication-calculation-administration.html':     'note_pharm_2',
    'beta-blockers.html':                             'note_pharm_3',
    'calcium-channel-blockers.html':                  'note_pharm_4',
    'high-alert-medications.html':                    'note_pharm_5',
    'mental-health-medications.html':                 'note_pharm_6',
    'drug-dosage-math.html':                          'note_pharm_7',
    'ace-inhibitors.html':                            'note_pharm_8',
    'arbs.html':                                      'note_pharm_9',
    'respiratory-medications.html':                   'note_pharm_10',
    'gastrointestinal-medications.html':              'note_pharm_11',
    'eent-medications.html':                          'note_pharm_12',
    'pediatric-medications.html':                     'note_pharm_13',
    'endocrine-medications.html':                     'note_pharm_14',
    'emergency-shock-surgical-medications.html':      'note_pharm_15',
    'nursing-common-medications.html':                'note_pharm_16',
    'renal-urinary-medications.html':                 'note_pharm_17',
    'fluids-electrolytes-iv-therapy.html':            'note_pharm_18',
    'burns-dermatology-medications.html':             'note_pharm_19',
    'maternal-health-medications.html':               'note_pharm_20',
    'infectious-diseases-medications.html':           'note_pharm_21',
    'autoimmune-inflammatory-medications.html':       'note_pharm_22',
    'cancer-overview.html':                           'note_cancer_1',
    'tumor-grading.html':                             'note_cancer_2',
    'all-cancer-overview.html':                       'note_cancer_3',
    'hematological-cancers.html':                     'note_cancer_4',
    'gi-cancers.html':                                'note_cancer_5',
    'large-organ-cancers.html':                       'note_cancer_6',
    'sclc.html':                                      'note_cancer_7',
    'female-reproductive-cancers.html':               'note_cancer_8',
    'male-reproductive-cancers.html':                 'note_cancer_9',
    'skin-cancer.html':                               'note_cancer_10',
    'kawasaki-disease.html':                          'note_ped_1',
    'amblyopia.html':                                 'note_ped_2',
    'congenital-cataracts.html':                      'note_ped_3',
    'pediatric-conjunctivitis.html':                  'note_ped_4',
    'retinopathy-of-prematurity.html':                'note_ped_5',
    'strabismus.html':                                'note_ped_6',
    'pediatric-developmental-stages.html':            'note_ped_7',
    'pediatric-medications.html':                     'note_ped_8',
    'rickets.html':                                   'note_ped_9',
    'pediatric-ortho.html':                           'note_ped_10',
    'omphalocele.html':                               'note_ped_11',
    'pediatric-medication-administration.html':       'note_ped_12',
    'care-of-the-newborn.html':                       'note_ped_13',
    'pediatric-respiratory-disorders.html':           'note_ped_14',
    'pediatric-cardiovascular-nursing.html':          'note_ped_15',
    'pediatric-neuro-psych-disorders.html':           'note_ped_16',
    'pediatric-diabetes.html':                        'note_ped_17',
    'pediatric-fever-dehydration-pku.html':           'note_ped_18',
    'pediatric-gi-disorders.html':                    'note_ped_19',
    'pediatric-hematological-oncological.html':       'note_ped_20',
    'pediatric-infectious-diseases.html':             'note_ped_21',
    'pediatric-renal-gu.html':                        'note_ped_22',
    'pediatric-musculoskeletal.html':                 'note_ped_23',
    'pediatric-integumentary.html':                   'note_ped_24',
    'pediatric-eye-ear-throat.html':                  'note_ped_25',
    'pediatric-cognitive-neuro-psych.html':           'note_ped_26',
    'reproductive-anatomy.html':                      'note_rep_1',
    'female-reproductive-cycle.html':                 'note_rep_2',
    'contraception-family-planning.html':             'note_rep_3',
    'sti-std.html':                                   'note_rep_4',
    'reproductive-complications.html':                'note_rep_5',
    'infertility.html':                               'note_rep_6',
    'bph.html':                                       'note_rep_7',
    'turp-prostatectomy.html':                        'note_rep_8',
    'priapism.html':                                  'note_rep_9',
    'sexual-health-nursing.html':                     'note_rep_10',
    'reproductive-health-overview.html':              'note_rep_11',
    'burns.html':                                     'note_burns_1',
    'burns-dermatology-meds.html':                    'note_burns_2',
    'common-skin-disorders.html':                     'note_burns_3',
    'skin-conditions-overview.html':                  'note_burns_4',
    'dermatitis-cellulitis.html':                     'note_burns_5',
    'dvt-vs-cellulitis.html':                         'note_burns_6',
    'periorbital-cellulitis.html':                    'note_burns_7',
    'pressure-ulcers.html':                           'note_burns_8',
    'burns-skin-overview.html':                       'note_burns_9',
    'eye-anatomy.html':                               'note_eye_1',
    'glaucoma.html':                                  'note_eye_2',
    'cataracts.html':                                 'note_eye_3',
    'retinal-detachment.html':                        'note_eye_4',
    'macular-degeneration.html':                      'note_eye_5',
    'diabetic-retinopathy.html':                      'note_eye_6',
    'conjunctivitis.html':                            'note_eye_7',
    'conjunctivitis-vs-keratitis.html':               'note_eye_8',
    'vision-disorders.html':                          'note_eye_9',
    'eye-medications.html':                           'note_eye_10',
    'eye-disorders-overview.html':                    'note_eye_11',
    'fractures.html':                                 'note_msk_1',
    'osteomyelitis.html':                             'note_msk_2',
    'musculoskeletal-conditions.html':                'note_msk_3',
    'sprains-strains-dislocations.html':              'note_msk_4',
    'connective-tissue-disorders.html':               'note_msk_5',
    'mobility-assistive-devices.html':                'note_msk_6',
    'intercostal-spaces.html':                        'note_msk_7',
    'always-prioritize.html':                         'note_msk_8',
    'msk-overview.html':                              'note_msk_9',
    'abuse-violence.html':                            'note_psa_1',
    'aging-changes.html':                             'note_psa_2',
    'end-of-life-care.html':                          'note_psa_3',
    'psychosocial-overview.html':                     'note_psa_4',
    'eent-upper-airway.html':                         'note_eent_1',
    'eent-medications.html':                          'note_eent_2',
    'eent-disorders-overview.html':                   'note_eent_3',
    'ear-disorders.html':                             'note_eent_4',
    'nose-disorders.html':                            'note_eent_5',
    'throat-upper-airway.html':                       'note_eent_6',
    'gingivitis.html':                                'note_eent_7',
    'eent-master-overview.html':                      'note_eent_8',
    'medsurg-pharmacology.html':                      'note_medsurg_1',
    'orthopedic-postop-care.html':                    'note_medsurg_2',
    'emergency-shock-surgical-meds.html':             'note_medsurg_3',
    'medsurg-priorities.html':                        'note_medsurg_4',
    'postoperative-surgical-emergencies.html':        'note_medsurg_5',
    'preoperative-postoperative-care.html':           'note_medsurg_6',
    'shock-management-emergency-care.html':           'note_medsurg_7',
    'medsurg-master-overview.html':                   'note_medsurg_8',
    'alzheimers-disease.html':                        'note_psych_1',
    'anxiety-disorders.html':                         'note_psych_2',
    'bipolar-personality-disorders.html':             'note_psych_3',
    'cognitive-impairments-adhd.html':                'note_psych_4',
    'core-ethical-principles.html':                   'note_psych_5',
    'defense-mechanisms.html':                        'note_psych_6',
    'delirium-depression-dementia.html':              'note_psych_7',
    'ect.html':                                       'note_psych_8',
    'eating-disorders.html':                          'note_psych_9',
    'family-systems-theory.html':                     'note_psych_10',
    'guided-imagery.html':                            'note_psych_11',
    'legal-ethical-safety.html':                      'note_psych_12',
    'mental-health-medications.html':                 'note_psych_13',
    'mental-health-overview.html':                    'note_psych_14',
    'parenting-styles.html':                          'note_psych_15',
    'personality-disorders.html':                     'note_psych_16',
    'schizophrenia.html':                             'note_psych_17',
    'serotonin-syndrome.html':                        'note_psych_18',
    'substance-abuse-addiction.html':                 'note_psych_19',
    'suicide-risk-assessment.html':                   'note_psych_20',
    'therapeutic-relationships.html':                 'note_psych_21',
    'therapeutic-relationships-full.html':            'note_psych_22',
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
