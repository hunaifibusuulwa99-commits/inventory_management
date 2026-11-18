from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database import get_db
from app.deps import apply_updates, get_current_user, get_owned_or_404
from app.models import Supplier, User
from app.schemas import MessageOut, SupplierCreate, SupplierOut, SupplierUpdate

router = APIRouter(prefix="/suppliers", tags=["Suppliers"])


@router.get("", response_model=list[SupplierOut])
def list_suppliers(
    q: str | None = Query(default=None, description="Search by name"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    stmt = select(Supplier).where(Supplier.user_id == user.id)
    if q:
        stmt = stmt.where(Supplier.name.ilike(f"%{q}%"))
    stmt = stmt.order_by(Supplier.name).offset(skip).limit(limit)
    return db.scalars(stmt).all()


@router.post("", response_model=SupplierOut, status_code=201)
def create_supplier(
    payload: SupplierCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    supplier = Supplier(user_id=user.id, **payload.model_dump())
    db.add(supplier)
    db.commit()
    db.refresh(supplier)
    return supplier


@router.get("/{supplier_id}", response_model=SupplierOut)
def get_supplier(
    supplier_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)
):
    return get_owned_or_404(db, Supplier, supplier_id, user.id, "Supplier")


@router.put("/{supplier_id}", response_model=SupplierOut)
def update_supplier(
    supplier_id: int,
    payload: SupplierUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Partial update: send only the fields you want to change."""
    supplier = get_owned_or_404(db, Supplier, supplier_id, user.id, "Supplier")
    apply_updates(supplier, payload.model_dump(exclude_unset=True), non_nullable={"name"})
    db.commit()
    db.refresh(supplier)
    return supplier


@router.delete("/{supplier_id}", response_model=MessageOut)
def delete_supplier(
    supplier_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)
):
    """Products from this supplier are kept; their supplier becomes empty."""
    supplier = get_owned_or_404(db, Supplier, supplier_id, user.id, "Supplier")
    db.delete(supplier)
    db.commit()
    return MessageOut(detail="Supplier deleted")
