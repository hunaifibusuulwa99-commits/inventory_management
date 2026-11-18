# Inventory Management API (backend)

FastAPI + SQLAlchemy + SQLite (or PostgreSQL/MySQL). Built for small and medium
enterprises to manage products, categories, suppliers and stock.

**Features:** register/login with bcrypt-hashed passwords and JWT tokens · each user sees only
their own data · full CRUD on products, categories and suppliers · stock in/out/adjust with
history · low-stock list · search and filters · dashboard summary · automatic API docs.


## Connecting the Flutter app
See [`../docs/API_ENDPOINTS.md`](../docs/API_ENDPOINTS.md) (endpoints, request/response shapes,
base URL for emulator vs real phone, Dart examples).
`--host 0.0.0.0` lets a real phone on the same Wi-Fi reach the laptop at `http://<laptop-ip>:8000`.

## Run the tests
```bash
pytest
```

## Use PostgreSQL / MySQL instead of SQLite
Set `DATABASE_URL` in `.env` (see `.env.example`) and install the driver
(`pip install psycopg2-binary` for PostgreSQL). No code changes needed.

## Project layout
```
backend/
  app/
    main.py          app setup, CORS, error format
    config.py        settings from .env
    database.py      engine and session
    models.py        database tables (match docs/ERD.md)
    schemas.py       request/response shapes and validation
    security.py      bcrypt hashing and JWT
    deps.py          get_current_user (401 if token is bad) and helpers
    routers/         auth, categories, suppliers, products, stock, dashboard
  tests/             automated tests
  seed.py            demo data
```

## Before deploying anywhere public
Set a long random `SECRET_KEY` in `.env` and restrict `allow_origins` in `app/main.py`.
