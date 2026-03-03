const fs = require('fs');
let html = fs.readFileSync('question.html', 'utf8');
html = html.replace(/<link href="https:\/\/fonts\.googleapis\.com\/css2\?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">\s+<link href="https:\/\/fonts\.googleapis\.com\/css2\?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">/g, '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">');
fs.writeFileSync('question.html', html, 'utf8');
