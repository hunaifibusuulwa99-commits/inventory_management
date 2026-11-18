from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.database import get_db
from app.deps import get_current_user, get_owned_or_404
from app.models import Product, StockMovement, User, utcnow
from app.schemas import MovementCreate, MovementOut

router = APIRouter(prefix="/stock-movements", tags=["Stock movements"])


@router.get("", response_model=list[MovementOut])
def list_movements(
    product_id: int | None = None,
    movement_type: Literal["in", "out", "adjust"] | None = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Stock history, newest first."""
    stmt = (
        select(StockMovement)
        .where(StockMovement.user_id == user.id)
        .options(joinedload(StockMovement.product))
    )
    if product_id is not None:
        stmt = stmt.where(StockMovement.product_id == product_id)
    if movement_type is not None:
        stmt = stmt.where(StockMovement.movement_type == movement_type)
    stmt = stmt.order_by(StockMovement.created_at.desc(), StockMovement.id.desc())
    return db.scalars(stmt.offset(skip).limit(limit)).all()


@router.post("", response_model=MovementOut, status_code=201)
def create_movement(
    payload: MovementCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Receive stock ('in'), sell/use stock ('out'), or correct a stock count ('adjust').

    The product's quantity is updated in the same step.
    """
    product = db.scalar(
        select(Product).where(Product.id == payload.product_id, Product.user_id == user.id)
    )
    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")

    if payload.movement_type == "in":
        new_quantity = product.quantity + payload.quantity
    elif payload.movement_type == "out":
        if payload.quantity > product.quantity:
            raise HTTPException(
                status_code=400,
                detail=f"Not enough stock: only {product.quantity} in stock",
            )
        new_quantity = product.quantity - payload.quantity
    else:  # adjust: the quantity is the counted stock level
        new_quantity = payload.quantity

    product.quantity = new_quantity
    product.updated_at = utcnow()
    movement = StockMovement(
        user_id=user.id,
        product_id=product.id,
        movement_type=payload.movement_type,
        quantity=payload.quantity,
        quantity_after=new_quantity,
        note=payload.note,
    )
    db.add(movement)
    db.commit()
    db.refresh(movement)
    return movement


@router.get("/{movement_id}", response_model=MovementOut)
def get_movement(
    movement_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)
):
    return get_owned_or_404(db, StockMovement, movement_id, user.id, "Stock movement")
