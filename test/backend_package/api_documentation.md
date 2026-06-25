# FastAPI Deployment API Documentation

## Endpoints

### 1. Health Check
`GET /health`
- **Response**: `{"status": "healthy"}`

### 2. Predict Stroke Risk
`POST /predict`
- **Request Body**:
```json
{
  "age": 52,
  "gender": "Male",
  "chest_pain": 0,
  "high_blood_pressure": 1,
  "irregular_heartbeat": 0,
  "shortness_of_breath": 0,
  "fatigue_weakness": 1,
  "dizziness": 0,
  "swelling_edema": 0,
  "neck_jaw_pain": 0,
  "excessive_sweating": 0,
  "persistent_cough": 0,
  "nausea_vomiting": 0,
  "chest_discomfort": 0,
  "cold_hands_feet": 0,
  "snoring_sleep_apnea": 0,
  "anxiety_doom": 0
}
```
- **Response**:
```json
{
  "stroke_risk_probability": 0.724,
  "at_risk": 1
}
```

### 3. Model Info
`GET /model-info`
