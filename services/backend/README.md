# Recall backend

The backend is a local-only FastAPI service. Layer 1 provides validated
configuration, SQLite connectivity, and `GET /health`; Capture persistence and
API routes begin in Layer 2.

Run all commands below from `services/backend/`.

## Install

```bash
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt
```

The service reads optional configuration from the repository-root `.env` and
then from the shell environment. It starts safely without `.env` or an OpenAI
key. Copy `.env.example` to `.env` only when local overrides are needed.

`RECALL_HOST` must be `localhost` or a loopback IP address. The default is
`127.0.0.1`; public or LAN binding is rejected.

## Start

```bash
.venv/bin/python -m app
```

In another terminal:

```bash
curl --fail --silent http://127.0.0.1:8765/health
```

Without an API key, the expected response is:

```json
{"status":"ok","database":"ok","openai_configured":false}
```

The health probe creates the configured SQLite file if needed and checks it
with `SELECT 1`. Layer 1 does not create application tables.

## Test

```bash
.venv/bin/python -m pytest
```

## Configuration

| Variable | Default | Purpose |
| --- | --- | --- |
| `OPENAI_API_KEY` | unset | Enables later OpenAI layers when non-empty |
| `OPENAI_MODEL` | `gpt-5.6` | Later enrichment model |
| `OPENAI_EMBEDDING_MODEL` | `text-embedding-3-small` | Later embedding model |
| `RECALL_HOST` | `127.0.0.1` | Loopback-only bind host |
| `RECALL_PORT` | `8765` | Backend port, from 1 through 65535 |
| `RECALL_DATABASE_PATH` | `./data/recall.db` | SQLite file, relative to repository root |
| `RECALL_LOG_LEVEL` | `INFO` | Python logging level |
| `RECALL_CORS_ORIGINS` | unset | Comma-separated allowed origins for a later client layer |
