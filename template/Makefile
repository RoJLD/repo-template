.PHONY: help install dev test validation lint format clean

# Self-documenting Makefile : `make help` lists all commands
help:
	@echo "Available targets :"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install:  ## Install in editable mode with all dev deps
	pip install -e ".[dev]"

dev: install  ## Alias for install

test:  ## Run code-correctness tests (fast)
	pytest -m "not slow"

test-all:  ## Run all tests including slow ones
	pytest

validation:  ## Run scientific correctness suite
	pytest validation/

lint:  ## Lint code
	ruff check src/ tests/

format:  ## Format code
	ruff format src/ tests/
	black src/ tests/

check: lint test  ## Run lint + fast tests (pre-commit)

clean:  ## Remove build artifacts and caches
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf build/ dist/ .pytest_cache/ .ruff_cache/ .coverage htmlcov/
