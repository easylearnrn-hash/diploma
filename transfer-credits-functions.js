// Transfer Credits JavaScript Functions
// Add these functions to admin-student-page.html <script> section

// ===========================================
// TRANSFER CREDITS FUNCTIONS
// ===========================================

let currentTransferCredit = null; // For editing

// Load transfer credits for current student
async function loadTransferCredits() {
  if (!currentStudentId || !sbClient) return;
  
  try {
    const { data, error } = await sbClient
      .from('transfer_credits')
      .select('*')
      .eq('student_id', currentStudentId)
      .order('created_at', { ascending: false });
    
    if (error) {
      console.error('Error loading transfer credits:', error);
      return;
    }
    
    renderTransferCredits(data || []);
    
    // Recalculate GPA including transfer credits
    if (data && data.length > 0) {
      await recalculateGPAWithTransfers();
    }
  } catch (err) {
    console.error('Failed to load transfer credits:', err);
  }
}

// Render transfer credits in the UI
function renderTransferCredits(credits) {
  const container = document.getElementById('transferCreditsContainer');
  
  if (!credits || credits.length === 0) {
    container.innerHTML = `
      <div class="empty-state" style="padding: 40px 20px;">
        <div class="empty-icon">🎓</div>
        <p>No transfer credits recorded yet</p>
      </div>
    `;
    return;
  }
  
  const html = `
    <div class="transfer-credits-list">
      ${credits.map(credit => `
        <div class="transfer-credit-card">
          <div class="transfer-card-header">
            <div class="transfer-card-title">
              <div class="transfer-course-code">${credit.course_code}</div>
              <div class="transfer-course-name">${credit.course_name}</div>
              <div class="transfer-institution">
                🏫 ${credit.institution_name}
                ${credit.institution_city ? `, ${credit.institution_city}` : ''}
                ${credit.institution_country ? `, ${credit.institution_country}` : ''}
              </div>
            </div>
            <div class="transfer-card-actions">
              <span class="transfer-badge ${credit.status || 'approved'}">
                ${credit.status === 'pending' ? '⏳ Pending' : credit.status === 'rejected' ? '✗ Rejected' : '✓ Approved'}
              </span>
              <button class="transfer-edit-btn" onclick="editTransferCredit('${credit.id}')">✏️ Edit</button>
              <button class="transfer-delete-btn" onclick="deleteTransferCredit('${credit.id}', '${credit.course_code}')">🗑️ Delete</button>
            </div>
          </div>
          <div class="transfer-card-details">
            <div class="transfer-detail-item">
              <div class="transfer-detail-label">Credits</div>
              <div class="transfer-detail-value">${credit.credits}</div>
            </div>
            <div class="transfer-detail-item">
              <div class="transfer-detail-label">Grade</div>
              <div class="transfer-detail-value">${credit.letter_grade || credit.grade}</div>
            </div>
            <div class="transfer-detail-item">
              <div class="transfer-detail-label">Grade Points</div>
              <div class="transfer-detail-value">${credit.grade_points !== null ? credit.grade_points.toFixed(2) : '—'}</div>
            </div>
            <div class="transfer-detail-item">
              <div class="transfer-detail-label">Term</div>
              <div class="transfer-detail-value">${credit.term_completed || '—'} ${credit.year_completed || ''}</div>
            </div>
            ${credit.acnhs_equivalent_course ? `
            <div class="transfer-detail-item" style="grid-column: 1 / -1;">
              <div class="transfer-detail-label">ACNHS Equivalent</div>
              <div class="transfer-detail-value">${credit.acnhs_equivalent_course}</div>
            </div>
            ` : ''}
          </div>
        </div>
      `).join('')}
    </div>
  `;
  
  container.innerHTML = html;
}

// Open modal to add new transfer credit
function openAddTransferCreditModal() {
  currentTransferCredit = null;
  document.getElementById('transferModalTitle').textContent = 'Add Transfer Credit';
  document.getElementById('transferSubmitText').textContent = '💾 Save Transfer Credit';
  document.getElementById('transferCreditForm').reset();
  
  // Set default status
  document.getElementById('transferStatus').value = 'approved';
  
  document.getElementById('transferCreditModal').style.display = 'block';
  document.body.style.overflow = 'hidden';
}

