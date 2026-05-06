# Ribbler Demo Runbook

What your partner sees: an admin UI where the AI proposes Google Ads optimizations
(against synthetic Acme Plumbing data) and they approve/reject each one. No real
Google account, no real mutations — everything runs through the mock backend.

## Pre-demo checklist

- [ ] `infra/.env` has a real `ANTHROPIC_API_KEY` (Claude Sonnet 4.6 access)
- [ ] `infra/.env` has secure values for `JWT_SECRET`, `ENCRYPTION_KEY`, `BETTER_AUTH_SECRET`, `POSTGRES_PASSWORD` (use `openssl rand -base64 32` for each)
- [ ] `PUBLIC_URL` matches the Cloudflare Tunnel hostname (or `http://localhost:3000` for local-only)
- [ ] Stack is up: `docker compose ps` shows postgres, core-module, control-panel all running
- [ ] Migrations applied: `./scripts/migrate.sh` ran without errors
- [ ] Demo customer + ad_account seeded: `./scripts/seed.sh` ran
- [ ] You've signed up via the web UI at `$PUBLIC_URL/sign-up` and run `./scripts/link-user.sh your@email.com`
- [ ] You've kicked off at least one analysis run before the demo (see "Pre-warm proposals" below) so the queue isn't empty when your partner first looks
- [ ] Cloudflare tunnel is running (`cloudflared tunnel run ribbler-demo` or `--url`) and the URL is accessible

## Pre-warm proposals

The AI doesn't run automatically — you must trigger an analysis run before the demo. Either:

1. Sign in to the admin yourself, navigate to AI Suggestions, click "Run analysis", and wait 30–60 seconds for proposals to appear.
2. Or via curl (replace `$JWT` and `$ACCT`):
   ```bash
   ACCT=$(docker compose exec postgres psql -U ribbler -d ribbler -tA -c "SELECT id FROM core.ad_accounts LIMIT 1")
   # JWT-mint requires being signed in via the UI to get a session cookie, so the easier path is the UI button.
   ```

Verify proposals exist:
```bash
docker compose exec postgres psql -U ribbler -d ribbler -c \
  "SELECT type, COUNT(*) FROM core.proposals GROUP BY type"
```

You should see counts for `add_negative_keyword`, `add_keyword`, and `set_geo_bid_modifier`.
**If any are zero, iterate on `core-module/prompts/analyst-v1.md` and re-run.** This is the
most likely failure mode — the prompt may need tweaking against the mock fixture to find
all three optimization types.

## Demo flow (10 minutes)

1. **Partner opens `$PUBLIC_URL`** and signs in with the credentials you set up. (Or: have them sign up live — the link-user.sh script associates them with the seeded customer.)

2. **Dashboard** — point out spend ($4,720), clicks, conversions, CPA. Note the badge counting pending suggestions.

3. **AI Suggestions** — show the queue. Pick one **negative keyword** proposal (e.g. "plumber salary"):
   - Expand "Evidence" — explain that's the actual data the AI saw.
   - Expand "Raw mutation" — explain that's exactly what would be sent to Google Ads.
   - Click **Approve**.
   - Show the green "Executed (simulated)" diff.

4. **Search Terms tab** (under Campaigns → Brand-Search-US → Search Terms):
   - Show that the same proposals render inline next to the source data.
   - Click an "AI suggests negative" pill and approve from there.

5. **AI Permissions** — every tool has allow / approve / deny. For this demo, all writes are "approve" — that's why nothing ever runs without your partner clicking.

6. **Activity Log** — every AI decision, every approval, every execution is recorded. Forensic audit by design.

7. **Run analysis live** — click the button on AI Suggestions, watch new proposals appear in 30–60 seconds.

## Reset between demos

```bash
docker compose exec postgres psql -U ribbler -d ribbler -c \
  "TRUNCATE core.proposals, core.analysis_runs, core.audit_log RESTART IDENTITY CASCADE"
```

This wipes all proposals and runs. Customer, ad_account, users, and tool_overrides are preserved.

## Troubleshooting

- **"No customer membership"** on the Dashboard → run `./scripts/link-user.sh your@email.com`
- **"Failed to load /me"** → check `JWT_SECRET` is identical in core-module and control-panel env vars. They must match exactly.
- **Run analysis stays in `running` for >2 minutes** → `docker compose logs core-module` will show the Anthropic error. Most common: invalid API key, or rate limit.
- **Partner sees a 401** → their Better-Auth session expired. Have them sign in again.
