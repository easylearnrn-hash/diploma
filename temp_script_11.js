
const form = document.getElementById('admissionForm');
const progressBar = document.getElementById('progressBar');
const submitBtn = document.getElementById('submitBtn');

const APPLICATION_STORAGE_BUCKET = 'application-documents';
const APPLICATION_STORAGE_FOLDER = 'applications';
const DOCUMENT_UPLOAD_FIELDS = [
  { id: 'passportUpload', name: 'Passport', optional: false },
  { id: 'diplomaUpload', name: 'Diploma', optional: false },
  { id: 'transcriptUpload', name: 'Transcript', optional: false },
  { id: 'englishUpload', name: 'English Test', optional: true },
  { id: 'recommendationUpload', name: 'Recommendation', optional: true }
];

function getSubmitStatusElement() {
  if (!submitBtn) return null;
  let statusEl = document.getElementById('submitStatusMessage');
  if (!statusEl && submitBtn.parentNode) {
    statusEl = document.createElement('div');
    statusEl.id = 'submitStatusMessage';
    statusEl.style.marginTop = '12px';
    statusEl.style.fontSize = '0.95rem';
    statusEl.style.textAlign = 'center';
    statusEl.style.color = '#38bdf8';
    statusEl.style.display = 'none';
    statusEl.style.transition = 'opacity 0.2s ease';
    submitBtn.parentNode.insertBefore(statusEl, submitBtn.nextSibling);
  }
  return statusEl;
}

function updateSubmitStatus(message, type = 'info') {
  const statusEl = getSubmitStatusElement();
  if (!statusEl) return;
  if (!message) {
    statusEl.style.display = 'none';
    statusEl.textContent = '';
    return;
  }
  statusEl.style.display = 'block';
  statusEl.textContent = message;
  if (type === 'error') {
    statusEl.style.color = '#f87171';
  } else if (type === 'success') {
    statusEl.style.color = '#34d399';
  } else {
    statusEl.style.color = '#38bdf8';
  }
}

function clearSubmitStatus() {
  updateSubmitStatus('');
}
const dateFormatter = new Intl.DateTimeFormat('en-US', {month: 'long', day: 'numeric', year: 'numeric'});

// Track preview and signature status
let hasPreviewedApplication = false;
let hasSignedApplication = false;

// Update submit button state
function updateSubmitButton() {
  if (hasPreviewedApplication && hasSignedApplication) {
    submitBtn.disabled = false;
    submitBtn.textContent = 'Submit Application';
    submitBtn.style.opacity = '1';
  } else {
    submitBtn.disabled = true;
    if (!hasPreviewedApplication) {
      submitBtn.textContent = 'Review Required Before Submit';
    } else if (!hasSignedApplication) {
      submitBtn.textContent = 'Sign Application to Submit';
    }
    submitBtn.style.opacity = '0.5';
  }
}

// Initially disable submit button
updateSubmitButton();

// Listen for signature confirmation from preview iframe
window.addEventListener('message', function(event) {
  if (event.data && event.data.type === 'applicationSigned') {
    hasSignedApplication = true;
    updateSubmitButton();
    console.log('Application signed by user');
  }
});

// CUSTOM MODAL FUNCTIONS
function showModal(message, type = 'info') {
  const modal = document.getElementById('customModal');
  const modalIcon = document.getElementById('modalIcon');
  const modalMessage = document.getElementById('modalMessage');
  const modalButtons = document.getElementById('modalButtons');

  // Set icon based on type
  const icons = {
    success: '✅',
    error: '❌',
    warning: '⚠️',
    info: 'ℹ️'
  };
  modalIcon.textContent = icons[type] || icons.info;

  // Set message
  modalMessage.innerHTML = message;

  // Set button
  modalButtons.innerHTML = '';
  const button = document.createElement('button');
  button.className = 'modal-btn';
  button.textContent = 'Close';
  button.onclick = closeModal;
  modalButtons.appendChild(button);

  modal.classList.add('active');
}

function closeModal() {
  const modal = document.getElementById('customModal');
  modal.classList.remove('active');
}

// Photo upload preview
document.getElementById('photoUpload').addEventListener('change', function(e) {
  const file = e.target.files[0];
  if (file) {
    const reader = new FileReader();
    reader.onload = function(event) {
      const preview = document.getElementById('photoPreview');
      preview.innerHTML = `<img src="${event.target.result}" alt="Photo preview">`;
      document.getElementById('photoLabel').classList.add('has-file');
      document.getElementById('photoText').textContent = file.name;
    };
    reader.readAsDataURL(file);
  }
});

// File upload handlers
const fileUploads = [
  {input: 'passportUpload', label: 'passportLabel', text: 'passportText'},
  {input: 'diplomaUpload', label: 'diplomaLabel', text: 'diplomaText'},
  {input: 'transcriptUpload', label: 'transcriptLabel', text: 'transcriptText'},
  {input: 'englishUpload', label: 'englishLabel', text: 'englishText'},
  {input: 'recommendationUpload', label: 'recommendationLabel', text: 'recommendationText'},
  // Transfer student documents
  {input: 'transferTranscriptUpload', label: 'transferTranscriptLabel', text: 'transferTranscriptText'},
  {input: 'syllabusUpload', label: 'syllabusLabel', text: 'syllabusText'},
  {input: 'goodStandingUpload', label: 'goodStandingLabel', text: 'goodStandingText'},
  {input: 'withdrawalUpload', label: 'withdrawalLabel', text: 'withdrawalText'},
  {input: 'clinicalHoursUpload', label: 'clinicalHoursLabel', text: 'clinicalHoursText'},
  {input: 'creditEvalUpload', label: 'creditEvalLabel', text: 'creditEvalText'}
];

fileUploads.forEach(upload => {
  const uploadElement = document.getElementById(upload.input);
  if (uploadElement) {
    uploadElement.addEventListener('change', function(e) {
      const files = e.target.files;
      if (files.length > 0) {
        const label = document.getElementById(upload.label);
        const text = document.getElementById(upload.text);
        if (label && text) {
          label.classList.add('has-file');
          text.textContent = files.length > 1 ? `${files.length} files selected` : files[0].name;
        }
      }
    });
  }
});

// Transfer student section toggle
function toggleTransferSection(value) {
  const transferDetailsSection = document.getElementById('transferDetailsSection');
  
  // IDs of required transfer fields
  const requiredTransferFields = [
    'prevInstitution',
    'prevProgram',
    'prevStartDate',
    'prevEndDate',
    'academicStatus',
    'transferReason',
    'creditsEarned',
    'creditsTransfer',
    'prevGPA',
    'completedCourses',
    'transferTranscriptUpload',
    'goodStandingUpload',
    'disciplinaryAction'
  ];
  
  if (value === 'yes') {
    transferDetailsSection.style.display = 'block';
    
    // Make transfer fields required
    requiredTransferFields.forEach(fieldId => {
      const field = document.getElementById(fieldId);
      if (field) {
        field.required = true;
        
        // Add visual indicator for required fields
        const formGroup = field.closest('.form-group');
        if (formGroup) {
          // Find the first label (not the file-upload-label)
          const labels = formGroup.querySelectorAll('label');
          labels.forEach(label => {
            if (!label.classList.contains('file-upload-label') && !label.classList.contains('required')) {
              label.classList.add('required');
            }
          });
        }
      }
    });
    
    // Smooth scroll to the section
    setTimeout(() => {
      transferDetailsSection.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }, 100);
  } else {
    transferDetailsSection.style.display = 'none';
    
    // Remove required attribute from transfer fields
    requiredTransferFields.forEach(fieldId => {
      const field = document.getElementById(fieldId);
      if (field) {
        field.required = false;
        field.value = ''; // Clear the field value
        
        // Remove visual indicator
        const formGroup = field.closest('.form-group');
        if (formGroup) {
          const labels = formGroup.querySelectorAll('label');
          labels.forEach(label => {
            if (!label.classList.contains('file-upload-label') && label.classList.contains('required')) {
              label.classList.remove('required');
            }
          });
        }
      }
    });
  }
}

// Disciplinary action toggle
const disciplinarySelect = document.getElementById('disciplinaryAction');
if (disciplinarySelect) {
  disciplinarySelect.addEventListener('change', function() {
    const detailsGroup = document.getElementById('disciplinaryDetailsGroup');
    if (this.value === 'yes') {
      detailsGroup.style.display = 'block';
    } else {
      detailsGroup.style.display = 'none';
    }
  });
}

// US Immigration Status - Show "Other" text field when "Other" is selected
const usStatusRadios = document.querySelectorAll('input[name="usImmigrationStatus"]');
const usStatusOtherField = document.getElementById('usStatusOtherField');
const usStatusOtherInput = document.querySelector('input[name="usImmigrationStatusOther"]');

usStatusRadios.forEach(radio => {
  radio.addEventListener('change', function() {
    if (this.value === 'Other') {
      usStatusOtherField.style.display = 'block';
      if (usStatusOtherInput) {
        usStatusOtherInput.required = true;
      }
    } else {
      usStatusOtherField.style.display = 'none';
      if (usStatusOtherInput) {
        usStatusOtherInput.required = false;
        usStatusOtherInput.value = '';
      }
    }
  });
});

