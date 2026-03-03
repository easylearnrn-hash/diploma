const fs = require('fs');
let html = fs.readFileSync('question.html', 'utf8');

// remove duplicate bulkActions block
const bulkActionRegex = /<div id="bulkActions"[^>]*>[\s\S]*?<\/div>\s*<div id="bulkActions"[^>]*>[\s\S]*?<\/div>/;

const singleBulkAction = `<div id="bulkActions" style="display: none; align-items: center; gap: 12px; margin-bottom: 12px; padding: 12px; background: var(--navy-800); border: 1px solid var(--border-gold); border-radius: var(--radius-md);">
      <label style="display: flex; align-items: center; gap: 8px; margin: 0; cursor: pointer; font-size: 14px;">
        <input type="checkbox" id="selectAllCheckbox" class="q-checkbox"> <b style="color: var(--text-primary);">Select All</b>
      </label>
      <button id="bulkDeleteBtn" class="btn-danger" style="margin-left: auto;" disabled>Delete Selected (0)</button>
    </div>`;

html = html.replace(bulkActionRegex, singleBulkAction);

// fix color on manageCount
html = html.replace(/color: #475569;/g, 'color: var(--text-muted);');

fs.writeFileSync('question.html', html, 'utf8');
