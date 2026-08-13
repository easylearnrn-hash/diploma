const fs = require('fs');
const unzipper = require('unzipper');

fs.createReadStream('/tmp/test-export.docx')
  .pipe(unzipper.Parse())
  .on('entry', function (entry) {
    const fileName = entry.path;
    if (fileName === 'word/header1.xml') {
      entry.buffer().then(content => {
        const text = content.toString('utf8');
        console.log("ALL TAGS IN HEADER:", text.match(/<w:[a-zA-Z0-9]+/g).reduce((acc, t) => { acc[t] = (acc[t]||0)+1; return acc; }, {}))
      });
    } else {
      entry.autodrain();
    }
  });