// Progress bar
form.addEventListener('input', function() {
  const inputs = form.querySelectorAll('input[required], select[required], textarea[required]');
  let filled = 0;

  inputs.forEach(input => {
    if (input.type === 'checkbox') {
      if (input.checked) filled++;
    } else if (input.type === 'file') {
      if (input.files.length > 0) filled++;
    } else if (input.value.trim() !== '') {
      filled++;
    }
  });

  const progress = (filled / inputs.length) * 100;
  progressBar.style.width = progress + '%';
  const progressPercent = document.getElementById('progressPercent');
  if (progressPercent) progressPercent.textContent = Math.round(progress) + '%';
});

/**
 * Send welcome email to applicant with login credentials
 */
async function sendApplicationSubmittedEmail(applicationData, username, password, referenceNumber) {
  const studentEmail = applicationData.email;
  const applicantName = resolveApplicantNameFromData(applicationData);
  const loginUrl = 'https://acnhs.am/application-status.html';
  
  console.log('📧 Sending application submission confirmation to:', studentEmail);
  console.log('📧 Applicant name:', applicantName);

  const emailSubject = `Application Received - ${referenceNumber}`;
  
  // Build the email body content
  const bodyContent = `
    Thank you for submitting your application to the Armenian College of Nursing & Health Sciences! We have successfully received your application.
    
    <div style="background:#f0fdfa;border-left:3px solid #0d9488;padding:16px;border-radius:8px;margin:20px 0;">
      <table role="presentation" cellpadding="0" cellspacing="0" style="border-collapse:collapse;margin:0 0 8px 0;padding:0;">
        <tr>
          <td style="font-size:18px;padding:0 10px 0 0;vertical-align:top;white-space:nowrap;">✅</td>
          <td style="font-size:15px;font-weight:800;color:#0f172a;white-space:nowrap;">Application Submitted Successfully</td>
        </tr>
      </table>
      <div style="font-size:14px;color:#475569;line-height:22px;">Your application is now being processed. You can track your application status using the credentials below.</div>
    </div>
    
    <div style="background:#fff3cd;border:1px solid #ffc107;padding:16px;border-radius:8px;margin:20px 0;">
      <div style="font-size:14px;font-weight:700;color:#856404;margin-bottom:12px;">🔐 Your Login Credentials</div>
      <div style="background:white;padding:14px;border-radius:6px;margin-bottom:10px;">
        <div style="font-size:12px;font-weight:700;color:#64748b;margin-bottom:4px;">USERNAME</div>
        <div style="font-size:14px;font-weight:800;color:#0f172a;font-family:monospace;">${username}</div>
      </div>
      <div style="background:white;padding:14px;border-radius:6px;">
        <div style="font-size:12px;font-weight:700;color:#64748b;margin-bottom:4px;">PASSWORD</div>
        <div style="font-size:14px;font-weight:800;color:#0f172a;font-family:monospace;letter-spacing:1px;">${password}</div>
      </div>
    </div>
    
    <div style="background:#f8fafc;padding:14px;border-radius:8px;margin:16px 0;">
      <div style="font-size:12px;font-weight:700;color:#64748b;margin-bottom:4px;">REFERENCE NUMBER</div>
      <div style="font-size:14px;font-weight:800;color:#0f172a;">${referenceNumber}</div>
    </div>
    
    <div style="height:1px;background:#e2e8f0;margin:24px 0;"></div>
    
    Use the button below to track your application status and view updates:
    
    <div style="text-align:center;margin:24px 0;">
      <a href="${loginUrl}" style="display:inline-block;background:linear-gradient(135deg,#2dd4bf 0%,#0d9488 100%);color:#ffffff;text-decoration:none;padding:12px 28px;border-radius:8px;font-weight:700;font-size:14px;box-shadow:0 4px 12px rgba(45,212,191,0.3);">
        <table role="presentation" cellpadding="0" cellspacing="0" style="border-collapse:collapse;margin:0;padding:0;">
          <tr>
            <td style="font-size:18px;padding:0 8px 0 0;color:#ffffff;white-space:nowrap;">🔐</td>
            <td style="font-size:14px;font-weight:700;color:#ffffff;white-space:nowrap;">Log In to View Status</td>
          </tr>
        </table>
      </a>
    </div>
    
    <div style="background:#f8fafc;padding:14px;border-radius:8px;margin-top:20px;border:1px solid #e2e8f0;">
      <table role="presentation" cellpadding="0" cellspacing="0" style="border-collapse:collapse;margin:0;padding:0;">
        <tr>
          <td style="font-size:18px;padding:0 10px 0 0;vertical-align:top;white-space:nowrap;">💡</td>
          <td style="font-size:13px;color:#64748b;line-height:20px;">
            <strong style="color:#475569;">Tip:</strong> Please save these credentials in a secure location. You will need them to access your student portal throughout the application process.
          </td>
        </tr>
      </table>
    </div>
  `;
  
  // Use the EXACT email template from admin-applications.html
  let emailHtml = `<!doctype html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${emailSubject}</title>
  <style>
    html,body{margin:0!important;padding:0!important;height:100%!important;width:100%!important}
    *{-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%}
    table,td{mso-table-lspace:0pt!important;mso-table-rspace:0pt!important;border-collapse:collapse!important}
    img{-ms-interpolation-mode:bicubic;border:0;outline:none;text-decoration:none;display:block}
    a{color:inherit;text-decoration:none}
    .u-link{color:#c9a84c!important;text-decoration:underline!important}
    @media (max-width: 620px){
      .container{width:100%!important}
      .px{padding-left:18px!important;padding-right:18px!important}
    }
  </style>
</head>
<body style="margin:0;padding:0;background:#ffffff;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#ffffff;">
    <tr>
      <td align="center" style="padding:32px 10px 48px;">
        <table role="presentation" width="600" class="container" cellpadding="0" cellspacing="0"
          style="width:600px;max-width:600px;border-radius:18px;overflow:hidden;background:#ffffff;
                 box-shadow:0 8px 48px rgba(4,17,31,0.18),0 2px 8px rgba(201,168,76,0.10);">
          <!-- HEADER -->
          <tr>
            <td style="background:linear-gradient(135deg,#04111f 0%,#071b30 60%,#0c2444 100%);
                       padding:28px 36px 24px;border-bottom:3px solid #c9a84c;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td width="70" valign="middle" style="padding-right:18px;">
                    <img src="{{ACNHS_SEAL_BASE64}}" width="60" height="60" alt="ACNHS Seal"
                         style="border-radius:999px;background:rgba(201,168,76,0.12);
                                padding:6px;border:1.5px solid rgba(201,168,76,0.35);">
                  </td>
                  <td valign="middle">
                    <div style="font-family:Georgia,'Times New Roman',serif;font-size:17px;color:#e2cc92;font-weight:700;letter-spacing:0.2px;line-height:1.25;">Armenian College of Nursing</div>
                    <div style="font-family:Georgia,'Times New Roman',serif;font-size:15px;color:#d4b56a;font-weight:600;line-height:1.25;margin-top:2px;">&amp; Health Sciences</div>
                    <div style="font-family:Arial,sans-serif;font-size:11px;color:rgba(200,191,178,0.65);font-weight:500;letter-spacing:2px;text-transform:uppercase;margin-top:7px;">Yerevan, Republic of Armenia</div>
                  </td>
                </tr>
              </table>
              <div style="height:1px;background:linear-gradient(90deg,transparent 0%,rgba(201,168,76,0.15) 15%,#c9a84c 50%,rgba(201,168,76,0.15) 85%,transparent 100%);margin:20px 0 18px;"></div>
              <div style="font-family:Georgia,'Times New Roman',serif;font-size:24px;color:#f0e3bc;font-weight:700;letter-spacing:-0.3px;line-height:1.25;">Welcome to ACNHS!</div>
              <div style="font-family:Arial,sans-serif;font-size:11px;color:rgba(200,191,178,0.55);font-weight:500;letter-spacing:1.5px;text-transform:uppercase;margin-top:8px;">${new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</div>
            </td>
          </tr>
          <!-- BODY -->
          <tr>
            <td class="px" style="background-color:#ffffff;padding:36px 36px 28px;">
              <div style="font-family:Georgia,'Times New Roman',serif;font-size:18px;color:#04111f;font-weight:700;margin-bottom:16px;">Dear ${applicantName},</div>
              <div style="font-family:Arial,Helvetica,sans-serif;font-size:15px;line-height:1.75;color:#2c2a25;">${bodyContent}</div>
              <div style="height:1px;background:linear-gradient(90deg,transparent 0%,rgba(201,168,76,0.15) 15%,#c9a84c 50%,rgba(201,168,76,0.15) 85%,transparent 100%);margin:32px 0 28px;"></div>
              <!-- Signature -->
              <table role="presentation" cellpadding="0" cellspacing="0" style="border-collapse:collapse;width:100%;">
                <tr>
                  <td width="80" valign="middle" style="padding-right:18px;">
                    <img src="{{ACNHS_SEAL_BASE64}}" width="70" height="70" alt="ACNHS Seal" style="display:block;">
                  </td>
                  <td valign="middle">
                    <div style="font-family:Georgia,'Times New Roman',serif;font-size:15px;font-weight:700;color:#04111f;margin-bottom:3px;">Admissions Officer</div>
                    <div style="font-family:Arial,sans-serif;font-size:12px;font-weight:600;color:#5a4e3a;margin-bottom:2px;">Admissions Department</div>
                    <div style="font-family:Arial,sans-serif;font-size:12px;font-weight:600;color:#5a4e3a;margin-bottom:8px;">Armenian College of Nursing &amp; Health Sciences</div>
                    <table role="presentation" cellpadding="0" cellspacing="0" style="border-collapse:collapse;">
                      <tr>
                        <td style="padding:0 10px 3px 0;vertical-align:middle;">
                          <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='%23c9a84c' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.87 9.84 19.79 19.79 0 0 1 1.9 1.26 2 2 0 0 1 3.87 0h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 7.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z'/%3E%3C/svg%3E" width="13" height="13" alt="">
                        </td>
                        <td style="font-family:Arial,sans-serif;font-size:11px;color:#8a7a55;padding:0 0 3px;white-space:nowrap;">+374 93 798879</td>
                      </tr>
                      <tr>
                        <td style="padding:0 10px 3px 0;vertical-align:middle;">
                          <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='%23c9a84c' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Crect x='2' y='4' width='20' height='16' rx='2'/%3E%3Cpath d='m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7'/%3E%3C/svg%3E" width="13" height="13" alt="">
                        </td>
                        <td style="font-family:Arial,sans-serif;font-size:11px;padding:0 0 3px;white-space:nowrap;"><a href="mailto:admissions@acnhs.am" style="color:#c9a84c;font-weight:600;text-decoration:none;">admissions@acnhs.am</a></td>
                      </tr>
                      <tr>
                        <td style="padding:0 10px 0 0;vertical-align:middle;">
                          <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='%23c9a84c' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='12' cy='12' r='10'/%3E%3Cpath d='M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z'/%3E%3C/svg%3E" width="13" height="13" alt="">
                        </td>
                        <td style="font-family:Arial,sans-serif;font-size:11px;padding:0;white-space:nowrap;"><a href="https://www.acnhs.am" style="color:#c9a84c;font-weight:600;text-decoration:none;">www.acnhs.am</a></td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <!-- FOOTER DIVIDER -->
          <tr>
            <td style="padding:0;line-height:0;font-size:0;background:#04111f;">
              <div style="height:1px;background:linear-gradient(90deg,transparent 0%,rgba(201,168,76,0.15) 15%,#c9a84c 50%,rgba(201,168,76,0.15) 85%,transparent 100%);"></div>
            </td>
          </tr>
          <!-- FOOTER -->
          <tr>
            <td style="background:#04111f;padding:20px 36px;">
              <div style="font-family:Arial,sans-serif;font-size:11px;color:rgba(200,191,178,0.50);line-height:1.7;">&copy; ${new Date().getFullYear()} Armenian College of Nursing &amp; Health Sciences. All rights reserved.</div>
              <div style="font-family:Arial,sans-serif;font-size:10px;color:rgba(200,191,178,0.30);margin-top:4px;line-height:1.6;">This message is intended solely for the named recipient. If you received this in error, please disregard and notify our office immediately.</div>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;

  // Replace logo placeholder with hosted URL (same as admin-applications.html)
  // CRITICAL: Use ONLY inline base64 - NEVER external URLs to prevent attachment display
  const getInlineLogo = () => {
    if (typeof window !== 'undefined') {
      if (window.ACNHS_LOGO_BASE64) return window.ACNHS_LOGO_BASE64;
      if (window.ACNHS_LOGO_DATA_URL) return window.ACNHS_LOGO_DATA_URL;
    }
    if (typeof ACNHS_LOGO_BASE64 !== 'undefined' && ACNHS_LOGO_BASE64) return ACNHS_LOGO_BASE64;
    return null;
  };

  const toDataUrl = (value) => {
    if (!value || typeof value !== 'string') return null;
    if (value.startsWith('data:image')) return value;
    const isJpeg = value.startsWith('/9j');
    const mimeType = isJpeg ? 'image/jpeg' : 'image/png';
    return `data:${mimeType};base64,${value}`;
  };

  const inlineLogo = getInlineLogo();
  const logoForEmail = toDataUrl(inlineLogo) || '';
  
  // If no base64 logo available, remove <img> tags entirely (prevent broken images)
  if (logoForEmail) {
    emailHtml = emailHtml.replace(/{{ACNHS_SEAL_BASE64}}/g, logoForEmail);
  } else {
    emailHtml = emailHtml.replace(/<img[^>]*{{ACNHS_SEAL_BASE64}}[^>]*>/g, '');
  }

  // Get BCC recipients for application submissions
  const bccEmails = window.BccUtils ? window.BccUtils.getBccEmailsByType('applicationSubmission') : null;

  try {
    const response = await fetch('https://eyhksbiceueoiamwnqpr.supabase.co/functions/v1/send-email', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5aGtzYmljZXVlb2lhbXducXByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4NTIwOTAsImV4cCI6MjA4NDQyODA5MH0.1G3RZLKLJvIR8U9Cvmner3kUIxDtUfFYkHpzUUbnbq8'
      },
      body: JSON.stringify({
        to: studentEmail,
        from: 'admissions@acnhs.am',
        ...(bccEmails && { bcc: bccEmails }),
        subject: emailSubject,
        html: emailHtml,
        sender_name: 'Admissions Officer'
      })
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.error || `Email API returned ${response.status}`);
    }

    const result = await response.json();
    console.log('✅ Welcome email sent successfully:', result);
    
    return result;
  } catch (error) {
    console.error('❌ Failed to send welcome email:', error);
    // Don't throw - we don't want to block the application if email fails
    // User still gets credentials in the modal
  }
}

// Form submission handler
form.addEventListener('submit', handleAdmissionSubmit);

async function handleAdmissionSubmit(e) {
  e.preventDefault();

  // GA4 key event — application form submitted
  if (typeof gtag !== 'undefined') {
    gtag('event', 'apply_now_click', {
      button_location: 'admission_form',
      form_step: 'submit',
      page_path: window.location.pathname
    });
  }

  submitBtn.disabled = true;
  submitBtn.textContent = 'Submitting...';
  updateSubmitStatus('Uploading your application. Please stay on this page.');

  const submissionDate = dateFormatter.format(new Date());
  const referenceNumber = generateReferenceNumber();
  const barcode = generateBarcodeValue(referenceNumber);
  const verificationCodes = generateVerificationCodes();
  
  // Use async version to include photo and document files
  const data = await gatherAdmissionDataWithFiles();
  data.submissionDate = submissionDate;
  data.referenceNumber = referenceNumber;
  data.barcode = barcode;
  data.documentId = verificationCodes.documentId;
  data.controlNumber = verificationCodes.controlNumber;
  data.verificationHash = verificationCodes.verificationHash;
  
  // Generate application credentials
  const firstName = document.querySelector('[name="firstName"]').value;
  const middleName = document.querySelector('[name="middleName"]').value;
  const lastName = document.querySelector('[name="lastName"]').value;
  const username = generateUsername(firstName, lastName);
  const password = generateSecurePassword();
  const passwordHash = await hashPassword(password);
  
  data.firstName = (data.firstName || firstName || '').trim();
  data.middleName = (data.middleName || middleName || '').trim();
  data.lastName = (data.lastName || lastName || '').trim();
  data.applicantName = resolveApplicantNameFromData(data);
  
  data.username = username;
  data.passwordHash = passwordHash;
  data.latestCredentials = {
    username,
    password,
    createdAt: new Date().toISOString(),
    source: 'submission'
  };
  data.status = 'SUBMITTED';

  let uploadedAssets = { photo: null, documents: [] };
  try {
    updateSubmitStatus('Uploading your files securely...', 'info');
    uploadedAssets = await uploadApplicationAssets(referenceNumber);
    updateSubmitStatus('Files uploaded. Saving your application...', 'info');
  } catch (uploadError) {
    console.error('File upload failed', uploadError);
    throw new Error(uploadError.message || 'We could not upload your files. Please try again.');
  }

  const supabasePayload = createSupabasePayload(data, uploadedAssets);

  try {
    const savedData = await saveApplicationWithRetries(supabasePayload, {
      maxAttempts: 3,
      timeoutMs: 45000,
      onStatus: ({ attempt, maxAttempts, stage, delayMs }) => {
        if (stage === 'waiting') {
          const seconds = Math.ceil((delayMs || 0) / 1000);
          submitBtn.textContent = `Retrying in ${seconds}s...`;
          updateSubmitStatus(`Connection issue detected. Retrying in ${seconds} second${seconds === 1 ? '' : 's'} (${attempt}/${maxAttempts})...`);
        } else if (stage === 'retry') {
          submitBtn.textContent = `Retrying... (${attempt}/${maxAttempts})`;
          updateSubmitStatus(`Still saving your application (${attempt}/${maxAttempts}). Please keep this tab open.`, 'info');
        } else {
          submitBtn.textContent = 'Submitting...';
          updateSubmitStatus('Uploading your application. Please stay on this page.');
        }
      }
    });
    const assignedUsername = savedData && savedData.username ? savedData.username : data.username;
    if (assignedUsername) {
      data.username = assignedUsername;
    }
    if (uploadedAssets.photo) {
      data.applicantPhotoRemote = uploadedAssets.photo.url;
    }
    if (uploadedAssets.documents?.length) {
      data.uploadedDocuments = uploadedAssets.documents;
    }
    populateAdmissionDocument(data);
    await renderBarcode(barcode);
    
    // Store data globally for PDF download
  window.currentApplicationData = {
    ...data,
    documentPreviews: data.documentPreviews || (Array.isArray(data.documents) ? data.documents : [])
  };

    form.dataset.submitted = 'true';
    submitBtn.textContent = 'Application Submitted ✓';
    updateSubmitStatus('Application saved! Generating credentials...', 'success');
    setTimeout(clearSubmitStatus, 4000);
    
    // Show credentials modal only if credentials were saved
    if (assignedUsername) {
      showCredentialsModal(assignedUsername, password, referenceNumber);
      // Send welcome email with credentials
      sendApplicationSubmittedEmail(data, assignedUsername, password, referenceNumber);
    } else {
      // Fallback: show success message without credentials
      showModal('✅ Application Submitted Successfully!\n\nReference Number: ' + referenceNumber + '\n\nYour application has been received. You will be contacted via email regarding next steps.', 'success');
    }
    
    console.log('Form data saved:', data);
  } catch (error) {
    console.error('Admission processing failed', error);
    submitBtn.disabled = false;
    submitBtn.textContent = 'Submit Application';
    updateSubmitStatus('We could not submit your application after several attempts. Please check your connection and try again.', 'error');
    
    // Check if it's a database column error
    if (isMissingColumnError(error)) {
      showModal('⚠️ Database Update Required\n\nThe database schema needs to be updated. Please run the ADD-APPLICATION-CREDENTIALS.sql file in Supabase first.\n\nContact your administrator to run the database migration.', 'error');
    } else if (isNetworkError(error)) {
      // Network/timeout error - show user-friendly message
      showModal('⏱️ Connection Timeout\n\nWe tried submitting your application multiple times but the connection kept dropping.\n\nPlease try again:\n✓ Check your internet connection\n✓ Try switching between WiFi and mobile data\n✓ Close other apps/tabs using bandwidth\n✓ Move closer to your WiFi router\n\nYour information is still in this form, so tap Submit again once your connection is stable.', 'error');
    } else {
      showModal('We could not finish saving your application. Please try again or contact admissions.\n\nError: ' + (error.message || 'Unknown error'), 'error');
    }
  }
}

/**
 * Display credentials modal to applicant after successful submission
 */
function showCredentialsModal(username, password, referenceNumber) {
  const modalHTML = `
    <div id="credentialsModal" style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(44, 62, 80, 0.95); z-index: 10000; display: flex; align-items: center; justify-content: center; padding: 20px;">
      <div id="credentialsContent" style="background: white; border-radius: 8px; padding: 3rem; max-width: 600px; width: 100%; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
        
        <div style="text-align: center; margin-bottom: 2rem;">
          <div style="width: 80px; height: 80px; background: #3498db; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.5rem;">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
              <circle cx="12" cy="7" r="4"></circle>
            </svg>
          </div>
          <h2 style="margin: 0; color: #2c3e50; font-size: 1.75rem; font-weight: 600;">Application Submitted Successfully!</h2>
          <p style="margin: 0.5rem 0 0; color: #666; font-size: 1rem;">Your login credentials have been generated</p>
        </div>

        <div style="background: #fff3cd; border: 1px solid #ffc107; border-radius: 4px; padding: 1.5rem; margin-bottom: 1.5rem;">
          <p style="margin: 0 0 1.25rem; color: #856404; font-weight: 600; font-size: 0.95rem;">
            ⚠️ IMPORTANT: Please save these credentials immediately.<br>You will need them to track your application status.
          </p>
          
          <div style="margin-bottom: 1rem;">
            <label style="display: block; font-weight: 500; color: #2c3e50; margin-bottom: 0.5rem; font-size: 0.9rem;">Reference Number</label>
            <div style="background: white; border: 1px solid #ddd; border-radius: 4px; padding: 0.75rem; font-family: 'Courier New', monospace; font-size: 1rem; color: #333;">
              ${referenceNumber}
            </div>
          </div>

          <div style="margin-bottom: 1rem;">
            <label style="display: block; font-weight: 500; color: #2c3e50; margin-bottom: 0.5rem; font-size: 0.9rem;">Username</label>
            <div style="background: white; border: 1px solid #ddd; border-radius: 4px; padding: 0.75rem; font-family: 'Courier New', monospace; font-size: 1rem; color: #333;">
              ${username}
            </div>
          </div>

          <div style="margin-bottom: 0;">
            <label style="display: block; font-weight: 500; color: #2c3e50; margin-bottom: 0.5rem; font-size: 0.9rem;">Password</label>
            <div style="background: white; border: 1px solid #ddd; border-radius: 4px; padding: 0.75rem; font-family: 'Courier New', monospace; font-size: 1rem; color: #333; letter-spacing: 1px;">
              ${password}
            </div>
          </div>
        </div>

        <div style="background: #e8f4fd; border-left: 4px solid #3498db; padding: 1rem; margin-bottom: 1.5rem; border-radius: 4px;">
          <p style="margin: 0; color: #2c3e50; font-size: 0.9rem; line-height: 1.6;">
            <strong>📝 What's Next?</strong><br>
            Use these credentials to log in and track your application status in real-time. You'll receive updates as your application moves through our review process.
          </p>
        </div>

        <div style="display: flex; gap: 0.75rem; flex-wrap: wrap;">
          <button onclick="copyCredentials('${username}', '${password}', '${referenceNumber}')" style="flex: 1; min-width: 140px; background: #3498db; color: white; border: none; padding: 0.75rem 1rem; border-radius: 4px; font-size: 1rem; font-weight: 500; cursor: pointer; transition: background-color 0.3s;">
            📋 Copy All
          </button>
          <button onclick="window.location.href='Student-page.html'" style="flex: 1; min-width: 140px; background: #27ae60; color: white; border: none; padding: 0.75rem 1rem; border-radius: 4px; font-size: 1rem; font-weight: 500; cursor: pointer; transition: background-color 0.3s;">
            🔍 Track Status
          </button>
          <button onclick="closeCredentialsModal()" style="flex: 1; min-width: 140px; background: #95a5a6; color: white; border: none; padding: 0.75rem 1rem; border-radius: 4px; font-size: 1rem; font-weight: 500; cursor: pointer; transition: background-color 0.3s;">
            Close
          </button>
        </div>

      </div>
    </div>
  `;
  
  document.body.insertAdjacentHTML('beforeend', modalHTML);
  
  // Capture screenshot after modal is rendered
  setTimeout(() => captureCredentialsScreenshot(referenceNumber), 500);
}

/**
 * Copy credentials to clipboard
 */
function copyCredentials(username, password, referenceNumber) {
  const text = `Application Credentials
━━━━━━━━━━━━━━━━━━━━
Reference Number: ${referenceNumber}
Username: ${username}
Password: ${password}

Login at: [Your Domain]/application-status.html`;

  navigator.clipboard.writeText(text).then(() => {
    const btn = event.target;
    const originalText = btn.textContent;
    btn.textContent = '✓ Copied!';
    btn.style.background = '#27ae60';
    setTimeout(() => {
      btn.textContent = originalText;
      btn.style.background = '#3498db';
    }, 2000);
  }).catch(err => {
    console.error('Copy failed:', err);
    alert('Could not copy to clipboard. Please copy manually.');
  });
}

/**
 * Capture screenshot of credentials modal
 */
async function captureCredentialsScreenshot(referenceNumber) {
  console.log('🔍 DEBUG: Starting screenshot capture for:', referenceNumber);
  
  try {
    const credentialsContent = document.getElementById('credentialsContent');
    if (!credentialsContent) {
      console.error('❌ ERROR: Credentials content element not found');
      return;
    }
    
    console.log('✅ DEBUG: Credentials content found, dimensions:', {
      width: credentialsContent.offsetWidth,
      height: credentialsContent.offsetHeight
    });

    // Check if html2canvas is available
    if (typeof html2canvas === 'undefined') {
      console.error('❌ ERROR: html2canvas library not loaded!');
      return;
    }
    
    console.log('✅ DEBUG: html2canvas library is available');

    // Use html2canvas to capture the modal content
    console.log('📸 DEBUG: Capturing screenshot with html2canvas...');
    const canvas = await html2canvas(credentialsContent, {
      scale: 2,
      backgroundColor: '#ffffff',
      logging: false,
      useCORS: true
    });
    
    console.log('✅ DEBUG: Canvas created, dimensions:', {
      width: canvas.width,
      height: canvas.height
    });

    // Convert canvas to base64 data URL
    const screenshotDataUrl = canvas.toDataURL('image/png');
    const screenshotSize = (screenshotDataUrl.length * 0.75 / 1024).toFixed(2); // Approximate size in KB
    console.log('✅ DEBUG: Screenshot converted to base64, size:', screenshotSize, 'KB');
    
    // Save to database
    console.log('💾 DEBUG: Saving screenshot to Supabase...');
    const client = initSupabase();
    const { data, error } = await client
      .from('applications')
      .update({ credentials_screenshot: screenshotDataUrl })
      .eq('reference_number', referenceNumber)
      .select('reference_number, credentials_screenshot');

    if (error) {
      console.error('❌ ERROR: Failed to save screenshot to database:', error);
      console.error('Error details:', {
        message: error.message,
        code: error.code,
        details: error.details
      });
    } else {
      console.log('✅ SUCCESS: Credentials screenshot saved to database!');
      console.log('Saved data:', {
        referenceNumber: data?.[0]?.reference_number,
        hasScreenshot: !!data?.[0]?.credentials_screenshot,
        screenshotSize: screenshotSize + ' KB'
      });
    }
  } catch (error) {
    console.error('❌ FATAL ERROR: Exception during screenshot capture:', error);
    console.error('Stack trace:', error.stack);
  }
}

/**
 * Close credentials modal
 */
function closeCredentialsModal() {
  const modal = document.getElementById('credentialsModal');
  if (modal) {
    modal.remove();
  }
}

function isMissingColumnError(error) {
  if (!error) return false;
  if (error.code === '42703') return true;
  const message = error.message ? error.message.toLowerCase() : '';
  return message.includes('column') && message.includes('does not exist');
}

function isNetworkError(error) {
  if (!error) return false;
  
  // Check for TypeError (most common for fetch failures)
  if (error.name === 'TypeError' || error.constructor.name === 'TypeError') {
    return true;
  }
  
  // Check for common network error messages
  const message = (error.message || '').toLowerCase();
  const networkErrors = [
    'failed to fetch',
    'network error',
    'network request failed',
    'timeout',
    'timed out',
    'connection refused',
    'connection reset',
    'connection aborted',
    'connection closed',
    'no internet',
    'offline',
    'unreachable',
    'cors',
    'net::err'
  ];
  
  return networkErrors.some(errText => message.includes(errText));
}

function isTimeoutError(error) {
  if (!error || !error.message) return false;
  return error.message.toLowerCase().includes('timeout');
}

function isRetryableError(error) {
  return isNetworkError(error) || isTimeoutError(error);
}

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function promiseWithTimeout(promise, timeoutMs = 45000, timeoutMessage = 'Request timed out') {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      reject(new Error(timeoutMessage));
    }, timeoutMs);

    promise
      .then(value => {
        clearTimeout(timer);
        resolve(value);
      })
      .catch(error => {
        clearTimeout(timer);
        reject(error);
      });
  });
}

async function fetchExistingApplication(referenceNumber) {
  if (!referenceNumber) return null;
  const supabase = initSupabase();
  if (!supabase) return null;
  try {
    const { data, error } = await supabase
      .from('applications')
      .select('id, reference_number, username, submission_date')
      .eq('reference_number', referenceNumber)
      .limit(1);
    if (error) {
      console.warn('Existing application lookup failed:', error);
      return null;
    }
    return data && data.length > 0 ? data[0] : null;
  } catch (lookupError) {
    console.warn('Existing application lookup error:', lookupError);
    return null;
  }
}

async function saveApplicationWithRetries(data, options = {}) {
  const {
    maxAttempts = 3,
    timeoutMs = 45000,
    onStatus
  } = options;

  let attempt = 0;
  let lastError = null;

  while (attempt < maxAttempts) {
    attempt++;
    if (typeof onStatus === 'function') {
      onStatus({ attempt, maxAttempts, stage: attempt === 1 ? 'initial' : 'retry' });
    }

    try {
      const result = await promiseWithTimeout(saveApplicationToSupabase(data), timeoutMs, 'Submission timed out');
      return result;
    } catch (error) {
      lastError = error;
      console.warn(`Submission attempt ${attempt} failed`, error);

      const alreadySaved = await fetchExistingApplication(data.referenceNumber);
      if (alreadySaved) {
        console.warn('Application appears to be saved already. Using existing record.');
        return alreadySaved;
      }

      const retryable = isRetryableError(error);
      if (!retryable || attempt >= maxAttempts) {
        error.attempts = attempt;
        throw error;
      }

      const delayMs = Math.min(5000, 1500 * attempt);
      if (typeof onStatus === 'function') {
        onStatus({ attempt, maxAttempts, stage: 'waiting', delayMs });
      }
      await delay(delayMs);
    }
  }

  throw lastError;
}

function isDuplicateUsernameError(error) {
  if (!error) return false;
  const message = (error.message || '').toLowerCase();
  const details = (error.details || '').toLowerCase();
  return error.code === '23505' && (message.includes('username') || details.includes('username'));
}

function regenerateUsernameSlug(username) {
  const randomDigits = Math.floor(1000 + Math.random() * 9000);
  if (!username) {
    return `applicant.${randomDigits}`;
  }
  const parts = username.split('.');
  if (parts.length >= 3) {
    return `${parts.slice(0, parts.length - 1).join('.')}.${randomDigits}`;
  }
  return `${username}.${randomDigits}`;
}

const DOCUMENT_FIELD_NAMES = ['document_id', 'control_number', 'verification_hash', 'applicant_name_armenian'];
const CREDENTIAL_FIELD_NAMES = ['username', 'password_hash', 'status', 'plain_password'];

function detectMissingColumn(error) {
  if (!error || !error.message) return null;
  const message = error.message.toLowerCase();
  const allColumns = DOCUMENT_FIELD_NAMES.concat(CREDENTIAL_FIELD_NAMES);
  return allColumns.find(column => message.includes(column));
}

function buildApplicationRecord(baseRecord, data, includeDocumentFields, includeCredentialFields) {
  const record = { ...baseRecord };

  if (includeDocumentFields) {
    if (data.documentId) record.document_id = data.documentId;
    if (data.controlNumber) record.control_number = data.controlNumber;
    if (data.verificationHash) record.verification_hash = data.verificationHash;
    if (data.fullNameArmenian) record.applicant_name_armenian = data.fullNameArmenian;
  }

  if (includeCredentialFields) {
    if (data.username) record.username = data.username;
    if (data.passwordHash) record.password_hash = data.passwordHash;
    if (data.status) record.status = data.status;
    // Store plain password for admin viewing
    if (data.latestCredentials && data.latestCredentials.password) {
      record.plain_password = data.latestCredentials.password;
    }
  }

  return record;
}

async function saveApplicationToSupabase(data) {
  const client = initSupabase();
  if (!client) throw new Error('Supabase client not initialized');

  const baseRecord = {
    reference_number: data.referenceNumber,
    control_number: data.controlNumber,
    document_id: data.documentId,
    barcode: data.barcode,
    hash: data.verificationHash,
    applicant_name: data.applicantName,
    email: data.email,
    phone: data.phone,
    date_of_birth: data.dobIso || data.rawDob || null,
    program: data.programChoice,
    start_term: data.startTerm,
    submission_date: new Date().toISOString(),
    payload: data
  };

  const maxUsernameAttempts = 5;
  let attempt = 0;
  let includeDocumentFields = true;
  let includeCredentialFields = true;

  while (attempt < maxUsernameAttempts) {
    const record = buildApplicationRecord(baseRecord, data, includeDocumentFields, includeCredentialFields);

    const { data: inserted, error } = await client
      .from('applications')
      .insert([record])
      .select()
      .single();

    if (!error) {
      return inserted;
    }

    if (isDuplicateUsernameError(error) && includeCredentialFields) {
      console.warn('Username collision detected, generating a new username', error);
      data.username = regenerateUsernameSlug(data.username);
      attempt++;
      continue;
    }

    if (isMissingColumnError(error)) {
      const missingColumn = detectMissingColumn(error);
      let adjusted = false;
      
      const exactMatch = error.message && error.message.match(/column "([^"]+)" of relation/i);
      const actualMissing = exactMatch ? exactMatch[1] : missingColumn;
      if (actualMissing && baseRecord.hasOwnProperty(actualMissing)) {
        delete baseRecord[actualMissing];
        console.warn(`Removed missing column ${actualMissing} from baseRecord and retrying.`);
        adjusted = true;
      }

      if (missingColumn && DOCUMENT_FIELD_NAMES.includes(missingColumn) && includeDocumentFields) {
        includeDocumentFields = false;
        adjusted = true;
      } else if (missingColumn && CREDENTIAL_FIELD_NAMES.includes(missingColumn) && includeCredentialFields) {
        includeCredentialFields = false;
        adjusted = true;
      } else if (includeDocumentFields || includeCredentialFields) {
        includeDocumentFields = false;
        includeCredentialFields = false;
        adjusted = true;
      }

      if (adjusted) {
        console.warn(`Column ${missingColumn || 'unknown'} missing. Retrying without optional fields.`, error);
        continue;
      }
    }

    throw error;
  }

  throw new Error('Unable to generate a unique username after multiple attempts. Please try again.');
}

function generateBarcodeValue(referenceNumber) {
  const array = new Uint8Array(4);
  crypto.getRandomValues(array);
  const suffix = Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('').slice(0, 6).toUpperCase();
  return `${referenceNumber}-${suffix}`;
}

function renderBarcode(value) {
  return new Promise((resolve, reject) => {
    const target = document.getElementById('barcodeSvg');
    if (!target) {
      resolve();
      return;
    }

    if (typeof JsBarcode === 'undefined') {
      reject(new Error('JsBarcode unavailable'));
      return;
    }

    try {
      JsBarcode(target, value, {
        format: 'code128',
        lineColor: '#0f172a',
        width: 2,
        height: 60,
        displayValue: true,
        fontSize: 13,
        background: '#ffffff',
        margin: 0
      });
      // give the browser a tick to paint the SVG
      requestAnimationFrame(() => resolve());
    } catch (err) {
      reject(err);
    }
  });
}

async function buildAndDownloadAdmissionPdf() {
  if (typeof html2pdf === 'undefined') {
    throw new Error('html2pdf library unavailable');
  }

  const source = document.getElementById('admissionDocument');
  if (!source) {
    throw new Error('Admission document template missing');
  }

  const previousDisplay = source.style.display;
  const previousPosition = source.style.position;
  const previousLeft = source.style.left;
  const previousTop = source.style.top;

  source.style.display = 'block';
  source.style.position = 'absolute';
  source.style.left = '-9999px';
  source.style.top = '0';
  await waitForAssets(source);

  const options = {
    filename: 'ACNHS-Admission-Receipt.pdf',
    margin: [10, 10, 10, 10],
    image: { type: 'jpeg', quality: 0.98 },
    html2canvas: { scale: 2, useCORS: true, backgroundColor: '#ffffff' },
    jsPDF: { unit: 'pt', format: 'letter', orientation: 'portrait' }
  };

  try {
    await html2pdf().set(options).from(source).save();
  } finally {
    source.style.display = previousDisplay || 'none';
    source.style.position = previousPosition || '';
    source.style.left = previousLeft || '';
    source.style.top = previousTop || '';
  }
}

function waitForAssets(container) {
  const images = Array.from(container.querySelectorAll('img')).filter(img => !img.complete || img.naturalWidth === 0);
  if (!images.length) return Promise.resolve();

  return Promise.all(images.map(img => new Promise(resolve => {
    const done = () => resolve();
    img.onload = done;
    img.onerror = done;
  })));
}

const INVALID_NAME_PLACEHOLDERS = new Set(['', 'undefined', 'null', 'n/a', 'na', 'none', '-', '—', 'applicant', 'student']);

function sanitizeNameValue(value) {
  if (value === undefined || value === null) return '';
  const text = String(value)
    .replace(/\b(undefined|null|n\/a|na)\b/gi, ' ')
    .replace(/[<>]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  if (!text) return '';
  if (INVALID_NAME_PLACEHOLDERS.has(text.toLowerCase())) return '';
  return text;
}

function toTitleCaseName(name) {
  return name
    .split(/\s+/)
    .filter(Boolean)
    .map(part => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function buildFullName(...parts) {
  const cleanedParts = parts
    .map(sanitizeNameValue)
    .filter(Boolean);
  if (!cleanedParts.length) return '';
  return toTitleCaseName(cleanedParts.join(' '));
}

function resolveApplicantNameFromData(data = {}) {
  const candidates = [
    data.applicantName,
    `${data.firstName || ''} ${data.lastName || ''}`,
    `${data.first_name || ''} ${data.last_name || ''}`,
    data.full_name,
    data.fullName,
    data.signature,
    data.metadata?.applicant_name,
    data.metadata?.full_name,
    data.payload?.applicantName,
    data.payload?.fullName,
    data.payload?.personal_information?.fullName
  ];

  for (const candidate of candidates) {
    const cleaned = sanitizeNameValue(candidate);
    if (cleaned) return toTitleCaseName(cleaned);
  }

  if (data.email) {
    const localPart = data.email.split('@')[0];
    const cleanedEmailName = sanitizeNameValue(localPart.replace(/[._-]+/g, ' '));
    if (cleanedEmailName) return toTitleCaseName(cleanedEmailName);
  }

  return 'Student';
}

function gatherAdmissionData() {
  const formData = new FormData(form);
  const getValue = name => (formData.get(name) || '').toString().trim();
  const getSelectText = name => {
    const field = form.querySelector(`[name="${name}"]`);
    if (field && field.options && field.selectedIndex >= 0) {
      return field.options[field.selectedIndex].textContent.trim();
    }
    return getValue(name);
  };

  const firstName = getValue('firstName');
  const middleName = getValue('middleName');
  const lastName = getValue('lastName');
  const fullNameArmenian = getValue('fullNameArmenian');
  const applicantName = buildFullName(firstName, middleName, lastName) || 'Applicant';
  const birthLocation = [getValue('birthCity'), getValue('birthCountry')]
    .filter(Boolean)
    .join(', ') || '—';
  const addressLine = [getValue('address'), getValue('city'), getValue('state'), getValue('postalCode'), getValue('country')]
    .filter(Boolean)
    .join(', ') || '—';

  const dobInputValue = getValue('dob') || getValue('dateOfBirth');

  const documents = {
    passport: documentStatus('passportUpload'),
    diploma: documentStatus('diplomaUpload'),
    transcript: documentStatus('transcriptUpload'),
    english: documentStatus('englishUpload', true),
    recommendation: documentStatus('recommendationUpload', true)
  };

  // Handle US Immigration Status - combine radio selection with "Other" text field
  let usImmigrationStatusValue = getValue('usImmigrationStatus') || '—';
  if (usImmigrationStatusValue === 'Other') {
    const otherValue = getValue('usImmigrationStatusOther');
    usImmigrationStatusValue = otherValue ? `Other: ${otherValue}` : 'Other (not specified)';
  }

  return {
    applicantName,
    firstName,
    middleName,
    lastName,
    fullNameArmenian,
  dob: formatDateValue(dobInputValue),
  rawDob: dobInputValue || null,
  dobIso: formatDateIsoValue(dobInputValue),
    gender: getSelectText('gender') || '—',
    nationality: getValue('nationality') || '—',
    birthLocation,
    // Armenian citizenship and immigration status
    armenianCitizen: getValue('armenianCitizen') || '—',
    usImmigrationStatus: usImmigrationStatusValue,
    lastTimeInArmenia: formatDateValue(getValue('lastTimeInArmenia')) || '—',
    armeniaExitDate: formatDateValue(getValue('armeniaExitDate')) || '—',
    email: getValue('email') || '—',
    phone: getValue('phone') || '—',
    altPhone: getValue('altPhone') || 'Not provided',
    addressLine,
    emergencyName: getValue('emergencyName') || '—',
    emergencyRelation: getValue('emergencyRelation') || '—',
    emergencyPhone: getValue('emergencyPhone') || '—',
    educationLevel: getSelectText('education') || '—',
    institution: getValue('institution') || '—',
    fieldOfStudy: getValue('fieldOfStudy') || '—',
    gradYear: getValue('gradYear') || '—',
    gpa: getValue('gpa') || '—',
    programChoice: getSelectText('program') || '—',
    startTerm: getSelectText('startDate') || '—',
    previousApplication: getSelectText('previousApplication') || '—',
    // Transfer student information
    isTransferStudent: getValue('isTransferStudent'),
    prevInstitution: getValue('prevInstitution') || '—',
    prevProgram: getValue('prevProgram') || '—',
    prevStudentId: getValue('prevStudentId') || 'N/A',
    prevStartDate: getValue('prevStartDate') || '—',
    prevEndDate: getValue('prevEndDate') || '—',
    academicStatus: getSelectText('academicStatus') || '—',
    transferReason: getValue('transferReason') || '—',
    creditsEarned: getValue('creditsEarned') || '—',
    creditsTransfer: getValue('creditsTransfer') || '—',
    prevGPA: getValue('prevGPA') || '—',
    completedCourses: getValue('completedCourses') || '—',
    documents,
    statement: summarizeStatement(getValue('personalStatement')),
    declaration: form.querySelector('[name="declaration"]').checked ? 'Confirmed' : 'Pending',
    consent: form.querySelector('[name="dataConsent"]').checked ? 'Granted' : 'Pending'
  };
}

// NEW: Async function to gather data WITH photo and document files
async function gatherAdmissionDataWithFiles() {
  const baseData = gatherAdmissionData();
  baseData.documentStatuses = { ...baseData.documents };
  
  // Get photo as base64
  const photoInput = document.getElementById('photoUpload');
  if (photoInput && photoInput.files && photoInput.files[0]) {
    try {
      baseData.applicantPhoto = await fileToBase64(photoInput.files[0]);
    } catch (error) {
      console.error('Error reading photo:', error);
    }
  }
  
  // Get documents as base64 array (for immediate preview only)
  const documentPreviews = [];
  for (const doc of DOCUMENT_UPLOAD_FIELDS) {
    const input = document.getElementById(doc.id);
    if (input && input.files && input.files.length > 0) {
      for (let i = 0; i < input.files.length; i++) {
        const file = input.files[i];
        try {
          const data = await fileToBase64(file);
          documentPreviews.push({
            name: doc.name + (input.files.length > 1 ? ` (${i + 1})` : ''),
            fileName: file.name,
            data: data
          });
        } catch (error) {
          console.error(`Error reading ${file.name}:`, error);
        }
      }
    }
  }
  
  if (documentPreviews.length > 0) {
    baseData.documentPreviews = documentPreviews;
  }
  
  // Add signature (applicant name)
  baseData.signature = baseData.applicantName;
  
  return baseData;
}

// Helper function to convert file to base64
function fileToBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

function sanitizeFileName(fileName = '') {
  return fileName
    .toLowerCase()
    .replace(/[^a-z0-9.\-]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '') || 'file';
}

function deepClonePayload(data) {
  if (typeof structuredClone === 'function') {
    return structuredClone(data);
  }
  return JSON.parse(JSON.stringify(data));
}

async function uploadApplicationAssets(referenceNumber) {
  const client = initSupabase();
  if (!client) throw new Error('Supabase client not initialized');
  if (!APPLICATION_STORAGE_BUCKET) throw new Error('Storage bucket not configured');

  const storage = client.storage.from(APPLICATION_STORAGE_BUCKET);
  const folder = `${APPLICATION_STORAGE_FOLDER}/${referenceNumber}`;
  const uploads = { photo: null, documents: [] };

  const photoInput = document.getElementById('photoUpload');
  if (photoInput && photoInput.files && photoInput.files[0]) {
    const photoFile = photoInput.files[0];
    const photoPath = `${folder}/photo-${Date.now()}-${sanitizeFileName(photoFile.name)}`;
    const { error: photoError } = await storage.upload(photoPath, photoFile, {
      cacheControl: '86400',
      upsert: true,
      contentType: photoFile.type || 'application/octet-stream'
    });
    if (photoError) {
      console.error('Photo upload failed:', photoError);
      throw new Error(photoError.message || 'Unable to upload applicant photo');
    }
    const { data: publicPhoto } = storage.getPublicUrl(photoPath);
    uploads.photo = {
      path: photoPath,
      url: publicPhoto?.publicUrl || null,
      fileName: photoFile.name,
      contentType: photoFile.type || 'application/octet-stream',
      size: photoFile.size,
      uploadedAt: new Date().toISOString()
    };
  }

  for (const doc of DOCUMENT_UPLOAD_FIELDS) {
    const input = document.getElementById(doc.id);
    if (!input || !input.files || input.files.length === 0) continue;

    for (let i = 0; i < input.files.length; i++) {
      const file = input.files[i];
      const label = doc.name + (input.files.length > 1 ? ` (${i + 1})` : '');
      const docPath = `${folder}/documents/${doc.id}/${Date.now()}-${sanitizeFileName(file.name)}`;
      const { error: docError } = await storage.upload(docPath, file, {
        cacheControl: '86400',
        upsert: true,
        contentType: file.type || 'application/octet-stream'
      });
      if (docError) {
        console.error(`Upload failed for ${label}:`, docError);
        throw new Error(docError.message || `Unable to upload ${label}`);
      }
      const { data: publicDoc } = storage.getPublicUrl(docPath);
      uploads.documents.push({
        path: docPath,
        url: publicDoc?.publicUrl || null,
        name: label,
        fileName: file.name,
        bucket: APPLICATION_STORAGE_BUCKET,
        contentType: file.type || 'application/octet-stream',
        size: file.size,
        uploadedAt: new Date().toISOString(),
        fieldId: doc.id,
        optional: !!doc.optional
      });
    }
  }

  return uploads;
}

function createSupabasePayload(originalData, uploads) {
  const sanitized = deepClonePayload(originalData);
  ['documentPreviews', 'documentsPreview', 'documentFiles'].forEach(key => {
    if (sanitized[key]) delete sanitized[key];
  });

  if (uploads.photo) {
    sanitized.applicantPhotoMeta = uploads.photo;
    sanitized.applicantPhotoUrl = uploads.photo.url;
    sanitized.applicantPhoto = uploads.photo.url;
  } else {
    sanitized.applicantPhotoMeta = null;
    sanitized.applicantPhotoUrl = null;
    sanitized.applicantPhoto = null;
  }

  sanitized.uploadedDocuments = uploads.documents;
  sanitized.documentUploads = uploads.documents;
  sanitized.attachmentsSummary = {
    bucket: APPLICATION_STORAGE_BUCKET,
    folder: `${APPLICATION_STORAGE_FOLDER}/${originalData.referenceNumber}`,
    documentCount: uploads.documents.length,
    hasPhoto: Boolean(uploads.photo),
    totalBytes:
      uploads.documents.reduce((sum, doc) => sum + (doc.size || 0), 0) +
      (uploads.photo?.size || 0)
  };

  if (sanitized.documentStatuses) {
    sanitized.documents = sanitized.documentStatuses;
  }

  return sanitized;
}

function summarizeStatement(text) {
  if (!text) return 'Statement on file.';
  const cleaned = text.replace(/\s+/g, ' ').trim();
  return cleaned.length > 500 ? `${cleaned.slice(0, 500)}…` : cleaned;
}

function formatDateValue(value) {
  if (!value) return '—';
  
  // Parse date in local timezone to avoid timezone shift issues
  // Input format: YYYY-MM-DD from date input
  const parts = value.split('-');
  if (parts.length === 3) {
    const year = parseInt(parts[0], 10);
    const month = parseInt(parts[1], 10) - 1; // Month is 0-indexed
    const day = parseInt(parts[2], 10);
    const parsed = new Date(year, month, day);
    return Number.isNaN(parsed.getTime()) ? '—' : dateFormatter.format(parsed);
  }
  
  // Fallback for other formats
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? '—' : dateFormatter.format(parsed);
}

function formatDateIsoValue(value) {
  if (!value) return null;
  
  // CRITICAL FIX: Do NOT use new Date() for date-only values
  // HTML date input provides YYYY-MM-DD format already
  // Using new Date() causes timezone conversion and ±1 day bugs
  
  // Validate YYYY-MM-DD format
  const datePattern = /^\d{4}-\d{2}-\d{2}$/;
  if (!datePattern.test(value)) {
    console.warn('Invalid date format, expected YYYY-MM-DD:', value);
    return null;
  }
  
  // Return exact string - no parsing, no timezone conversion
  return value;
}

function documentStatus(inputId, optional = false) {
  const input = document.getElementById(inputId);
  const provided = input && input.files && input.files.length > 0;
  if (optional) {
    return provided ? 'Received (Optional)' : 'Not Provided (Optional)';
  }
  return provided ? 'Received' : 'Pending';
}

function populateAdmissionDocument(data) {
  const fields = {
    'reference-number': data.referenceNumber,
    'applicant-name': data.applicantName,
    'dob': data.dob,
    'gender': data.gender,
    'nationality': data.nationality,
    'birth-location': data.birthLocation,
    // Armenian citizenship and immigration
    'armenian-citizen': data.armenianCitizen,
    'us-immigration-status': data.usImmigrationStatus,
    'last-time-armenia': data.lastTimeInArmenia,
    'armenia-exit-date': data.armeniaExitDate,
    'email': data.email,
    'phone': data.phone,
    'alt-phone': data.altPhone,
    'address': data.addressLine,
    'barcode-value': data.barcode,
    'program': data.programChoice,
    'start-term': data.startTerm,
    'previous-application': data.previousApplication,
    'education': data.educationLevel,
    'institution': data.institution,
    'field-of-study': data.fieldOfStudy,
    'grad-year': data.gradYear,
    'gpa': data.gpa,
    'emergency-name': data.emergencyName,
    'emergency-relation': data.emergencyRelation,
    'emergency-phone': data.emergencyPhone,
    'doc-passport': data.documents.passport,
    'doc-diploma': data.documents.diploma,
    'doc-transcript': data.documents.transcript,
    'doc-english': data.documents.english,
    'doc-recommendation': data.documents.recommendation,
    'statement': data.statement,
    'declaration': data.declaration,
    'consent': data.consent,
    'submission-date': data.submissionDate
  };

  Object.entries(fields).forEach(([field, value]) => {
    document
      .querySelectorAll(`#admissionDocument [data-field="${field}"]`)
      .forEach(el => {
        el.textContent = value || '—';
      });
  });
}

