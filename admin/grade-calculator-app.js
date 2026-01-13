/**
 * ACNHS Grade Calculator - Main Application
 * Connects UI, calculation engine, and database persistence
 */

import { GradeCalculator } from './grade-calculator.js';
import { GradeService } from './grade-service.js';

// Initialize Supabase client
const supabase = window.initSupabase ? window.initSupabase() : null;
if (!supabase) {
  console.error('Supabase client not initialized. Make sure supabase-config.js is loaded.');
}

// Initialize services
const gradeService = new GradeService(supabase);
let calculator = new GradeCalculator();

// Context from URL parameters
let studentId = null;
let courseId = null;
let semester = null;
let isLocked = false;

// DOM elements
const $ = (id) => document.getElementById(id);

// Exam list management
const examList = $('examList');

function makeExamRow(idx, name = '', value = '') {
  const row = document.createElement('div');
  row.className = 'examRow';
  row.dataset.idx = String(idx);

  const nameWrap = document.createElement('div');
  const lab = document.createElement('label');
  lab.textContent = 'Exam Name';
  const nameInput = document.createElement('input');
  nameInput.type = 'text';
  nameInput.value = name || `Exam ${idx + 1}`;
  nameInput.placeholder = 'Exam name';
  nameInput.disabled = isLocked;
  nameWrap.appendChild(lab);
  nameWrap.appendChild(nameInput);

  const scoreWrap = document.createElement('div');
  const slab = document.createElement('label');
  slab.textContent = 'Score';
  const score = document.createElement('input');
  score.type = 'number';
  score.min = '0';
  score.max = '100';
  score.step = '0.01';
  score.placeholder = 'e.g., 78.00';
  score.value = value;
  score.disabled = isLocked;
  scoreWrap.appendChild(slab);
  scoreWrap.appendChild(score);

  const del = document.createElement('button');
  del.className = 'tiny danger';
  del.title = 'Remove exam';
  del.textContent = '✕';
  del.disabled = isLocked;
  del.addEventListener('click', () => {
    if (!isLocked) {
      row.remove();
      reindexExamRows();
      triggerAutosave();
    }
  });

  row.appendChild(nameWrap);
  row.appendChild(scoreWrap);
  row.appendChild(del);

  // Autosave on change
  if (!isLocked) {
    nameInput.addEventListener('input', triggerAutosave);
    score.addEventListener('input', triggerAutosave);
  }

  return row;
}

function reindexExamRows() {
  [...examList.children].forEach((row, i) => {
    row.dataset.idx = String(i);
    const nameInput = row.querySelector('input[type="text"]');
    if (/^Exam\s+\d+$/i.test(nameInput.value.trim())) {
      nameInput.value = `Exam ${i + 1}`;
    }
  });
}

function addExamRow(name = '', value = '') {
  const idx = examList.children.length;
  examList.appendChild(makeExamRow(idx, name, value));
}

// Initialize with 4 default exams
addExamRow();
addExamRow();
addExamRow();
addExamRow();

$('btnAddExam').addEventListener('click', () => {
  if (!isLocked) {
    addExamRow();
    triggerAutosave();
  }
});

// Helper functions
function toNum(v) {
  if (v === '' || v === null || v === undefined) return NaN;
  const n = Number(v);
  return Number.isFinite(n) ? n : NaN;
}

function getClinical() {
  const picked = document.querySelector('input[name="clinical"]:checked');
  return picked ? picked.value : '';
}

function showErrors(errors) {
  const box = $('errorsBox');
  const list = $('errorsList');
  list.innerHTML = '';
  if (!errors.length) {
    box.style.display = 'none';
    return;
  }
  errors.forEach(e => {
    const li = document.createElement('li');
    li.textContent = e;
    list.appendChild(li);
  });
  box.style.display = 'block';
}

function badge(text, kind) {
  const span = document.createElement('span');
  span.className = 'badge ' + (kind || '');
  span.textContent = text;
  return span;
}

// Get form data
function getFormData() {
  const examRows = [...examList.children];
  const exams = examRows.map(row => {
    const name = row.querySelector('input[type="text"]').value.trim() || 'Exam';
    const score = toNum(row.querySelector('input[type="number"]').value);
    return { name, score };
  });

  return {
    exams,
    finalExam: toNum($('finalExam').value),
    quizAvg: toNum($('quizAvg').value),
    stdAvg: toNum($('stdAvg').value),
    clinical: getClinical(),
    absTheory: parseInt($('absTheory').value) || 0,
    absClinical: parseInt($('absClinical').value) || 0
  };
}

// Update calculator config
function updateCalculatorConfig() {
  calculator = new GradeCalculator({
    gateExamMin: toNum($('gateExamMin').value),
    gateFinalMin: toNum($('gateFinalMin').value),
    progMin: toNum($('progMin').value),
    wExams: toNum($('wExams').value),
    wFinal: toNum($('wFinal').value),
    wQuiz: toNum($('wQuiz').value),
    wStd: toNum($('wStd').value),
    enableAttendance: $('enableAttendance').value === 'on',
    absTheory: parseInt($('absTheory').value) || 0,
    absClinical: parseInt($('absClinical').value) || 0
  });
}

