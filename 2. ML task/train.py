import joblib
import pandas as pd
import xgboost as xgb
from sklearn.metrics import roc_auc_score
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.preprocessing import LabelEncoder

from artifacts.features import CATEGORICAL, FEATURES, NUMERICAL


import warnings
warnings.filterwarnings('ignore')

from base_logger import logger

SEED = 42

data_path = 'artifacts/data.csv'
data = pd.read_csv(data_path).set_index('ID')
data['Marker'] = data['Marker'].replace({'good': 1, 'bad': 0})
data = data.dropna()

y = data['Marker']
X = data.drop(columns='Marker', inplace=False)
X = X[FEATURES]

label_encoders = {}
for col in CATEGORICAL:
        le = LabelEncoder()
        le.fit(X[col].astype('str'))
        X[col] = le.transform(X[col].astype('str'))
        label_encoders[col] = le

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15, random_state=SEED)
X_train, X_valid, y_train, y_valid = train_test_split(X_train, y_train, test_size=0.25, random_state=SEED)

param_grid = {
    "n_estimators": [5, 10, 15, 20, 50],
    "eta": [1e-1, 1e-2, 3e-1],
    "gamma": [0.1, 1],
    "max_depth": [4, 6, 8],
    "lambda": [0.1, 1],
    "alpha": [0,0.1,1],
    "verbosity": [0]
}
xgb_model = xgb.XGBClassifier()
grid_search = GridSearchCV(
    estimator=xgb_model, param_grid=param_grid, cv=5, n_jobs=-1)
grid_search.fit(X_train, y_train)
parameters = grid_search.best_params_
parameters["early_stopping_rounds"] = 10
model_best = xgb.XGBClassifier(**parameters)

try:
    model_best.fit(X_train, y_train, eval_set=[(X_valid, y_valid)])
except Exception as e:
    logger.error(f"Model training failed: {e}")
    raise

pred = model_best.predict_proba(X_test)[:,1]
logger.info(f"ROC_AUC score for best model: {roc_auc_score(y_test, pred)}")

joblib.dump(model_best, 'artifacts/XGBoost.joblib', compress=True)
joblib.dump(label_encoders, 'artifacts/label_encoders.joblib', compress=True)
