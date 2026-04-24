# WebGame (2c-bs-www-phoenix)

Phoenix LiveView 实时多人游戏（slither.io 风格 snake + RPG 进化 + 幸运系统）。
原公司官网代码库，2026-04 转型为 webgame 产品；www 已迁回 Next.js (`2c-bs-www-next`)。

- Tech: Elixir 1.17 + Phoenix 1.7 + LiveView 1.0 + Bandit + Tailwind 4
- Namespace: `lurus-webgame`
- Domain: `webgame.lurus.cn`
- Image: `ghcr.io/hanmahong5-arch/webgame:latest`
- Node: cloud-ubuntu-1-16c32g (co-located with Traefik)
- Product Group: Lucrum / Entertainment

> 相关 skill: `/webgame` — 游戏设计、引擎踩坑、Canvas 渲染、Elixir 陷阱大全。

## Directory

```
lib/
├── lurus_www/
│   ├── games/
│   │   ├── game_server.ex           # Per-room GenServer tick loop
│   │   ├── game_supervisor.ex       # DynamicSupervisor
│   │   └── snake/engine.ex          # Core snake/food/collision physics
│   └── scores/                      # Player score persistence
└── lurus_www_web/
    ├── live/
    │   ├── home_live.ex             # Homepage IS the game (zero-friction)
    │   ├── game_live.ex             # Full game room
    │   ├── creator_live.ex          # Future: skin/room creator
    │   └── privacy_live.ex / terms_live.ex
    └── components/
assets/                              # JS hooks, Canvas renderer, Tailwind
deploy/k8s/                          # lurus-webgame ns manifests
```

## Commands

```bash
mix deps.get
mix phx.server                   # http://localhost:4000
mix assets.deploy                # Tailwind + esbuild + digest
MIX_ENV=prod mix release
mix test                         # ExUnit (lazy_html required for LV 1.1+)
mix credo --strict
mix format --check-formatted
bun run test:e2e                 # Playwright (playwright.config.ts)
```

## Environment Variables

| Var | Default | Purpose |
|---|---|---|
| `PHX_HOST` | `localhost` | URL + CORS host |
| `PORT` | `4000` | HTTP |
| `SECRET_KEY_BASE` | (required) | 64+ hex chars |
| `DATABASE_URL` | (optional) | player_scores persistence |

## Gotchas (still active)

- **BadBooleanError**: 不要在 LV 模板用 `and/or/not`，一律 `&&`/`||`/`!`。
- **TDZ ReferenceError**: Canvas `draw()` 里 `const` 必须在首次使用前声明。
- **playerId 漂移**: 三路 fallback — localStorage baseline + form + `joined` event。
- **Tail growth**: 必须用真实间隔 points 扩展尾部，不要 `List.duplicate`（会坍塌）。
- **多 tab 碰撞**: 服务端每 tick push `my_id`，前端按最新覆盖。

## BMAD

| Resource | Path |
|---|---|
| PRD | `./_bmad-output/planning-artifacts/prd.md` |
| Epics | `./_bmad-output/planning-artifacts/epics.md` |
| Architecture | `./_bmad-output/planning-artifacts/architecture.md` |
| Sprint Status | `./_bmad-output/sprint-status.yaml` |
