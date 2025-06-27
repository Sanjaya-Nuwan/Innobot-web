import os
import uuid
import shutil
from fastapi import UploadFile


def save_profile_picture(file: UploadFile) -> str:
    upload_dir = "uploads"
    os.makedirs(upload_dir, exist_ok=True)  # Create folder if not exists

    _, ext = os.path.splitext(file.filename)  # get file extension with dot, e.g. '.jpg'
    filename = f"{uuid.uuid4().hex}{ext}"
    path = os.path.join(upload_dir, filename)

    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return path  # relative path to save in DB
