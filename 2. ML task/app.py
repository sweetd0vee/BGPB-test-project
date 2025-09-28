import io
from typing import Annotated

import joblib
import numpy as np
import pandas as pd
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from artifacts.features import CATEGORICAL, FEATURES
from base_logger import logger


# Load the pre-trained XGBoost model
try:
    model = joblib.load('artifacts/XGBoost.joblib')
except FileNotFoundError:
    logger.error("Model file not found")
    raise HTTPException(500, "Model not available")

try:
    categorical_le = joblib.load('artifacts/label_encoders.joblib')
except FileNotFoundError:
    logger.error("Categorical encoders not found")
    raise HTTPException(500, "Model not available")


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
    data_test = pd.DataFrame(csvdata)

    logger.info(data_test)

    # Validation of columns in input file
    required_cols = ['ID'] + FEATURES
    if not all(c in data_test.columns for c in required_cols):
        raise HTTPException(400, f"Missing required columns")

    data_test = data_test.set_index('ID')

    # Encoded categorical features in PredictionInput
    logger.info(categorical_le)
    data_test[CATEGORICAL] = categorical_le.transform(data_test[CATEGORICAL].astype('str'))
    logger.info(data_test)
    # Convert input features to a NumPy array

    input_array = np.array(data_test[FEATURES]).reshape(1, -1)

    # Make prediction
    prediction = model.predict(input_array).tolist()
    prediction_proba = model.predict_proba(input_array).tolist()
    return {"prediction": prediction[0], "prediction_probability": prediction_proba[0]}


# Health check endpoint
@app.get("/")
async def root():
    return {"message": "XGBoost Model API is running!"}
