# Flutter Handover Document

## API Schema Definition

### Prediction Request (JSON)
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

### Prediction Response (JSON)
```json
{
  "stroke_risk_probability": 0.724,
  "at_risk": 1
}
```

## UI Recommendation
- Display fields in logical groupings (e.g. Demographics, Cardiovascular Symptoms, Systemic Symptoms).
- Show warning indicators for high probabilities (e.g., Red badge for `at_risk == 1`).
