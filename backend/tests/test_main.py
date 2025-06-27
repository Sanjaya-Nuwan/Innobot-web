import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import uuid
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "FastAPI is working!"}


def test_read_users():
    response = client.get("/users/?skip=0&limit=5")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_update_user():
    unique_email = f"temp_{uuid.uuid4()}@example.com"
    # Create user
    user_resp = client.post("/users/", data={
        "name": "Temp User",
        "email": unique_email,
        "phone": "0712345678",
        "address": "Somewhere",
        "age": 30
    })
    user = user_resp.json()
    user_id = user["id"]

    # Update same user with a different unique email
    update_email = f"updated_{uuid.uuid4()}@example.com"
    response = client.put(f"/users/{user_id}", data={
        "name": "Updated User",
        "email": update_email,
        "phone": "0777777777",
        "address": "New Address",
        "age": 35
    })

    assert response.status_code == 200
    updated_user = response.json()
    assert updated_user["email"] == update_email


def test_delete_user():
    # Create a user to delete
    user_resp = client.post("/users/", data={
        "name": "Delete User",
        "email": "delete@example.com"
    })
    user_id = user_resp.json()["id"]

    delete_resp = client.delete(f"/users/{user_id}")
    assert delete_resp.status_code == 200
    assert delete_resp.json() == {"message": "User deleted"}
