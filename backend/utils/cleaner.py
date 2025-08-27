import sys
import json

def clean_value(field):
    """
    Recursively clean a field from the verbose API format.
    Only unwraps 'type' objects with valueString, valueNumber, valueBoolean, valueArray, valueObject.
    """
    if isinstance(field, dict):
        if 'type' in field:
            if 'valueString' in field:
                return field['valueString']
            elif 'valueNumber' in field:
                return field['valueNumber']
            elif 'valueBoolean' in field:      # <-- ADD THIS
                return field['valueBoolean']
            elif 'valueArray' in field:
                return [clean_value(item) for item in field['valueArray']]
            elif 'valueObject' in field:
                return clean_value(field['valueObject'])
            else:
                return None
        else:
            # Regular dict without type
            return {k: clean_value(v) for k, v in field.items()}
    elif isinstance(field, list):
        return [clean_value(item) for item in field]
    else:
        return field  # primitive value


def clean_plan_fields(plan_item):
    """
    Convert a raw plan item to a clean dict.
    Preserves FUNDAMENTAL as boolean.
    """
    return {
        "NUM_ASIG": plan_item.get("NUM_ASIG"),
        "COD_ASIG": plan_item.get("COD_ASIG"),
        "FUNDAMENTAL": plan_item.get("FUNDAMENTAL", False),
        "ASIGNATURA": plan_item.get("ASIGNATURA"),
        "REQUISITOS": plan_item.get("REQUISITOS") or [],
        "AÑO": plan_item.get("AÑO"),
        "SEMESTRE": plan_item.get("SEMESTRE")
    }

def clean_document(content):
    """
    Convert a single content block to a clean document.
    """
    fields = clean_value(content.get("fields", {}))  # unwrap all 'type' layers

    plan_items = fields.get("PLAN", [])
    plan = [clean_plan_fields(p) for p in plan_items]

    return {
        "DOC_ID": fields.get("DOC_ID"),
        "FACULTAD": fields.get("FACULTAD"),
        "CARRERA": fields.get("CARRERA"),
        "PLAN": plan
    }
