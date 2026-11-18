from tests.conftest import register_and_login


# ---------- Authentication ----------
def test_register_hides_password_and_rejects_duplicates(client):
    body = {"full_name": "Amina K", "email": "amina@example.com", "password": "Password123"}
    r = client.post("/auth/register", json=body)
    assert r.status_code == 201
    assert "password" not in r.text and "password_hash" not in r.text
    assert client.post("/auth/register", json=body).status_code == 400


def test_register_validation_returns_400(client):
    r = client.post("/auth/register", json={"full_name": "A", "email": "bad", "password": "123"})
    assert r.status_code == 400
    assert r.json()["errors"]


def test_login_wrong_password_is_401(client):
    client.post(
        "/auth/register",
        json={"full_name": "Joel M", "email": "joel@example.com", "password": "Password123"},
    )
    r = client.post("/auth/login", json={"email": "joel@example.com", "password": "wrongpass1"})
    assert r.status_code == 401


def test_protected_endpoints_need_a_valid_token(client):
    assert client.get("/products").status_code == 401
    bad = {"Authorization": "Bearer not-a-real-token"}
    assert client.get("/products", headers=bad).status_code == 401
    assert client.get("/dashboard/summary", headers=bad).status_code == 401


def test_swagger_form_login(client):
    client.post(
        "/auth/register",
        json={"full_name": "Form User", "email": "form@example.com", "password": "Password123"},
    )
    r = client.post("/auth/token", data={"username": "form@example.com", "password": "Password123"})
    assert r.status_code == 200 and r.json()["access_token"]


# ---------- Categories (full CRUD) ----------
def test_category_crud(client, auth):
    r = client.post("/categories", json={"name": "Drinks"}, headers=auth)
    assert r.status_code == 201
    cid = r.json()["id"]

    assert client.post("/categories", json={"name": "drinks"}, headers=auth).status_code == 400
    assert client.get(f"/categories/{cid}", headers=auth).json()["name"] == "Drinks"

    r = client.put(f"/categories/{cid}", json={"description": "Cold drinks"}, headers=auth)
    assert r.status_code == 200 and r.json()["description"] == "Cold drinks"

    assert client.delete(f"/categories/{cid}", headers=auth).status_code == 200
    assert client.get(f"/categories/{cid}", headers=auth).status_code == 404


# ---------- Products (full CRUD, one-to-many, ownership) ----------
def make_product(client, auth, **overrides):
    body = {"name": "Sugar 1kg", "sku": "GRC-001", "cost_price": 4200,
            "selling_price": 5000, "quantity": 10, "reorder_level": 5}
    body.update(overrides)
    return client.post("/products", json=body, headers=auth)


def test_product_crud_and_validation(client, auth):
    r = make_product(client, auth)
    assert r.status_code == 201
    product = r.json()
    assert product["quantity"] == 10 and product["is_low_stock"] is False

    assert make_product(client, auth).status_code == 400  # duplicate SKU
    assert make_product(client, auth, sku="X-2", selling_price=-5).status_code == 400
    assert make_product(client, auth, sku="X-3", category_id=99999).status_code == 400

    r = client.put(f"/products/{product['id']}", json={"selling_price": 5500}, headers=auth)
    assert r.status_code == 200 and r.json()["selling_price"] == 5500

    assert client.delete(f"/products/{product['id']}", headers=auth).status_code == 200
    assert client.get(f"/products/{product['id']}", headers=auth).status_code == 404


def test_product_belongs_to_category_and_supplier(client, auth):
    cat = client.post("/categories", json={"name": "Groceries"}, headers=auth).json()
    sup = client.post("/suppliers", json={"name": "Mukwano"}, headers=auth).json()
    r = make_product(client, auth, category_id=cat["id"], supplier_id=sup["id"])
    assert r.status_code == 201
    assert r.json()["category_name"] == "Groceries" and r.json()["supplier_name"] == "Mukwano"
    assert client.get(f"/categories/{cat['id']}", headers=auth).json()["product_count"] == 1

    # Deleting the category keeps the product
    client.delete(f"/categories/{cat['id']}", headers=auth)
    kept = client.get(f"/products/{r.json()['id']}", headers=auth).json()
    assert kept["category_id"] is None


def test_users_only_see_their_own_records(client):
    alice, bob = register_and_login(client), register_and_login(client)
    pid = make_product(client, alice).json()["id"]
    assert client.get("/products", headers=bob).json() == []
    assert client.get(f"/products/{pid}", headers=bob).status_code == 404
    assert client.delete(f"/products/{pid}", headers=bob).status_code == 404
    assert client.get(f"/products/{pid}", headers=alice).status_code == 200


def test_search_and_low_stock_filter(client, auth):
    make_product(client, auth, name="Soda", sku="S-1", quantity=2, reorder_level=10)
    make_product(client, auth, name="Water", sku="W-1", quantity=50, reorder_level=10)
    assert [p["name"] for p in client.get("/products?q=soda", headers=auth).json()] == ["Soda"]
    low = client.get("/products/low-stock", headers=auth).json()
    assert [p["name"] for p in low] == ["Soda"]


# ---------- Stock movements ----------
def test_stock_in_out_adjust(client, auth):
    pid = make_product(client, auth, quantity=10).json()["id"]

    r = client.post("/stock-movements", json={"product_id": pid, "movement_type": "in", "quantity": 5}, headers=auth)
    assert r.status_code == 201 and r.json()["quantity_after"] == 15

    r = client.post("/stock-movements", json={"product_id": pid, "movement_type": "out", "quantity": 4, "note": "Sale"}, headers=auth)
    assert r.json()["quantity_after"] == 11

    r = client.post("/stock-movements", json={"product_id": pid, "movement_type": "out", "quantity": 500}, headers=auth)
    assert r.status_code == 400  # cannot sell more than we have

    r = client.post("/stock-movements", json={"product_id": pid, "movement_type": "adjust", "quantity": 7}, headers=auth)
    assert r.json()["quantity_after"] == 7
    assert client.get(f"/products/{pid}", headers=auth).json()["quantity"] == 7

    history = client.get(f"/stock-movements?product_id={pid}", headers=auth).json()
    assert len(history) == 4  # opening stock + in + out + adjust

    bad = client.post("/stock-movements", json={"product_id": pid, "movement_type": "in", "quantity": 0}, headers=auth)
    assert bad.status_code == 400
    missing = client.post("/stock-movements", json={"product_id": 99999, "movement_type": "in", "quantity": 1}, headers=auth)
    assert missing.status_code == 404


def test_dashboard_summary(client, auth):
    make_product(client, auth, sku="D-1", quantity=10, cost_price=100, selling_price=150, reorder_level=3)
    make_product(client, auth, sku="D-2", quantity=0, cost_price=50, selling_price=80, reorder_level=3)
    s = client.get("/dashboard/summary", headers=auth).json()
    assert s["total_products"] == 2 and s["total_units"] == 10
    assert s["stock_value_at_cost"] == 1000 and s["stock_value_at_selling_price"] == 1500
    assert s["low_stock_count"] == 1 and s["out_of_stock_count"] == 1
    assert len(s["recent_movements"]) == 1
