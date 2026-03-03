const fs = require('fs');

let html = fs.readFileSync('question.html', 'utf8');

// There's duplicate event listeners for `els.selectAllCheckbox` and `els.bulkDeleteBtn`, and duplicate `window.updateBulkBtn`.
// Let's strip all of them and overwrite just exactly one copy of the loadTopicQuestions logic.

const startToken = "async function loadTopicQuestions() {";
const firstIdx = html.indexOf(startToken);

// The parseText function should be right after the initial load.
// Let's replace everything from first loadTopicQuestions() to parseText function.

const endToken = "\n    function parseText(raw) {";
const endIdx = html.indexOf(endToken, firstIdx);

const newLogic = `
    async function loadTopicQuestions() {
      const topicId = els.topic.value;
      if (!topicId) {
        els.manageSection.style.display = 'none';
        return;
      }
      
      els.manageSection.style.display = 'block';
      els.questionsList.innerHTML = '<div style="padding: 20px; text-align: center; color: var(--text-muted);">Loading questions...</div>';
      els.manageCount.textContent = 'Fetching...';
      
      try {
        const { data, error } = await db
          .from('test_questions')
          .select('id, question_stem, options, correct_answers, rationale, display_order')
          .eq('topic_id', topicId)
          .order('display_order', { ascending: true });
          
        if (error) throw error;
        
        els.manageCount.textContent = data.length + ' questions found in this topic.';
        els.questionsList.innerHTML = '';
        
        if (data.length === 0) {
          els.questionsList.innerHTML = '<div style="padding: 20px; text-align: center; color: var(--text-muted); background: rgba(4, 17, 31, 0.4); border-radius: 8px; border: 1px dashed var(--border-gold);">No questions currently uploaded for this topic.</div>';
          if (els.bulkActions) els.bulkActions.style.display = 'none';
          return;
        }
        
        data.forEach((q, idx) => {
          const card = document.createElement('div');
          card.className = 'question-card';
          
          const getOptText = (opts) => {
            if (!Array.isArray(opts)) return '';
            return opts.map(o => {
               const isCorrect = Array.isArray(q.correct_answers) && q.correct_answers.includes(o.id.toLowerCase());
               return \`<div style="\${isCorrect ? 'color: #4ade80; font-weight: 600;' : ''}">\${o.id.toUpperCase()}. \${o.text} \${isCorrect ? '✓' : ''}</div>\`;
            }).join('');
          };

          card.innerHTML = \`
            <div style="margin-right: 16px; padding-top: 2px;">
                <input type="checkbox" class="q-checkbox" value="\${q.id}" style="width: 18px; height: 18px; cursor: pointer;">
            </div>
            <div class="question-content" style="flex: 1;">
              <div class="question-stem">\${idx + 1}. \${q.question_stem}</div>
              <div class="question-options">
                \${getOptText(q.options)}
              </div>
              \${q.rationale ? \`<div style="margin-top: 8px; font-size: 13px; color: var(--text-muted);"><em>Rationale: \${q.rationale}</em></div>\` : ''}
            </div>
            <button class="btn-danger" style="margin-left: 16px;" onclick="deleteQuestion('\${q.id}')">Delete</button>
          \`;
          els.questionsList.appendChild(card);
        });
        
        if (els.bulkActions) els.bulkActions.style.display = 'flex';
        if (els.selectAllCheckbox) els.selectAllCheckbox.checked = false;
        if (window.updateBulkBtn) window.updateBulkBtn();
        
        document.querySelectorAll('.q-checkbox').forEach(cb => cb.addEventListener('change', window.updateBulkBtn));
        
      } catch (err) {
        logMessage('Error loading questions: ' + err.message, 'error');
        els.questionsList.innerHTML = '<div style="color: red;">Failed to load questions. See log.</div>';
      }
    }

    els.topic.addEventListener('change', loadTopicQuestions);
    if (els.refreshBtn) els.refreshBtn.addEventListener('click', loadTopicQuestions);
    
    window.deleteQuestion = async function(id) {
       if (!confirm("Are you sure you want to permanently delete this question?")) return;
       try {
         const { error } = await db.from('test_questions').delete().eq('id', id);
         if (error) throw error;
         logMessage("Question deleted successfully.", "success");
         loadTopicQuestions(); // Refresh list
       } catch (err) {
         logMessage("Failed to delete question: " + err.message, "error");
         alert("Delete failed. See log.");
       }
    };

    window.updateBulkBtn = () => {
      if (!els.bulkDeleteBtn) return;
      const checkedBoxes = document.querySelectorAll('.q-checkbox:checked');
      const totalBoxes = document.querySelectorAll('.q-checkbox');
      els.bulkDeleteBtn.disabled = checkedBoxes.length === 0;
      els.bulkDeleteBtn.textContent = \`Delete Selected (\${checkedBoxes.length})\`;
      if (els.selectAllCheckbox) els.selectAllCheckbox.checked = (checkedBoxes.length > 0 && checkedBoxes.length === totalBoxes.length);
    };

    if (els.selectAllCheckbox) {
      els.selectAllCheckbox.addEventListener('change', (e) => {
        const checkboxes = document.querySelectorAll('.q-checkbox');
        checkboxes.forEach(cb => cb.checked = e.target.checked);
        window.updateBulkBtn();
      });
    }

    if (els.bulkDeleteBtn) {
      els.bulkDeleteBtn.addEventListener('click', async () => {
        const checkedBoxes = document.querySelectorAll('.q-checkbox:checked');
        const ids = Array.from(checkedBoxes).map(cb => cb.value);
        if (ids.length === 0) return;
        if (!confirm(\`Are you sure you want to completely delete \${ids.length} questions?\`)) return;
        
        els.bulkDeleteBtn.disabled = true;
        els.bulkDeleteBtn.textContent = 'Deleting...';
        
        try {
          const { error } = await db.from('test_questions').delete().in('id', ids);
          if (error) throw error;
          logMessage(\`Bulk deleted \${ids.length} questions.\`, "success");
          loadTopicQuestions();
        } catch(err) {
          logMessage("Bulk delete failed: " + err.message, "error");
          alert("Delete failed. See log.");
          els.bulkDeleteBtn.disabled = false;
        }
      });
    }
`;

html = html.substring(0, firstIdx) + newLogic + html.substring(endIdx);
fs.writeFileSync('question.html', html, 'utf8');
