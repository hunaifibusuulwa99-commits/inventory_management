# Inventory Management App

Mobile App Development Capstone: Flutter app + FastAPI backend for small and medium enterprises.

**Group members:** _add the three names here_
**Project idea:** Inventory management for small and medium enterprises: track products,
categories, suppliers and stock levels, and get low-stock alerts.

## Repository structure
| Folder | Contents |
|--------|----------|
| `backend/` | FastAPI REST API. Run instructions in [`backend/README.md`](backend/README.md) |
| `app/` | Flutter project (to be added by the Flutter lead) |
| `docs/` | Design document, ERD ([`ERD.md`](docs/ERD.md)), API documentation ([`API_ENDPOINTS.md`](docs/API_ENDPOINTS.md)) |

## Quick start
```bash
cd backend
python -m venv venv && source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt
python seed.py
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
API docs: http://127.0.0.1:8000/docs

## Screenshots
_Add app screenshots here._
