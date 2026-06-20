# Reviewlens-ai API

FastAPI backend for the Reviewlens-ai project.

## Run locally

```bash
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
pip install -e .
uvicorn app.main:app --reload --port 8000
```

Start local PostgreSQL from repo root:

```bash
./scripts/dev-db-up.sh
```

## Endpoints

### Health & Status

- `GET /api/v1/health` — Health check
- `GET /api/v1/ready` — Readiness check
- `GET /api/v1/version` — API version info

### Application Endpoints

- `GET /api/me` (canonical) — Returns the app user profile when available
- `GET /api/v1/auth/me` (legacy) — Compatibility endpoint retained during transition

## Testing

Install dev dependencies:

```bash
pip install -e ".[dev]"
```

Run tests:

```bash
pytest
```

Run tests with coverage:

```bash
pytest --cov=app --cov-report=html
```

## Migrations

Run migrations from `apps/api`:

```bash
alembic upgrade head
```

Reset migration state for reproducibility checks:

```bash
alembic downgrade base
alembic upgrade head
```

## Configuration

Create environment variables from the repo root `.env.example` and ensure `DATABASE_URL` points to the local PostgreSQL container:

`postgresql+psycopg://postgres:postgres@localhost:5432/reviewlens-ai`

Database-related setting:

- `DATABASE_URL`: SQLAlchemy connection URL used by runtime and Alembic

CORS-related settings:

- `CORS_ORIGINS`: comma-separated allowlist of exact origins. Supports wildcard entries such as `https://*.your-project.pages.dev` for preview deployments.
- `CORS_ORIGIN_REGEX`: optional advanced regex appended to the computed allow-origin regex.
