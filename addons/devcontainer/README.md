# addon : devcontainer

Zero-config dev environment via VS Code DevContainers / GitHub Codespaces.

## When to add

Your project :
- Has collaborators on Mac/Linux/Windows mixed setups
- Needs specific system deps (PostgreSQL, Redis, Tesseract, etc.) that
  are painful to install per-OS
- Will be tried by visitors who shouldn't have to set up a Python venv
- Is OSS and you want zero-friction "click to develop"

**Note** : if you're a solo Windows dev with Docker Desktop, the `web`
addon's `start.ps1` is simpler. DevContainers shine when developer
setups diverge.

## What it adds

| File | Purpose |
|---|---|
| `.devcontainer/devcontainer.json` | VS Code DevContainer spec |
| `.devcontainer/Dockerfile` | Dev image (different from prod web Dockerfile) |
| `.devcontainer/postCreateCommand.sh` | Install hook (pip install -e .[dev]) |

## Why this works

- **VS Code DevContainer** = open repo, click "Reopen in Container",
  done. No local Python install needed.
- **GitHub Codespaces** uses the same `.devcontainer/` spec — your repo
  becomes "one click to start hacking" for anyone on GitHub.
- Reproducibility : "it works on my machine" disappears because the
  machine is defined in code.

## Integration with core template

- `.devcontainer/` folder at repo root
- VS Code prompts collaborators to reopen in container automatically
- Combine with the `web` addon for projects that also ship a production
  Dockerfile (the two Dockerfiles serve different purposes :
  `.devcontainer/Dockerfile` = dev with full toolchain ; `/Dockerfile` =
  minimal prod image)

## Cost

DevContainers add ~3 minutes to first-time setup (image build) but save
hours of "Python version mismatch" debugging. ROI positive once you have
> 1 contributor.
