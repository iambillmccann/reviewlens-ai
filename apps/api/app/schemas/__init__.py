from typing import Any

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str


class VersionResponse(BaseModel):
    name: str
    version: str


class ApiErrorDetail(BaseModel):
    field: str | None = None
    issue: str
    context: dict[str, Any] | None = None


class ApiError(BaseModel):
    code: str
    message: str
    details: list[ApiErrorDetail] = Field(default_factory=list)


class ApiErrorResponse(BaseModel):
    error: ApiError