function generateReferenceNumber() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const random = Math.floor(100 + Math.random() * 900);
  return `ACNHS-ADM-${year}${month}${day}-${random}`;
}

// Generate unique document ID
function generateDocumentId() {
  const now = new Date();
  const year = now.getFullYear();
  const random = Math.floor(100000 + Math.random() * 900000);
  return `ACN-${year}-${random}`;
}

// Generate control number
function generateControlNumber() {
  const now = new Date();
  const year = now.getFullYear();
  const random = Math.floor(100000 + Math.random() * 900000);
  return `ACN-${year}-${random}`;
}

// Generate SHA256-style hash (simplified for frontend)
function generateVerificationHash() {
  const array = new Uint8Array(3);
  crypto.getRandomValues(array);
  return 'SHA256-' + Array.from(array, byte => byte.toString(16).padStart(2, '0').toUpperCase()).join('');
}

// Generate all verification codes at once
function generateVerificationCodes() {
  return {
    documentId: generateDocumentId(),
    controlNumber: generateControlNumber(),
    verificationHash: generateVerificationHash()
  };
}

// ==========================================
// APPLICATION CREDENTIALS GENERATION
// ==========================================

// Generate unique username for applicant
function generateUsername(firstName, lastName) {
  // Format: firstname.lastname.XXXX (XXXX = random 4 digits)
  const cleanFirst = firstName.toLowerCase().replace(/[^a-z]/g, '');
  const cleanLast = lastName.toLowerCase().replace(/[^a-z]/g, '');
  const randomDigits = Math.floor(1000 + Math.random() * 9000); // 4 digits
  return `${cleanFirst}.${cleanLast}.${randomDigits}`;
}

