const fs = require('fs');
const unzipper = require('unzipper');

fs.createReadStream('/tmp/test-export.docx')
  .pipe(unzipper.Parse())
  .on('entry', function (entry) {
    const fileName = entry.path;
    if (fileName === 'word/header1.xml') {
      entry.buffer().then(content => {
        const text = content.toString('utf8');
        console.log("XML starts with", text.substring(0, 150));
        console.log("Does it contain <w:tbl>?", text.includes('<w:tbl>'));
      });
    } else {
      entry.autodrain();
    }
  });
