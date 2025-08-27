from pydantic import BaseModel
from typing import List, Optional

class Course(BaseModel):
    NUM_ASIG: int
    COD_ASIG: int
    FUNDAMENTAL: bool
    ASIGNATURA: str
    REQUISITOS: List[str]
    AÑO: str
    SEMESTRE: str
    PASSED: Optional[bool] = None

class StudyPlan(BaseModel):
    DOC_ID: str
    FACULTAD: str
    CARRERA: str
    PLAN: List[Course]

