#!/bin/bash
# Setup hook: Automatic dependency installation
# Triggered by: claude --init or claude --init-only

set -euo pipefail

echo "=== Setup: Installing dependencies ==="

# Node.js
if [ -f package.json ] && [ ! -d node_modules ]; then
  if [ -f bun.lockb ]; then bun install
  elif [ -f pnpm-lock.yaml ]; then pnpm install
  elif [ -f yarn.lock ]; then yarn install
  else npm install
  fi
  echo "✓ Node.js dependencies installed"
fi

# Python
if [ -f pyproject.toml ]; then
  if command -v uv >/dev/null 2>&1; then uv sync
  elif [ -f requirements.txt ]; then pip install -r requirements.txt
  fi
  echo "✓ Python dependencies installed"
fi

# Go
if [ -f go.mod ]; then
  go mod download
  echo "✓ Go dependencies installed"
fi

# Flutter/Dart
if [ -f pubspec.yaml ]; then
  if command -v flutter >/dev/null 2>&1; then flutter pub get
  elif command -v dart >/dev/null 2>&1; then dart pub get
  fi
  echo "✓ Dart dependencies installed"
fi

# Rust
if [ -f Cargo.toml ]; then
  cargo fetch 2>/dev/null || true
  echo "✓ Rust dependencies fetched"
fi

# Ruby
if [ -f Gemfile ] && ! [ -d vendor/bundle ]; then
  bundle install 2>/dev/null || true
  echo "✓ Ruby dependencies installed"
fi

# PHP
if [ -f composer.json ] && ! [ -d vendor ]; then
  composer install 2>/dev/null || true
  echo "✓ PHP dependencies installed"
fi

# Git hooks: wire the committed .husky/ directory so the counts self-heal
# pre-commit actually runs. Idempotent, and it REPAIRS a stale absolute
# core.hooksPath (e.g. left over from a repo rename) that silently disables every
# git hook. Local-scope only; no-op outside a work tree or without .husky/.
if [ -d .husky ] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [ "$(git config --local core.hooksPath 2>/dev/null || true)" != ".husky" ]; then
    git config --local core.hooksPath .husky
    echo "✓ git hooks wired (core.hooksPath=.husky)"
  fi
fi

echo "=== Setup complete ==="
exit 0
