#!/usr/bin/env python3
"""Apply Phase 3 Postman collection updates."""

import json
import math
import re
import sys
from copy import deepcopy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "BrainGuard API.postman_collection.json"
DST = ROOT / "BrainGuard_API_postman_collection.json"


def generate_ppg_signal(length: int = 1250) -> list[float]:
    return [
        round(math.sin(2 * math.pi * i / 125) * 0.8 + math.sin(2 * math.pi * i / 25) * 0.2, 4)
        for i in range(length)
    ]


def url_raw(item: dict) -> str:
    req = item.get("request") or {}
    url = req.get("url") or {}
    return url.get("raw", "") if isinstance(url, dict) else str(url)


def set_bearer_auth(request: dict) -> None:
    request["auth"] = {
        "type": "bearer",
        "bearer": [{"key": "token", "value": "{{token}}", "type": "string"}],
    }


def make_request(name: str, method: str, path: str, body: str | None = None, description: str | None = None) -> dict:
    req: dict = {
        "method": method,
        "header": [{"key": "Accept", "value": "application/json", "type": "text"}],
        "url": {
            "raw": f"{{{{base_url}}}}{path}",
            "host": ["{{base_url}}"],
            "path": [p for p in path.strip("/").split("/") if p],
        },
    }
    if body is not None:
        req["header"].append({"key": "Content-Type", "value": "application/json", "type": "text"})
        req["body"] = {"mode": "raw", "raw": body, "options": {"raw": {"language": "json"}}}
    set_bearer_auth(req)
    item: dict = {"name": name, "request": req, "response": []}
    if description:
        item["description"] = description
    return item


def find_folder(items: list, name: str) -> dict | None:
    for item in items:
        if item.get("name") == name and "item" in item:
            return item
    return None


def has_request(items: list, predicate) -> bool:
    for item in items:
        if "request" in item and predicate(item):
            return True
        if "item" in item and has_request(item["item"], predicate):
            return True
    return False


def insert_after(items: list, after_name: str, new_item: dict) -> bool:
    for idx, item in enumerate(items):
        if item.get("name") == after_name:
            items.insert(idx + 1, new_item)
            return True
        if "item" in item and insert_after(item["item"], after_name, new_item):
            return True
    return False