// Edit existing transfer credit
async function editTransferCredit(creditId) {
  try {
    const { data, error } = await sbClient
      .from('transfer_credits')
      .select('*')
      .eq('id', creditId)
      .single();
    
    if (error) throw error;
    
    currentTransferCredit = data;
    
    // Populate form
    document.getElementById('institutionName').value = data.institution_name || '';
    document.getElementById('institutionCountry').value = data.institution_country || '';
    document.getElementById('institutionCity').value = data.institution_city || '';
    document.getElementById('courseCode').value = data.course_code || '';
    document.getElementById('courseName').value = data.course_name || '';
    document.getElementById('credits').value = data.credits || '';
    document.getElementById('termCompleted').value = data.term_completed || '';
    document.getElementById('yearCompleted').value = data.year_completed || '';
    document.getElementById('grade').value = data.grade || '';
    document.getElementById('letterGrade').value = data.letter_grade || '';
    document.getElementById('gradePoints').value = data.grade_points !== null ? data.grade_points : '';
    document.getElementById('acnhsEquivalent').value = data.acnhs_equivalent_course || '';
    document.getElementById('transferStatus').value = data.status || 'approved';
    document.getElementById('transferDate').value = data.transfer_date || '';
    document.getElementById('evaluationNotes').value = data.evaluation_notes || '';
    
    document.getElementById('transferModalTitle').textContent = 'Edit Transfer Credit';
    document.getElementById('transferSubmitText').textContent = '💾 Update Transfer Credit';
    document.getElementById('transferCreditModal').style.display = 'block';
    document.body.style.overflow = 'hidden';
  } catch (err) {
    console.error('Error loading transfer credit:', err);
    alert('Failed to load transfer credit for editing');
  }
}

// Close modal
function closeTransferCreditModal() {
  document.getElementById('transferCreditModal').style.display = 'none';
  document.body.style.overflow = '';
  currentTransferCredit = null;
}

// Save transfer credit (create or update)
async function saveTransferCredit(event) {
  event.preventDefault();
  
  if (!currentStudentId || !sbClient) {
    alert('No student selected');
    return;
  }
  
  // Get admin email from session
  const adminEmail = sessionStorage.getItem('userEmail') || 'admin';
  
  // Gather form data
  const formData = {
    student_id: currentStudentId,
    institution_name: document.getElementById('institutionName').value,
    institution_country: document.getElementById('institutionCountry').value || null,
    institution_city: document.getElementById('institutionCity').value || null,
    course_code: document.getElementById('courseCode').value.toUpperCase(),
    course_name: document.getElementById('courseName').value,
    credits: parseFloat(document.getElementById('credits').value),
    term_completed: document.getElementById('termCompleted').value || null,
    year_completed: document.getElementById('yearCompleted').value ? parseInt(document.getElementById('yearCompleted').value) : null,
    grade: document.getElementById('grade').value,
    letter_grade: document.getElementById('letterGrade').value || null,
    grade_points: document.getElementById('gradePoints').value ? parseFloat(document.getElementById('gradePoints').value) : null,
    acnhs_equivalent_course: document.getElementById('acnhsEquivalent').value || null,
    status: document.getElementById('transferStatus').value || 'approved',
    transfer_date: document.getElementById('transferDate').value || null,
    evaluation_notes: document.getElementById('evaluationNotes').value || null,
    evaluated_by: adminEmail,
    created_by: adminEmail
  };
  
  try {
    if (currentTransferCredit) {
      // Update existing
      const { error } = await sbClient
        .from('transfer_credits')
        .update(formData)
        .eq('id', currentTransferCredit.id);
      
      if (error) throw error;
      
      alert('✅ Transfer credit updated successfully!');
    } else {
      // Create new
      const { error } = await sbClient
        .from('transfer_credits')
        .insert([formData]);
      
      if (error) throw error;
      
      alert('✅ Transfer credit added successfully!');
    }
    
    closeTransferCreditModal();
    loadTransferCredits(); // Reload the list
  } catch (err) {
    console.error('Error saving transfer credit:', err);
    alert('❌ Failed to save transfer credit: ' + err.message);
  }
}

// Delete transfer credit
async function deleteTransferCredit(creditId, courseCode) {
  if (!confirm(`Are you sure you want to delete the transfer credit for ${courseCode}? This action cannot be undone.`)) {
    return;
  }
  
  try {
    const { error } = await sbClient
      .from('transfer_credits')
      .delete()
      .eq('id', creditId);
    
    if (error) throw error;
    
    alert('✅ Transfer credit deleted successfully!');
    loadTransferCredits(); // Reload the list
  } catch (err) {
    console.error('Error deleting transfer credit:', err);
    alert('❌ Failed to delete transfer credit: ' + err.message);
  }
}

// Recalculate GPA including transfer credits
async function recalculateGPAWithTransfers() {
  if (!currentStudentId || !sbClient) return;
  
  try {
    // Get approved transfer credits with grade points
    const { data: transfers, error } = await sbClient
      .from('transfer_credits')
      .select('*')
      .eq('student_id', currentStudentId)
      .eq('status', 'approved')
      .not('grade_points', 'is', null);
    
    if (error) throw error;
    
    // Calculate transfer GPA contribution
    let totalPoints = 0;
    let totalCredits = 0;
    
    transfers?.forEach(credit => {
      if (credit.grade_points !== null && credit.credits) {
        totalPoints += credit.grade_points * credit.credits;
        totalCredits += credit.credits;
      }
    });
    
    // Note: You'll need to integrate this with your existing ACNHS grades calculation
    // For now, this just shows transfer credits impact
    
    console.log(`Transfer Credits: ${totalCredits.toFixed(2)} credits, ${(totalCredits > 0 ? totalPoints / totalCredits : 0).toFixed(2)} GPA`);
    
  } catch (err) {
    console.error('Error calculating GPA with transfers:', err);
  }
}
