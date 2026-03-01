(function () {
  function escHtml(str) {
    const d = document.createElement('div');
    d.textContent = str || '';
    return d.innerHTML;
  }

  function buildPaymentForPhrase(tags) {
    if (tags.size === 0) return null;

    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];

    const parts = [];
    if (tags.has('Enrollment Fee')) parts.push('the Enrollment Fee');
    if (tags.has('This Month')) parts.push("this month's tuition");
    if (tags.has('Next Month')) parts.push("next month's tuition");

    const selectedMonths = months.filter(m => tags.has(m));
    if (selectedMonths.length === 1) {
      parts.push(`the month of ${selectedMonths[0]}`);
    } else if (selectedMonths.length === 2) {
      parts.push(`the months of ${selectedMonths[0]} and ${selectedMonths[1]}`);
    } else if (selectedMonths.length >= 3) {
      const last = selectedMonths[selectedMonths.length - 1];
      const rest = selectedMonths.slice(0, -1);
      parts.push(`the months of ${rest.join(', ')}, and ${last}`);
    }

    if (parts.length === 1) return parts[0];
    const last = parts[parts.length - 1];
    const rest = parts.slice(0, -1);
    return `${rest.join(', ')} and ${last}`;
  }

  function buildPaymentItemList(tags, student) {
    const months = ['January','February','March','April','May','June',
                    'July','August','September','October','November','December'];
    const items = [];
    if (tags.has('Enrollment Fee')) items.push({ label: 'Enrollment Fee', key: 'Enrollment Fee' });
    if (tags.has('This Month')) items.push({ label: "Current Month's Tuition", key: null });
    if (tags.has('Next Month')) items.push({ label: "Upcoming Month's Tuition", key: null });
    months.filter(m => tags.has(m)).forEach(m => items.push({ label: `${m} Tuition`, key: m }));
    if (items.length < 1) return '';

    return `
      <table role="presentation" cellpadding="0" cellspacing="0" style="margin:14px 0 22px;border-collapse:collapse;width:100%;">
        ${items.map(({ label, key }) => {
          const st = (key && student && student.monthStatuses) ? (student.monthStatuses[key] || 'unpaid') : 'unpaid';
          const isPaid    = st === 'paid';
          const isPartial = st === 'partial';

          // Calculate % remaining for partial items
          let pctLabel = '';
          if (isPartial && key && student && student.monthAmounts && student.monthAmounts[key]) {
            const { paid, total } = student.monthAmounts[key];
            if (total > 0) {
              const remaining = total - paid;
              const pctRemaining = Math.round((remaining / total) * 100);
              pctLabel = ` (${pctRemaining}% left)`;
            }
          }

          const bg      = isPaid ? '#f0fdf4' : isPartial ? '#fffbeb' : '#fef5f5';
          const border  = isPaid ? '#bbf7d0' : isPartial ? '#fde68a' : '#fecaca';
          const dotClr  = isPaid ? '#16a34a' : isPartial ? '#d97706' : '#dc2626';
          const textClr = isPaid ? '#14532d' : isPartial ? '#78350f'  : '#991b1b';
          const badgeClr= isPaid ? '#22c55e' : isPartial ? '#f59e0b'  : '#ef4444';
          const badge   = isPaid ? 'PAID'    : isPartial ? `PARTIAL${pctLabel}` : 'UNPAID';
          const shadow  = isPaid ? 'rgba(34,197,94,0.08)' : 'rgba(220,38,38,0.08)';
          return `
        <tr>
          <td style="padding:10px 14px;background:${bg};border:1px solid ${border};border-radius:6px;font-family:Arial,Helvetica,sans-serif;font-size:14px;font-weight:600;color:${textClr};letter-spacing:0.01em;box-shadow:0 0 10px ${shadow};">
            <div style="display:flex; justify-content:space-between; align-items:center;">
              <div>
                <span style="display:inline-block;width:7px;height:7px;background:${dotClr};border-radius:50%;vertical-align:middle;margin-right:10px;box-shadow:0 0 5px ${dotClr}80;"></span>
                ${label}
              </div>
              <div style="font-size:11px; font-weight:700; color:${badgeClr}; letter-spacing:0.05em;">${badge}</div>
            </div>
          </td>
        </tr>
        <tr><td style="height:8px;"></td></tr>`;
        }).join('')}
      </table>
    `;
  }

  function buildPaymentReminderEmail(student, tags, customMsg) {
    const today = new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' });

    const phrase = buildPaymentForPhrase(tags);
    const itemList = buildPaymentItemList(tags, student);

    // Classify what's selected: all paid, all unpaid/partial, or mixed
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    const selectedKeys = [];
    if (tags.has('Enrollment Fee')) selectedKeys.push('Enrollment Fee');
    months.filter(m => tags.has(m)).forEach(m => selectedKeys.push(m));
    const statuses = selectedKeys.map(k => (student && student.monthStatuses && student.monthStatuses[k]) || 'unpaid');
    const allPaid    = statuses.length > 0 && statuses.every(s => s === 'paid');
    const anyUnpaid  = statuses.some(s => s === 'unpaid' || s === 'partial');
    const mixedPaid  = statuses.some(s => s === 'paid') && anyUnpaid;

    const customMsgHtml = customMsg
      ? `<p style="margin:0 0 16px;padding:12px 16px;background:#fef3c7;border-left:3px solid #f59e0b;border-radius:0 8px 8px 0;font-family:Arial,Helvetica,sans-serif;font-size:14px;color:#92400e;">${escHtml(customMsg).replace(/\n/g, '<br>')}</p>`
      : '';

    const multiItems = tags.size > 1;

    // Subject line
    let subject;
    if (allPaid) {
      subject = phrase
        ? `Payment Confirmation — ${phrase.replace(/^the\s/i,'').replace(/^the months? of\s/i,'')} — Thank You`
        : 'Payment Confirmation — Thank You';
    } else {
      subject = phrase
        ? `Payment Reminder — ${multiItems ? 'Outstanding Balances' : phrase.replace(/^the\s/i,'').replace(/^the months? of\s/i,'') + ' Payment'} — Action Required`
        : 'Payment Reminder — Action Required';
    }

    // Opening sentence
    let openingSentence;
    if (!phrase) {
      openingSentence = 'This is a formal reminder that your student account currently reflects an outstanding balance. Please remit payment at your earliest convenience.';
    } else if (allPaid) {
      openingSentence = 'We are pleased to confirm that we have received your payment for the following item(s). Your account has been updated accordingly:';
    } else if (mixedPaid) {
      openingSentence = 'This is a summary of your recent payment activity. Please review the status of each item below:';
    } else {
      openingSentence = 'This is a formal reminder that your student account currently reflects outstanding balances for the following items:';
    }

    const urgencyParagraph = anyUnpaid
      ? `<p style="margin:0 0 20px;">Please note that if payment is not received within <strong>24 hours</strong>, you may be subject to academic consequences, including <strong>failure of the course</strong> and/or <strong>temporary suspension of access to the online portal</strong>.</p>`
      : '';

    const balanceParagraph = anyUnpaid
      ? `<p style="margin:0 0 20px;">Please ensure that full payment is submitted promptly to avoid any disruption to your enrollment or access to academic resources.</p>`
      : `<p style="margin:0 0 20px;">Thank you for keeping your account in good standing. If you have any questions about your payment record, please contact our Billing Office.</p>`;

    const bodyContent = `
      <p style="margin:0 0 ${multiItems && itemList ? '6px' : '20px'};">${openingSentence}</p>
      ${itemList}
      ${!phrase ? '' : balanceParagraph}
      ${customMsgHtml}
      ${urgencyParagraph}
      <hr style="border:none;border-top:1px solid #c9a84c;opacity:0.35;margin:0 0 20px;">
      <p style="margin:0 0 16px;">If you have any questions regarding your account, please do not hesitate to contact the Billing Office directly at <a href="mailto:billing@acnhs.am" style="color:#c9a84c;font-weight:600;text-decoration:none;">billing@acnhs.am</a>.</p>
      <p style="margin:0;">Should you wish to upload a payment receipt, please log in to your portal and navigate to the <strong>Financial</strong> section.</p>
    `.trim();

    const studentInfo = student.studentId
      ? `<div style="font-family:Arial,sans-serif;font-size:11px;color:rgba(200,191,178,0.75);text-align:right;">ID: ${escHtml(student.studentId)}</div>`
      : '';

    const sealRaw = (typeof ACNHS_SEAL_BASE64 !== 'undefined' && ACNHS_SEAL_BASE64)
      || (typeof window.ACNHS_SEAL_BASE64 !== 'undefined' && window.ACNHS_SEAL_BASE64)
      || null;
    const sealSrc = sealRaw ? `data:image/png;base64,${sealRaw}` : '';

    const signatureHtml = `
      <div style="font-family:Georgia,'Times New Roman',serif;font-size:15px;font-weight:700;color:#04111f;margin-bottom:3px;">Billing Department</div>
      <div style="font-family:Arial,sans-serif;font-size:12px;font-weight:600;color:#5a4e3a;margin-bottom:2px;">Office of Billing &amp; Finance</div>
      <div style="font-family:Arial,sans-serif;font-size:12px;font-weight:600;color:#5a4e3a;margin-bottom:8px;">Armenian College of Nursing &amp; Health Sciences</div>
      <div style="font-family:Arial,sans-serif;font-size:11px;color:#7c6d55;margin-bottom:6px;">Yerevan, Armenia</div>
      <div style="font-family:Arial,sans-serif;font-size:10px;color:#8a7a55;font-style:italic;margin-bottom:10px;">Graduates Receive Lifetime ANA-US, Inc. Membership</div>
      <table role="presentation" cellpadding="0" cellspacing="0" style="border-collapse:collapse;">
        <tr>
          <td style="padding:0 10px 3px 0;vertical-align:middle;">
            <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='%23c9a84c' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.87 9.84 19.79 19.79 0 0 1 1.9 1.26 2 2 0 0 1 3.87 0h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 7.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z'/%3E%3C/svg%3E" width="13" height="13" alt="" style="display:block;">
          </td>
          <td style="font-family:Arial,sans-serif;font-size:11px;color:#8a7a55;padding:0 0 3px;white-space:nowrap;">+374 93 798879</td>
        </tr>
        <tr>
          <td style="padding:0 10px 3px 0;vertical-align:middle;">
            <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='%23c9a84c' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.87 9.84 19.79 19.79 0 0 1 1.9 1.26 2 2 0 0 1 3.87 0h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 7.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z'/%3E%3C/svg%3E" width="13" height="13" alt="" style="display:block;">
          </td>
          <td style="font-family:Arial,sans-serif;font-size:11px;color:#8a7a55;padding:0 0 3px;white-space:nowrap;">+1 (707) 717-4440</td>
        </tr>
        <tr>
          <td style="padding:0 10px 3px 0;vertical-align:middle;">
            <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='%23c9a84c' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Crect x='2' y='4' width='20' height='16' rx='2'/%3E%3Cpath d='m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7'/%3E%3C/svg%3E" width="13" height="13" alt="" style="display:block;">
          </td>
          <td style="font-family:Arial,sans-serif;font-size:11px;padding:0 0 3px;white-space:nowrap;"><a href="mailto:billing@acnhs.am" style="color:#c9a84c;font-weight:600;text-decoration:none;">billing@acnhs.am</a></td>
        </tr>
        <tr>
          <td style="padding:0 10px 0 0;vertical-align:middle;">
            <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='%23c9a84c' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='12' cy='12' r='10'/%3E%3Cpath d='M2 12h20M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z'/%3E%3C/svg%3E" width="13" height="13" alt="" style="display:block;">
          </td>
          <td style="font-family:Arial,sans-serif;font-size:11px;padding:0;white-space:nowrap;"><a href="https://www.acnhs.am" style="color:#c9a84c;font-weight:600;text-decoration:none;">www.acnhs.am</a></td>
        </tr>
      </table>
    `.trim();

    if (typeof window.EMAIL_HTML_TEMPLATE !== 'undefined') {
      const emailTitle = tags.size > 1 ? 'Payment Reminder — Outstanding Balances' : 'Payment Reminder';
      const html = window.EMAIL_HTML_TEMPLATE
        .replace(/\{\{SUBJECT\}\}/g, subject)
        .replace(/\{\{EMAIL_TITLE\}\}/g, emailTitle)
        .replace(/\{\{DATE\}\}/g, today)
        .replace(/\{\{APPLICANT_NAME\}\}/g, escHtml(student.name))
        .replace(/\{\{BODY_CONTENT\}\}/g, bodyContent)
        .replace(/\{\{STUDENT_INFO\}\}/g, studentInfo)
        .replace(/\{\{SIGNATURE\}\}/g, signatureHtml)
        .replace(/\{\{ACNHS_SEAL_BASE64\}\}/g, sealSrc)
        .replace(/\{\{YEAR\}\}/g, new Date().getFullYear().toString());
      return { html, subject };
    }

    const fallbackHtml = `<!doctype html><html><head><meta charset="utf-8"><title>${subject}</title></head>
    <body style="font-family:Arial,sans-serif;line-height:1.6;color:#111;">
      <h2>Payment Reminder</h2>
      <p>Dear ${escHtml(student.name)},</p>
      ${bodyContent}
      <p style="margin-top:20px;">ACNHS Billing Office</p>
    </body></html>`;
    return { html: fallbackHtml, subject };
  }

  function initPaymentReminder(config) {
    const toast = (msg, type) => {
      if (config.showToast) return config.showToast(msg, type);
      if (typeof window.showToast === 'function') return window.showToast(msg, type);
      if (typeof window.showNotification === 'function') return window.showNotification(msg, type);
      alert(msg);
    };
    const tags = new Set();
    let student = null;
    let emailHtml = '';
    let emailSubject = '';

    const get = (id) => document.getElementById(id);
    const qsa = (sel) => Array.from(document.querySelectorAll(sel));

    function renderTags() {
      const row = get(config.tagsRowId);
      if (!row) return;
      if (tags.size === 0) {
        row.style.display = 'none';
        row.innerHTML = '';
        return;
      }
      row.style.display = 'flex';
      row.innerHTML = [...tags].map(t =>
        `<span style="background:rgba(201,168,76,0.18);border:1px solid rgba(201,168,76,0.35);color:#c9a84c;
          font-size:10.5px;font-weight:700;padding:3px 10px;border-radius:999px;">${t}</span>`
      ).join('');
    }

    function applyGlowToBtn(btn) {
      const val = btn.getAttribute('data-val');
      btn.classList.remove('unpaid-glow', 'partial-glow', 'paid-glow');
      if (student && student.monthStatuses && student.monthStatuses[val]) {
        const st = student.monthStatuses[val];
        if (st === 'unpaid') btn.classList.add('unpaid-glow');
        else if (st === 'partial') btn.classList.add('partial-glow');
        else if (st === 'paid') btn.classList.add('paid-glow');
      } else if (student && student.unpaidMonths && student.unpaidMonths.includes(val)) {
        btn.classList.add('unpaid-glow');
      }
    }

    function toggleTag(btn) {
      const val = btn.getAttribute('data-val');

      if (val === 'This Month' && tags.has('Next Month')) {
        tags.delete('Next Month');
        const nmBtn = document.querySelector(`${config.tagButtonSelector}[data-val="Next Month"]`);
        if (nmBtn) { nmBtn.classList.remove('active'); applyGlowToBtn(nmBtn); }
      }
      if (val === 'Next Month' && tags.has('This Month')) {
        tags.delete('This Month');
        const tmBtn = document.querySelector(`${config.tagButtonSelector}[data-val="This Month"]`);
        if (tmBtn) { tmBtn.classList.remove('active'); applyGlowToBtn(tmBtn); }
      }

      if (tags.has(val)) {
        tags.delete(val);
        btn.classList.remove('active');
      } else {
        tags.add(val);
        btn.classList.add('active');
      }

      // Always restore the glow after any toggle
      applyGlowToBtn(btn);

      renderTags();
      updatePreview();
    }

    function updatePreview() {
      if (!student) return;
      const customMsg = get(config.customMessageId)?.value.trim() || '';
      const built = buildPaymentReminderEmail(student, tags, customMsg);
      emailHtml = built.html;
      emailSubject = built.subject;

      const wrap = get(config.previewWrapId);
      let shadow = wrap.shadowRoot;
      if (!shadow) shadow = wrap.attachShadow({ mode: 'open' });
      shadow.innerHTML = emailHtml;
    }

    async function open(context) {
      student = await config.resolveStudent(context);
      if (!student || !student.email) {
        toast('No email on file for this student.', 'error');
        return;
      }

      tags.clear();
      qsa(config.tagButtonSelector).forEach(b => {
        b.classList.remove('active', 'unpaid-glow', 'partial-glow', 'paid-glow');
        const val = b.getAttribute('data-val');
        
        if (student.monthStatuses && student.monthStatuses[val]) {
          const st = student.monthStatuses[val];
          console.log(`[PaymentReminder Debug] Student: ${student.name}, Month: ${val}, Status: ${st}`);
          if (st === 'unpaid') b.classList.add('unpaid-glow');
          else if (st === 'partial') b.classList.add('partial-glow');
          else if (st === 'paid') b.classList.add('paid-glow');
        } else if (student.unpaidMonths && student.unpaidMonths.includes(val)) {
          b.classList.add('unpaid-glow');
        }
      });
      renderTags();
      if (get(config.customMessageId)) get(config.customMessageId).value = '';

      const subtitle = `${student.name} · ${student.email}`;
      const subtitleEl = get(config.subtitleId);
      if (subtitleEl) subtitleEl.textContent = subtitle;

      updatePreview();
      get(config.overlayId).classList.add('open');
      document.body.style.overflow = 'hidden';
    }

    function close() {
      get(config.overlayId).classList.remove('open');
      document.body.style.overflow = '';
    }

    function confirmSend() {
      if (!student) return;
      const initials = (student.name || '?').split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);
      get(config.confirmAvatarId).textContent = initials;
      get(config.confirmNameId).textContent = student.name || '—';
      get(config.confirmEmailId).textContent = student.email || '—';
      get(config.confirmOverlayId).classList.add('open');
    }

    function closeConfirm() {
      get(config.confirmOverlayId).classList.remove('open');
    }

    async function executeSend() {
      if (!student) return;
      const okBtn = get(config.confirmOkId);
      const cancelBtn = get(config.confirmCancelId);
      const sendBtn = get(config.sendBtnId);

      okBtn.disabled = cancelBtn.disabled = true;
      okBtn.innerHTML = `
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="animation:${config.spinnerKeyframes} 0.8s linear infinite;">
          <path d="M21 12a9 9 0 1 1-6.219-8.56"/>
        </svg>
        Sending…`;

      if (sendBtn) sendBtn.disabled = true;

      try {
        const db = config.getSupabase();
        if (!db) throw new Error('Supabase not initialised');

        const { error: sendError } = await db.functions.invoke('send-email', {
          body: {
            to: student.email,
            subject: emailSubject,
            html: emailHtml,
            from: 'billing@acnhs.am',
            fromName: 'ACNHS Billing Department'
          }
        });
        if (sendError) throw new Error(sendError.message || 'Failed to send email');

        await db.from('email_history').insert({
          recipient: student.email,
          sender: 'billing@acnhs.am',
          subject: emailSubject,
          body: 'Payment reminder email',
          html_body: emailHtml,
          status: 'sent',
          sent_at: new Date().toISOString()
        });

        closeConfirm();
        toast(`Reminder sent to ${student.email}`, 'success');
        close();
      } catch (err) {
        console.error('Failed to send reminder:', err);
        closeConfirm();
        toast('Failed to send reminder — ' + (err.message || 'check console'), 'error');
      } finally {
        okBtn.disabled = cancelBtn.disabled = false;
        okBtn.innerHTML = config.confirmOkLabelHtml;
        if (sendBtn) sendBtn.disabled = false;
      }
    }

    // backdrop close
    const overlay = get(config.overlayId);
    if (overlay) {
      overlay.addEventListener('click', (e) => { if (e.target === overlay) close(); });
    }
    const confirmOverlay = get(config.confirmOverlayId);
    if (confirmOverlay) {
      confirmOverlay.addEventListener('click', (e) => { if (e.target === confirmOverlay) closeConfirm(); });
    }

    return { open, close, confirmSend, closeConfirm, executeSend, toggleTag, updatePreview, renderTags };
  }

  window.PaymentReminder = { init: initPaymentReminder };
})();
