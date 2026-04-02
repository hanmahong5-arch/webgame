# lurus-www

Public website and marketing landing pages. Elixir/Phoenix with LiveView for SSR + interactive components. No database -- stateless, all data fetched from platform APIs at runtime.

| Item | Value |
|---|---|
| URL | `https://www.lurus.cn` (`lurus.cn` 301 redirects here) |
| Namespace | `lurus-www` |
| Image | `ghcr.io/hanmahong5-arch/lurus-www:main-<sha7>` |
| Dev port | `4000` |

## Tech Stack

- Elixir 1.17 + OTP 27
- Phoenix 1.7 + LiveView 1.0 (dead-render for SEO, LiveView for interactivity)
- Bandit (HTTP server, replaces Cowboy)
- Tailwind CSS 4 (integrated via `mix assets.deploy`)
- Finch (HTTP client for API proxy and server-side fetches)
- No database, no Ecto

## Directory Structure

```
lurus-www/
├── lib/
│   ├── lurus_www/            # Application logic (OIDC, API client, release helpers)
│   └── lurus_www_web/        # Phoenix web layer
│       ├── controllers/      # Auth callback, health check
│       ├── live/             # LiveView pages (Home, Pricing, Solutions, Download...)
│       ├── components/       # Function components (Hero, Chat, Features, Portal...)
│       ├── layouts/          # Root and app layouts
│       └── router.ex         # Route definitions
├── assets/                   # JS, CSS (Tailwind), static assets
├── priv/static/              # Compiled assets (after mix assets.deploy)
├── config/                   # Config files (config.exs, runtime.exs, prod.exs)
├── test/                     # ExUnit tests
├── deploy/
│   ├── Dockerfile            # Multi-stage Elixir release build
│   └── k8s/                  # K8s manifests (deployment, service, ingress, pdb, kustomization)
└── _bmad-output/             # BMAD artifacts
```

## Commands

```bash
# Development
mix deps.get
mix phx.server           # http://localhost:4000

# Build
mix assets.deploy         # Compile + digest static assets
MIX_ENV=prod mix release  # Production release

# Test
mix test                  # ExUnit tests
mix test --cover          # With coverage

# Quality
mix credo --strict        # Static analysis
mix format --check-formatted  # Formatting check
```

## Environment Variables

Runtime configuration (via `config/runtime.exs`, read at boot):

| Variable | Default | Description |
|---|---|---|
| `PHX_HOST` | `localhost` | Hostname for URL generation and CORS |
| `PORT` | `4000` | HTTP listen port |
| `SECRET_KEY_BASE` | (required) | Phoenix session/cookie signing key (64+ hex chars) |
| `ZITADEL_ISSUER` | `https://auth.lurus.cn` | OIDC issuer URL |
| `ZITADEL_CLIENT_ID` | (required) | OIDC public client ID |
| `API_URL` | `https://api.lurus.cn` | Backend API base URL (proxied via Finch) |
| `CHAT_ENABLED` | `"false"` | Enable AI chat widget |

## Key Patterns

- **Dead-render SSR**: All pages render full HTML on first request (SEO-friendly). LiveView upgrades to WebSocket for interactivity.
- **OIDC auth**: Authorization Code + PKCE flow, session stored in encrypted cookie (no client-side token storage).
- **API proxy**: Server-side requests to `api.lurus.cn` via Finch connection pool. No direct browser-to-API calls for authenticated endpoints.
- **Static data**: Marketing content lives in module attributes / config, not hardcoded in templates.
- **Health endpoint**: `GET /health` returns 200 for K8s probes.

## BMAD

| Resource | Path |
|---|---|
| PRD | `./_bmad-output/planning-artifacts/prd.md` |
| Epics | `./_bmad-output/planning-artifacts/epics.md` |
| Architecture | `./_bmad-output/planning-artifacts/architecture.md` |
| UX Design | `./_bmad-output/planning-artifacts/ux-design-specification.md` |
| Product Brief | `./_bmad-output/planning-artifacts/product-brief.md` |
| Sprint Status | `./_bmad-output/sprint-status.yaml` |
| Stories | `./_bmad-output/implementation-artifacts/stories/` |
| Code Review | `./_bmad-output/code-review/` |
