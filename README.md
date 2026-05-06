# Ribbler · Infra

## Local dev (Postgres only — apps run on host)

```bash
docker compose -f docker-compose.dev.yml up
```

Then `pnpm dev` in `core-module/` and `npm run dev` in `control-panel/`.

## Full-stack deploy (laptop or VM)

```bash
cp .env.example .env       # fill in secrets, especially ANTHROPIC_API_KEY and PUBLIC_URL
docker compose up --build -d
./scripts/migrate.sh
./scripts/seed.sh
# Sign up at $PUBLIC_URL/sign-up, then:
./scripts/link-user.sh you@example.com
```

Then expose with Cloudflare Tunnel — see [`scripts/tunnel.md`](scripts/tunnel.md).

For the demo runbook see [`DEMO.md`](DEMO.md).
