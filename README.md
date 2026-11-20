#

Inventory management application for small and medium enterprises

# Stockwise: Inventory Management for SMEs

Mobile App Development Capstone: Flutter app + FastAPI backend.

**Group members:** _add the three names here_
BUSUULWA HUNAIFI 241-22302-7511 BACKEND LEAD 
NAMUSUBO ATIKA  FLUTTER LEAD
NSUBUGA FARID  ANALYST AND INTERGRATION LEAD 
**Project idea:** Inventory management for small and medium enterprises. Track products,
categories, suppliers and stock levels, record stock in and out, and get low-stock alerts.

## Repository structure
| Folder | Contents |
|--------|----------|
| `backend/` | FastAPI REST API, SQLite database, JWT login, tests. Run steps in [`backend/README.md`](backend/README.md) |
| `app/` | Flutter app. Setup and run steps in [`app/README.md`](app/README.md) |
| `docs/` | [Design document](docs/DESIGN_DOCUMENT.md) · [ERD and data dictionary](docs/ERD.md) · [API endpoints](docs/API_ENDPOINTS.md) · [Screens](docs/SCREENS.md) |

## Run everything (summary)

**1. Backend** (Terminal 1, in `backend/`)
```bash
python -m venv venv
venv\Scripts\Activate.ps1          # macOS/Linux: source venv/bin/activate
pip install -r requirements.txt
python seed.py                     # optional demo data: demo@example.com / Demo12345
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
API docs: http://127.0.0.1:8000/docs

**2. Flutter app** (Terminal 2, in `app/`) - first time only: `flutter create --platforms=android,ios --project-name stockwise .`
then add the INTERNET permission and cleartext flag described in `app/README.md`.
```bash
flutter pub get
flutter run
```
The app uses `http://10.0.2.2:8000` on the Android emulator. On a real phone, set the laptop's
address with the gear icon on the login screen.

## Capstone checklist
| Requirement | Status |
|-------------|--------|
| REST API returning JSON | Done (`backend/`) |
| Relational database matching the ERD, 4+ tables, one-to-many | Done: 5 tables |
| Full CRUD on 2+ tables | Done: products, categories, suppliers |
| Validation and status codes 200/201/400/401/404 | Done |
| Swagger/OpenAPI documentation | Done: `/docs` |
| Register, login, bcrypt, token, 401, per-user data | Done |
| Flutter: 4+ screens, navigation | Done: 10 screens + forms |
| Data from the backend, no hard-coded lists | Done |
| Loading and error states, server off | Done |
| Form validation | Done |
| models / services / screens / widgets | Done |
| Logout clears the token | Done |
| Design document, ERD, data dictionary, endpoint table | `docs/` (add diagrams and sketches, export to PDF) |

GROUP MEMBERS
BUSUULWA HUNAIFI, 241-22302-7511 BACK END LEAD
NAMUSUBO ATIKA,  FLUTTER LEAD
NSUBUGA FARID,  ANALYST AND INTERGRATION

