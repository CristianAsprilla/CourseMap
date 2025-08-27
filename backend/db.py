import json
import sqlite3
from pathlib import Path
from typing import Any, Iterable

DB_PATH = Path(__file__).parent / "app.db"


def get_conn() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db() -> None:
    conn = get_conn()
    try:
        cur = conn.cursor()
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS documents (
              doc_id TEXT PRIMARY KEY,
              name TEXT,
              facultad TEXT,
              carrera TEXT,
              payload_json TEXT NOT NULL
            )
            """
        )
        cur.execute(
            """
            CREATE TABLE IF NOT EXISTS course_status (
              doc_id TEXT NOT NULL,
              cod_asig TEXT NOT NULL,
              passed INTEGER NOT NULL,
              PRIMARY KEY (doc_id, cod_asig),
              FOREIGN KEY (doc_id) REFERENCES documents(doc_id) ON DELETE CASCADE
            )
            """
        )
        conn.commit()
    finally:
        conn.close()


def save_document(doc_id: str, name: str | None, facultad: str, carrera: str, payload: dict[str, Any]) -> None:
    conn = get_conn()
    try:
        conn.execute(
            """
            INSERT INTO documents(doc_id, name, facultad, carrera, payload_json)
            VALUES(?,?,?,?,?)
            ON CONFLICT(doc_id) DO UPDATE SET
              name=excluded.name,
              facultad=excluded.facultad,
              carrera=excluded.carrera,
              payload_json=excluded.payload_json
            """,
            (doc_id, name, facultad, carrera, json.dumps(payload, ensure_ascii=False)),
        )
        conn.commit()
    finally:
        conn.close()


def load_document(doc_id: str) -> dict[str, Any] | None:
    conn = get_conn()
    try:
        row = conn.execute("SELECT * FROM documents WHERE doc_id=?", (doc_id,)).fetchone()
        if not row:
            return None
        payload = json.loads(row["payload_json"])  # type: ignore[no-any-return]
        payload["DOC_ID"] = row["doc_id"]
        payload["FACULTAD"] = row["facultad"]
        payload["CARRERA"] = row["carrera"]
        if row["name"] is not None:
            payload["NAME"] = row["name"]
        # merge stored course statuses
        statuses = get_course_statuses(doc_id)
        if statuses:
            for course in payload.get("PLAN", []):
                code = str(course.get("COD_ASIG"))
                if code in statuses:
                    course["PASSED"] = bool(statuses[code])
        return payload
    finally:
        conn.close()


def load_document_by_name(name: str) -> dict[str, Any] | None:
    conn = get_conn()
    try:
        row = conn.execute("SELECT * FROM documents WHERE name=?", (name,)).fetchone()
        if not row:
            return None
        payload = json.loads(row["payload_json"])  # type: ignore[no-any-return]
        payload["DOC_ID"] = row["doc_id"]
        payload["FACULTAD"] = row["facultad"]
        payload["CARRERA"] = row["carrera"]
        if row["name"] is not None:
            payload["NAME"] = row["name"]
        statuses = get_course_statuses(row["doc_id"])  # merge
        if statuses:
            for course in payload.get("PLAN", []):
                code = str(course.get("COD_ASIG"))
                if code in statuses:
                    course["PASSED"] = bool(statuses[code])
        return payload
    finally:
        conn.close()

def set_document_name(doc_id: str, name: str) -> None:
    conn = get_conn()
    try:
        conn.execute("UPDATE documents SET name=? WHERE doc_id=?", (name, doc_id))
        conn.commit()
    finally:
        conn.close()


def set_course_status(doc_id: str, cod_asig: str, passed: bool) -> None:
    conn = get_conn()
    try:
        conn.execute(
            """
            INSERT INTO course_status(doc_id, cod_asig, passed)
            VALUES(?,?,?)
            ON CONFLICT(doc_id, cod_asig) DO UPDATE SET passed=excluded.passed
            """,
            (doc_id, str(cod_asig), 1 if passed else 0),
        )
        conn.commit()
    finally:
        conn.close()


def get_course_statuses(doc_id: str) -> dict[str, int]:
    conn = get_conn()
    try:
        cur = conn.execute("SELECT cod_asig, passed FROM course_status WHERE doc_id=?", (doc_id,))
        return {row[0]: row[1] for row in cur.fetchall()}
    finally:
        conn.close()