// Calculate grades
function calculate() {
  updateCalculatorConfig();
  const formData = getFormData();
  const result = calculator.calculate(formData);

  if (!result.success) {
    showErrors(result.errors);
    $('resultBox').style.display = 'none';
    return null;
  }

  showErrors([]);

  // Render results
  $('resultBox').style.display = 'block';
  $('outExamAvg').textContent = GradeCalculator.formatPercent(result.examAvg);
  $('outTheoryFinal').textContent = GradeCalculator.formatPercent(result.theoryFinal);
  $('outLetter').textContent = result.letter;
  $('outOutcome').textContent = result.outcome;

  // Badges
  const badges = $('headlineBadges');
  badges.innerHTML = '';
  badges.appendChild(badge(result.outcome, result.outcome === 'PASS' ? 'good' : 'bad'));

  const letterKind = ['A', 'A-', 'B+', 'B', 'B-'].includes(result.letter) ? 'good'
    : result.letter === 'C+' ? 'warn' : 'bad';
  badges.appendChild(badge('Letter: ' + result.letter, letterKind));
  badges.appendChild(badge(result.allGatesPassed ? 'Gates: ALL PASSED' : 'Gates: NOT MET',
    result.allGatesPassed ? 'good' : 'bad'));
  badges.appendChild(badge(result.progressionOK ? 'Progression: YES' : 'Progression: NO',
    result.progressionOK ? 'good' : 'bad'));

  // Stamp line
  const sName = $('studentName').value.trim() || (studentId ? `Student ${studentId}` : '');
  const cName = $('courseName').value.trim() || (courseId || '');
  const headerBits = [];
  if (sName) headerBits.push('Student: ' + sName);
  if (cName) headerBits.push('Course: ' + cName);
  if (semester) headerBits.push('Semester: ' + semester);
  headerBits.push('Generated: ' + GradeCalculator.getTimestamp());
  $('stampLine').textContent = headerBits.join(' • ');

  // Audit list
  const auditList = $('auditList');
  auditList.innerHTML = '';
  result.audit.forEach(line => {
    const li = document.createElement('li');
    li.textContent = line;
    auditList.appendChild(li);
  });

  // Policy note
  const config = calculator;
  $('policyNote').innerHTML =
    `<b>Policy:</b> ACNHS does not round up. Gates require exact ≥ thresholds. ` +
    `Weights: Exams ${config.wExams.toFixed(2)}%, Final ${config.wFinal.toFixed(2)}%, ` +
    `Quizzes ${config.wQuiz.toFixed(2)}%, Standardized ${config.wStd.toFixed(2)}%.`;

  return result;
}

// Autosave
function triggerAutosave() {
  if (!studentId || !courseId || !semester || isLocked) return;

  const result = calculate();
  if (!result) return;

  const formData = getFormData();
  const gradeData = GradeService.buildGradeData(studentId, courseId, semester, formData, result);

  gradeService.autosave(gradeData, (status) => {
    const statusEl = $('saveStatus');
    statusEl.style.display = 'block';
    statusEl.className = 'save-status ' + status.status;
    
    if (status.status === 'saving') {
      statusEl.textContent = 'Saving...';
    } else if (status.status === 'saved') {
      statusEl.textContent = '✓ Saved at ' + new Date().toLocaleTimeString();
      setTimeout(() => {
        statusEl.style.display = 'none';
      }, 3000);
    } else if (status.status === 'error') {
      statusEl.textContent = '✗ Error: ' + status.message;
      statusEl.className = 'save-status';
      statusEl.style.color = 'var(--bad)';
    }
  });
}

// Manual save
async function saveGrade() {
  if (!studentId || !courseId || !semester) {
    alert('Cannot save: Missing student, course, or semester context.');
    return;
  }

  const result = calculate();
  if (!result) {
    alert('Cannot save: Fix validation errors first.');
    return;
  }

  const formData = getFormData();
  const gradeData = GradeService.buildGradeData(studentId, courseId, semester, formData, result);

  $('saveStatus').textContent = 'Saving...';
  $('saveStatus').style.display = 'block';

  const saved = await gradeService.saveGrade(gradeData);

  if (saved.success) {
    $('saveStatus').textContent = '✓ Saved successfully';
    $('saveStatus').className = 'save-status saved';
    setTimeout(() => {
      $('saveStatus').style.display = 'none';
    }, 3000);
  } else {
    alert('Save failed: ' + saved.error);
    $('saveStatus').style.display = 'none';
  }
}

// Finalize grade
async function finalizeGrade() {
  if (!studentId || !courseId || !semester) {
    alert('Cannot finalize: Missing context.');
    return;
  }

  const confirm = window.confirm(
    '⚠️ FINALIZE SEMESTER GRADE?\n\n' +
    'This will LOCK the grade record. No edits will be allowed after finalization.\n\n' +
    'Only super-admin can override. Continue?'
  );

  if (!confirm) return;

  // Save first
  await saveGrade();

  // Get admin ID (from sessionStorage or prompt)
  const adminEmail = sessionStorage.getItem('adminEmail') || 'admin@acnhs.edu';

  const result = await gradeService.finalizeGrade(studentId, courseId, semester, adminEmail);

  if (result.success) {
    alert('✅ Grade finalized successfully. Record is now locked.');
    location.reload(); // Reload to show locked state
  } else {
    alert('Finalization failed: ' + result.error);
  }
}

