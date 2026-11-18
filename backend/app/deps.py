from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User
from app.security import decode_access_token

# tokenUrl lets the "Authorize" button in /docs (Swagger) log in with a form.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")


def get_current_user(
    token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)
) -> User:
    """Protects an endpoint: missing or invalid token -> 401."""
    user_id = decode_access_token(token)
    user = db.get(User, user_id) if user_id is not None else None
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


def get_owned_or_404(db: Session, model, obj_id: int, user_id: int, label: str):
    """Fetch a record that belongs to this user. Other users' records look like 404."""
    obj = db.scalar(select(model).where(model.id == obj_id, model.user_id == user_id))
    if obj is None:
        raise HTTPException(status_code=404, detail=f"{label} not found")
    return obj


def apply_updates(obj, data: dict, non_nullable: set[str]) -> None:
    """Copy fields from a partial update onto a record.

    Fields in `non_nullable` ignore an explicit null; other fields can be cleared with null.
    """
    for key, value in data.items():
        if value is None and key in non_nullable:
            continue
        setattr(obj, key, value)
