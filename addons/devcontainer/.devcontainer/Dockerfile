# Dev container — full toolchain, NOT optimized for size.
# Use this for the dev experience ; the production Dockerfile (if any)
# lives at the repo root and is minimal.

FROM mcr.microsoft.com/devcontainers/python:3.12

# System deps for dev (compilers, debuggers, etc.) — adjust as needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    git \
    curl \
    less \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Project deps will be installed via postCreateCommand.sh
USER vscode
WORKDIR /workspaces/{{PROJECT_NAME}}
