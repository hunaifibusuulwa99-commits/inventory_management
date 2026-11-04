"""Fill the database with demo data for the class demo.

Run from the backend/ folder:   python seed.py
Demo login:  demo@example.com / Demo12345
"""
from sqlalchemy import select

from app.database import Base, SessionLocal, engine
from app.models import Category, Product, StockMovement, Supplier, User
from app.security import hash_password

EMAIL = "demo@example.com"


def main():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        if db.scalar(select(User).where(User.email == EMAIL)):
            print("Demo data already exists. Delete inventory.db to start fresh.")
            return

        user = User(
            full_name="Demo Owner",
            email=EMAIL,
            password_hash=hash_password("Demo12345"),
            business_name="Kampala Corner Shop",
        )
        db.add(user)
        db.flush()

        cats = {n: Category(user_id=user.id, name=n) for n in ("Drinks", "Groceries", "Stationery")}
        sups = {
            "Crystal Distributors": Supplier(
                user_id=user.id, name="Crystal Distributors", phone="+256700000001",
                email="sales@crystal.example.com", address="Industrial Area, Kampala"),
            "Mukwano Wholesale": Supplier(
                user_id=user.id, name="Mukwano Wholesale", phone="+256700000002"),
        }
        db.add_all([*cats.values(), *sups.values()])
        db.flush()

        # name, sku, category, supplier, cost (UGX), selling (UGX), quantity, reorder level
        rows = [
            ("Mineral Water 500ml", "DRK-001", "Drinks", "Crystal Distributors", 800, 1000, 120, 24),
            ("Soda 300ml", "DRK-002", "Drinks", "Crystal Distributors", 1000, 1500, 8, 20),
            ("Sugar 1kg", "GRC-001", "Groceries", "Mukwano Wholesale", 4200, 5000, 40, 10),
            ("Cooking Oil 1L", "GRC-002", "Groceries", "Mukwano Wholesale", 7500, 9000, 0, 6),
            ("Exercise Book A4", "STA-001", "Stationery", None, 1500, 2500, 60, 15),
        ]
        for name, sku, cat, sup, cost, price, qty, reorder in rows:
            product = Product(
                user_id=user.id, name=name, sku=sku, category_id=cats[cat].id,
                supplier_id=sups[sup].id if sup else None,
                cost_price=cost, selling_price=price, quantity=qty, reorder_level=reorder)
            db.add(product)
            db.flush()
            if qty:
                db.add(StockMovement(
                    user_id=user.id, product_id=product.id, movement_type="in",
                    quantity=qty, quantity_after=qty, note="Opening stock"))
        db.commit()
        print(f"Demo data created. Login: {EMAIL} / Demo12345")
    finally:
        db.close()


if __name__ == "__main__":
    main()
