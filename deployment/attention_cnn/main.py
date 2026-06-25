# pyrefly: ignore [missing-import]
from fastapi import FastAPI, HTTPException, UploadFile, File
# pyrefly: ignore [missing-import]
from fastapi.middleware.cors import CORSMiddleware
# pyrefly: ignore [missing-import]
from pydantic import BaseModel
from typing import List, Optional
# pyrefly: ignore [missing-import]
import numpy as np
import json
import os
import io
# pyrefly: ignore [missing-import]
import scipy.io

# Disable GPU for deployment to save RAM (unless you have a GPU server)
os.environ["CUDA_VISIBLE_DEVICES"] = "-1"
import tensorflow as tf

app = FastAPI(title="Stroke Prediction AI API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model and encoder globally
mock_mode = False
model_error = ""
ort_session = None
input_name = None

try:
    # pyrefly: ignore [missing-import]
    import onnxruntime as ort
    # Use ONNX Runtime to bypass all TensorFlow and Keras issues entirely!
    ort_session = ort.InferenceSession("model.onnx")
    input_name = ort_session.get_inputs()[0].name
    
    # Load the new labels
    with open("labels.json", "r") as f:
        labels = json.load(f)["classes"]
        
    print("ONNX Model and labels loaded successfully.")
except Exception as e:
    model_error = str(e)
    print(f"Warning: Real model not found or broken ({model_error}). Starting in MOCK MODE.")
    mock_mode = True
    labels = ["AF", "NSR", "PAC"]

class PredictRequest(BaseModel):
    signal: Optional[List[float]] = None

@app.get("/")
def read_root():
    return {"status": "Active", "message": "Stroke Prediction API is running", "model_loaded": not mock_mode, "error": model_error}

@app.post("/predict")
def predict_stroke(request: PredictRequest):
    try:
        if not request.signal:
            raise HTTPException(status_code=400, detail="No signal data provided.")
            
        signal_data = request.signal
        
        # New Window Size requirement: 1250
        if len(signal_data) != 1250:
            raise HTTPException(status_code=400, detail=f"Invalid signal length. Expected 1250, got {len(signal_data)}.")
            
        return make_prediction(signal_data)
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/predict-mat")
async def predict_stroke_mat(file: UploadFile = File(...)):
    try:
        content = await file.read()
        mat = scipy.io.loadmat(io.BytesIO(content))
        
        if "PPG_raw_buffer" not in mat:
            raise HTTPException(status_code=400, detail="Invalid .mat file. Missing 'PPG_raw_buffer'.")
            
        signal = mat["PPG_raw_buffer"].flatten()
        signal = signal[:1250]
        
        if len(signal) < 1250:
            signal = np.pad(signal, (0, 1250-len(signal)))
            
        return make_prediction(signal.tolist())
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def make_prediction(signal_data):
    if mock_mode:
        import random
        confidence = random.uniform(0.1, 0.99)
        label = "NSR" if confidence < 0.5 else "AF"
        risk_score = int(confidence * 100)
        return {
            "prediction": label,
            "confidence": round(confidence, 4),
            "risk_score": risk_score,
            "is_mock": True,
            "error": model_error
        }
    else:
        # Convert to numpy array
        signal_np = np.array(signal_data, dtype=np.float32)
        
        # VERY IMPORTANT: Apply Z-score normalization because the model was trained on scaled data
        # (Mean ~ 0, Std ~ 1)
        mean_val = np.mean(signal_np)
        std_val = np.std(signal_np)
        if std_val > 0:
            signal_np = (signal_np - mean_val) / std_val
            
        # Shape required: (1, 1250, 1)
        processed_signal = signal_np.reshape(1, 1250, 1)
        
        # Predict using ONNX
        pred = ort_session.run(None, {input_name: processed_signal})[0]
        
        predicted_class_idx = np.argmax(pred)
        confidence = float(np.max(pred))
        label = labels[predicted_class_idx]
        
        # Simple risk mapping
        risk_score = 0
        if label == "AF":
            risk_score = 85 + int(confidence * 15)
        elif label == "PAC":
            risk_score = 60 + int(confidence * 15)
        else: # NSR
            risk_score = 10 + int((1 - confidence) * 20)
            
        return {
            "prediction": label,
            "confidence": round(confidence, 4),
            "risk_score": risk_score,
            "probabilities": pred[0].tolist()
        }