// Generate secure password
function generateSecurePassword() {
  // Password format: Uppercase + lowercase + numbers (12 characters)
  const uppercase = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // Excluding I, O
  const lowercase = 'abcdefghjkmnpqrstuvwxyz'; // Excluding i, l, o
  const numbers = '23456789'; // Excluding 0, 1
  
  let password = '';
  
  // Ensure at least 2 uppercase, 2 lowercase, 2 numbers
  for (let i = 0; i < 2; i++) {
    password += uppercase.charAt(Math.floor(Math.random() * uppercase.length));
  }
  for (let i = 0; i < 2; i++) {
    password += lowercase.charAt(Math.floor(Math.random() * lowercase.length));
  }
  for (let i = 0; i < 2; i++) {
    password += numbers.charAt(Math.floor(Math.random() * numbers.length));
  }
  
  // Add 6 more random characters from all sets
  const allChars = uppercase + lowercase + numbers;
  for (let i = 0; i < 6; i++) {
    password += allChars.charAt(Math.floor(Math.random() * allChars.length));
  }
  
  // Shuffle the password
  return password.split('').sort(() => Math.random() - 0.5).join('');
}

// Hash password using SHA-256
async function hashPassword(password) {
  const encoder = new TextEncoder();
  const data = encoder.encode(password);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// Close warning
window.addEventListener('beforeunload', function(e) {
  const inputs = form.querySelectorAll('input, select, textarea');
  let hasData = false;

  inputs.forEach(input => {
    if (input.value || (input.type === 'file' && input.files.length > 0)) {
      hasData = true;
    }
  });

  if (hasData && !form.dataset.submitted) {
    e.preventDefault();
    e.returnValue = '';
  }
});

// PDF Preview Modal Functions
function showPdfPreview() {
  const modal = document.getElementById('pdfPreviewModal');
  const content = document.getElementById('pdfPreviewContent');
  const admissionDoc = document.getElementById('admissionDocument');
  
  if (!modal || !content || !admissionDoc) {
    throw new Error('Required elements not found for PDF preview');
  }
  
  // Get the admission document HTML
  const documentHTML = admissionDoc.innerHTML;
  
  if (!documentHTML || documentHTML.trim() === '') {
    throw new Error('Admission document is empty');
  }
  
  // Create a styled wrapper for the preview
  content.innerHTML = `
    <style>
      ${getAdmissionDocumentStyles()}
    </style>
    <div class="print-document" style="max-width: 8.5in; margin: 0 auto; background: white; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
      <div class="print-shell">
        ${documentHTML}
      </div>
    </div>
  `;
  
  modal.classList.add('active');
  document.body.style.overflow = 'hidden';
}

function closePdfPreview() {
  const modal = document.getElementById('pdfPreviewModal');
  modal.classList.remove('active');
  document.body.style.overflow = '';
  
  // Show success message after closing preview
  if (window.currentApplicationData) {
    const data = window.currentApplicationData;
    showModal(
      `<strong>Application Submitted Successfully!</strong>\n\n<strong>Reference Number:</strong> ${data.referenceNumber}\n<strong>Barcode:</strong> ${data.barcode}\n\nYou can download your application PDF anytime.\n\nOur admissions team will contact you within 10-15 business days.`,
      'success'
    );
  }
}

async function downloadPdfFromPreview() {
  try {
    await buildAndDownloadAdmissionPdf();
    
    // Show success notification
    const downloadBtn = document.querySelector('.pdf-download-btn');
    const originalText = downloadBtn.innerHTML;
    downloadBtn.innerHTML = '<span>✓</span> Downloaded Successfully!';
    downloadBtn.style.background = 'linear-gradient(135deg, #10b981 0%, #059669 100%)';
    
    setTimeout(() => {
      downloadBtn.innerHTML = originalText;
      downloadBtn.style.background = '';
    }, 2000);
  } catch (error) {
    console.error('PDF download failed:', error);
    showModal('Failed to download PDF. Please try again.', 'error');
  }
}

function getAdmissionDocumentStyles() {
  return `
    @import url('https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;0,600;0,700;1,400&display=swap');
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { background: #f5f0e8; }
    .print-shell {
      font-family: 'EB Garamond', 'Georgia', serif;
      background: #ffffff;
      color: #1a1205;
      font-size: 11pt;
      line-height: 1.5;
      max-width: 8.5in;
      margin: 0 auto;
    }
    p { margin: 0; }
    table { border-collapse: collapse; }
    th, td { vertical-align: top; }
  `;
}

// ==========================================
// PREVIEW SIDEBAR FUNCTIONS
// ==========================================

function togglePreviewSidebar() {
  const sidebar = document.getElementById('previewSidebar');
  const toggle = document.getElementById('previewToggle');
  const body = document.body;
  const iframe = document.getElementById('previewIframe');
  
  // Toggle open state
  const isOpening = !sidebar.classList.contains('open');
  sidebar.classList.toggle('open');
  toggle.classList.toggle('hidden');
  
  if (isOpening) {
    // Always open in fullscreen mode
    sidebar.classList.add('fullscreen');
    body.classList.add('preview-fullscreen');
    // Mark that user has previewed
    hasPreviewedApplication = true;
    updateSubmitButton();
    // Load preview data
    loadPreviewData();
  } else {
    // Close completely
    sidebar.classList.remove('fullscreen');
    body.classList.remove('preview-fullscreen', 'preview-open');
  }
}

function closePreviewSidebar() {
  const sidebar = document.getElementById('previewSidebar');
  const toggle = document.getElementById('previewToggle');
  const body = document.body;
  const iframe = document.getElementById('previewIframe');
  
  // ===== PERFORMANCE FIX: Unload iframe to free memory =====
  // Setting src to about:blank stops all rendering/repainting
  // Massive CPU + memory reduction when preview is closed
  iframe.src = 'about:blank';
  
  // Remove all preview classes
  sidebar.classList.remove('open', 'fullscreen');
  toggle.classList.remove('hidden');
  body.classList.remove('preview-open', 'preview-fullscreen');
}

function loadPreviewData() {
  const iframe = document.getElementById('previewIframe');
  
  try {
    // Gather current form data
    const formData = gatherAdmissionData();
    
    // Generate temporary verification codes for preview
    // Note: These are TEMPORARY and will be regenerated on actual submission
    const previewCodes = generateVerificationCodes();
    formData.documentId = previewCodes.documentId;
    formData.controlNumber = previewCodes.controlNumber;
    formData.verificationHash = previewCodes.verificationHash;
    formData.referenceNumber = generateReferenceNumber();
    formData.barcode = generateBarcodeValue(formData.referenceNumber);
    
    // Convert documents to array format for preview
    const documentInputs = [
      { id: 'passportUpload', name: 'Passport' },
      { id: 'diplomaUpload', name: 'Diploma' },
      { id: 'transcriptUpload', name: 'Transcript' },
      { id: 'englishUpload', name: 'English Test' },
      { id: 'recommendationUpload', name: 'Recommendation' }
    ];
    
    const documentsArray = [];
    let pendingFiles = 0;
    let processedFiles = 0;
    
    // Count total files
    documentInputs.forEach(doc => {
      const input = document.getElementById(doc.id);
      if (input && input.files && input.files.length > 0) {
        pendingFiles += input.files.length;
      }
    });
    
    // Get photo as base64 BEFORE loading iframe
    const photoInput = document.getElementById('photoUpload');
    
    if (photoInput && photoInput.files && photoInput.files[0]) {
      pendingFiles++;
      console.log('📸 Photo found, loading for preview:', photoInput.files[0].name);
      const reader = new FileReader();
      reader.onload = function(e) {
        // Include photo in the data
        formData.applicantPhoto = e.target.result;
        console.log('✅ Photo loaded as base64');
        processedFiles++;
        checkAllFilesLoaded();
      };
      reader.readAsDataURL(photoInput.files[0]);
    }
    
    // Load all documents as base64
    documentInputs.forEach(doc => {
      const input = document.getElementById(doc.id);
      if (input && input.files && input.files.length > 0) {
        for (let i = 0; i < input.files.length; i++) {
          const file = input.files[i];
          const reader = new FileReader();
          reader.onload = function(e) {
            documentsArray.push({
              name: doc.name + (input.files.length > 1 ? ` (${i + 1})` : ''),
              data: e.target.result,
              fileName: file.name
            });
            processedFiles++;
            console.log(`✅ Document loaded: ${doc.name} (${processedFiles}/${pendingFiles})`);
            checkAllFilesLoaded();
          };
          reader.readAsDataURL(file);
        }
      }
    });
    
    // Function to check if all files are loaded
    function checkAllFilesLoaded() {
      if (processedFiles === pendingFiles) {
        // All files loaded, now include documents array
  formData.documentPreviews = documentsArray;
  formData.documents = documentsArray;
        console.log(`✅ All files loaded (${documentsArray.length} documents)`);
        loadIframeWithData(iframe, formData);
      }
    }
    
    // If no files to load, proceed immediately
    if (pendingFiles === 0) {
      console.log('⚠️ No photo or documents to load');
  formData.documentPreviews = [];
  formData.documents = [];
      loadIframeWithData(iframe, formData);
    }
    
  } catch (err) {
    console.error('Error loading preview data:', err);
  }
}

function loadIframeWithData(iframe, formData) {
  try {
    // Store data globally to send via postMessage
    window.previewFormData = formData;
    
    // Load pdf.html without data in URL (URL would be too long with base64 images)
    iframe.src = `pdf.html?preview=true&postMessage=true`;
    
    // Send data via postMessage after iframe loads
    iframe.onload = function() {
      setTimeout(() => {
        if (iframe.contentWindow) {
          iframe.contentWindow.postMessage({
            type: 'PREVIEW_DATA',
            data: window.previewFormData
          }, '*');
          console.log('✅ Preview data sent via postMessage:', {
            hasPhoto: !!formData.applicantPhoto,
            documentsCount: formData.documents?.length || 0
          });
        }
      }, 100);
    };
  } catch (error) {
    console.error('Error loading preview:', error);
    showModal('Failed to load preview. Please check your form data.', 'error');
  }
}

// Add real-time preview update on form changes (optional enhancement)
function initPreviewAutoUpdate() {
  const formInputs = document.querySelectorAll('input, select, textarea');
  formInputs.forEach(input => {
    input.addEventListener('change', () => {
      const sidebar = document.getElementById('previewSidebar');
      if (sidebar.classList.contains('open')) {
        loadPreviewData();
      }
    });
  });
}

// Initialize auto-update when page loads
document.addEventListener('DOMContentLoaded', function() {
  // Set watermark image from base64
  const watermarkImg = document.getElementById('watermarkImg');
  if (watermarkImg && typeof ACNHS_LOGO_DATA_URL !== 'undefined') {
    watermarkImg.src = ACNHS_LOGO_DATA_URL;
  }
  
  // Call existing initialization if needed
  initPreviewAutoUpdate();
});

