from typing import Optional
from pydantic import BaseModel, EmailStr, field_validator


class UserCreate(BaseModel):
    """
    Schema for creating a new user.
    """
    name: str
    email: EmailStr
    phone: Optional[str]
    address: Optional[str]
    age: Optional[int]
    profile_picture: Optional[str] = None


class UserOut(UserCreate):
    """
    Schema for returning user data including ID and normalized profile picture URL.
    """
    id: int
    profile_picture: Optional[str]

    @field_validator("profile_picture")
    def add_base_url(cls, value: Optional[str]) -> Optional[str]:
        """
        Ensure the profile_picture URL is absolute by adding base URL if missing.

        Args:
            value: The profile picture path or URL.

        Returns:
            The absolute URL to the profile picture or None.
        """
        if value and not value.startswith("http"):
            normalized = value.replace("\\", "/")
            return f"http://localhost:8000/{normalized}"
        return value
