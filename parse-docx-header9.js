const fs = require('fs');
const unzipper = require('unzipper');

fs.createReadStream('/tmp/test-export.docx')
  .pipe(unzipper.Parse())
  .on('entry', function (entry) {
    const fileName = entry.path;
    if (fileName === 'word/header1.xml') {
      entry.buffer().then(content => {
        const text = content.toString('utf8').replace(/></g, '>\n<').split('\n');
        let just = text.filter(l => l.includes('<w:jc'));
        console.log("Justify tags in header:", just);
      });
    } else {
      entry.autodrain();
    }
  });
