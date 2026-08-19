#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "kubex registry — deploy"
echo "========================"

# Check wrangler is installed
if ! command -v wrangler &>/dev/null; then
  echo "error: wrangler is not installed"
  echo "  install it with: npm install -g wrangler"
  exit 1
fi

echo "wrangler found: $(wrangler --version 2>&1 | head -1)"

# Create D1 database if not exists
echo
echo "setting up D1 database..."
DB_OUTPUT=$(wrangler d1 create kubex-registry-db 2>&1) || true
DB_ID=$(echo "$DB_OUTPUT" | grep 'database_id' | sed 's/.*"\(.*\)".*/\1/' || true)

if [ -z "$DB_ID" ]; then
  # Database already exists, try to get its ID
  DB_ID=$(wrangler d1 list 2>/dev/null | grep kubex-registry-db | awk '{print $1}' || true)
fi

if [ -n "$DB_ID" ]; then
  echo "D1 database ID: $DB_ID"
  # Update wrangler.toml with the real ID
  sed -i "s/database_id = \"PLACEHOLDER_D1_ID\"/database_id = \"$DB_ID\"/" wrangler.toml
else
  echo "warning: could not determine D1 database ID, using placeholder"
fi

# Create R2 bucket if not exists
echo
echo "setting up R2 bucket..."
wrangler r2 bucket create kubex-registry-bucket 2>/dev/null || true
echo "R2 bucket ready"

# Run migrations
echo
echo "running migrations..."
wrangler d1 execute kubex-registry-db --file=./migrations/0001_initial.sql
wrangler d1 execute kubex-registry-db --file=./migrations/0002_admin.sql
echo "migrations applied"

# Deploy the worker
echo
echo "deploying worker..."
wrangler deploy

# Get the deployment URL
echo
echo "========================"
echo "deployment complete!"
echo
echo "  worker:  kubex-registry"
echo "  API:     https://kubex-registry.<your-subdomain>.workers.dev/v1"
echo
echo "update your registry URL:"
echo "  kubex --registry https://kubex-registry.<your-subdomain>.workers.dev/v1 <command>"
echo "  or set KUBEX_REGISTRY_URL in your environment"
