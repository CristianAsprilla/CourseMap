from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from models import StudyPlan
from extractor import extract_pdf_to_json
from utils.cleaner import clean_document
from db import init_db, save_document, load_document, set_document_name, set_course_status, load_document_by_name
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    yield

app = FastAPI(lifespan=lifespan)

# Allow front-end to access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/upload/pdf")
async def upload_pdf(file: UploadFile = File(...)):
    pdf_bytes = await file.read()
    raw_json = extract_pdf_to_json(pdf_bytes)
    contents = raw_json.get("result", {}).get("contents", [])
    if not contents:
        raise HTTPException(status_code=400, detail="Analyzer returned no contents")
    cleaned_json = clean_document(contents[0])
    doc_id = cleaned_json.get("DOC_ID")
    if not doc_id:
        raise HTTPException(status_code=400, detail="DOC_ID missing in extracted document")
    save_document(
        doc_id=doc_id,
        name=None,
        facultad=cleaned_json.get("FACULTAD", ""),
        carrera=cleaned_json.get("CARRERA", ""),
        payload=cleaned_json,
    )
    return cleaned_json


@app.post("/upload/json")
async def upload_json(plan: StudyPlan):
    payload = plan.model_dump()
    save_document(
        doc_id=payload["DOC_ID"],
        name=None,
        facultad=payload.get("FACULTAD", ""),
        carrera=payload.get("CARRERA", ""),
        payload=payload,
    )
    return payload


@app.get("/documents/{doc_id}")
async def get_document(doc_id: str):
    payload = load_document(doc_id)
    if not payload:
        raise HTTPException(status_code=404, detail="Document not found")
    return payload


@app.post("/documents/{doc_id}/name")
async def rename_document(doc_id: str, name: str):
    set_document_name(doc_id, name)
    return {"doc_id": doc_id, "name": name}


@app.post("/documents/{doc_id}/courses/{cod_asig}/status")
async def update_course_status(doc_id: str, cod_asig: str, passed: bool):
    set_course_status(doc_id, cod_asig, passed)
    payload = load_document(doc_id)
    if not payload:
        raise HTTPException(status_code=404, detail="Document not found")
    return payload

@app.get("/documents/by-name/{name}")
async def get_document_by_name(name: str):
    payload = load_document_by_name(name)
    if not payload:
        raise HTTPException(status_code=404, detail="Document not found")
    return payload
