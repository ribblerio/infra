#!/usr/bin/env bash
# Link a Better-Auth user (by email) to the seeded customer's first membership row.
# Usage: ./scripts/link-user.sh user@example.com
set -euo pipefail
EMAIL="${1:?email required}"
cd "$(dirname "$0")/.."

docker compose exec -T postgres psql -U ribbler -d ribbler -v ON_ERROR_STOP=1 -v email="$EMAIL" <<'SQL'
\set email_quoted '''' :email ''''
UPDATE core.memberships
SET user_id = (SELECT id FROM auth.user WHERE email = :email_quoted::text)
WHERE user_id = '00000000-0000-0000-0000-000000000001';
SELECT customer_id, user_id, role FROM core.memberships;
SQL
echo "linked $EMAIL to seeded customer"
