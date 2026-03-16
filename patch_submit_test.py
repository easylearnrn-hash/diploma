import re

with open('test.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Replace submitTest
new_submit_test = """function submitTest(autoSubmit = false) {
  closeSubmitModal();
  
  testState.endTime = Date.now();
  clearInterval(testState.timerInterval);
  window.removeEventListener('beforeunload', handleBeforeUnload);

  if (document.getElementById('testContainer')) {
    document.getElementById('testContainer').style.display = 'none';
  }

  const isTeacherColdCall = SESSION_ROLE.isTeacher && coldCallTrackerMode && coldCallState.analytics.size > 0;

  if (isTeacherColdCall) {
    // Generate multi-student gradebook and hide normal result renders
    submitColdCallGrades().then(() => {
        // Clear local cache just in case
        clearLocalStorage();
    });
  } else {
    // Standard single-user submission
    const results = calculateResults();
    
    // Save to Supabase (async, non-blocking)
    saveTestAttempt(results).then(attempt => {
      if (attempt) console.log('Test attempt saved with ID:', attempt.id);
    });

    // Save permanent grade record and load history
    saveTestGrade(results).then(history => {
      renderGradesCard(history, results.scorePercent);
    });
    
    // Show results
    displayResults(results);
    
    clearLocalStorage();
    
    if (autoSubmit) {
      showToast('Test auto-submitted due to time limit', 'info');
    }
  }
}

async function submitColdCallGrades() {
   // Prepare array of test history models
   const gradePayloads = [];

   // Title and topic info
   const title = document.getElementById('testTitle') ? document.getElementById('testTitle').textContent || 'Cold Call Session' : 'Teacher Cold Call';
   
   // Loop through all answered students and compute their A-F
   for (const [studentId, stats] of coldCallState.analytics.entries()) {
      const correct = stats.correct || 0;
      const incorrect = stats.wrong || 0;
      const total = correct + incorrect;

      // Skip students with 0 questions answered just in case
      if (total === 0) continue;

      const percentage = Math.round((correct / total) * 100);
      let letterGrade = 'F';
      if (percentage >= 90) letterGrade = 'A';
      else if (percentage >= 80) letterGrade = 'B';
      else if (percentage >= 70) letterGrade = 'C';

      // Insert record
      gradePayloads.push({
         owner_id: String(studentId),
         student_name: stats.name,
         student_email: null, // We might not have email easily accessible in this object yet
         test_title: 'Cold Call: ' + title,
         topics: 'Cold Call Session',
         test_id: TEST_CONFIG ? TEST_CONFIG.testId : 'cold-call',
         score_percent: percentage,
         letter_grade: letterGrade,
         correct_count: correct,
         incorrect_count: incorrect,
         total_questions: total
      });
   }

   try {
     const { data, error } = await sdb.from('test_grade_history').insert(gradePayloads);
     if (error) throw error;
     showToast(`Cold call grades submitted for ${gradePayloads.length} students.`, 'success');
     
     // Special UI render for teachers
     renderColdCallResults(gradePayloads);

   } catch(e) {
     console.error("Failed storing cold call grades", e);
     showToast("Failed to save Cold Call Grades", "error");
   }
}

function renderColdCallResults(grades) {
    const resultsContainer = document.getElementById('testResults');
    if (!resultsContainer) return;
    
    // Keep it modular, clear everything
    resultsContainer.innerHTML = '';
    resultsContainer.style.display = 'block';

    let html = `
      <div class="test-header" style="margin-bottom: 2rem; border-left: 4px solid var(--gold-primary); padding-left: 1rem;">
        <h2 style="font-family: 'Playfair Display', serif; color: var(--navy-dark); font-size: 2rem;">Cold Call Session Results</h2>
        <p style="color: var(--text-light); margin-top: 0.5rem; font-size: 1.1rem;">Teacher Gradebook Export</p>
      </div>
      
      <div class="results-summary">
        <h3 style="color: var(--navy-dark); margin-bottom: 1rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.5rem;">Student Grades Submitted</h3>
        <div style="display: flex; flex-direction: column; gap: 0.75rem; margin-top: 1rem;">
    `;

    // Sort by letter grade or percentage desc
    grades.sort((a,b) => b.score_percent - a.score_percent);

    if (grades.length === 0) {
       html += `<p style="color: var(--text-light);">No student answers were recorded during this session.</p>`;
    } else {
       for (const g of grades) {
         let pillColor = 'var(--text-light)';
         let bg = '#F3F4F6';
         
         if (g.letter_grade === 'A' || g.letter_grade === 'B') {
           pillColor = 'var(--status-approved)'; bg = '#DEF7EC'; 
         } else if (g.letter_grade === 'C') {
           pillColor = 'var(--status-pending)'; bg = '#FEF3C7';
         } else {
           pillColor = 'var(--status-rejected)'; bg = '#FDE8E8';
         }

         html += `
          <div style="display: flex; justify-content: space-between; align-items: center; padding: 1rem; background: var(--bg-white); border-radius: 8px; border: 1px solid var(--border-color); box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
            <div style="display: flex; flex-direction: column;">
               <span style="font-weight: 600; color: var(--navy-primary); font-size: 1.1rem;">${g.student_name}</span>
               <span style="font-size: 0.85rem; color: var(--text-light); margin-top: 0.2rem;">${g.correct_count} Correct, ${g.incorrect_count} Incorrect</span>
            </div>
            <div style="display: flex; align-items: center; gap: 1rem;">
               <div style="font-family: 'Space Mono', monospace; font-size: 1.2rem; font-weight: 700; color: var(--navy-dark);">
                 ${g.score_percent}%
               </div>
               <div style="display: inline-flex; align-items: center; justify-content: center; width: 40px; height: 40px; border-radius: 8px; font-weight: bold; font-size: 1.2rem; color: ${pillColor}; background-color: ${bg};">
                 ${g.letter_grade}
               </div>
            </div>
          </div>
         `;
       }
    }

    html += `
        </div>
        
        <div style="margin-top: 2rem; display: flex; gap: 1rem; justify-content: center;">
           <button class="btn btn-primary" onclick="window.location.href='index.html'" style="padding: 0.75rem 2rem; background: var(--gold-primary); color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; transition: all 0.2s;">
             Return Home
           </button>
           <button class="btn btn-secondary" onclick="window.location.reload()" style="padding: 0.75rem 2rem; background: var(--bg-white); color: var(--navy-primary); border: 1px solid var(--border-color); border-radius: 8px; font-weight: 600; cursor: pointer; transition: all 0.2s;">
             Start New Test
           </button>
        </div>
      </div>
    `;

    resultsContainer.innerHTML = html;
}
"""

# Try to find the function block for submitTest
pattern = re.compile(
    r'function submitTest\(autoSubmit = false\) \{[\s\S]*?(?=function calculateResults\(\))', 
    re.MULTILINE
)

new_content = html
if pattern.search(html):
    new_content = pattern.sub(new_submit_test + "\n", html)
else:
    print("Could not find submitTest regex pattern")

with open('test.html', 'w', encoding='utf-8') as f:
    f.write(new_content)

