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

# Git hooks: wire the committed .husky/ so the counts self-heal pre-commit runs.
# Delegated to git-hooks-wire.sh — ONE definition, shared with the SessionStart
# registration. init alone was not enough: a fresh clone (local config is not
# cloned) and a repo rename (stale absolute path) both break the wiring AFTER
# init, which is why the same repair also runs per session.
_wire="$(dirname "${BASH_SOURCE[0]}")/git-hooks-wire.sh"
if [ -f "$_wire" ]; then
  bash "$_wire" || true
fi

echo "=== Setup complete ==="
exit 0
