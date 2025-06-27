import os
from dotenv import load_dotenv
from fastapi import FastAPI, Depends, UploadFile, File, Form, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from typing import List, Optional
from app import database, models, schemas, crud, utils
load_dotenv()
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"]
)

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")


def get_db():
    """
    Dependency to get a SQLAlchemy database session.
    """
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.post("/users/", response_model=schemas.UserOut)
async def create_user(
        name: str = Form(...),
        email: str = Form(...),
        phone: Optional[str] = Form(None),
        address: Optional[str] = Form(None),
        age: Optional[int] = Form(None),
        file: UploadFile = File(None),
        db: Session = Depends(get_db)
) -> schemas.UserOut:
    """
    Create a new user with optional profile picture.

    Args:
        name: Name of the user.
        email: Email address.
        phone: Optional phone number.
        address: Optional address.
        age: Optional age.
        file: Optional profile picture.
        db: Database session.

    Returns:
        The created user data.
    """
    profile_pic_path = utils.save_profile_picture(file) if file else None
    user_data = schemas.UserCreate(name=name, email=email, phone=phone, address=address, age=age)
    return crud.create_user(db, user_data, profile_pic_path)


@app.get("/users/", response_model=List[schemas.UserOut])
def read_users(
        skip: int = 0,
        limit: int = 10,
        db: Session = Depends(get_db)
) -> List[schemas.UserOut]:
    """
    Get a paginated list of users.

    Args:
        skip: Number of records to skip.
        limit: Maximum number of records to return.
        db: Database session.

    Returns:
        List of user records.
    """
    return crud.get_users(db, skip=skip, limit=limit)


@app.put("/users/{user_id}", response_model=schemas.UserOut)
async def update_user(
        user_id: int,
        name: str = Form(...),
        email: str = Form(...),
        phone: Optional[str] = Form(None),
        address: Optional[str] = Form(None),
        age: Optional[int] = Form(None),
        file: UploadFile = File(None),
        db: Session = Depends(get_db)
) -> schemas.UserOut:
    """
    Update an existing user's details and profile picture.

    Args:
        user_id: ID of the user to update.
        name: Updated name.
        email: Updated email.
        phone: Updated phone number.
        address: Updated address.
        age: Updated age.
        file: Optional updated profile picture.
        db: Database session.

    Returns:
        The updated user data.
    """
    profile_pic_path = utils.save_profile_picture(file) if file else None
    user_data = schemas.UserCreate(name=name, email=email, phone=phone, address=address, age=age)
    return crud.update_user(db, user_id, user_data, profile_pic_path)


@app.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)) -> dict:
    """
    Delete a user by ID.

    Args:
        user_id: ID of the user to delete.
        db: Database session.

    Returns:
        Confirmation message.
    """
    crud.delete_user(db, user_id)
    return {"message": "User deleted"}


@app.get("/users/")
def read_users(db: Session = Depends(get_db)) -> List[schemas.UserOut]:
    """
    Get all users without pagination (overrides previous /users/ GET).

    Args:
        db: Database session.

    Returns:
        List of all user records.
    """
    return crud.get_users(db)


@app.get("/")
def read_root() -> dict:
    """
    Root endpoint to confirm the API is working.

    Returns:
        Welcome message.
    """
    return {"message": "FastAPI is working!"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=True)
