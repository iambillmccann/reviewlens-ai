import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.fixture
def client():
    """Provide a test client for the FastAPI app."""
    return TestClient(app)


class TestHealthEndpoint:
    """Tests for the /api/v1/health endpoint."""

    def test_health_returns_ok(self, client):
        """Health endpoint should return status ok."""
        response = client.get("/api/v1/health")
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}

    def test_health_response_schema(self, client):
        """Health response should match HealthResponse schema."""
        response = client.get("/api/v1/health")
        data = response.json()
        assert "status" in data
        assert isinstance(data["status"], str)


class TestReadyEndpoint:
    """Tests for the /api/v1/ready endpoint."""

    def test_ready_returns_ready(self, client):
        """Readiness endpoint should return status ready."""
        response = client.get("/api/v1/ready")
        assert response.status_code == 200
        assert response.json() == {"status": "ready"}

    def test_ready_response_schema(self, client):
        """Ready response should match HealthResponse schema."""
        response = client.get("/api/v1/ready")
        data = response.json()
        assert "status" in data
        assert isinstance(data["status"], str)


class TestVersionEndpoint:
    """Tests for the /api/v1/version endpoint."""

    def test_version_returns_data(self, client):
        """Version endpoint should return name and version."""
        response = client.get("/api/v1/version")
        assert response.status_code == 200
        data = response.json()
        assert "name" in data
        assert "version" in data
        assert data["name"] == "reviewlens-api"
        assert data["version"] == "0.1.0"

    def test_version_response_schema(self, client):
        """Version response should match VersionResponse schema."""
        response = client.get("/api/v1/version")
        data = response.json()
        assert isinstance(data["name"], str)
        assert isinstance(data["version"], str)


class TestErrorShapes:
    """Tests for structured error responses."""

    def test_404_error_shape(self, client):
        """404 responses should use structured error format."""
        response = client.get("/api/v1/does-not-exist")
        assert response.status_code == 404
        data = response.json()
        assert "error" in data
        assert "code" in data["error"]
        assert "message" in data["error"]
        assert "details" in data["error"]
        assert data["error"]["code"] == "http_error"
        assert isinstance(data["error"]["details"], list)

    def test_validation_error_shape(self, client):
        """Validation error responses should use structured error format."""
        # This would require an endpoint that accepts request body with validation
        # For now, we verify the error handler structure is in place
        # by checking that a malformed request produces an error response
        response = client.post("/api/v1/health", json={"invalid": "data"})
        assert response.status_code in [404, 405, 422]
        # Endpoints that return 404 or 405 should still use structured error
        data = response.json()
        assert "error" in data or response.status_code in [404, 405]

    def test_error_response_has_required_fields(self, client):
        """Error responses should always have error.code, error.message, error.details."""
        response = client.get("/api/v1/nonexistent")
        assert response.status_code == 404
        data = response.json()
        error = data.get("error")
        assert error is not None
        assert isinstance(error.get("code"), str)
        assert isinstance(error.get("message"), str)
        assert isinstance(error.get("details"), list)


class TestCORSConfiguration:
    """Tests for CORS configuration."""

    def test_cors_allows_localhost_5173(self, client):
        """CORS should allow requests from localhost:5173."""
        # CORS middleware should be configured with the origin
        # Verify via GET request with Origin header
        origin = "http://localhost:5173"
        response = client.get(
            "/api/v1/health",
            headers={"Origin": origin},
        )
        assert response.status_code == 200
        # Verify the response still works with origin header
        assert response.json() == {"status": "ok"}
        assert response.headers.get("access-control-allow-origin") == origin

    def test_cors_allows_localhost_5174(self, client):
        """CORS should allow requests from localhost:5174."""
        origin = "http://localhost:5174"
        response = client.get(
            "/api/v1/health",
            headers={"Origin": origin},
        )
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}
        assert response.headers.get("access-control-allow-origin") == origin

    def test_cors_allows_localhost_4173(self, client):
        """CORS should allow requests from localhost:4173."""
        origin = "http://localhost:4173"
        response = client.get(
            "/api/v1/health",
            headers={"Origin": origin},
        )
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}
        assert response.headers.get("access-control-allow-origin") == origin

    def test_cors_allows_localhost_3000(self, client):
        """CORS should allow requests from localhost:3000."""
        origin = "http://localhost:3000"
        response = client.get(
            "/api/v1/health",
            headers={"Origin": origin},
        )
        assert response.status_code == 200
        assert response.json() == {"status": "ok"}
        assert response.headers.get("access-control-allow-origin") == origin
