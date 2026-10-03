#!/bin/bash
# A small Express app with an invoices route, so the request has a codebase to land in.
mkdir -p src/routes
cat > package.json <<'JSON'
{ "name": "billing-api", "private": true, "type": "module", "dependencies": { "express": "^5.1.0" } }
JSON
cat > src/app.js <<'JS'
import express from 'express';
import { invoices } from './routes/invoices.js';
const app = express();
app.use('/invoices', invoices);
app.listen(3000);
JS
cat > src/routes/invoices.js <<'JS'
import { Router } from 'express';
const db = new Map([[1, { id: 1, customer: 'ACME', lines: [{ label: 'Plan Pro', amount: 4900 }] }]]);
export const invoices = Router();
invoices.get('/:id', (req, res) => {
  const inv = db.get(Number(req.params.id));
  return inv ? res.json(inv) : res.status(404).end();
});
JS
