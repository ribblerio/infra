# Cloudflare Tunnel — exposing the demo to a remote partner

Two options. Pick one based on how persistent you need the URL.

## Option A — Ephemeral tunnel (no DNS needed, URL changes on every restart)

```bash
cloudflared tunnel --url http://localhost:3000
# prints something like https://random-words-here.trycloudflare.com
```

Send that URL to your partner. When you restart `cloudflared`, the URL changes.

## Option B — Named tunnel (stable URL, requires a domain)

One-time setup:

```bash
cloudflared tunnel login           # opens browser; pick the domain you own
cloudflared tunnel create ribbler-demo
# note the printed UUID

cloudflared tunnel route dns ribbler-demo ribbler.<your-domain>
```

Create `~/.cloudflared/config.yml`:

```yaml
tunnel: <UUID-from-tunnel-create>
credentials-file: /Users/<you>/.cloudflared/<UUID>.json

ingress:
  - hostname: ribbler.<your-domain>
    service: http://localhost:3000
  - service: http_status:404
```

Run:

```bash
cloudflared tunnel run ribbler-demo
```

Set `PUBLIC_URL=https://ribbler.<your-domain>` in `infra/.env` so Better-Auth's `BETTER_AUTH_URL` matches the tunnel hostname.
