const fs = require('fs');
const content = fs.readFileSync('hub.html', 'utf8');
const match = content.match(/const HUB_SEED = (\[[\s\S]*?\]);\n/);
if (match) {
    let missing = 0;
    try {
        const HUB_SEED = eval(match[1]);
        HUB_SEED.forEach(category => {
            category.notes.forEach(note => {
                if (!fs.existsSync(note.htmlFile)) {
                    console.log("MISSING:", note.htmlFile);
                    missing++;
                }
            });
        });
        console.log("Total missing:", missing);
    } catch (e) {
        console.error("Eval failed", e);
    }
}
