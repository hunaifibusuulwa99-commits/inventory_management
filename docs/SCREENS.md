# Screens (Flutter app "Stockwise")

Design language: clean white cards on a soft grey-green background, one brand green
(`#167A55`) for actions and positive states, amber for low stock, red for out of stock and
errors. Text colour is a near-black green (`#17251F`) with muted grey (`#748078`) for hints.
All colours are defined once in `app/lib/theme.dart`.

## Screen list

| # | Screen | File | Purpose | Endpoints |
|---|--------|------|---------|-----------|
| 1 | Splash | `screens/splash_screen.dart` | Checks the saved login at start; shows Retry if the server is off | `GET /auth/me` |
| 2 | Login | `screens/login_screen.dart` | Sign in; gear icon sets the server address | `POST /auth/login` |
| 3 | Register | `screens/register_screen.dart` | Create account, then signs in | `POST /auth/register`, `POST /auth/login` |
| 4 | Home (dashboard) | `screens/home_screen.dart` | Inventory value, product / low / out-of-stock numbers, quick actions, low-stock alerts, recent activity | `GET /dashboard/summary`, `GET /products/low-stock` |
| 5 | Products | `screens/products_screen.dart` | Search, filter (All, Low stock, Out of stock, by category), list, open details | `GET /products`, `GET /categories` |
| 6 | Activity | `screens/activity_screen.dart` | Stock history with filters (All, In, Out, Adjustments) | `GET /stock-movements` |
| 7 | More | `screens/more_screen.dart` | Menu: Categories, Suppliers, Profile, Settings, Sign out | – |
| 8 | Categories | `screens/categories_screen.dart` | List, add, edit, delete categories | `GET/POST/PUT/DELETE /categories` |
| 9 | Suppliers | `screens/suppliers_screen.dart` | List, add, edit, delete suppliers | `GET/POST/PUT/DELETE /suppliers` |
| 10 | Profile | `screens/profile_screen.dart` | Account details and Sign out | session (from `/auth/me`) |

## Bottom-sheet forms (open on top of the screens above)

| Sheet | File | Purpose | Endpoints |
|-------|------|---------|-----------|
| Add / Edit product | `screens/sheets/product_form_sheet.dart` | Create or change a product | `POST /products`, `PUT /products/{id}` |
| Product details | `screens/sheets/product_details_sheet.dart` | Full product info; Edit, Adjust stock, Delete | `DELETE /products/{id}` |
| Update stock | `screens/sheets/movement_sheet.dart` | Stock in, Stock out or Adjust, with live "after saving" preview | `POST /stock-movements` |
| Add / Edit category | `screens/sheets/category_sheet.dart` | Create, change, delete | `POST/PUT/DELETE /categories` |
| Add / Edit supplier | `screens/sheets/supplier_sheet.dart` | Create, change, delete | `POST/PUT/DELETE /suppliers` |
| Server address | `widgets/server_settings_sheet.dart` | Point the app at the laptop; Test connection | `GET /health` |

## Navigation

```
Splash ─┬─ no/expired token ──► Login ◄──► Register
        └─ valid token ───────► Main app (bottom tabs)
                                  ├─ Home ──► (View stock) Products · (View all) Products [Low stock] · (See all) Activity
                                  ├─ Products ──► Product details ──► Edit · Adjust stock · Delete
                                  ├─ Activity ──► Update stock
                                  └─ More ──► Categories · Suppliers · Profile · Settings · Sign out
Top bar: notifications (low-stock count) and profile.
```

## Behaviour rules (capstone requirements)

- **Loading:** spinner while data loads; buttons show a spinner and are disabled while saving.
- **Server off / error:** "Can't reach the server" with the current address, **Try again** and **Change server address**. Other errors show the server's message.
- **Empty states:** friendly message with an action button.
- **Form validation:** limits match the API (name 1–150, SKU 1–50, prices 0 or more, password 8–72, valid email, and so on). Server-side errors such as "duplicate SKU" appear inside the form.
- **Stock rules:** stock out cannot exceed current stock; the product's quantity changes only through stock movements, so the history always adds up.
- **Auth:** token saved on the phone after login and sent with every request; a 401 clears it and returns to Login; Sign out deletes it.
- **Pull down to refresh** on every list.

## Differences from the HTML prototype (and why)

| Prototype | App | Reason |
|-----------|-----|--------|
| Product has an icon | Emoji chosen from the category name | The API has no image or icon field |
| One price | Unit (selling) price plus optional cost price | The API tracks both so profit can be reported later |
| Quantity editable when editing a product | Quantity is read-only in edit; use **Adjust stock** | Keeps stock history correct |
| Stock in / Stock out | Adds a third option, **Adjust**, for stock counts | Supported by the API |
| Categories / suppliers can only be added or edited | Delete added (with confirmation) | Capstone asks for full create, read, update and delete |
| Suppliers: name only | Name, phone, email, address | Fields exist in the database |
| "Account type: Administrator" | "Business owner" | The API has no roles |
| Settings toast | Settings opens the server address form | Needed to connect a real phone |
