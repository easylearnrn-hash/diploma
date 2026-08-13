const fs = require('fs');
const unzipper = require('unzipper');

fs.createReadStream('/tmp/test.docx')
  .pipe(unzipper.Parse())
  .on('entry', function (entry) {
    const fileName = entry.path;
    if (fileName === 'word/header1.xml') {
      entry.buffer().then(content => {
        const text = content.toString('utf8');
        if (text.includes('<w:tbl>')) {
           console.log("Table was found in header!");
           console.log(text.replace(/></g, '>\n<').match(/<w:tbl.*/)[0]);
        } else {
           console.log("No table found in header.xml");
        }
      });
    } else {
      entry.autodrain();
    }
  });
