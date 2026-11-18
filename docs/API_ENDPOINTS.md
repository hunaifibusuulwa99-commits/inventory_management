# API Endpoint Table

Base URL (local): `http://127.0.0.1:8000` · Interactive docs (Swagger/OpenAPI): `/docs` · OpenAPI JSON: `/openapi.json`

All endpoints except `register`, `login`, `token` and `health` need the header
`Authorization: Bearer <access_token>`. A missing or invalid token returns **401**.
Every record belongs to the logged-in user; another user's record returns **404**.
Do **not** add a trailing slash (use `/products`, not `/products/`).

## Status codes

| Code | Meaning |
|------|---------|
| 200 | OK (read, update, delete) |
| 201 | Created |
| 400 | Validation failed, duplicate value, bad reference, or not enough stock |
| 401 | Missing/invalid token, or wrong email/password |
| 404 | Record not found (or belongs to someone else) |

Every error has a `detail` text the app can show. Validation errors (400) also contain
`errors: [{ "field": "...", "message": "..." }]`.

## Auth

| Method | Path | Purpose | Request body | Response |
|--------|------|---------|--------------|----------|
| POST | `/auth/register` | Create account | `{full_name, email, password (8–72 chars), business_name?}` | 201 `{id, full_name, email, business_name, created_at}` |
| POST | `/auth/login` | Log in (used by the app) | `{email, password}` | 200 `{access_token, token_type:"bearer", user}` |
| POST | `/auth/token` | Log in via form (Swagger "Authorize" button) | form: `username` (email), `password` | 200 same as login |
| GET | `/auth/me` | Current user / check token | – | 200 user |

Logout: the API is stateless, so the app logs out by deleting the saved token on the phone.

## Categories

| Method | Path | Purpose | Request body | Response |
|--------|------|---------|--------------|----------|
| GET | `/categories?q=&skip=&limit=` | List my categories | – | 200 `[category]` |
| POST | `/categories` | Create | `{name, description?}` | 201 category |
| GET | `/categories/{id}` | Read one | – | 200 category / 404 |
| PUT | `/categories/{id}` | Update (send only changed fields) | `{name?, description?}` | 200 category / 404 |
| DELETE | `/categories/{id}` | Delete (products are kept) | – | 200 `{detail}` / 404 |

Category: `{id, name, description, product_count, created_at}`

## Suppliers

| Method | Path | Purpose | Request body | Response |
|--------|------|---------|--------------|----------|
| GET | `/suppliers?q=&skip=&limit=` | List my suppliers | – | 200 `[supplier]` |
| POST | `/suppliers` | Create | `{name, phone?, email?, address?}` | 201 supplier |
| GET | `/suppliers/{id}` | Read one | – | 200 supplier / 404 |
| PUT | `/suppliers/{id}` | Update (send only changed fields) | `{name?, phone?, email?, address?}` | 200 supplier / 404 |
| DELETE | `/suppliers/{id}` | Delete (products are kept) | – | 200 `{detail}` / 404 |

Supplier: `{id, name, phone, email, address, product_count, created_at}`

## Products

| Method | Path | Purpose | Request body | Response |
|--------|------|---------|--------------|----------|
| GET | `/products?q=&category_id=&supplier_id=&low_stock=&skip=&limit=` | List / search / filter | – | 200 `[product]` |
| GET | `/products/low-stock` | Products at or below reorder level | – | 200 `[product]` |
| POST | `/products` | Create (opening `quantity` is logged as stock-in) | `{name, sku, description?, category_id?, supplier_id?, cost_price, selling_price, quantity, reorder_level}` | 201 product |
| GET | `/products/{id}` | Read one | – | 200 product / 404 |
| PUT | `/products/{id}` | Update (send only changed fields; **quantity is not editable here**) | `{name?, sku?, description?, category_id?, supplier_id?, cost_price?, selling_price?, reorder_level?}` | 200 product / 404 |
| DELETE | `/products/{id}` | Delete product and its stock history | – | 200 `{detail}` / 404 |

Product: `{id, name, sku, description, category_id, category_name, supplier_id, supplier_name, cost_price, selling_price, quantity, reorder_level, is_low_stock, created_at, updated_at}`
Prices are in UGX. SKU must be unique per user.

## Stock movements

| Method | Path | Purpose | Request body | Response |
|--------|------|---------|--------------|----------|
| GET | `/stock-movements?product_id=&movement_type=&skip=&limit=` | Stock history, newest first | – | 200 `[movement]` |
| POST | `/stock-movements` | Record stock change and update the product's quantity | `{product_id, movement_type: "in"｜"out"｜"adjust", quantity, note?}` | 201 movement / 400 not enough stock / 404 product |
| GET | `/stock-movements/{id}` | Read one | – | 200 movement / 404 |

- `in`: add `quantity` units (≥ 1). `out`: remove `quantity` units (≥ 1, cannot exceed current stock).
- `adjust`: set stock to the counted `quantity` (≥ 0).

Movement: `{id, product_id, product_name, movement_type, quantity, quantity_after, note, created_at}`

## Dashboard

| Method | Path | Purpose | Response |
|--------|------|---------|----------|
| GET | `/dashboard/summary` | Numbers for the home screen | 200 `{total_products, total_categories, total_suppliers, total_units, stock_value_at_cost, stock_value_at_selling_price, low_stock_count, out_of_stock_count, recent_movements[]}` |

## Health

| Method | Path | Purpose | Response |
|--------|------|---------|----------|
| GET | `/health` | Is the server on? | 200 `{status:"ok"}` |

---

## Notes for the Flutter developer

**Base URL per device**

| Where the app runs | Base URL |
|--------------------|----------|
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator | `http://127.0.0.1:8000` |
| Real phone (same Wi-Fi as laptop) | `http://<laptop-ip>:8000` (server started with `--host 0.0.0.0`) |

Android blocks plain `http` in release builds. For development add
`android:usesCleartextTraffic="true"` to `<application>` in `android/app/src/main/AndroidManifest.xml`.

**Login and authenticated calls (Dart, `http` package)**

```dart
final res = await http.post(
  Uri.parse('$baseUrl/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': email, 'password': password}),
);
if (res.statusCode == 200) {
  final token = jsonDecode(res.body)['access_token'];   // save it (e.g. flutter_secure_storage)
}

// every later request
final products = await http.get(
  Uri.parse('$baseUrl/products'),
  headers: {'Authorization': 'Bearer $token'},
);
```

**Handling responses**
- `401` on any call → delete the saved token and go to the login screen.
- `400` → show `jsonDecode(res.body)['detail']` to the user.
- No connection / timeout → show the "server is off" state (required by the capstone).
- Parse `created_at` with `DateTime.parse(...)`; timestamps are UTC.
