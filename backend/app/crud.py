from sqlalchemy.orm import Session
from app import models
from app import schemas


def create_user(db: Session, user: schemas.UserCreate, profile_picture: str = None) -> models.User:
    """
    Create a new user in the database.

    Args:
        db: Database session.
        user: User data from the request.
        profile_picture: Path to the uploaded profile picture (if any).

    Returns:
        The created User model instance.
    """
    user_data = user.dict()
    user_data["profile_picture"] = profile_picture
    db_user = models.User(**user_data)

    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def get_users(db: Session, skip: int = 0, limit: int = 10) -> list[models.User]:
    """
    Retrieve a list of users with optional pagination.

    Args:
        db: Database session.
        skip: Number of users to skip.
        limit: Maximum number of users to return.

    Returns:
        A list of User model instances.
    """
    return db.query(models.User).offset(skip).limit(limit).all()


def get_user(db: Session, user_id: int) -> models.User | None:
    """
    Retrieve a single user by ID.

    Args:
        db: Database session.
        user_id: ID of the user.

    Returns:
        A User model instance or None if not found.
    """
    return db.query(models.User).filter(models.User.id == user_id).first()


def update_user(db: Session, user_id: int, updated: schemas.UserCreate, profile_picture: str = None) -> models.User:
    """
    Update an existing user's information.

    Args:
        db: Database session.
        user_id: ID of the user to update.
        updated: Updated user data.
        profile_picture: Optional new profile picture path.

    Returns:
        The updated User model instance.
    """
    user = db.query(models.User).filter(models.User.id == user_id).first()
    for field, value in updated.dict().items():
        setattr(user, field, value)
    if profile_picture:
        user.profile_picture = profile_picture
    db.commit()
    return user


def delete_user(db: Session, user_id: int) -> None:
    """
    Delete a user by ID.

    Args:
        db: Database session.
        user_id: ID of the user to delete.

    Returns:
        None
    """
    user = db.query(models.User).filter(models.User.id == user_id).first()
    db.delete(user)
    db.commit()
