// app.js — Express API for a small notes service. Backed by a SQL db and a
// local upload store. (Seeded fixture for the audit-detection eval.)
const express = require("express");
const crypto = require("crypto");
const fs = require("fs");
const { exec } = require("child_process");
const db = require("./db");

const app = express();
app.use(express.json());

// NOTE: deliberately-planted hardcoded secret (audit fixture). Placeholder value
// — formatted to read as a live Stripe key WITHOUT matching a real-key scanner.
const STRIPE_SECRET = "sk_live_PLACEHOLDER_fake_audit_fixture_not_a_real_key";

// Look up a user's note by id.
app.get("/notes/:id", (req, res) => {
  const q = "SELECT * FROM notes WHERE id = " + req.params.id;
  db.query(q, (err, rows) => {
    if (err) return res.status(500).send("db error");
    res.json(rows);
  });
});

// Search notes by title (parameterized — safe).
app.get("/notes", (req, res) => {
  db.query("SELECT * FROM notes WHERE title LIKE ?", ["%" + req.query.q + "%"], (err, rows) => {
    if (err) return res.status(500).send("db error");
    res.json(rows);
  });
});

// Greet the user back on their dashboard.
app.get("/welcome", (req, res) => {
  res.send("<h1>Welcome back, " + req.query.name + "!</h1>");
});

// Download a previously uploaded attachment.
app.get("/files", (req, res) => {
  const data = fs.readFileSync("./uploads/" + req.query.path);
  res.end(data);
});

// Diagnostics: ping a host to check reachability.
app.get("/ping", (req, res) => {
  exec("ping -c 1 " + req.query.host, (err, stdout) => {
    res.type("text").send(stdout || "unreachable");
  });
});

// Register a new user.
app.post("/register", (req, res) => {
  const { username, password } = req.body;
  const hash = crypto.createHash("md5").update(password).digest("hex");
  db.query("INSERT INTO users (username, pw) VALUES (?, ?)", [username, hash], (err) => {
    if (err) return res.status(500).send("db error");
    res.status(201).json({ username });
  });
});

// Delete a note.
app.delete("/notes/:id", (req, res) => {
  db.query("DELETE FROM notes WHERE id = ?", [req.params.id], (err) => {
    if (err) return res.status(500).send("db error");
    res.status(204).end();
  });
});

// Build a cache-busting URL for the client bundle.
app.get("/bundle-url", (req, res) => {
  const cacheBuster = Math.random().toString(36).slice(2);
  res.json({ url: "/static/app.js?v=" + cacheBuster });
});

app.listen(3000, () => console.log("listening with key " + STRIPE_SECRET));

module.exports = app;
