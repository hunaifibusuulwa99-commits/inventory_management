# Inventory Management System: Design Document

**Course:** Mobile App Development Capstone
**Group members:** _Name 1 · Name 2 · Name 3_
**Project:** Stockwise, an inventory management app for small and medium enterprises (SMEs)

> To make the PDF for submission: open this file in VS Code, install the extension
> "Markdown PDF", right-click > **Markdown PDF: Export (pdf)**. Add the ERD image and screen
> sketches where marked, then save the PDF in the `docs/` folder.

---

## 1. Problem statement

Small shops, kiosks and wholesalers in Uganda often track their stock in exercise books or in
their heads. Owners do not know exactly what they have, notice too late that a product has run
out, lose money to unrecorded sales or damaged goods, and cannot tell how much their stock is
worth. Existing inventory software is built for large companies: it is expensive, complicated
and often needs a computer.

**Stockwise** is a mobile app that lets a business owner record products, suppliers and every
stock movement from a phone. It shows what is in stock, warns when items run low, keeps a
history of every change, and calculates the value of the stock in UGX. A server with a
database keeps the data safe and separate for each business.

## 2. Users and their goals

| User | Description | Goals |
|------|-------------|-------|
| Business owner | Owns a shop or small enterprise, uses the app daily | See stock levels and value at a glance; get warned before products run out; know what was sold and received; manage products and suppliers |
| Shop attendant (uses the owner's account) | Serves customers and receives deliveries | Quickly record stock in and out; look up a product and its price |

## 3. Requirements

### Functional requirements
1. The system shall allow a new user to register with name, email and password.
2. The system shall allow a registered user to log in and shall return an access token.
3. The system shall store passwords only as bcrypt hashes.
4. The system shall reject requests to protected endpoints that have a missing or invalid token with status 401.
5. The system shall let each user see and change only their own records.
6. The system shall allow a user to create, view, edit and delete products with name, SKU, prices and reorder level.
7. The system shall require each product's SKU to be unique for that user.
8. The system shall allow a user to create, view, edit and delete categories and assign a product to a category.
9. The system shall allow a user to create, view, edit and delete suppliers and assign a product to a supplier.
10. The system shall allow a user to record stock coming in, stock going out, and a corrected stock count for a product.
11. The system shall prevent stock going out from exceeding the quantity in stock.
12. The system shall keep a history of every stock movement with type, quantity, resulting stock, note and time.
13. The system shall list products at or below their reorder level as low-stock alerts.
14. The system shall let a user search products by name or SKU and filter by category, supplier and stock status.
15. The system shall show a dashboard with total products, total units, stock value, low-stock count, out-of-stock count and recent activity.
16. The system shall validate all input and return status 400 with a readable message when it is invalid.
17. The system shall let the user log out, which deletes the token from the phone.

### Non-functional requirements
1. **Usability:** all main actions (add product, record stock) shall be possible in three taps or fewer from the home screen, and every form shall show clear validation messages.
2. **Reliability on weak connections:** the app shall show a loading state and, if the server cannot be reached, a clear message with a Retry button rather than a blank or crashing screen.
3. **Security:** passwords shall be hashed, tokens shall expire (24 hours by default), and a user shall never be able to read another user's data.
4. **Performance:** list and dashboard requests shall normally respond in under 2 seconds on a local network.
5. **Portability:** the backend shall run on a laptop with the steps in its README, using SQLite by default and PostgreSQL or MySQL by changing one setting.
6. **Maintainability:** code shall be organised into models, services, screens and widgets (app) and routers, schemas and models (backend), with automated tests for the API.

## 4. User stories

| # | As a... | I want to... | So that... |
|---|---------|--------------|------------|
| 1 | new business owner | register an account with my business name | my data is kept separate and safe |
| 2 | owner | log in and out securely | nobody else can see my stock |
| 3 | owner | add a product with its SKU, price and opening stock | I can start tracking it |
| 4 | owner | edit or delete a product | my catalogue stays correct |
| 5 | attendant | record stock coming in from a supplier | the quantity is updated and the delivery is on record |
| 6 | attendant | record stock going out after a sale | the quantity is reduced and I cannot sell more than I have |
| 7 | owner | correct the stock after counting the shelves | the system matches reality |
| 8 | owner | see which products are running low | I can reorder before I run out |
| 9 | owner | search and filter products | I can find an item quickly |
| 10 | owner | organise products into categories | my catalogue is easy to browse |
| 11 | owner | keep my suppliers' contact details | I know whom to call to restock |
| 12 | owner | see the total value of my stock and recent activity | I understand how my business is doing |

## 5. ERD

See [`ERD.md`](ERD.md) for the diagram (Mermaid), cardinalities and normalisation notes.
Export the diagram as an image (for example from https://mermaid.live) and place it here in the PDF.

Summary: 5 entities, `users`, `categories`, `suppliers`, `products`, `stock_movements`.
All relationships are one-to-many, implemented with foreign keys; there are no many-to-many
relationships, so no junction table is needed. Tables are in third normal form.

## 6. Data dictionary

See [`ERD.md`](ERD.md), section "Data dictionary": a table of field, type, size, constraints
and meaning for each of the five entities.

## 7. API endpoint table

See [`API_ENDPOINTS.md`](API_ENDPOINTS.md): method, path, purpose, request body and response
for all endpoints, plus status codes. A live version is at `/docs` (Swagger) when the server runs.

## 8. Screen sketches

The screens are described in [`SCREENS.md`](SCREENS.md). Add screenshots of the running app
here, or photos of your paper sketches, for these screens:

1. Login and Register
2. Home (dashboard)
3. Products list and Product details
4. Add / Edit product form
5. Update stock form
6. Activity (stock history)
7. Categories and Suppliers
8. Profile
