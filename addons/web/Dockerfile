# {{PROJECT_NAME}} — multi-stage Dockerfile
# Adapt to your project's languages and stack.

# ---- Stage 1 : frontend build (Node, if applicable) ----
# FROM node:20-alpine AS frontend-build
# WORKDIR /app/frontend
# COPY src/frontend/package*.json ./
# RUN npm ci --no-audit --no-fund
# COPY src/frontend/ ./
# RUN npm run build

# ---- Stage 2 : Python backend + final image ----
FROM python:3.12-slim AS final

WORKDIR /app

# System deps (adjust as needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Python deps first (for layer caching)
COPY pyproject.toml ./
COPY src/ ./src/
RUN pip install --no-cache-dir -e ".[web]"

# Frontend assets (if applicable)
# COPY --from=frontend-build /app/frontend/dist /app/src/{{PROJECT_NAME}}/server/static

EXPOSE 8000
CMD ["python", "-m", "{{PROJECT_NAME}}"]
