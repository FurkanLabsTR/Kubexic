#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "kubex registry — local dev"
echo "==========================="

# Check wrangler is installed
if ! command -v wrangler &>/dev/null; then
  echo "error: wrangler is not installed"
  echo "  install it with: npm install -g wrangler"
  exit 1
fi

# Install deps if needed
if [ ! -d "node_modules" ]; then
  echo "installing dependencies..."
  npm install
fi

# Run local migrations
echo
echo "running local migrations..."
wrangler d1 execute kubex-registry-db --local --file=./migrations/0001_initial.sql

# Start local dev server
echo
echo "starting local dev server..."
echo "  http://localhost:8787"
echo "  press Ctrl+C to stop"
echo
wrangler dev --local
