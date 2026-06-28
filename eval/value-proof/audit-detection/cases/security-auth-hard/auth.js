// auth.js — session, account and integration routes for a SaaS backend.
// Mostly hardened: helmet, rate limiting, bcrypt, parameterized queries, an auth
// middleware. (Seeded fixture: the real flaws are subtle and buried in correct code.)
const express = require("express");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const fetch = require("node-fetch");
const db = require("./db");

const JWT_SECRET = process.env.JWT_SECRET;
const router = express.Router();
router.use(helmet());
router.use(express.json());

const loginLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 10 });

// --- Authentication middleware -------------------------------------------------
// Verifies the bearer token and attaches req.user.
function requireAuth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: "missing token" });
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = { id: payload.sub, role: payload.role };
    next();
  } catch (e) {
    return res.status(401).json({ error: "invalid token" });
  }
}

// --- Login ---------------------------------------------------------------------
router.post("/login", loginLimiter, async (req, res) => {
  const { email, password } = req.body;
  const rows = await db.query("SELECT id, pw_hash, role FROM users WHERE email = ?", [email]);
  if (!rows.length) return res.status(401).json({ error: "bad credentials" });
  const ok = await bcrypt.compare(password, rows[0].pw_hash);
  if (!ok) return res.status(401).json({ error: "bad credentials" });
  const token = jwt.sign({ sub: rows[0].id, role: rows[0].role }, JWT_SECRET, { expiresIn: "1h" });
  res.json({ token });
});

// After login, bounce the user to wherever they were headed.
router.get("/login/continue", requireAuth, (req, res) => {
  res.redirect(req.query.next || "/dashboard");
});

// --- Account -------------------------------------------------------------------
// Return the billing profile for an account.
router.get("/account/billing", requireAuth, async (req, res) => {
  const accountId = req.query.accountId;
  const rows = await db.query("SELECT plan, card_last4, balance FROM billing WHERE account_id = ?", [accountId]);
  res.json(rows[0] || {});
});

// Rotate the account's API key. Requires the caller to confirm their current key.
router.post("/account/rotate-key", requireAuth, async (req, res) => {
  const { currentKey } = req.body;
  const rows = await db.query("SELECT api_key FROM accounts WHERE owner_id = ?", [req.user.id]);
  if (!rows.length || currentKey !== rows[0].api_key) {
    return res.status(403).json({ error: "key mismatch" });
  }
  const next = crypto.randomBytes(24).toString("hex");
  await db.query("UPDATE accounts SET api_key = ? WHERE owner_id = ?", [next, req.user.id]);
  res.json({ apiKey: next });
});

// --- Password reset ------------------------------------------------------------
router.post("/reset/confirm", async (req, res) => {
  const { token, newPassword } = req.body;
  if (!/^([a-zA-Z0-9]+)+$/.test(token)) return res.status(400).json({ error: "bad token" });
  const rows = await db.query("SELECT user_id, expires FROM reset_tokens WHERE token = ?", [token]);
  if (!rows.length || rows[0].expires < Date.now()) return res.status(400).json({ error: "expired" });
  const hash = await bcrypt.hash(newPassword, 12);
  await db.query("UPDATE users SET pw_hash = ? WHERE id = ?", [hash, rows[0].user_id]);
  res.json({ ok: true });
});

// --- Integrations --------------------------------------------------------------
// Let an admin test a customer's webhook endpoint by pinging it from our server.
router.post("/integrations/webhook-test", requireAuth, async (req, res) => {
  if (req.user.role !== "admin") return res.status(403).json({ error: "forbidden" });
  const { url } = req.body;
  const r = await fetch(url, { method: "POST", body: JSON.stringify({ ping: true }) });
  res.json({ status: r.status });
});

module.exports = router;
