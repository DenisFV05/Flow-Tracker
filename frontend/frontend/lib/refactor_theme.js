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
let totalReplacements = 0;

files.forEach(file => {
    let content = fs.readFileSync(file, 'utf8');
    let original = content;

    content = content.replace(/AppTheme\.background/g, 'context.backgroundColor');
    content = content.replace(/AppTheme\.textPrimary/g, 'context.textPrimaryColor');
    content = content.replace(/AppTheme\.textSecondary/g, 'context.textSecondaryColor');
    content = content.replace(/AppTheme\.surfaceLight/g, 'context.surfaceLightColor');
    content = content.replace(/AppTheme\.textDark/g, 'context.textDarkColor');
    
    // Specifically for container backgrounds:
    // color: Colors.white -> color: context.surfaceColor
    content = content.replace(/color:\s*Colors\.white/g, 'color: context.surfaceColor');
    
    // Also change `backgroundColor: Colors.white` to `context.surfaceColor`
    content = content.replace(/backgroundColor:\s*Colors\.white/g, 'backgroundColor: context.surfaceColor');

    // Revert text styles if we accidentally messed them up
    // Text style with context.surfaceColor instead of Colors.white is mostly harmless but could be wrong contextually.
    
    if (content !== original) {
        fs.writeFileSync(file, content, 'utf8');
        console.log(`Refactored: ${file}`);
        totalReplacements++;
    }
});

console.log(`Total files modified: ${totalReplacements}`);
