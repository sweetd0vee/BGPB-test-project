import joblib
import numpy as np
import pandas as pd
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from artifacts.features import CATEGORICAL, FEATURES

# Load the pre-trained XGBoost model
model = joblib.load('artifacts/XGBoost.joblib')
categorical_le = joblib.load('artifacts/label_encoders.joblib')


app = FastAPI()

# CORS middleware allowing all origins and methods
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],            # Change to your domain in production
    allow_credentials=True,
    allow_methods=["*"],            # Allow all HTTP methods including OPTIONS
    allow_headers=["*"],
)


@app.post("/predict")
async def predict(data: pd.DataFrame):
    data.set_index('ID')
    # Encoded categorical features in PredictionInput
    for c in CATEGORICAL:
        data[c] = categorical_le.transform(data[c].astype('str'))

    # Convert input features to a NumPy array
    input_array = np.array(data[FEATURES]).reshape(1, -1)

    # Make prediction
    prediction = model.predict(input_array).tolist()
    prediction_proba = model.predict_proba(input_array).tolist()
    return {"prediction": prediction[0], "prediction_probability": prediction_proba[0]}


# Health check endpoint
@app.get("/")
async def root():
    return {"message": "XGBoost Model API is running!"}
