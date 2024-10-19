from fastapi import FastAPI, status
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from fastapi.openapi.docs import get_swagger_ui_html
from pydantic import BaseModel

# Create FastAPI app instance
app = FastAPI(debug=True, docs_url=None, redoc_url=None)

# Mount the static files directory
app.mount("/static", StaticFiles(directory="static", html=True))

# Custom Swagger documentation endpoint
@app.get("/docs", include_in_schema=False)
async def custom_swagger_ui_html():
    return get_swagger_ui_html(
        openapi_url=app.openapi_url,
        title=app.title + " - Swagger UI",
        oauth2_redirect_url=app.swagger_ui_oauth2_redirect_url,
        swagger_js_url="static/swagger-ui-bundle.js",
        swagger_css_url="static/swagger-ui.css",
    )

# Simple post request
@app.post("/start")
def start_app(s: str):
    return JSONResponse(status_code=status.HTTP_400_BAD_REQUEST, content={"data": "test"})