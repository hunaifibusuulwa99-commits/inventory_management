from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app import models  # noqa: F401  (registers the tables)
from app.database import Base, engine
from app.routers import auth, categories, dashboard, products, stock, suppliers


@asynccontextmanager
async def lifespan(_app: FastAPI):
    Base.metadata.create_all(bind=engine)  # creates the tables on first run
    yield


app = FastAPI(
    title="Inventory Management API",
    description=(
        "REST API for small and medium enterprises to manage products, categories, "
        "suppliers and stock. Every record belongs to the logged-in user.\n\n"
        "**How to try it:** register with `POST /auth/register`, then click **Authorize** "
        "and log in (username = your email)."
    ),
    version="1.0.0",
    lifespan=lifespan,
)

# Lets the Flutter app (or Flutter web) call the API during development.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(RequestValidationError)
async def validation_error_handler(_request: Request, exc: RequestValidationError):
    """Return 400 (not FastAPI's default 422) with a readable list of problems."""
    errors = []
    for err in exc.errors():
        location = [str(part) for part in err["loc"] if part not in ("body", "query", "path")]
        errors.append({"field": ".".join(location) or "request", "message": err["msg"]})
    summary = "; ".join(f"{e['field']}: {e['message']}" for e in errors)
    return JSONResponse(
        status_code=400,
        content={"detail": f"Validation failed. {summary}", "errors": errors},
    )


app.include_router(auth.router)
app.include_router(categories.router)
app.include_router(suppliers.router)
app.include_router(products.router)
app.include_router(stock.router)
app.include_router(dashboard.router)


@app.get("/", tags=["Health"])
def root():
    return {"name": "Inventory Management API", "docs": "/docs", "status": "ok"}


@app.get("/health", tags=["Health"])
def health():
    return {"status": "ok"}
