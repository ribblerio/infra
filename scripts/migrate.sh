#!/usr/bin/env bash
# Apply core-module's Drizzle migrations and Better-Auth's schema to the running Postgres.
# Idempotent — safe to run multiple times.
set -euo pipefail
cd "$(dirname "$0")/.."

# Apply core-module migrations (creates core.* tables)
docker compose run --rm core-module pnpm db:migrate

# Apply Better-Auth schema (creates auth.* tables) using the SQL produced by
# @better-auth/cli generate. The file lives in control-panel/drizzle-auth.sql
# and was committed to git.
docker compose exec -T postgres psql -U ribbler -d ribbler \
  < ../control-panel/drizzle-auth.sql || echo "(auth schema may already exist; ignoring)"

echo "migrations applied"
