"""Request and response shapes (what the Flutter app sends and receives)."""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

EMAIL_PATTERN = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"


class StrictModel(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


# ---------- Auth / users ----------
class UserCreate(StrictModel):
    full_name: str = Field(min_length=2, max_length=100)
    email: str = Field(max_length=255, pattern=EMAIL_PATTERN)
    password: str = Field(min_length=8, max_length=72)
    business_name: str | None = Field(default=None, max_length=150)

    @field_validator("email")
    @classmethod
    def lowercase_email(cls, v: str) -> str:
        return v.lower()


class UserLogin(StrictModel):
    email: str = Field(max_length=255)
    password: str = Field(max_length=72)

    @field_validator("email")
    @classmethod
    def lowercase_email(cls, v: str) -> str:
        return v.lower()


class UserOut(ORMModel):
    id: int
    full_name: str
    email: str
    business_name: str | None
    created_at: datetime


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut | None = None


# ---------- Categories ----------
class CategoryCreate(StrictModel):
    name: str = Field(min_length=1, max_length=80)
    description: str | None = Field(default=None, max_length=255)


class CategoryUpdate(StrictModel):
    name: str | None = Field(default=None, min_length=1, max_length=80)
    description: str | None = Field(default=None, max_length=255)


class CategoryOut(ORMModel):
    id: int
    name: str
    description: str | None
    product_count: int
    created_at: datetime


# ---------- Suppliers ----------
class SupplierCreate(StrictModel):
    name: str = Field(min_length=1, max_length=120)
    phone: str | None = Field(default=None, max_length=30)
    email: str | None = Field(default=None, max_length=255, pattern=EMAIL_PATTERN)
    address: str | None = Field(default=None, max_length=255)


class SupplierUpdate(StrictModel):
    name: str | None = Field(default=None, min_length=1, max_length=120)
    phone: str | None = Field(default=None, max_length=30)
    email: str | None = Field(default=None, max_length=255, pattern=EMAIL_PATTERN)
    address: str | None = Field(default=None, max_length=255)


class SupplierOut(ORMModel):
    id: int
    name: str
    phone: str | None
    email: str | None
    address: str | None
    product_count: int
    created_at: datetime


# ---------- Products ----------
class ProductCreate(StrictModel):
    name: str = Field(min_length=1, max_length=150)
    sku: str = Field(min_length=1, max_length=50)
    description: str | None = Field(default=None, max_length=500)
    category_id: int | None = None
    supplier_id: int | None = None
    cost_price: float = Field(default=0, ge=0)
    selling_price: float = Field(default=0, ge=0)
    quantity: int = Field(default=0, ge=0, description="Opening stock")
    reorder_level: int = Field(default=5, ge=0)


class ProductUpdate(StrictModel):
    """Stock quantity is NOT editable here. Use POST /stock-movements."""

    name: str | None = Field(default=None, min_length=1, max_length=150)
    sku: str | None = Field(default=None, min_length=1, max_length=50)
    description: str | None = Field(default=None, max_length=500)
    category_id: int | None = None
    supplier_id: int | None = None
    cost_price: float | None = Field(default=None, ge=0)
    selling_price: float | None = Field(default=None, ge=0)
    reorder_level: int | None = Field(default=None, ge=0)


class ProductOut(ORMModel):
    id: int
    name: str
    sku: str
    description: str | None
    category_id: int | None
    category_name: str | None
    supplier_id: int | None
    supplier_name: str | None
    cost_price: float
    selling_price: float
    quantity: int
    reorder_level: int
    is_low_stock: bool
    created_at: datetime
    updated_at: datetime


# ---------- Stock movements ----------
class MovementCreate(StrictModel):
    product_id: int
    movement_type: Literal["in", "out", "adjust"]
    quantity: int = Field(
        ge=0,
        description="'in'/'out': units moved (at least 1). 'adjust': the counted stock level.",
    )
    note: str | None = Field(default=None, max_length=255)

    @model_validator(mode="after")
    def quantity_must_be_positive_for_in_out(self):
        if self.movement_type in ("in", "out") and self.quantity < 1:
            raise ValueError("quantity must be at least 1 for 'in' and 'out' movements")
        return self


class MovementOut(ORMModel):
    id: int
    product_id: int
    product_name: str
    movement_type: str
    quantity: int
    quantity_after: int
    note: str | None
    created_at: datetime


# ---------- Dashboard ----------
class DashboardOut(BaseModel):
    total_products: int
    total_categories: int
    total_suppliers: int
    total_units: int
    stock_value_at_cost: float
    stock_value_at_selling_price: float
    low_stock_count: int
    out_of_stock_count: int
    recent_movements: list[MovementOut]


class MessageOut(BaseModel):
    detail: str
