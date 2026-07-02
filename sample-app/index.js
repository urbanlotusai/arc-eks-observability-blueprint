'use strict';

const http = require('http');

const PORT = process.env.PORT || 8080;
const VERSION = process.env.APP_VERSION || '1.0.0';

let requestCount = 0;

const server = http.createServer((req, res) => {
  requestCount += 1;

  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  // Structured JSON log line — Fluent Bit ships this to OpenSearch + S3
  console.log(JSON.stringify({
    level: 'info',
    message: 'request handled',
    method: req.method,
    path: req.url,
    requestCount,
    timestamp: new Date().toISOString(),
  }));

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: 'Your ARC EKS Observability Blueprint is live.',
    poweredBy: 'SourceFuse ARC Blueprint',
    version: VERSION,
    requestCount,
    timestamp: new Date().toISOString(),
  }, null, 2));
});

server.listen(PORT, () => console.log(`Sample app listening on :${PORT}`));
