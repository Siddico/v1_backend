import pickle
import numpy as np
import pandas as pd

class StrokeInferenceEngine:
    def __init__(self, model_path='final_model.pkl', preprocessor_path='preprocessor.pkl'):
        with open(model_path, 'rb') as f:
            self.model = pickle.load(f)
        with open(preprocessor_path, 'rb') as f:
            self.preprocessor = pickle.load(f)
            
    def predict(self, input_df):
        X_prep = self.preprocessor.transform(input_df)
        probs = self.model.predict_proba(X_prep)[:, 1]
        preds = self.model.predict(X_prep)
        return preds, probs
