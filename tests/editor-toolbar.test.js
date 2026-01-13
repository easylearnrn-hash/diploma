const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');

const HTML_PATH = path.resolve(__dirname, '..', 'note-viewer.html');
const html = fs.readFileSync(HTML_PATH, 'utf8');

const sanitizedHtml = html.replace(/<script src="https:\/\/cdnjs[\s\S]*?<\/script>/, '');

const toggleCommands = new Set([
  'bold', 'italic', 'underline', 'strikeThrough',
  'superscript', 'subscript', 'justifyLeft', 'justifyCenter',
  'justifyRight', 'justifyFull', 'insertOrderedList', 'insertUnorderedList'
]);

async function bootstrapDom() {
  const dom = new JSDOM(sanitizedHtml, {
    runScripts: 'dangerously',
    resources: 'usable',
    pretendToBeVisual: true,
    url: 'https://acnhs.local/editor-test',
    beforeParse(window) {
      window.__EDITOR_TEST__ = true;
      const promptAnswers = [
        'https://acnhs.edu/page',
        'https://acnhs.edu/image.png',
        '2',
        '2'
      ];
      window.prompt = () => promptAnswers.shift() || '2';
      window.alert = () => {};
      const selectionState = {
        text: 'Sample selection',
        insertedText: ''
      };
      window.__selectionState = selectionState;
      window.getSelection = () => ({
        rangeCount: 1,
        toString: () => selectionState.text,
        getRangeAt: () => ({
          deleteContents: () => { selectionState.deleted = true; },
          insertNode: (node) => { selectionState.insertedText = node.textContent; },
          setStartAfter: () => {},
          setEndAfter: () => {}
        }),
        removeAllRanges: () => {},
        addRange: () => {}
      });
    }
  });

  await new Promise((resolve) => {
    dom.window.document.addEventListener('DOMContentLoaded', () => {
      setTimeout(resolve, 0);
    });
  });

  const executed = [];
  const commandState = Object.create(null);
  const commandValues = {
    formatBlock: 'p',
    fontSize: '3',
    fontName: 'Inter',
    foreColor: '#0f172a',
    hiliteColor: '#fef08a'
  };

  dom.window.document.execCommand = (command, _showUI, value) => {
    executed.push({ command, value });
    if (toggleCommands.has(command)) {
      commandState[command] = !commandState[command];
    }
    if (command === 'formatBlock') {
      commandState[command] = value;
      commandValues.formatBlock = value;
    }
    if (command === 'fontSize') {
      commandValues.fontSize = value;
    }
    if (command === 'fontName') {
      commandValues.fontName = value;
    }
    if (command === 'foreColor' || command === 'hiliteColor' || command === 'backColor') {
      commandValues[command] = value;
    }
    if (command === 'insertHTML') {
      const visual = dom.window.document.getElementById('visualEditor');
      visual.innerHTML += value;
    }
    return true;
  };

  dom.window.document.queryCommandState = (command) => {
    if (command === 'formatBlock') {
      return commandValues.formatBlock;
    }
    return !!commandState[command];
  };

  dom.window.document.queryCommandValue = (command) => commandValues[command] || '';

  return { dom, executed, commandValues };
}

(async () => {
  const { dom, executed, commandValues } = await bootstrapDom();
  const { document } = dom.window;
  const selectionState = dom.window.__selectionState;
  const hooks = dom.window.__editorTestHooks;

  const toolbar = document.querySelector('.editor-toolbar');
  if (!toolbar) {
    throw new Error('Toolbar markup not found');
  }

  const visualEditor = document.getElementById('visualEditor');
  visualEditor.innerHTML = '<p>Sample content</p>';

  const buttonTests = [
    '[data-command="bold"]',
    '[data-command="italic"]',
    '[data-command="underline"]',
    '[data-command="strikeThrough"]',
    '[data-command="superscript"]',
    '[data-command="subscript"]',
    '[data-command="justifyLeft"]',
    '[data-command="justifyCenter"]',
    '[data-command="justifyRight"]',
    '[data-command="justifyFull"]',
    '[data-command="insertUnorderedList"]',
    '[data-command="insertOrderedList"]',
    '[data-command="outdent"]',
    '[data-command="indent"]',
    '[data-command="insertHorizontalRule"]',
    '[data-command="formatBlock"]',
    '[data-command="unlink"]',
    '[data-command="removeFormat"]',
    '[data-command="undo"]',
    '[data-command="redo"]'
  ];

  buttonTests.forEach((selector) => {
    const button = toolbar.querySelector(selector);
    if (!button) {
      throw new Error(`Missing toolbar button ${selector}`);
    }
    button.dispatchEvent(new dom.window.MouseEvent('click', { bubbles: true }));
  });

  const actionButtons = [
    '[data-action="link"]',
    '[data-action="image"]',
    '[data-action="table"]',
    '[data-action="inlineCode"]'
  ];

  actionButtons.forEach((selector) => {
    const button = toolbar.querySelector(selector);
    if (!button) {
      throw new Error(`Missing action button ${selector}`);
    }
    button.dispatchEvent(new dom.window.MouseEvent('click', { bubbles: true }));
  });

  const uppercaseButton = toolbar.querySelector('[data-action="uppercase"]');
  selectionState.text = 'nurse';
  uppercaseButton.dispatchEvent(new dom.window.MouseEvent('click', { bubbles: true }));
  if (selectionState.insertedText !== 'NURSE') {
    throw new Error('Uppercase transform failed');
  }

  const lowercaseButton = toolbar.querySelector('[data-action="lowercase"]');
  selectionState.text = 'NURSE';
  lowercaseButton.dispatchEvent(new dom.window.MouseEvent('click', { bubbles: true }));
  if (selectionState.insertedText !== 'nurse') {
    throw new Error('Lowercase transform failed');
  }

  const titlecaseButton = toolbar.querySelector('[data-action="titlecase"]');
  selectionState.text = 'mental health review';
  titlecaseButton.dispatchEvent(new dom.window.MouseEvent('click', { bubbles: true }));
  if (selectionState.insertedText !== 'Mental Health Review') {
    throw new Error('Title case transform failed');
  }

  const checklistButton = toolbar.querySelector('[data-action="checklist"]');
  checklistButton.dispatchEvent(new dom.window.MouseEvent('click', { bubbles: true }));
  if (!executed.some((entry) => entry.command === 'insertHTML' && entry.value.includes('checklist'))) {
    throw new Error('Checklist action did not trigger insertHTML command');
  }

  const headingSelect = document.getElementById('headingSelect');
  headingSelect.value = 'h2';
  headingSelect.dispatchEvent(new dom.window.Event('change', { bubbles: true }));

  const fontSizeSelect = document.getElementById('fontSizeSelect');
  fontSizeSelect.value = '5';
  fontSizeSelect.dispatchEvent(new dom.window.Event('change', { bubbles: true }));

  const fontFamilySelect = document.getElementById('fontFamilySelect');
  fontFamilySelect.value = 'Georgia';
  fontFamilySelect.dispatchEvent(new dom.window.Event('change', { bubbles: true }));

  const textColor = document.getElementById('textColorInput');
  textColor.value = '#123456';
  textColor.dispatchEvent(new dom.window.Event('change', { bubbles: true }));

  const highlightColor = document.getElementById('highlightColorInput');
  highlightColor.value = '#ffeeaa';
  highlightColor.dispatchEvent(new dom.window.Event('change', { bubbles: true }));

  visualEditor.innerHTML = `<p>${'word '.repeat(210)}</p>`;
  hooks.updateEditorStats();
  const wordCountText = document.querySelector('#wordCountDisplay strong').textContent.replace(/,/g, '');
  if (wordCountText !== '210') {
    throw new Error('Word count display did not update');
  }
  const readingTimeText = document.querySelector('#readingTimeDisplay strong').textContent.trim();
  if (readingTimeText !== '2 min') {
    throw new Error('Reading time did not calculate correctly');
  }

  const requiredCommands = [
    'bold', 'italic', 'underline', 'strikeThrough', 'superscript', 'subscript',
    'justifyLeft', 'justifyCenter', 'justifyRight', 'justifyFull',
    'insertUnorderedList', 'insertOrderedList', 'outdent', 'indent',
    'insertHorizontalRule', 'formatBlock', 'unlink', 'removeFormat',
    'undo', 'redo', 'createLink', 'insertImage', 'insertHTML', 'foreColor',
    'hiliteColor', 'fontSize', 'fontName'
  ];

  requiredCommands.forEach((command) => {
    if (!executed.some((entry) => entry.command === command)) {
      throw new Error(`Command ${command} was not triggered by toolbar interaction`);
    }
  });

  if (commandValues.foreColor !== '#123456') {
    throw new Error('Text color command did not capture custom value');
  }
  if (commandValues.hiliteColor !== '#ffeeaa' && commandValues.backColor !== '#ffeeaa') {
    throw new Error('Highlight color command did not capture custom value');
  }
  if (commandValues.formatBlock !== 'h2') {
    throw new Error('Heading select did not update format block');
  }
  if (commandValues.fontSize !== '5') {
    throw new Error('Font size select did not trigger execCommand');
  }
  if (commandValues.fontName !== 'Georgia') {
    throw new Error('Font family select did not trigger execCommand');
  }

  console.log('Editor toolbar tests passed');
  dom.window.close();
})().catch((error) => {
  console.error('Editor toolbar tests failed');
  console.error(error);
  process.exit(1);
});
