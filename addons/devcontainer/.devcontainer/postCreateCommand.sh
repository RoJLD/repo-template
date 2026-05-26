#!/usr/bin/env bash
# Runs once after the dev container is created.
# Installs the project in editable mode with all dev deps.

set -euo pipefail

echo "Installing {{PROJECT_NAME}} in editable mode..."
pip install --user -e ".[dev]"

# If you have extra optional groups, install them too :
# pip install --user -e ".[web,ml,docs]"

echo ""
echo "=== Dev container ready ==="
echo "Run tests :    pytest"
echo "Lint    :      ruff check src/"
echo "Format  :      ruff format src/"
echo ""
