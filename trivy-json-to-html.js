// trivy-json-to-html.js
const fs = require('fs');

const [,, inputFile, outputFile] = process.argv;
if (!inputFile || !outputFile) {
  console.error("Usage: node trivy-json-to-html.js <input.json> <output.html>");
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(inputFile, 'utf8'));

let html = `
<html>
<head>
  <title>Trivy Vulnerability Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h1 { color: #333; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
    th { background-color: #f2f2f2; }
    tr.HIGH { background-color: #ffe0e0; }
    tr.CRITICAL { background-color: #ffcccc; }
  </style>
</head>
<body>
  <h1>Trivy Vulnerability Report</h1>
  <table>
    <tr>
      <th>Library</th>
      <th>CVE</th>
      <th>Severity</th>
      <th>Installed Version</th>
      <th>Fixed Version</th>
      <th>Title</th>
    </tr>
`;

data.Results.forEach(result => {
  if (result.Vulnerabilities) {
    result.Vulnerabilities.forEach(vuln => {
      html += `
        <tr class="${vuln.Severity}">
          <td>${result.Target}</td>
          <td>${vuln.VulnerabilityID}</td>
          <td>${vuln.Severity}</td>
          <td>${vuln.InstalledVersion || ''}</td>
          <td>${vuln.FixedVersion || ''}</td>
          <td>${vuln.Title || ''}</td>
        </tr>
      `;
    });
  }
});

html += `
  </table>
</body>
</html>
`;

fs.writeFileSync(outputFile, html);
console.log(`HTML report written to ${outputFile}`);
