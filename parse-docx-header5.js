const fs = require('fs');
const unzipper = require('unzipper');

fs.createReadStream('/tmp/test-export.docx')
  .pipe(unzipper.Parse())
  .on('entry', function (entry) {
    const fileName = entry.path;
    if (fileName === 'word/header1.xml') {
      entry.buffer().then(content => {
        const text = content.toString('utf8');
        console.log(text.replace(/></g, '>\n<').split('\n').filter(line => line.includes('<w:tbl') || line.includes('ACADEMIC')).join('\n'));
      });
    } else {
      entry.autodrain();
    }
  });
