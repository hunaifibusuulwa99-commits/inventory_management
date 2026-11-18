from fastapi import APIRouter, Depends
from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.database import get_db
from app.deps import get_current_user
from app.models import Category, Product, StockMovement, Supplier, User
from app.schemas import DashboardOut

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/summary", response_model=DashboardOut)
def summary(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Numbers for the app's home screen."""
    mine = Product.user_id == user.id

    def count(column, condition):
        return db.scalar(select(func.count(column)).where(condition)) or 0

    recent = db.scalars(
        select(StockMovement)
        .where(StockMovement.user_id == user.id)
        .options(joinedload(StockMovement.product))
        .order_by(StockMovement.created_at.desc(), StockMovement.id.desc())
        .limit(5)
    ).all()

    return DashboardOut(
        total_products=count(Product.id, mine),
        total_categories=count(Category.id, Category.user_id == user.id),
        total_suppliers=count(Supplier.id, Supplier.user_id == user.id),
        total_units=db.scalar(select(func.coalesce(func.sum(Product.quantity), 0)).where(mine)),
        stock_value_at_cost=float(
            db.scalar(
                select(func.coalesce(func.sum(Product.quantity * Product.cost_price), 0.0)).where(mine)
            )
        ),
        stock_value_at_selling_price=float(
            db.scalar(
                select(
                    func.coalesce(func.sum(Product.quantity * Product.selling_price), 0.0)
                ).where(mine)
            )
        ),
        low_stock_count=count(Product.id, mine & (Product.quantity <= Product.reorder_level)),
        out_of_stock_count=count(Product.id, mine & (Product.quantity == 0)),
        recent_movements=recent,
    )
