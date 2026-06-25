# pyrefly: ignore [missing-import]
import uvicorn
# pyrefly: ignore [missing-import]
from fastapi import FastAPI, HTTPException
# pyrefly: ignore [missing-import]
from pydantic import BaseModel, Field
from typing import List
import pandas as pd
# pyrefly: ignore [missing-import]
import numpy as np
import pickle
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("stroke_risk_api")

app = FastAPI(title="Stroke Risk Prediction API", version="1.0.0")

try:
    with open('final_model.pkl', 'rb') as f:
        model = pickle.load(f)
    with open('preprocessor.pkl', 'rb') as f:
        preprocessor = pickle.load(f)
except Exception as e:
    logger.error(f"Error loading models: {e}")
    model = None
    preprocessor = None

class PatientData(BaseModel):
    age: int = Field(..., ge=0, le=120, example=52)
    gender: str = Field(..., example="Male")
    chest_pain: int = Field(..., ge=0, le=1, example=0)
    high_blood_pressure: int = Field(..., ge=0, le=1, example=1)
    irregular_heartbeat: int = Field(..., ge=0, le=1, example=0)
    shortness_of_breath: int = Field(..., ge=0, le=1, example=0)
    fatigue_weakness: int = Field(..., ge=0, le=1, example=1)
    dizziness: int = Field(..., ge=0, le=1, example=0)
    swelling_edema: int = Field(..., ge=0, le=1, example=0)
    neck_jaw_pain: int = Field(..., ge=0, le=1, example=0)
    excessive_sweating: int = Field(..., ge=0, le=1, example=0)
    persistent_cough: int = Field(..., ge=0, le=1, example=0)
    nausea_vomiting: int = Field(..., ge=0, le=1, example=0)
    chest_discomfort: int = Field(..., ge=0, le=1, example=0)
    cold_hands_feet: int = Field(..., ge=0, le=1, example=0)
    snoring_sleep_apnea: int = Field(..., ge=0, le=1, example=0)
    anxiety_doom: int = Field(..., ge=0, le=1, example=0)

class PredictionResponse(BaseModel):
    stroke_risk_probability: float
    at_risk: int

class BatchPredictionResponse(BaseModel):
    predictions: List[PredictionResponse]

@app.get("/health")
def health_check():
    if model is None or preprocessor is None:
        raise HTTPException(status_code=503, detail="Model and preprocessor not loaded")
    return {"status": "healthy"}

@app.post("/predict", response_model=PredictionResponse)
def predict(patient: PatientData):
    if model is None or preprocessor is None:
        raise HTTPException(status_code=503, detail="Model or preprocessor failed to load on server startup. Check server logs.")
    df_in = pd.DataFrame([patient.dict()])
    X_prep = preprocessor.transform(df_in)
    prob = float(model.predict_proba(X_prep)[0, 1])
    pred = int(model.predict(X_prep)[0])
    return PredictionResponse(stroke_risk_probability=prob, at_risk=pred)

@app.post("/batch-predict", response_model=BatchPredictionResponse)
def batch_predict(patients: List[PatientData]):
    df_in = pd.DataFrame([p.dict() for p in patients])
    X_prep = preprocessor.transform(df_in)
    probs = model.predict_proba(X_prep)[:, 1]
    preds = model.predict(X_prep)
    res = [PredictionResponse(stroke_risk_probability=float(prob), at_risk=int(pred)) for prob, pred in zip(probs, preds)]
    return BatchPredictionResponse(predictions=res)

@app.get("/model-info")
def model_info():
    return {
        "model_name": "Stroke Risk Prediction Model (LightGBM)",
        "version": "1.0.0",
        "description": "Production-ready binary classification model to predict high risk of stroke."
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=7860)