def main() -> int:
    with SRC.open(encoding="utf-8") as f:
        data = json.load(f)

    text_before = json.dumps(data)

    # CHANGE 1: Fix hardcoded doctors URLs
    def fix_urls(obj):
        if isinstance(obj, dict):
            for k, v in obj.items():
                if k == "raw" and isinstance(v, str) and "brainguard.devawy.com" in v:
                    obj[k] = v.replace("https://brainguard.devawy.com/api/v1/doctors", "{{base_url}}/doctors")
                else:
                    fix_urls(v)
        elif isinstance(obj, list):
            for i in obj:
                fix_urls(i)

    fix_urls(data)

    ppg_values = generate_ppg_signal()
    assert len(ppg_values) == 1250

    qr_body = '{\r\n    "qr_data": "DOCTOR_3"\r\n}'
    qr_description = (
        "Scan a doctor QR code. Format: DOCTOR_{doctor_profile_id}.\r\n"
        "Response includes: doctor profile, connection_status (connected/pending/none).\r\n"
        "If connection_status is 'none' → Flutter shows Send Request button."
    )

    questionnaire_body = (
        '{\r\n    "age": 55,\r\n    "gender": "Male",\r\n    "chest_pain": 1,\r\n'
        '    "high_blood_pressure": 1,\r\n    "irregular_heartbeat": 0,\r\n'
        '    "shortness_of_breath": 1,\r\n    "fatigue_weakness": 1,\r\n'
        '    "dizziness": 0,\r\n    "swelling_edema": 0,\r\n    "neck_jaw_pain": 0,\r\n'
        '    "excessive_sweating": 0,\r\n    "persistent_cough": 0,\r\n'
        '    "nausea_vomiting": 0,\r\n    "chest_discomfort": 1,\r\n'
        '    "cold_hands_feet": 0,\r\n    "snoring_sleep_apnea": 1,\r\n'
        '    "anxiety_doom": 0\r\n}'
    )
    questionnaire_description = (
        "EHR questionnaire-based stroke prediction using LightGBM model.\r\n"
        "No PPG signal required. Uses EHR_AI_SERVICE_URL.\r\n"
        "Returns same prediction format as /patient/predict with prediction_type: AI_QUESTIONNAIRE."
    )

    scan_qr_body = '{\r\n    "qr_data": "PATIENT_12"\r\n}'
    scan_qr_description = (
        "Doctor scans patient QR code. Format: PATIENT_{patient_profile_id}.\r\n"
        "Response includes: patient profile + is_connected boolean.\r\n"
        "If is_connected is false → Flutter shows Add Patient button."
    )

    def walk(items: list):
        for item in items:
            req = item.get("request")
            if req:
                raw_url = url_raw(item)
                method = req.get("method", "")

                # CHANGE 2: Update signals raw_data
                if method == "POST" and "/patient/signals" in raw_url and item.get("name") == "Upload Signal (ECG/PPG)":
                    body_obj = {
                        "signal_type": "ECG",
                        "raw_data": ppg_values,
                        "source": "wearable",
                        "file_url": "https://medlineplus.gov/ency/imagepages/1135.htm",
                    }
                    req["body"] = {
                        "mode": "raw",
                        "raw": json.dumps(body_obj, separators=(",", ":")),
                        "options": {"raw": {"language": "json"}},
                    }

                # CHANGE 3: Update patient/qr
                if method == "POST" and raw_url.endswith("/patient/qr"):
                    req["body"] = {
                        "mode": "raw",
                        "raw": qr_body,
                        "options": {"raw": {"language": "json"}},
                    }
                    item["description"] = qr_description

                # CHANGE 5: Update questionnaire if exists
                if method == "POST" and "/patient/questionnaire-predict" in raw_url:
                    req["body"] = {
                        "mode": "raw",
                        "raw": questionnaire_body,
                        "options": {"raw": {"language": "json"}},
                    }
                    item["description"] = questionnaire_description
                    set_bearer_auth(req)

                # Remove otp_code from saved responses/examples
                if "otp/send" in raw_url:
                    item.pop("response", None)
                    req["response"] = []

            if "item" in item:
                walk(item["item"])

    walk(data["item"])

    patient_folder = find_folder(data["item"], "Patient")
    doctor_folder = find_folder(data["item"], "Doctor")

    if patient_folder:
        pitems = patient_folder["item"]

        if not has_request(pitems, lambda i: "/patient/questionnaire-predict" in url_raw(i)):
            insert_after(pitems, "Run Prediction (AI)", make_request(
                "Questionnaire Stroke Risk Predict (EHR)",
                "POST",
                "/patient/questionnaire-predict",
                questionnaire_body,
                questionnaire_description,
            ))

        if not has_request(pitems, lambda i: "/patient/notifications/" in url_raw(i) and "/read" in url_raw(i)):
            insert_after(pitems, "Get Notifications", make_request(
                "Mark Notification Read (Flutter alias)",
                "PATCH",
                "/patient/notifications/1/read",
                description=(
                    "Flutter compatibility route. Identical to PATCH /patient/notifications/{id}.\r\n"
                    "Use this path if Flutter sends the /read suffix."
                ),
            ))

        if not has_request(pitems, lambda i: url_raw(i).endswith("/patient/chat/read")):
            insert_after(pitems, "Get Chat", make_request(
                "Mark All Chats Read",
                "POST",
                "/patient/chat/read",
            ))

    if doctor_folder:
        ditems = doctor_folder["item"]
        if not has_request(ditems, lambda i: "/doctor/scan-qr" in url_raw(i)):
            ditems.append(make_request(
                "Scan Patient QR (Doctor)",
                "POST",
                "/doctor/scan-qr",
                scan_qr_body,
                scan_qr_description,
            ))

    # Strip otp_code from any example responses in collection
    text = json.dumps(data)
    text = re.sub(r'"otp_code"\s*:\s*"[^"]*"\s*,?', "", text)
    text = re.sub(r',\s*}', "}", text)
    data = json.loads(text)

    with DST.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
        f.write("\n")

    # Verification
    out_text = DST.read_text(encoding="utf-8")
    with DST.open(encoding="utf-8") as f:
        verify = json.load(f)

    raw_count = 0
    def count_signals(items):
        nonlocal raw_count
        for item in items:
            req = item.get("request")
            if req and req.get("method") == "POST" and "/patient/signals" in url_raw(item):
                body = req.get("body", {}).get("raw", "")
                if body:
                    obj = json.loads(body)
                    raw_count = len(obj.get("raw_data", []))
            if "item" in item:
                count_signals(item["item"])

    count_signals(verify["item"])

    print(f"Wrote {DST}")
    print(f"raw_data count: {raw_count}")
    print(f"brainguard.devawy.com count: {out_text.count('brainguard.devawy.com')}")
    print(f"otp_code count: {out_text.count('otp_code')}")
    print(f"scan-qr present: {'scan-qr' in out_text}")
    print(f"questionnaire-predict present: {'questionnaire-predict' in out_text}")
    print(f"notifications/1/read present: {'notifications/1/read' in out_text}")
    print(f"chat/read present: {'chat/read' in out_text}")

    if raw_count != 1250:
        print("ERROR: raw_data count is not 1250", file=sys.stderr)
        return 1
    if "brainguard.devawy.com" in out_text:
        print("ERROR: hardcoded URL remains", file=sys.stderr)
        return 1
    if "otp_code" in out_text:
        print("ERROR: otp_code remains in collection", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
