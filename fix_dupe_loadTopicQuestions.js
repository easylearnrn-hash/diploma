const fs = require('fs');
let html = fs.readFileSync('question.html', 'utf8');

const firstStr = html.indexOf('async function loadTopicQuestions() {');
const secondStr = html.indexOf('async function loadTopicQuestions() {', firstStr + 1);

console.log("Difference is " + (secondStr - firstStr) + " characters");
console.log(html.substring(firstStr, firstStr + 200));

