"""Minimal FastAPI application for the Recall localhost service."""

from __future__ import annotations

import logging
import sqlite3
from pathlib import Path
from typing import Literal

from fastapi import FastAPI, Response, status
from pydantic import BaseModel

from app.config import get_settings


logger = logging.getLogger(__name__)


class HealthResponse(BaseModel):
    status: Literal["ok", "degraded"]
    database: Literal["ok", "error"]
    openai_configured: bool


def check_database(database_path: Path) -> Literal["ok", "error"]:
    """Open the configured SQLite file and execute a connectivity probe."""

    try:
        database_path.parent.mkdir(parents=True, exist_ok=True)
        with sqlite3.connect(database_path, timeout=2) as connection:
            result = connection.execute("SELECT 1").fetchone()
        return "ok" if result == (1,) else "error"
    except (OSError, sqlite3.Error):
        logger.exception("SQLite health probe failed for %s", database_path)
        return "error"


app = FastAPI(title="Recall Backend", version="0.1.0")


@app.get("/health", response_model=HealthResponse)
def health(response: Response) -> HealthResponse:
    settings = get_settings()
    database = check_database(settings.recall_database_path)
    if database == "error":
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
        return HealthResponse(
            status="degraded",
            database=database,
            openai_configured=settings.openai_configured,
        )

    return HealthResponse(
        status="ok",
        database=database,
        openai_configured=settings.openai_configured,
    )
