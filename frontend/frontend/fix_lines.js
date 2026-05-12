const fs = require('fs');

const output = fs.readFileSync('analyze_output.txt', 'utf16le');
const lines = output.split('\n');

const fixes = {};

lines.forEach(line => {
    if (line.includes('invalid_constant')) {
        const pathMatch = line.match(/(lib[\\/].*?\.dart)/);
        const match = line.match(/:(\d+):\d+/);
        if (pathMatch && match) {
            const file = pathMatch[1];
            const lineNum = parseInt(match[1]) - 1; // 0-indexed
            if (!fixes[file]) fixes[file] = [];
            fixes[file].push(lineNum);
        }
    }
});

for (const [file, lineNums] of Object.entries(fixes)) {
    if (!fs.existsSync(file)) continue;
    let fileLines = fs.readFileSync(file, 'utf8').split('\n');
    let modified = false;

    lineNums.forEach(lineNum => {
        // Search backwards for up to 5 lines for 'const '
        for (let i = lineNum; i >= Math.max(0, lineNum - 5); i--) {
            if (fileLines[i].includes('const ')) {
                fileLines[i] = fileLines[i].replace(/const /g, '');
                modified = true;
                break;
            }
        }
    });

    if (modified) {
        fs.writeFileSync(file, fileLines.join('\n'), 'utf8');
        console.log(`Fixed consts in ${file}`);
    }
}
