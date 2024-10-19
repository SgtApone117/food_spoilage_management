from fastapi import FastAPI, status
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from fastapi.openapi.docs import get_swagger_ui_html
from pydantic import BaseModel
from starlette.middleware.cors import CORSMiddleware
import uvicorn

# Create FastAPI app instance
app = FastAPI(debug=True, docs_url=None, redoc_url=None)
app.mount("/static", StaticFiles(directory="static", html=True))

#Apparently fixes some CORS issue
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods (GET, POST, etc.)
    allow_headers=["*"],  # Allows all headers
)

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
class StartModel(BaseModel):
    s: str

#request
@app.post("/start", status_code=status.HTTP_200_OK)
def start_app(start_data: StartModel):
    return JSONResponse(status_code=status.HTTP_200_OK, content={"data": start_data.s})