const fs = require('fs');

let html = fs.readFileSync('question.html', 'utf8');

const regexMap = [
    {
        find: /body \{[\s\S]*?body\.dark-mode/g,
        replace: `body {` // just a placeholder
    }
];

// Instead of regex, let's just replace the entire <style> block and add Inter.
const styleStart = html.indexOf('<style>');
const styleEnd = html.indexOf('</style>') + 8;
const fontLink = `<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">\n  <style>`;

const newStyles = `
    :root {
      --navy-900: #04111f;
      --navy-800: #071b30;
      --navy-700: #0c2444;
      --navy-600: #112d55;
      --gold-500: #c9a84c;
      --gold-400: #d4b56a;
      --gold-300: #e2cc92;
      --gold-glow: rgba(201,168,76,0.14);
      --border-gold: rgba(201,168,76,0.28);
      --text-primary: #f0ece3;
      --text-secondary: #c8bfb2;
      --text-muted: #8a8070;
      --card: rgba(7, 27, 48, 0.85);
      --radius-xl: 20px;
      --radius-lg: 16px;
      --radius-md: 12px;
    }

    * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }
    
    body {
      background: var(--navy-900);
      background-image: 
        radial-gradient(ellipse 80% 60% at 20% 10%, rgba(201,168,76,0.07), transparent),
        radial-gradient(ellipse 60% 50% at 80% 85%, rgba(12,36,68,0.6), transparent);
      color: var(--text-primary);
      min-height: 100vh;
      margin: 40px auto;
      max-width: 1000px;
      padding: 0 20px;
      color-scheme: dark;
    }

    h1 {
      font-size: 32px;
      font-weight: 700;
      margin-bottom: 8px;
      background: linear-gradient(135deg, #f0e3bc 0%, #c9a84c 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      letter-spacing: -0.5px;
    }

    p { color: var(--text-secondary); font-size: 16px; margin-bottom: 30px; font-weight: 300; }
    
    .card { 
      background: var(--card); 
      padding: 32px; 
      border-radius: var(--radius-xl); 
      border: 1px solid var(--border-gold);
      box-shadow: 0 20px 50px rgba(0,0,0,0.4); 
      margin-bottom: 30px; 
      backdrop-filter: blur(10px);
      -webkit-backdrop-filter: blur(10px);
    }
    
    .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; }
    .form-group { display: flex; flex-direction: column; gap: 8px; }
    
    label { font-weight: 500; font-size: 14px; color: var(--gold-400); letter-spacing: 0.5px; text-transform: uppercase; }
    label span { color: #ef4444; }
    
    select, input, textarea { 
      width: 100%; 
      padding: 14px 16px; 
      background: rgba(4, 17, 31, 0.6); 
      border: 1px solid var(--border-gold); 
      border-radius: var(--radius-md); 
      color: var(--text-primary); 
      font-size: 15px;
      transition: all 0.2s ease;
    }
    
    select:focus, textarea:focus, input:focus { 
      outline: none; 
      border-color: var(--gold-400); 
      box-shadow: 0 0 0 3px var(--gold-glow); 
      background: var(--navy-800);
    }
    
    select:disabled { opacity: 0.5; cursor: not-allowed; }
    select option { background: var(--navy-800); color: var(--text-primary); }
    
    textarea {
      height: 400px;
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      font-size: 14px;
      line-height: 1.6;
      resize: vertical;
    }
    
    textarea::placeholder { color: var(--text-muted); }
    
    .row { display: flex; gap: 16px; align-items: center; margin-top: 24px; flex-wrap: wrap; }
    
    button {
      padding: 12px 24px; 
      border-radius: var(--radius-md); 
      border: none; 
      font-weight: 600; 
      cursor: pointer; 
      font-size: 15px; 
      transition: all 0.2s ease;
      letter-spacing: 0.5px;
    }
    
    .btn-primary { 
      background: linear-gradient(135deg, var(--gold-500) 0%, #b49138 100%);
      color: var(--navy-900); 
      box-shadow: 0 4px 15px var(--gold-glow);
    }
    .btn-primary:hover:not(:disabled) { 
      transform: translateY(-2px); 
      box-shadow: 0 6px 20px rgba(201,168,76,0.3);
    }
    
    .btn-secondary { 
      background: rgba(255,255,255,0.05); 
      color: var(--text-primary); 
      border: 1px solid rgba(255,255,255,0.1); 
    }
    .btn-secondary:hover:not(:disabled) { 
      background: rgba(255,255,255,0.1); 
    }
    
    .btn-danger { 
      background: rgba(239, 68, 68, 0.1); 
      color: #fca5a5; 
      border: 1px solid rgba(239, 68, 68, 0.2); 
      padding: 8px 16px; 
      font-size: 13px;
    }
    .btn-danger:hover:not(:disabled) { 
      background: rgba(239, 68, 68, 0.2); 
      color: #fff;
    }
    
    button:disabled { opacity: 0.5; cursor: not-allowed; }
    
    .hint { 
      font-size: 14px; 
      color: var(--text-secondary); 
      background: rgba(4, 17, 31, 0.5); 
      padding: 16px; 
      border-radius: var(--radius-md); 
      border-left: 3px solid var(--gold-500); 
      margin-bottom: 24px; 
      line-height: 1.6;
    }
    .hint strong { color: var(--gold-400); font-weight: 600; }
    .hint code { 
      background: var(--navy-700); 
      padding: 2px 6px; 
      border-radius: 4px; 
      color: #93c5fd; 
      font-size: 13px;
      font-family: ui-monospace, monospace;
    }
    
    .progress-log {
      margin-top: 24px; 
      max-height: 300px; 
      overflow-y: auto; 
      background: var(--navy-900); 
      border: 1px solid rgba(255,255,255,0.05);
      color: var(--text-secondary); 
      padding: 16px; 
      border-radius: var(--radius-md); 
      font-family: ui-monospace, monospace; 
      font-size: 13px; 
      display: none; 
      line-height: 1.6;
    }
    .progress-log div { margin-bottom: 6px; padding-bottom: 6px; border-bottom: 1px solid rgba(255,255,255,0.05); }
    .progress-log div:last-child { border-bottom: none; margin-bottom: 0; padding-bottom: 0; }
    .log-success { color: #4ade80 !important; }
    .log-error { color: #f87171 !important; }
    .log-warn { color: #fbbf24 !important; }
    
    /* Manage Section Overrides */
    h2 { font-size: 20px; font-weight: 600; color: var(--gold-400); margin: 0; }
    #manageSection p { color: var(--text-muted); margin-bottom: 20px; }
    
    #bulkActions {
      background: rgba(4, 17, 31, 0.6) !important;
      border: 1px solid var(--border-gold);
      padding: 16px 20px !important;
      border-radius: var(--radius-md) !important;
    }
    
    .question-card { 
      background: rgba(4, 17, 31, 0.4); 
      padding: 20px; 
      border-radius: var(--radius-md); 
      border: 1px solid var(--border-gold); 
      display: flex; 
      align-items: flex-start;
      transition: all 0.2s ease;
    }
    .question-card:hover { border-color: var(--gold-500); background: rgba(4, 17, 31, 0.7); }
    
    .question-stem { font-weight: 500; font-size: 16px; margin-bottom: 12px; color: var(--text-primary); white-space: pre-wrap; line-height: 1.5; }
    .question-options { font-size: 14px; color: var(--text-secondary); line-height: 1.8; }
    
    .q-checkbox {
      accent-color: var(--gold-500);
      width: 18px !important;
      height: 18px !important;
      margin-top: 2px;
      cursor: pointer;
    }
    
    /* Custom Scrollbar for Textarea and Logs */
    ::-webkit-scrollbar { width: 8px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: var(--navy-700); border-radius: 4px; }
    ::-webkit-scrollbar-thumb:hover { background: var(--gold-500); }
</style>
`;

html = html.substring(0, styleStart) + fontLink + newStyles + html.substring(styleEnd);

// Also let's update some inline styles or UI elements that were added that don't match dark mode.
html = html.replace(/background: white;/g, 'background: rgba(4, 17, 31, 0.4);');
html = html.replace(/background: #f1f5f9;/g, 'background: rgba(4, 17, 31, 0.6);');
html = html.replace(/color: #0f172a;/g, 'color: var(--gold-400);');
html = html.replace(/color: #64748b;/g, 'color: var(--text-muted);');
html = html.replace(/border: 1px dashed #cbd5e1;/g, 'border: 1px dashed var(--border-gold);');
html = html.replace(/border-bottom: 2px solid #e2e8f0;/g, 'border-bottom: 1px solid var(--border-gold);');
html = html.replace(/color: #15803d;/g, 'color: #4ade80;'); // lighter green for correct answer

fs.writeFileSync('question.html', html, 'utf8');
