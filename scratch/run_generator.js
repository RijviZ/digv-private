const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const chromePath = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const htmlPath = path.join(__dirname, 'generate.html');

console.log('Running headless Chrome to render icons...');
const cmd = `"${chromePath}" --headless --disable-gpu --dump-dom "file://${htmlPath}"`;

let stdout;
try {
  stdout = execSync(cmd, { maxBuffer: 10 * 1024 * 1024 }).toString();
} catch (err) {
  console.error('Error running Chrome:', err);
  process.exit(1);
}

// Find <div id="output">...</div>
const startTag = '<div id="output">';
const endTag = '</div>';
const startIndex = stdout.indexOf(startTag);
const endIndex = stdout.indexOf(endTag, startIndex);

if (startIndex === -1 || endIndex === -1) {
  console.error('Could not find output div in DOM. HTML output length:', stdout.length);
  process.exit(1);
}

const jsonString = stdout.substring(startIndex + startTag.length, endIndex);
let data;
try {
  data = JSON.parse(jsonString);
} catch (err) {
  console.error('Failed to parse JSON from output div. Raw content prefix:', jsonString.substring(0, 100));
  process.exit(1);
}

function saveBase64Image(dataUrl, targetPath) {
  const base64Data = dataUrl.replace(/^data:image\/png;base64,/, '');
  const dir = path.dirname(targetPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  fs.writeFileSync(targetPath, base64Data, 'base64');
  console.log(`Saved: ${targetPath}`);
}

// Save ic_launcher.png
for (const [density, dataUrl] of Object.entries(data.ic_launcher)) {
  const targetPath = path.join(__dirname, '..', 'android', 'app', 'src', 'main', 'res', `mipmap-${density}`, 'ic_launcher.png');
  saveBase64Image(dataUrl, targetPath);
}

// Save ic_launcher_foreground.png
for (const [density, dataUrl] of Object.entries(data.ic_launcher_foreground)) {
  const targetPath = path.join(__dirname, '..', 'android', 'app', 'src', 'main', 'res', `drawable-${density}`, 'ic_launcher_foreground.png');
  saveBase64Image(dataUrl, targetPath);
}

// Save ic_notification.png
const notifPath = path.join(__dirname, '..', 'android', 'app', 'src', 'main', 'res', 'drawable', 'ic_notification.png');
saveBase64Image(data.ic_notification, notifPath);

console.log('All icons generated successfully!');
