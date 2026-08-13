const fs = require('fs');
const unzipper = require('unzipper');

fs.createReadStream('/tmp/test-export.docx')
  .pipe(unzipper.Parse())
  .on('entry', function (entry) {
    const fileName = entry.path;
    if (fileName === 'word/document.xml') {
      entry.buffer().then(content => {
        const text = content.toString('utf8');
        console.log("Does body contain table?", text.includes('<w:tbl>'));
      });
    } else {
      entry.autodrain();
    }
  });
