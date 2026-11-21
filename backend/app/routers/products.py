from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import or_, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, joinedload

from app.database import get_db
from app.deps import apply_updates, get_current_user, get_owned_or_404
from app.models import Category, Product, StockMovement, Supplier, User, utcnow
from app.schemas import MessageOut, ProductCreate, ProductOut, ProductUpdate

router = APIRouter(prefix="/products", tags=["Products"])

_with_links = (joinedload(Product.category), joinedload(Product.supplier))


def _check_links(db: Session, user_id: int, category_id: int | None, supplier_id: int | None):
    """category_id and supplier_id must point to this user's own records."""
    if category_id is not None and not db.scalar(
        select(Category.id).where(Category.id == category_id, Category.user_id == user_id)
    ):
        raise HTTPException(status_code=400, detail="Category does not exist")
    if supplier_id is not None and not db.scalar(
        select(Supplier.id).where(Supplier.id == supplier_id, Supplier.user_id == user_id)
    ):
        raise HTTPException(status_code=400, detail="Supplier does not exist")


def _ensure_sku_free(db: Session, user_id: int, sku: str, exclude_id: int | None = None):
    existing = db.scalar(select(Product).where(Product.user_id == user_id, Product.sku == sku))
    if existing is not None and existing.id != exclude_id:
        raise HTTPException(status_code=400, detail="You already have a product with this SKU")


@router.get("", response_model=list[ProductOut])
def list_products(
    q: str | None = Query(default=None, description="Search name or SKU"),
    category_id: int | None = None,
    supplier_id: int | None = None,
    low_stock: bool | None = Query(default=None, description="true = only low/out of stock"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    stmt = select(Product).where(Product.user_id == user.id).options(*_with_links)
    if q:
        like = f"%{q}%"
        stmt = stmt.where(or_(Product.name.ilike(like), Product.sku.ilike(like)))
    if category_id is not None:
        stmt = stmt.where(Product.category_id == category_id)
    if supplier_id is not None:
        stmt = stmt.where(Product.supplier_id == supplier_id)
    if low_stock is True:
        stmt = stmt.where(Product.quantity <= Product.reorder_level)
    elif low_stock is False:
        stmt = stmt.where(Product.quantity > Product.reorder_level)
    stmt = stmt.order_by(Product.name).offset(skip).limit(limit)
    return db.scalars(stmt).all()


@router.get("/low-stock", response_model=list[ProductOut])
def low_stock_products(
    db: Session = Depends(get_db), user: User = Depends(get_current_user)
):
    """Products at or below their reorder level, lowest stock first."""
    stmt = (
        select(Product)
        .where(Product.user_id == user.id, Product.quantity <= Product.reorder_level)
        .options(*_with_links)
        .order_by(Product.quantity, Product.name)
    )
    return db.scalars(stmt).all()


@router.post("", response_model=ProductOut, status_code=201)
def create_product(
    payload: ProductCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    _check_links(db, user.id, payload.category_id, payload.supplier_id)
    _ensure_sku_free(db, user.id, payload.sku)

    product = Product(user_id=user.id, **payload.model_dump())
    db.add(product)
    db.flush()  # gives the product an id
    if payload.quantity > 0:
        db.add(
            StockMovement(
                user_id=user.id,
                product_id=product.id,
                movement_type="in",
                quantity=payload.quantity,
                quantity_after=payload.quantity,
                note="Opening stock",
            )
        )
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="You already have a product with this SKU")
    db.refresh(product)
    return product


@router.get("/{product_id}", response_model=ProductOut)
def get_product(
    product_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)
):
    return get_owned_or_404(db, Product, product_id, user.id, "Product")


@router.put("/{product_id}", response_model=ProductOut)
def update_product(
    product_id: int,
    payload: ProductUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Partial update: send only the fields you want to change.

    Stock quantity cannot be changed here; record a stock movement instead.
    """
    product = get_owned_or_404(db, Product, product_id, user.id, "Product")
    data = payload.model_dump(exclude_unset=True)

    _check_links(db, user.id, data.get("category_id"), data.get("supplier_id"))
    if data.get("sku"):
        _ensure_sku_free(db, user.id, data["sku"], exclude_id=product.id)

    apply_updates(
        product,
        data,
        non_nullable={"name", "sku", "cost_price", "selling_price", "reorder_level"},
    )
    product.updated_at = utcnow()
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="You already have a product with this SKU")
    db.refresh(product)
    return product


@router.delete("/{product_id}", response_model=MessageOut)
def delete_product(
    product_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)
):
    """Also deletes the product's stock history."""
    product = get_owned_or_404(db, Product, product_id, user.id, "Product")
    db.delete(product)
    db.commit()
    return MessageOut(detail="Product deleted")
