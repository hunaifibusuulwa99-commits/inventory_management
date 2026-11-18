from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.database import get_db
from app.deps import apply_updates, get_current_user, get_owned_or_404
from app.models import Category, User
from app.schemas import CategoryCreate, CategoryOut, CategoryUpdate, MessageOut

router = APIRouter(prefix="/categories", tags=["Categories"])


def _ensure_name_free(db: Session, user_id: int, name: str, exclude_id: int | None = None):
    stmt = select(Category).where(
        Category.user_id == user_id, func.lower(Category.name) == name.lower()
    )
    existing = db.scalar(stmt)
    if existing is not None and existing.id != exclude_id:
        raise HTTPException(status_code=400, detail="You already have a category with this name")


@router.get("", response_model=list[CategoryOut])
def list_categories(
    q: str | None = Query(default=None, description="Search by name"),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=500),
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    stmt = select(Category).where(Category.user_id == user.id)
    if q:
        stmt = stmt.where(Category.name.ilike(f"%{q}%"))
    stmt = stmt.order_by(Category.name).offset(skip).limit(limit)
    return db.scalars(stmt).all()


@router.post("", response_model=CategoryOut, status_code=201)
def create_category(
    payload: CategoryCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    _ensure_name_free(db, user.id, payload.name)
    category = Category(user_id=user.id, **payload.model_dump())
    db.add(category)
    db.commit()
    db.refresh(category)
    return category


@router.get("/{category_id}", response_model=CategoryOut)
def get_category(
    category_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)
):
    return get_owned_or_404(db, Category, category_id, user.id, "Category")


@router.put("/{category_id}", response_model=CategoryOut)
def update_category(
    category_id: int,
    payload: CategoryUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """Partial update: send only the fields you want to change."""
    category = get_owned_or_404(db, Category, category_id, user.id, "Category")
    data = payload.model_dump(exclude_unset=True)
    if data.get("name"):
        _ensure_name_free(db, user.id, data["name"], exclude_id=category.id)
    apply_updates(category, data, non_nullable={"name"})
    db.commit()
    db.refresh(category)
    return category


@router.delete("/{category_id}", response_model=MessageOut)
def delete_category(
    category_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)
):
    """Products in this category are kept; their category becomes empty."""
    category = get_owned_or_404(db, Category, category_id, user.id, "Category")
    db.delete(category)
    db.commit()
    return MessageOut(detail="Category deleted")
