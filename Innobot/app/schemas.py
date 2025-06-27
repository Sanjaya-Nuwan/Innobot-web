from pydantic import BaseModel, EmailStr
from typing import Optional


class UserCreate(BaseModel):
    name: str
    email: EmailStr
    phone: Optional[str]
    address: Optional[str]
    age: Optional[int]


class UserOut(UserCreate):
    id: int
    profile_picture: Optional[str]

    class Config:
        from_attributes = True

