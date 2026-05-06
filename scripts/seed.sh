#!/usr/bin/env bash
# Seed a demo customer + ad_account in core-module.
# After this, sign up via the web UI and then run scripts/link-user.sh
# to attach the new user to the seeded customer.
set -euo pipefail
cd "$(dirname "$0")/.."

docker compose run --rm core-module pnpm seed:dev
echo "seed complete. Now sign up at \$PUBLIC_URL/sign-up, then run scripts/link-user.sh \$EMAIL"
