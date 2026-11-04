# Inventory Management API (backend)

FastAPI + SQLAlchemy + SQLite (or PostgreSQL/MySQL). Built for small and medium
enterprises to manage products, categories, suppliers and stock.

**Features:** register/login with bcrypt-hashed passwords and JWT tokens · each user sees only
their own data · full CRUD on products, categories and suppliers · stock in/out/adjust with
history · low-stock list · search and filters · dashboard summary · automatic API docs.

## Run it (exact steps)

Requires Python 3.10 or newer. Open a terminal in the `backend/` folder.

**Windows (PowerShell)**
```powershell
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
python seed.py                                   # optional: demo data
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**macOS / Linux**
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python seed.py                                   # optional: demo data
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Then open:
- http://127.0.0.1:8000/docs – interactive API docs (Swagger). Click **Authorize** to log in.
- http://127.0.0.1:8000/health – should show `{"status":"ok"}`

Demo login after `python seed.py`: **demo@example.com / Demo12345**

The tables are created automatically on first start (`inventory.db` appears in this folder).
To reset everything, stop the server and delete `inventory.db`.

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
