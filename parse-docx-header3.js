const fs = require('fs');
const unzipper = require('unzipper');

fs.createReadStream('/tmp/test-export.docx')
  .pipe(unzipper.Parse())
  .on('entry', function (entry) {
    const fileName = entry.path;
    if (fileName === 'word/header1.xml') {
      entry.buffer().then(content => {
        console.log("----- HEADER.XML -----");
        console.log(content.toString('utf8').replace(/></g, '>\n<'));
      });
    } else {
      entry.autodrain();
    }
  });
