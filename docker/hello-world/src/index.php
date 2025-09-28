<?php
// Collect env-like values from multiple superglobals
$vars = array_merge($_ENV, $_SERVER);

// Keep only string-ish values and sort for readability
$vars = array_filter($vars, fn($v) => is_scalar($v));
ksort($vars);

// Render simple HTML
?><!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>PHP Env Printer</title>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <style>
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; padding: 2rem; }
    h1 { margin-top: 0; }
    table { border-collapse: collapse; width: 100%; max-width: 900px; }
    th, td { border: 1px solid #ddd; padding: .5rem .75rem; vertical-align: top; }
    th { background: #f6f6f6; text-align: left; }
    code { white-space: pre-wrap; word-break: break-word; }
  </style>
</head>
<body>
  <h1>Hello World - Environment Variables</h1>
  <table>
    <thead><tr><th>Name</th><th>Value</th></tr></thead>
    <tbody>
      <?php foreach ($vars as $k => $v): ?>
        <tr><td><code><?= htmlspecialchars($k) ?></code></td>
            <td><code><?= htmlspecialchars((string)$v) ?></code></td></tr>
      <?php endforeach; ?>
    </tbody>
  </table>
</body>
</html>
