import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = ""

# DATABASE_URL = os.getenv("DATABASE_URL")
#
# if not DATABASE_URL:
#     raise ValueError("DATABASE_URL is not set in the environment")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()
