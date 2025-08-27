mitrayectoriautp
=================

Project structure
-----------------

```
mitrayectoriautp/
├─ backend/
│  ├─ extractor.py
│  ├─ main.py
│  ├─ requirements.txt
│  └─ utils/
│      └─ cleaner.py
├─ frontend/
│  ├─ package.json
│  ├─ src/
│  │   ├─ App.jsx
│  │   ├─ components/
│  │   │   ├─ UploadPDF.jsx
│  │   │   ├─ StudyPlanViewer.jsx
│  │   │   └─ CourseSelector.jsx
│  │   └─ services/
│  │       └─ api.js
└─ README.md
```

Backend
-------
See `backend/README.md` for environment setup and running details.

Frontend
--------
- Install dependencies and run with your preferred Node.js manager.
- Configure `VITE_API_BASE_URL` to point to your backend.

