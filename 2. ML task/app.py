from http.client import HTTPException

import joblib
import numpy as np
import pandas as pd
from fastapi import FastAPI, File, UploadFile
from typing import Annotated
from fastapi.middleware.cors import CORSMiddleware

from artifacts.features import CATEGORICAL, FEATURES

import io

import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load the pre-trained XGBoost model
model = joblib.load('artifacts/XGBoost.joblib')
categorical_le = joblib.load('artifacts/label_encoders.joblib')

app = FastAPI()

# CORS middleware allowing all origins and methods
origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    logger.info("call predict")

    # Validation of file type
    if not file.filename.endswith('.csv'):
        raise HTTPException(400, "File must be CSV")

    contents = await file.read()
    csvdata = pd.read_csv(io.StringIO(contents.decode('utf-8')))
    data = pd.DataFrame(csvdata)

    logger.info(data)

    # Validation of columns in input file
    required_cols = ['ID'] + FEATURES
    if not all(c in data.columns for c in required_cols):
        raise HTTPException(400, f"Missing required columns")

    data = data.set_index('ID')
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
