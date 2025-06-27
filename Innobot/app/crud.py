from sqlalchemy.orm import Session
import models
import schemas


def create_user(db: Session, user: schemas.UserCreate, profile_picture: str = None):
    db_user = models.User(**user.dict(), profile_picture=profile_picture)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def get_users(db: Session, skip: int = 0, limit: int = 10):
    return db.query(models.User).offset(skip).limit(limit).all()


def get_user(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()


def update_user(db: Session, user_id: int, updated: schemas.UserCreate, profile_picture: str = None):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    for field, value in updated.dict().items():
        setattr(user, field, value)
    if profile_picture:
        user.profile_picture = profile_picture
    db.commit()
    return user


def delete_user(db: Session, user_id: int):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    db.delete(user)
    db.commit()
