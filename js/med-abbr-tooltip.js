/**
 * ACNHS Medical Abbreviation Tooltip System
 * ==========================================
 * Automatically scans text nodes for medical abbreviations and wraps them
 * with an interactive tooltip showing the full term.
 *
 * Usage: include this script (and med-abbr-tooltip.css) on any page.
 *        Call window.ACNHS_Abbr.init() or it auto-runs on DOMContentLoaded.
 *        For dynamically-injected HTML call window.ACNHS_Abbr.scan(rootElement).
 */

(function (global) {
  'use strict';

  /* ─────────────────────────────────────────────
     CENTRALIZED ABBREVIATION DICTIONARY
     Add / edit entries here – changes apply site-wide.
  ───────────────────────────────────────────── */
  const ABBR_DICT = {
    // ── Vital Signs & Monitoring ──────────────────────────────────────
    BP:      'Blood Pressure',
    HR:      'Heart Rate',
    RR:      'Respiratory Rate',
    SpO2:    'Oxygen Saturation (Pulse Oximetry)',
    O2:      'Oxygen',
    CO2:     'Carbon Dioxide',
    MAP:     'Mean Arterial Pressure',
    CVP:     'Central Venous Pressure',
    ICP:     'Intracranial Pressure',
    GCS:     'Glasgow Coma Scale',
    LOC:     'Level of Consciousness',
    UO:      'Urine Output',
    I_O:     'Intake and Output',
    'I&O':   'Intake and Output',
    Temp:    'Temperature',
    BMI:     'Body Mass Index',
    IBW:     'Ideal Body Weight',

    // ── Routes of Administration ──────────────────────────────────────
    IV:      'Intravenous',
    IVP:     'Intravenous Push',
    IVPB:    'Intravenous Piggyback',
    IM:      'Intramuscular',
    SQ:      'Subcutaneous',
    SC:      'Subcutaneous',
    SL:      'Sublingual',
    PO:      'Per Os (By Mouth)',
    NGT:     'Nasogastric Tube',
    NG:      'Nasogastric',
    GT:      'Gastrostomy Tube',
    PR:      'Per Rectum',
    TOP:     'Topical',
    INHALED: 'Inhaled (route of administration)',

    // ── Frequency / Timing ────────────────────────────────────────────
    PRN:     'Pro Re Nata (As Needed)',
    QD:      'Every Day',
    QID:     'Four Times a Day',
    TID:     'Three Times a Day',
    BID:     'Twice a Day',
    QHS:     'Every Bedtime',
    Q2H:     'Every 2 Hours',
    Q4H:     'Every 4 Hours',
    Q6H:     'Every 6 Hours',
    Q8H:     'Every 8 Hours',
    Q12H:    'Every 12 Hours',
    STAT:    'Immediately',
    AC:      'Before Meals',
    PC:      'After Meals',
    NPO:     'Nil Per Os (Nothing by Mouth)',
    HS:      'Hour of Sleep / Bedtime',

    // ── Cardiology ───────────────────────────────────────────────────
    MI:      'Myocardial Infarction',
    STEMI:   'ST-Elevation Myocardial Infarction',
    NSTEMI:  'Non-ST-Elevation Myocardial Infarction',
    ACS:     'Acute Coronary Syndrome',
    CAD:     'Coronary Artery Disease',
    CHF:     'Congestive Heart Failure',
    HF:      'Heart Failure',
    HFrEF:   'Heart Failure with Reduced Ejection Fraction',
    HFpEF:   'Heart Failure with Preserved Ejection Fraction',
    EF:      'Ejection Fraction',
    AF:      'Atrial Fibrillation',
    AFib:    'Atrial Fibrillation',
    AFL:     'Atrial Flutter',
    SVT:     'Supraventricular Tachycardia',
    VT:      'Ventricular Tachycardia',
    VF:      'Ventricular Fibrillation',
    PVC:     'Premature Ventricular Contraction',
    PAC:     'Premature Atrial Contraction',
    AV:      'Atrioventricular',
    SA:      'Sinoatrial',
    PEA:     'Pulseless Electrical Activity',
    ACLS:    'Advanced Cardiac Life Support',
    BLS:     'Basic Life Support',
    CPR:     'Cardiopulmonary Resuscitation',
    AED:     'Automated External Defibrillator',
    CABG:    'Coronary Artery Bypass Graft',
    PCI:     'Percutaneous Coronary Intervention',
    PTCA:    'Percutaneous Transluminal Coronary Angioplasty',
    EKG:     'Electrocardiogram',
    ECG:     'Electrocardiogram',
    ECHO:    'Echocardiogram',
    HTN:     'Hypertension',
    SBP:     'Systolic Blood Pressure',
    DBP:     'Diastolic Blood Pressure',
    DVT:     'Deep Vein Thrombosis',
    PE:      'Pulmonary Embolism',
    PAD:     'Peripheral Arterial Disease',
    AAA:     'Abdominal Aortic Aneurysm',
    AS:      'Aortic Stenosis',
    MR:      'Mitral Regurgitation',
    MS:      'Mitral Stenosis',

    // ── Pulmonology ──────────────────────────────────────────────────
    COPD:    'Chronic Obstructive Pulmonary Disease',
    ARDS:    'Acute Respiratory Distress Syndrome',
    TB:      'Tuberculosis',
    PNA:     'Pneumonia',
    SOB:     'Shortness of Breath',
    DOE:     'Dyspnea on Exertion',
    FVC:     'Forced Vital Capacity',
    FEV1:    'Forced Expiratory Volume in 1 Second',
    PEEP:    'Positive End-Expiratory Pressure',
    CPAP:    'Continuous Positive Airway Pressure',
    BiPAP:   'Bilevel Positive Airway Pressure',
    MV:      'Mechanical Ventilation',
    ETT:     'Endotracheal Tube',
    ABG:     'Arterial Blood Gas',
    PFT:     'Pulmonary Function Test',
    CXR:     'Chest X-Ray',
    CT:      'Computed Tomography',

    // ── Neurology ───────────────────────────────────────────────────
    CVA:     'Cerebrovascular Accident (Stroke)',
    TIA:     'Transient Ischemic Attack',
    SAH:     'Subarachnoid Hemorrhage',
    ICH:     'Intracranial Hemorrhage',
    SDH:     'Subdural Hematoma',
    EDH:     'Epidural Hematoma',
    MS_neuro:'Multiple Sclerosis',
    ALS:     'Amyotrophic Lateral Sclerosis',
    PD:      'Parkinson\'s Disease',
    AD:      'Alzheimer\'s Disease',
    EEG:     'Electroencephalogram',
    MRI:     'Magnetic Resonance Imaging',
    LP:      'Lumbar Puncture',
    CSF:     'Cerebrospinal Fluid',
    CN:      'Cranial Nerve',
    CNS:     'Central Nervous System',
    PNS:     'Peripheral Nervous System',
    ICP_neuro:'Intracranial Pressure',
    LOA:     'Loss of Awareness',

    // ── Endocrinology ───────────────────────────────────────────────
    DM:      'Diabetes Mellitus',
    DM1:     'Type 1 Diabetes Mellitus',
    DM2:     'Type 2 Diabetes Mellitus',
    T1DM:    'Type 1 Diabetes Mellitus',
    T2DM:    'Type 2 Diabetes Mellitus',
    DKA:     'Diabetic Ketoacidosis',
    HHS:     'Hyperosmolar Hyperglycemic State',
    HHNS:    'Hyperosmolar Hyperglycemic Nonketotic Syndrome',
    BS:      'Blood Sugar',
    BG:      'Blood Glucose',
    FBG:     'Fasting Blood Glucose',
    HbA1c:   'Glycated Hemoglobin (Hemoglobin A1c)',
    A1C:     'Hemoglobin A1c',
    TSH:     'Thyroid-Stimulating Hormone',
    T3:      'Triiodothyronine',
    T4:      'Thyroxine',
    PTH:     'Parathyroid Hormone',
    GH:      'Growth Hormone',
    ACTH:    'Adrenocorticotropic Hormone',
    ADH:     'Antidiuretic Hormone',
    SIADH:   'Syndrome of Inappropriate Antidiuretic Hormone',
    DI:      'Diabetes Insipidus',
    IGF:     'Insulin-like Growth Factor',

    // ── Nephrology ──────────────────────────────────────────────────
    AKI:     'Acute Kidney Injury',
    CKD:     'Chronic Kidney Disease',
    ESRD:    'End-Stage Renal Disease',
    ARF:     'Acute Renal Failure',
    CRF:     'Chronic Renal Failure',
    HD:      'Hemodialysis',
    PD_renal:'Peritoneal Dialysis',
    BUN:     'Blood Urea Nitrogen',
    Cr:      'Creatinine',
    GFR:     'Glomerular Filtration Rate',
    eGFR:    'Estimated Glomerular Filtration Rate',
    UA:      'Urinalysis',
    UTI:     'Urinary Tract Infection',
    ATN:     'Acute Tubular Necrosis',
    PKD:     'Polycystic Kidney Disease',

    // ── Gastroenterology ────────────────────────────────────────────
    GI:      'Gastrointestinal',
    GERD:    'Gastroesophageal Reflux Disease',
    IBD:     'Inflammatory Bowel Disease',
    IBS:     'Irritable Bowel Syndrome',
    UC:      'Ulcerative Colitis',
    CD:      'Crohn\'s Disease',
    LFT:     'Liver Function Test',
    ALT:     'Alanine Aminotransferase',
    AST:     'Aspartate Aminotransferase',
    ALP:     'Alkaline Phosphatase',
    GGT:     'Gamma-Glutamyl Transferase',
    PUD:     'Peptic Ulcer Disease',
    UGIB:    'Upper Gastrointestinal Bleed',
    LGIB:    'Lower Gastrointestinal Bleed',
    NGT2:    'Nasogastric Tube',
    TPN:     'Total Parenteral Nutrition',
    PPN:     'Peripheral Parenteral Nutrition',
    NJ:      'Nasojejunal',
    NJT:     'Nasojejunal Tube',

    // ── Hematology / Oncology ────────────────────────────────────────
    CBC:     'Complete Blood Count',
    WBC:     'White Blood Cell',
    RBC:     'Red Blood Cell',
    Hgb:     'Hemoglobin',
    Hct:     'Hematocrit',
    MCV:     'Mean Corpuscular Volume',
    MCH:     'Mean Corpuscular Hemoglobin',
    MCHC:    'Mean Corpuscular Hemoglobin Concentration',
    PLT:     'Platelet Count',
    PT:      'Prothrombin Time',
    PTT:     'Partial Thromboplastin Time',
    aPTT:    'Activated Partial Thromboplastin Time',
    INR:     'International Normalized Ratio',
    ESR:     'Erythrocyte Sedimentation Rate',
    CRP:     'C-Reactive Protein',
    ANC:     'Absolute Neutrophil Count',
    ALL:     'Acute Lymphoblastic Leukemia',
    AML:     'Acute Myeloid Leukemia',
    CLL:     'Chronic Lymphocytic Leukemia',
    CML:     'Chronic Myeloid Leukemia',
    NHL:     'Non-Hodgkin Lymphoma',
    HL:      'Hodgkin Lymphoma',
    SCD:     'Sickle Cell Disease',
    DIC:     'Disseminated Intravascular Coagulation',
    PRBC:    'Packed Red Blood Cells',
    FFP:     'Fresh Frozen Plasma',
    EDTA:    'Ethylenediaminetetraacetic Acid (anticoagulant in lavender-top tubes)',
    SST:     'Serum Separator Tube (gold/red-top)',

    // ── Electrolytes & Chemistry ─────────────────────────────────────
    CMP:     'Comprehensive Metabolic Panel',
    BMP:     'Basic Metabolic Panel',
    Na:      'Sodium',
    K:       'Potassium',
    Cl:      'Chloride',
    HCO3:    'Bicarbonate',
    CO3:     'Bicarbonate',
    Ca:      'Calcium',
    Mg:      'Magnesium',
    Phos:    'Phosphorus',
    Glu:     'Glucose',
    Alb:     'Albumin',
    TP:      'Total Protein',

    // ── Infectious Disease ──────────────────────────────────────────
    HIV:     'Human Immunodeficiency Virus',
    AIDS:    'Acquired Immunodeficiency Syndrome',
    MRSA:    'Methicillin-Resistant Staphylococcus aureus',
    VRSA:    'Vancomycin-Resistant Staphylococcus aureus',
    VRE:     'Vancomycin-Resistant Enterococcus',
    C_diff:  'Clostridioides difficile',
    'C.diff': 'Clostridioides difficile',
    PPD:     'Purified Protein Derivative (TB Skin Test)',
    IGRA:    'Interferon-Gamma Release Assay (TB Blood Test)',
    AFB:     'Acid-Fast Bacilli (TB smear test)',
    BCG:     'Bacillus Calmette-Guérin (TB vaccine)',
    TB:      'Tuberculosis',
    MDR:     'Multi-Drug Resistant',
    'MDR-TB': 'Multi-Drug Resistant Tuberculosis',
    INH:     'Isoniazid (anti-TB drug)',
    URI:     'Upper Respiratory Infection',
    LRTI:    'Lower Respiratory Tract Infection',
    SSI:     'Surgical Site Infection',
    SIRS:    'Systemic Inflammatory Response Syndrome',
    SEPSIS:  'Sepsis',
    COVID:   'Coronavirus Disease 2019',

    // ── Musculoskeletal ─────────────────────────────────────────────
    OA:      'Osteoarthritis',
    RA:      'Rheumatoid Arthritis',
    SLE:     'Systemic Lupus Erythematosus',
    AS_spine:'Ankylosing Spondylitis',
    ROM:     'Range of Motion',
    ORIF:    'Open Reduction Internal Fixation',
    THA:     'Total Hip Arthroplasty',
    TKA:     'Total Knee Arthroplasty',
    RICE:    'Rest, Ice, Compression, Elevation',
    PT_phys: 'Physical Therapy',
    OT:      'Occupational Therapy',
    BMD:     'Bone Mineral Density',
    DEXA:    'Dual-Energy X-ray Absorptiometry',

    // ── Obstetrics & Gynecology ──────────────────────────────────────
    OB:      'Obstetrics',
    GYN:     'Gynecology',
    OB_GYN:  'Obstetrics and Gynecology',
    LMP:     'Last Menstrual Period',
    EDD:     'Estimated Due Date',
    EGA:     'Estimated Gestational Age',

    CS:      'Cesarean Section',
    VBAC:    'Vaginal Birth After Cesarean',
    PIH:     'Pregnancy-Induced Hypertension',
    GDM:     'Gestational Diabetes Mellitus',
    PROM:    'Premature Rupture of Membranes',
    PPROM:   'Preterm Premature Rupture of Membranes',
    STI:     'Sexually Transmitted Infection',
    STD:     'Sexually Transmitted Disease',
    PID:     'Pelvic Inflammatory Disease',
    PCO:     'Polycystic Ovary',
    PCOS:    'Polycystic Ovary Syndrome',
    HPV:     'Human Papillomavirus',

    // ── Pediatrics ──────────────────────────────────────────────────
    NICU:    'Neonatal Intensive Care Unit',
    PICU:    'Pediatric Intensive Care Unit',
    SIDS:    'Sudden Infant Death Syndrome',
    RSV:     'Respiratory Syncytial Virus',
    PKU:     'Phenylketonuria',
    CF:      'Cystic Fibrosis',

    // ── Psychiatry / Mental Health ───────────────────────────────────
    MDD:     'Major Depressive Disorder',
    GAD:     'Generalized Anxiety Disorder',
    OCD:     'Obsessive-Compulsive Disorder',
    PTSD:    'Post-Traumatic Stress Disorder',
    ADHD:    'Attention-Deficit/Hyperactivity Disorder',
    ASD:     'Autism Spectrum Disorder',
    BPD:     'Borderline Personality Disorder',
    SUD:     'Substance Use Disorder',
    ECT:     'Electroconvulsive Therapy',
    SSRI:    'Selective Serotonin Reuptake Inhibitor',
    SNRI:    'Serotonin-Norepinephrine Reuptake Inhibitor',
    MAOI:    'Monoamine Oxidase Inhibitor',
    TCA:     'Tricyclic Antidepressant',

    // ── Pharmacology / Medications ───────────────────────────────────
    SE:      'Side Effects',
    ADR:     'Adverse Drug Reaction',
    AE:      'Adverse Effects',
    CI:      'Contraindication',
    MOA:     'Mechanism of Action',
    ACEi:    'ACE Inhibitor (Angiotensin-Converting Enzyme Inhibitor)',
    ARB:     'Angiotensin II Receptor Blocker',
    BB:      'Beta Blocker',
    CCB:     'Calcium Channel Blocker',
    ASA:     'Acetylsalicylic Acid (Aspirin)',
    NSAID:   'Non-Steroidal Anti-Inflammatory Drug',
    PCN:     'Penicillin',
    TMP_SMX: 'Trimethoprim-Sulfamethoxazole',
    LMWH:    'Low-Molecular-Weight Heparin',
    UFH:     'Unfractionated Heparin',
    GTN:     'Glyceryl Trinitrate (Nitroglycerin)',
    NTG:     'Nitroglycerin',
    epi:     'Epinephrine (Adrenaline)',
    Epi:     'Epinephrine (Adrenaline)',
    NE:      'Norepinephrine',
    Dopa:    'Dopamine',
    Dobu:    'Dobutamine',
    Lasix:   'Furosemide (Loop Diuretic)',
    MgSO4:   'Magnesium Sulfate',
    KCl:     'Potassium Chloride',
    NS:      'Normal Saline (0.9% NaCl)',
    LR:      'Lactated Ringer\'s Solution',
    D5W:     'Dextrose 5% in Water',
    D5NS:    'Dextrose 5% in Normal Saline',
    D10W:    'Dextrose 10% in Water',

    // ── Diagnostic / Imaging ─────────────────────────────────────────
    US:      'Ultrasound',
    XR:      'X-Ray',
    MRI2:    'Magnetic Resonance Imaging',
    PET:     'Positron Emission Tomography',
    ERCP:    'Endoscopic Retrograde Cholangiopancreatography',
    EGD:     'Esophagogastroduodenoscopy',
    EMG:     'Electromyography',
    NCS:     'Nerve Conduction Study',
    IVP:     'Intravenous Pyelogram',

    // ── Hospital / Clinical Settings ─────────────────────────────────
    ICU:     'Intensive Care Unit',
    CCU:     'Cardiac Care Unit',
    ED:      'Emergency Department',
    ER:      'Emergency Room',
    OR:      'Operating Room',
    PACU:    'Post-Anesthesia Care Unit',
    SNF:     'Skilled Nursing Facility',
    LTC:     'Long-Term Care',
    OPD:     'Outpatient Department',
    IPD:     'Inpatient Department',
    CPOE:    'Computerized Provider Order Entry',
    EHR:     'Electronic Health Record',
    EMR:     'Electronic Medical Record',
    MAR:     'Medication Administration Record',
    DNR:     'Do Not Resuscitate',
    DNI:     'Do Not Intubate',
    POA:     'Power of Attorney',
    ADL:     'Activities of Daily Living',
    IADL:    'Instrumental Activities of Daily Living',
    DC:      'Discharge',
    D_C:     'Discharge',
    Hx:      'History',
    PMH:     'Past Medical History',
    PSH:     'Past Surgical History',
    FH:      'Family History',
    SH:      'Social History',
    CC:      'Chief Complaint',
    HPI:     'History of Present Illness',
    ROS:     'Review of Systems',
    PE_exam: 'Physical Examination',
    HEENT:   'Head, Eyes, Ears, Nose, and Throat',
    PERRL:   'Pupils Equal, Round, Reactive to Light',
    PERRLA:  'Pupils Equal, Round, Reactive to Light and Accommodation',
    JVD:     'Jugular Venous Distension',
    S1:      'First Heart Sound',
    S2:      'Second Heart Sound',
    S3:      'Third Heart Sound (Gallop)',
    S4:      'Fourth Heart Sound (Gallop)',

    // ── Safety / Infection Control ───────────────────────────────────
    PPE:     'Personal Protective Equipment',
    HAI:     'Hospital-Acquired Infection',
    CAUTI:   'Catheter-Associated Urinary Tract Infection',
    CLABSI:  'Central Line-Associated Bloodstream Infection',
    VAP:     'Ventilator-Associated Pneumonia',
    BSI:     'Bloodstream Infection',
    AIIR:    'Airborne Infection Isolation Room',
    HOB:     'Head of Bed',
    ABCs:    'Airway, Breathing, Circulation',
    ABC:     'Airway, Breathing, Circulation',
    ABHR:    'Alcohol-Based Hand Rub',
    N95:     'N95 Respirator (filters ≥95% airborne particles)',
    C_DIFF:  'Clostridioides difficile',
    'C. diff': 'Clostridioides difficile',

    // ── Nutrition / Metabolic ────────────────────────────────────────
    BMR:     'Basal Metabolic Rate',
    REE:     'Resting Energy Expenditure',
    PEG:     'Percutaneous Endoscopic Gastrostomy',
    NG_tube: 'Nasogastric Tube',
    DBW:     'Desirable Body Weight',
    ABW:     'Adjusted Body Weight',

    // ── Pain / Scoring Scales ────────────────────────────────────────
    NRS:     'Numeric Rating Scale (Pain)',
    VAS:     'Visual Analog Scale',
    FACES:   'Wong-Baker FACES Pain Scale',
    CPOT:    'Critical-Care Pain Observation Tool',
    RASS:    'Richmond Agitation-Sedation Scale',
    CAM:     'Confusion Assessment Method',
    CAGE:    'Cut, Annoyed, Guilty, Eye-opener (Alcohol Screen)',

    // ── Surgical / Procedures ────────────────────────────────────────
    GA:      'General Anesthesia',
    LA:      'Local Anesthesia',
    RA_surg: 'Regional Anesthesia',
    Cx:      'Complication',
    POD:     'Postoperative Day',
    NPO_pre: 'Nothing by Mouth (Pre-op)',
    SICU:    'Surgical Intensive Care Unit',

    // ── Dermatology / Burns ──────────────────────────────────────────
    TBSA:    'Total Body Surface Area',
    BSA:     'Body Surface Area',
    Eschar:  'Dead Tissue from Burn',

    // ── Eye / EENT ──────────────────────────────────────────────────
    IOP:     'Intraocular Pressure',
    VA:      'Visual Acuity',
    OD:      'Right Eye (Oculus Dexter)',
    OS:      'Left Eye (Oculus Sinister)',
    OU:      'Both Eyes (Oculus Uterque)',
    ARMD:    'Age-Related Macular Degeneration',

    // ── Miscellaneous ───────────────────────────────────────────────
    NCLEX:   'National Council Licensure Examination',
    RN:      'Registered Nurse',
    LPN:     'Licensed Practical Nurse',
    LVN:     'Licensed Vocational Nurse',
    CNA:     'Certified Nursing Assistant',
    PCT:     'Patient Care Technician',
    UAP:     'Unlicensed Assistive Personnel',
    HCP:     'Healthcare Provider',
    NP:      'Nurse Practitioner',
    APRN:    'Advanced Practice Registered Nurse',
    CNS:     'Clinical Nurse Specialist',
    PA:      'Physician Assistant',
    MD:      'Medical Doctor',
    DO:      'Doctor of Osteopathic Medicine',
    PhD:     'Doctor of Philosophy',
    BSN:     'Bachelor of Science in Nursing',
    MSN:     'Master of Science in Nursing',
    ADLs:    'Activities of Daily Living',
    ADL:     'Activities of Daily Living',
    IADL:    'Instrumental Activities of Daily Living',
    ADPIE:   'Assess, Diagnose, Plan, Implement, Evaluate (Nursing Process)',
    AEB:     'As Evidenced By',
    PES:     'Problem, Etiology, Signs & Symptoms (Nursing Diagnosis Format)',
    NANDA:   'North American Nursing Diagnosis Association',
    SBAR:    'Situation, Background, Assessment, Recommendation',
    ISBAR:   'Identify, Situation, Background, Assessment, Recommendation',
    EBP:     'Evidence-Based Practice',
    BCMA:    'Barcode Medication Administration',
    BNP:     'B-type Natriuretic Peptide',
    FLACC:   'Face, Legs, Activity, Cry, Consolability (Pediatric Pain Scale)',
    DON:     'Director of Nursing',
    WHO:     'World Health Organization',
    Foley:   'Indwelling Urinary Catheter (Foley catheter)',
    HIPAA:   'Health Insurance Portability and Accountability Act',
    JCAHO:   'Joint Commission on Accreditation of Healthcare Organizations',
    AHA:     'American Heart Association',
    ANA:     'American Nurses Association',
  };

  /* ─────────────────────────────────────────────
     BUILD REGEX – matches whole-word abbreviations
  ───────────────────────────────────────────── */
  // Sort by length desc so longer matches win (e.g. STEMI before MI)
  const sortedKeys = Object.keys(ABBR_DICT).sort((a, b) => b.length - a.length);

  // Escape any regex-special characters in keys
  function escRe(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }

  const pattern = sortedKeys.map(escRe).join('|');
  // \b won't work well on keys ending in digits/special chars – use lookahead instead
  // Allow a trailing 's' so plurals (ABCs, IVs, DNRs, etc.) are still matched
  const ABBR_RE = new RegExp('(?<![A-Za-z])(' + pattern + ')s?(?![A-Za-z0-9])', 'g');

  /* ─────────────────────────────────────────────
     TOOLTIP ELEMENT (single shared tooltip)
  ───────────────────────────────────────────── */
  let tooltip = null;
  let hideTimer = null;

  function ensureTooltip(doc) {
    const d = doc || document;
    let el = d.getElementById('acnhs-abbr-tooltip');
    if (!el) {
      el = d.createElement('div');
      el.id = 'acnhs-abbr-tooltip';
      el.setAttribute('role', 'tooltip');
      d.body.appendChild(el);
    }
    return el;
  }

  function showTooltip(abbr, anchorEl, doc) {
    const definition = ABBR_DICT[abbr];
    if (!definition) return;
    clearTimeout(hideTimer);

    const tip = ensureTooltip(doc);
    tip.innerHTML = `<span class="acnhs-abbr-tip-abbr">${abbr}</span> <span class="acnhs-abbr-tip-sep">→</span> <span class="acnhs-abbr-tip-def">${definition}</span>`;
    tip.classList.add('visible');

    // Position
    positionTooltip(tip, anchorEl, doc);
  }

  function positionTooltip(tip, anchorEl, doc) {
    const d = doc || document;
    tip.style.left = '-9999px';
    tip.style.top  = '-9999px';

    requestAnimationFrame(() => {
      const rect    = anchorEl.getBoundingClientRect();
      const tipW    = tip.offsetWidth;
      const tipH    = tip.offsetHeight;
      const vW      = (d.documentElement || d.body).clientWidth;
      const scrollY = (d.documentElement.scrollTop || d.body.scrollTop);
      const scrollX = (d.documentElement.scrollLeft || d.body.scrollLeft);

      let left = rect.left + scrollX + (rect.width / 2) - (tipW / 2);
      let top  = rect.top  + scrollY - tipH - 10;

      // Clamp horizontally
      if (left < 8) left = 8;
      if (left + tipW > vW - 8) left = vW - tipW - 8;

      // Flip below if too close to top
      if (top < scrollY + 8) {
        top = rect.bottom + scrollY + 10;
        tip.classList.add('flip');
      } else {
        tip.classList.remove('flip');
      }

      tip.style.left = left + 'px';
      tip.style.top  = top  + 'px';
    });
  }

  function hideTooltip(doc) {
    clearTimeout(hideTimer);
    hideTimer = setTimeout(() => {
      const tip = (doc || document).getElementById('acnhs-abbr-tooltip');
      if (tip) tip.classList.remove('visible');
    }, 120);
  }

  /* ─────────────────────────────────────────────
     SCAN & WRAP TEXT NODES
  ───────────────────────────────────────────── */
  // Tags we never touch (editable / code / already-processed)
  const SKIP_TAGS = new Set([
    'SCRIPT', 'STYLE', 'NOSCRIPT', 'TEXTAREA', 'INPUT', 'SELECT',
    'CODE', 'PRE', 'KBD', 'SAMP', 'VAR', 'ABBR', 'MARK',
  ]);

  function processNode(node, doc) {
    if (node.nodeType === Node.ELEMENT_NODE) {
      if (SKIP_TAGS.has(node.tagName)) return;
      if (node.dataset && node.dataset.abbrProcessed) return;
      // Skip contenteditable
      if (node.isContentEditable) return;
      Array.from(node.childNodes).forEach(child => processNode(child, doc));
    } else if (node.nodeType === Node.TEXT_NODE) {
      const text = node.textContent;
      if (!text.trim() || !ABBR_RE.test(text)) return;
      ABBR_RE.lastIndex = 0;

      const frag = (doc || document).createDocumentFragment();
      let last = 0;
      let m;
      ABBR_RE.lastIndex = 0;

      while ((m = ABBR_RE.exec(text)) !== null) {
        const matched = m[1];
        if (!ABBR_DICT[matched]) continue;

        // Text before the match
        if (m.index > last) {
          frag.appendChild((doc || document).createTextNode(text.slice(last, m.index)));
        }

        // Wrap abbreviation
        const span = (doc || document).createElement('span');
        span.className = 'acnhs-abbr';
        span.textContent = matched;
        span.setAttribute('data-abbr', matched);
        span.setAttribute('tabindex', '0');
        span.setAttribute('aria-label', matched + ': ' + ABBR_DICT[matched]);

        // Desktop hover
        span.addEventListener('mouseenter', function () { showTooltip(matched, span, doc); });
        span.addEventListener('mouseleave', function () { hideTooltip(doc); });
        span.addEventListener('focus',      function () { showTooltip(matched, span, doc); });
        span.addEventListener('blur',       function () { hideTooltip(doc); });

        // Mobile tap
        span.addEventListener('touchstart', function (e) {
          e.stopPropagation();
          const isVisible = (doc || document).getElementById('acnhs-abbr-tooltip')
            && (doc || document).getElementById('acnhs-abbr-tooltip').classList.contains('visible')
            && (doc || document).getElementById('acnhs-abbr-tooltip').dataset.abbr === matched;
          if (isVisible) {
            hideTooltip(doc);
          } else {
            const tip = ensureTooltip(doc);
            tip.dataset.abbr = matched;
            showTooltip(matched, span, doc);
          }
        }, { passive: true });

        frag.appendChild(span);
        last = m.index + m[0].length;
      }

      // Remaining text
      if (last < text.length) {
        frag.appendChild((doc || document).createTextNode(text.slice(last)));
      }

      if (frag.childNodes.length > 0) {
        node.parentNode.replaceChild(frag, node);
      }
    }
  }

  function scan(root, doc) {
    const d = doc || document;
    const r = root || d.body;
    if (!r) return;
    // Dismiss tooltip on outside tap
    d.addEventListener('touchstart', function (e) {
      if (!e.target.classList.contains('acnhs-abbr')) hideTooltip(d);
    }, { passive: true, once: false, capture: true });
    processNode(r, d);
  }

  /* ─────────────────────────────────────────────
     CSS INJECTION (fallback if stylesheet missing)
  ───────────────────────────────────────────── */
  function injectFallbackCSS(doc) {
    const d = doc || document;
    if (d.getElementById('acnhs-abbr-style')) return;
    const style = d.createElement('style');
    style.id = 'acnhs-abbr-style';
    style.textContent = `
      .acnhs-abbr {
        border-bottom: none;
        cursor: help;
        color: inherit;
        text-decoration: none;
        display: inline;
        font-style: normal;
        transition: transform 0.15s ease;
      }
      .acnhs-abbr:hover { display: inline-block; transform: scale(1.08); color: inherit; }
      .acnhs-abbr:focus { outline: none; border-bottom: none; }
      #acnhs-abbr-tooltip {
        position: absolute;
        z-index: 99999;
        background: linear-gradient(135deg, #0c1a32, #0f2040);
        color: #e8edf5;
        font-family: 'Inter', system-ui, sans-serif;
        font-size: 13px;
        font-weight: 500;
        padding: 9px 16px;
        border-radius: 10px;
        border: 1px solid rgba(201,168,76,0.35);
        box-shadow: 0 12px 32px rgba(0,0,0,0.55), 0 0 0 1px rgba(201,168,76,0.08);
        white-space: nowrap;
        pointer-events: none;
        opacity: 0;
        transform: translateY(-4px);
        transition: opacity 0.18s ease, transform 0.18s ease;
        max-width: 340px;
        white-space: normal;
        line-height: 1.4;
      }
      #acnhs-abbr-tooltip::after {
        content: '';
        position: absolute;
        bottom: -6px; left: 50%; transform: translateX(-50%);
        width: 10px; height: 10px;
        background: #0c1a32;
        border-right: 1px solid rgba(201,168,76,0.35);
        border-bottom: 1px solid rgba(201,168,76,0.35);
        transform: translateX(-50%) rotate(45deg);
      }
      #acnhs-abbr-tooltip.flip::after {
        bottom: auto; top: -6px;
        border-right: none; border-bottom: none;
        border-left: 1px solid rgba(201,168,76,0.35);
        border-top: 1px solid rgba(201,168,76,0.35);
      }
      #acnhs-abbr-tooltip.visible { opacity: 1; transform: translateY(0); }
      .acnhs-abbr-tip-abbr { color: #c9a84c; font-weight: 700; }
      .acnhs-abbr-tip-sep   { color: rgba(201,168,76,0.5); margin: 0 4px; }
      .acnhs-abbr-tip-def   { color: #e8edf5; }
    `;
    d.head.appendChild(style);
  }

  /* ─────────────────────────────────────────────
     PUBLIC API
  ───────────────────────────────────────────── */
  function init(root, doc) {
    const d = doc || document;
    injectFallbackCSS(d);
    scan(root, d);
  }

  global.ACNHS_Abbr = {
    dict: ABBR_DICT,
    init: init,
    scan: scan,
  };

  /* Auto-run on DOMContentLoaded (for the host page) */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => init());
  } else {
    // DOM already ready (script loaded async/defer or after DOM)
    init();
  }

}(window));
