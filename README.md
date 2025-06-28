# Innobot Project Documentation

This repository contains both the backend (FastAPI) and frontend (Flutter) for the Innobot web application.

---

## Backend (FastAPI)

### Features
- User and data management
- Image upload and storage
- CRUD operations
- Modular code structure

### Structure
```
backend/
  app/
    __init__.py
    crud.py
    database.py
    main.py
    models.py
    schemas.py
    utils.py
    uploads/           # Uploaded images
  tests/               # Test files
  requirements.txt     # Python dependencies
```

### Setup & Run
1. Create and activate a virtual environment:
   ```
   python -m venv .venv
   .venv\Scripts\activate  # On Windows
   ```
2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
   
2. Change databese URL:
   ```
   backend/app/database.py
   ```
   
3. Start the backend server:
   ```
   .venv\Scripts\python.exe -m uvicorn app.main:app --reload
   ```
   The server will start at `http://127.0.0.1:8000` by default.
4. API docs: Visit `http://127.0.0.1:8000/docs` for Swagger UI.

### Testing
Test files are in the `tests/` directory. Use your preferred test runner (e.g., pytest).

---

## Frontend (Flutter)

### Features
- Cross-platform: Web, Android, iOS, Windows, macOS, Linux
- Modern UI with Flutter
- API integration with backend
- Image upload and display
- Modular code structure

### Structure
```
innobot_web_app/
  lib/
    main.dart
    config/
    models/
    screens/
    services/
  web/
    index.html
    favicon.png
    manifest.json
    icons/
  android/
  ios/
  linux/
  macos/
  windows/
  test/
  pubspec.yaml
  pubspec.lock
  README.md
```

### Setup & Run
1. Install Flutter: [Flutter Install Guide](https://docs.flutter.dev/get-started/install)
2. Get dependencies:
   ```
   cd innobot_web_app
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```
   - For web: `flutter run -d chrome`
   - For desktop/mobile: use the appropriate device flag (e.g., `-d windows`, `-d android`)
4. Build for production:
   - Web: `flutter build web`
   - Android: `flutter build apk`
   - iOS: `flutter build ios`

---

## Notes
- The frontend requires the backend server to be running for API features.
- Uploaded files are stored in the backend's `uploads/` directory.
- Update `requirements.txt` (backend) and `pubspec.yaml` (frontend) if you add new dependencies.

---

For any issues, see code comments or contact the project maintainer.
