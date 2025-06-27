import os
import uuid
import shutil
from fastapi import UploadFile


def save_profile_picture(file: UploadFile) -> str:
    """
    Save the uploaded profile picture to the 'uploads' directory with a unique filename.

    Args:
        file: The uploaded file from the client.

    Returns:
        The relative path to the saved profile picture.
    """
    upload_dir = "uploads"
    os.makedirs(upload_dir, exist_ok=True)

    _, ext = os.path.splitext(file.filename)
    filename = f"{uuid.uuid4().hex}{ext}"
    path = os.path.join(upload_dir, filename)

    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return path
