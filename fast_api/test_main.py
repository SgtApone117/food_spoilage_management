from fastapi.testclient import TestClient
import json
from main import app  # Import the FastAPI app from your main.py

client = TestClient(app)

def test_start_endpoint():
    # Load the test data from the JSON file
    with open("test_data.json", "r") as f:
        json_data = json.load(f)

    # Send a POST request to the /start endpoint with the loaded JSON data
    response = client.post("/start", json=json_data)

    # Check if the response status code is 200 OK
    assert response.status_code == 200

    # Check if the response body contains the expected value
    assert response.json() == {"foodtype": "test"}