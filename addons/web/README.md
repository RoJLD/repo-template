# addon : web

Patterns for projects with a web UI, REST/GraphQL API, or services that
need orchestration (databases, caches, frontends).

## When to add

Your project :
- Ships a web UI (React, Vue, Svelte, etc.)
- Exposes an HTTP/WebSocket API
- Needs orchestrated services (Postgres, Redis, NGINX, etc.)
- Has Windows-first developers who prefer `start.ps1` over `make up`

## What it adds

| File | Purpose |
|---|---|
| `Dockerfile` | Multi-stage build (Node frontend → Python backend → final image) |
| `docker-compose.yml` | Dev orchestration |
| `start.ps1` / `start.bat` | Windows one-click : `docker compose up` + open browser |
| `stop.ps1` / `stop.bat` | Graceful shutdown |
| `.dockerignore` | Excludes dev artifacts from build context |

## Why this works (lessons from all 4 Robin projects)

All four projects (hmm_studio, crypto, gitnexus, plane-like) use the same
`docker-compose + start.ps1 + stop.ps1` triplet. Windows developers
expect PowerShell entry points ; Mac/Linux can still use `docker compose
up` directly.

## Integration with core template

- Files copy to project root
- `start.bat` is a fallback for users who haven't enabled PowerShell
  execution policy
- The Dockerfile assumes Python backend + optional Node frontend ; adapt
  for other stacks (Rust, Go, etc.)

## Tier-3 OSS additions

If you go OSS, also add `.github/workflows/docker.yml` to publish images
to GHCR. See [tier-3-additions/](../../tier-3-additions/) for the OSS
extras (CODEOWNERS, SECURITY policy for the deployed service, etc.).
