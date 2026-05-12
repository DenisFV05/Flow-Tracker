const fs = require('fs');
const path = require('path');

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach((file) => {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat && stat.isDirectory()) {
            results = results.concat(walk(fullPath));
        } else if (fullPath.endsWith('.dart') && !fullPath.includes('app_theme.dart')) {
            results.push(fullPath);
        }
    });
    return results;
}

const files = walk(__dirname);

files.forEach(file => {
    let content = fs.readFileSync(file, 'utf8');
    let original = content;

    const widgetsToStrip = [
        'TextStyle', 'Icon', 'BoxDecoration', 'Text', 'Row', 'Column', 
        'Padding', 'SizedBox', 'Center', 'Align', 'Expanded', 'Container', 
        'Card', 'CircleAvatar', 'InputDecoration', 'OutlineInputBorder',
        'BorderSide', 'EdgeInsets', 'AlwaysStoppedAnimation'
    ];

    widgetsToStrip.forEach(widget => {
        // match "const Widget(" or "const Widget." (like EdgeInsets.all)
        const regex = new RegExp(`const\\s+${widget}\\b`, 'g');
        content = content.replace(regex, widget);
    });
    
    // special cases like "const ["
    content = content.replace(/const\s+\[/g, '[');

    if (content !== original) {
        fs.writeFileSync(file, content, 'utf8');
    }
});

console.log("Removed const keywords.");
