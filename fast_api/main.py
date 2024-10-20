from fastapi import FastAPI
from pydantic import BaseModel
import httpx  

app = FastAPI()

class ProductRequest(BaseModel):
    product: str

# This route in FastAPI will forward the request to Flask's /getexpiration route
@app.post("/checkexpiration")
async def check_expiration(product_request: ProductRequest):
    # The product sent from the client (Flutter app)
    product = product_request.product

    # Flask URL where we'll forward the request
    flask_url = "http://127.0.0.1:5000/getexpiration"

    # Make an asynchronous POST request to the Flask API
    async with httpx.AsyncClient() as client:
        response = await client.post(flask_url, json={"product": product})

    # Return the Flask response to the FastAPI client
    return response.json()

@app.get("/")
async def root():
    return {"message": "FastAPI is forwarding requests to Flask!"}