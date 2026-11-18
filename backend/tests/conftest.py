import os
import tempfile
import uuid

import pytest

# Use a throw-away database so tests never touch inventory.db.
_tmp = tempfile.mkdtemp()
os.environ["DATABASE_URL"] = f"sqlite:///{_tmp}/test.db"
os.environ["SECRET_KEY"] = "test-secret"

from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402


@pytest.fixture(scope="session")
def client():
    with TestClient(app) as c:
        yield c


def register_and_login(client) -> dict:
    """Create a fresh user and return auth headers."""
    email = f"user-{uuid.uuid4().hex[:8]}@example.com"
    r = client.post(
        "/auth/register",
        json={"full_name": "Test User", "email": email, "password": "Password123"},
    )
    assert r.status_code == 201, r.text
    r = client.post("/auth/login", json={"email": email, "password": "Password123"})
    assert r.status_code == 200, r.text
    return {"Authorization": f"Bearer {r.json()['access_token']}"}


@pytest.fixture()
def auth(client):
    return register_and_login(client)
