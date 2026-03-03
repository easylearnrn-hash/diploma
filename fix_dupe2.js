const fs = require('fs');
let html = fs.readFileSync('question.html', 'utf8');

const firstStr = html.indexOf('async function loadTopicQuestions() {');
const secondStr = html.indexOf('async function loadTopicQuestions() {', firstStr + 1);

let endOfFirst = html.indexOf('\n    }', firstStr);

// I should probably find exactly where the first one ends, let's just use regexp
const regex = /async function loadTopicQuestions\(\) \{[\s\S]*?(async function loadTopicQuestions\(\) \{[\s\S]*?)(?=<\/script>|\n    function )/;

// Let's read question.html into memory and see
