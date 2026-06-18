from fastapi import APIRouter

from app.core.config import settings
from app.schemas import (
    HealthResponse,
    VersionResponse,
)

router = APIRouter(prefix="/api/v1", tags=["v1"])
canonical_router = APIRouter(prefix="/api", tags=["canonical"])


@router.get("/health", response_model=HealthResponse)
async def health() -> HealthResponse:
    """Health check endpoint."""
    return HealthResponse(status="ok")


@router.get("/ready", response_model=HealthResponse)
async def ready() -> HealthResponse:
    """Readiness check endpoint."""
    return HealthResponse(status="ready")


@router.get("/version", response_model=VersionResponse)
async def version() -> VersionResponse:
    """API version endpoint."""
    return VersionResponse(name=settings.app_name, version=settings.app_version)