// Load existing grade
async function loadGrade() {
  if (!studentId || !courseId || !semester) return;

  const result = await gradeService.loadGrade(studentId, courseId, semester);

  if (!result.success || !result.data) {
    console.log('No saved grade found. Starting fresh.');
    return;
  }

  const data = GradeService.parseGradeData(result.data);

  // Check if finalized
  if (data.isFinalized) {
    isLocked = true;
    $('lockedBanner').style.display = 'block';
    $('btnFinalize').style.display = 'none';
    $('btnSave').style.display = 'none';
    
    // Disable all inputs
    document.querySelectorAll('input, select, button').forEach(el => {
      if (el.id !== 'btnCalc' && el.id !== 'btnPrint') {
        el.disabled = true;
      }
    });
  }

  // Populate form
  examList.innerHTML = '';
  if (data.exams && data.exams.length > 0) {
    data.exams.forEach(exam => addExamRow(exam.name, exam.score));
  } else {
    // Default 4 exams
    addExamRow();
    addExamRow();
    addExamRow();
    addExamRow();
  }

  $('finalExam').value = data.finalExam || '';
  $('quizAvg').value = data.quizAvg || '';
  $('stdAvg').value = data.stdAvg || '';

  if (data.clinical) {
    const radio = document.querySelector(`input[name="clinical"][value="${data.clinical}"]`);
    if (radio) radio.checked = true;
  }

  $('absTheory').value = data.absTheory || 0;
  $('absClinical').value = data.absClinical || 0;

  // If we have calculated results, display them
  if (data.calculatedResults) {
    calculate();
  }

  console.log('✓ Grade loaded successfully' + (isLocked ? ' (LOCKED)' : ''));
}

// Parse URL parameters
function parseContext() {
  const params = new URLSearchParams(window.location.search);
  studentId = params.get('student_id');
  courseId = params.get('course_id');
  semester = params.get('semester');
  const studentName = params.get('student_name');
  const program = params.get('program');

  if (studentId || courseId || semester) {
    $('studentContext').style.display = 'block';
    $('contextStudent').textContent = studentId || '—';
    $('contextCourse').textContent = courseId || '—';
    $('contextSemester').textContent = semester || '—';

    // Pre-fill student name and course name fields
    if (studentName) {
      $('studentName').value = studentName;
      $('studentName').disabled = true; // Disable editing since it's from URL
    }
    if (courseId) {
      $('courseName').value = courseId + (program ? ` - ${program}` : '');
    }

    // Show save/finalize buttons
    if (supabase) {
      $('btnSave').style.display = 'inline-block';
      $('btnFinalize').style.display = 'inline-block';
    }

    // Auto-load existing grade
    loadGrade();
  }
}

// Event listeners
$('btnCalc').addEventListener('click', calculate);

$('btnReset').addEventListener('click', () => {
  if (isLocked) {
    alert('Cannot reset: Grade is finalized and locked.');
    return;
  }

  // Reset exams to 4
  examList.innerHTML = '';
  addExamRow();
  addExamRow();
  addExamRow();
  addExamRow();

  $('studentName').value = '';
  $('courseName').value = '';
  $('finalExam').value = '';
  $('quizAvg').value = '';
  $('stdAvg').value = '';
  document.querySelectorAll('input[name="clinical"]').forEach(r => (r.checked = false));

  $('gateExamMin').value = '78.00';
  $('gateFinalMin').value = '75.00';
  $('progMin').value = '78.00';
  $('enableAttendance').value = 'off';
  $('absTheory').value = '0';
  $('absClinical').value = '0';

  $('wExams').value = '60.00';
  $('wFinal').value = '20.00';
  $('wQuiz').value = '10.00';
  $('wStd').value = '10.00';

  $('errorsBox').style.display = 'none';
  $('resultBox').style.display = 'none';
});

$('btnPrint').addEventListener('click', () => {
  if ($('resultBox').style.display !== 'block') calculate();
  window.print();
});

$('btnSave').addEventListener('click', saveGrade);
$('btnFinalize').addEventListener('click', finalizeGrade);

// Autosave on input changes (if context available)
if (!isLocked) {
  const autosaveInputs = [
    'finalExam', 'quizAvg', 'stdAvg', 'absTheory', 'absClinical',
    'gateExamMin', 'gateFinalMin', 'progMin', 'wExams', 'wFinal', 'wQuiz', 'wStd'
  ];

  autosaveInputs.forEach(id => {
    const el = $(id);
    if (el) el.addEventListener('input', triggerAutosave);
  });

  document.querySelectorAll('input[name="clinical"]').forEach(radio => {
    radio.addEventListener('change', triggerAutosave);
  });

  $('enableAttendance').addEventListener('change', triggerAutosave);
}

// Initialize
parseContext();
