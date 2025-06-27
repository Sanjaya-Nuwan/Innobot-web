from fastapi import FastAPI, Depends, UploadFile, File, Form, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from typing import List, Optional
from app import database, models, schemas, crud, utils

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI()

# CORS (optional for Flutter frontend)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"]
)

# Mount static files to serve profile pictures
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")


def get_db():
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
):
    profile_pic_path = utils.save_profile_picture(file) if file else None
    user_data = schemas.UserCreate(name=name, email=email, phone=phone, address=address, age=age)
    return crud.create_user(db, user_data, profile_pic_path)


@app.get("/users/", response_model=List[schemas.UserOut])
def read_users(
        skip: int = 0,
        limit: int = 10,
        db: Session = Depends(get_db)
):
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
):
    profile_pic_path = utils.save_profile_picture(file) if file else None
    user_data = schemas.UserCreate(name=name, email=email, phone=phone, address=address, age=age)
    return crud.update_user(db, user_id, user_data, profile_pic_path)


@app.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    crud.delete_user(db, user_id)
    return {"message": "User deleted"}


@app.get("/")
def read_root():
    return {"message": "FastAPI is working!"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=True)
