import category_encoders
import joblib
import numpy as np
import pandas as pd
import xgboost as xgb
from sklearn.metrics import roc_auc_score
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.preprocessing import LabelEncoder

import warnings
warnings.filterwarnings('ignore')

import logging

SEED = 42

data_path = 'artifacts/data.csv'
data = pd.read_csv(data_path).set_index('ID')
data['Marker'] = data['Marker'].replace({'good': 1, 'bad': 0})
data = data.dropna()
features =['Application creation month', 'NUMBER CREDITS IN KBI 3',
       'NUMBER CREDITS IN KBI 6', 'ADMINISTRATIVE VIOLATION',
       'CRIMINAL VIOLATION', 'NUMBER CREDITS IN KBI', 'NUMBER REQUESTS IN KBI',
       'NUMBER REQUESTS IN KBI ALL', 'CLOSED CREDITS IN KBI',
       'CLOSED CREDITS IN KBI YEAR', 'OVERDUES IN KBI',
       'DURATION LAST OVERDUE', 'COUNTGUARANTEE', 'COUNTCLOSEGUARANTEE',
       'COUNTOPENGUARANTEE', 'DURATIONGREATESTDELAYLASTYEAR',
       'DURATIONGREATESTDELAYLASTALL', 'LATECOUNTSUMM 1 7',
       'LATECOUNTSUMM 8 30', 'LATECOUNTSUMM 31 90', 'LATECOUNTSUMM 91 180',
       'LATECOUNTSUMM 181', 'LATECOUNTPRC 1 7', 'LATECOUNTPRC 8 30',
       'LATECOUNTPRC 31 90', 'LATECOUNTPRC 91 180', 'LATECOUNTPRC 181',
       'LATECOUNTPAY 1 7', 'LATECOUNTPAY 8 30', 'LATECOUNTPAY 31 90',
       'LATECOUNTPAY 91 180', 'LATECOUNTPAY 181', 'SEX', 'BIRTH CNTR',
       'MARITAL STATUS', 'CHILDREN', 'MINORS', 'HOMEPHONE', 'WORKPHONE',
       'MOBILE 1', 'REG TOWNTYPE', 'HOME TOWNTYPE', 'EMPLOYMENT', 'EDUCATION',
       'PROFESSION', 'REAL ESTATE', 'VEHICLE', 'PERSONNEL PHONE',
       'ACCOUNTING PHONE', 'Age', 'Length work',
       'Matching address of registration and residence', 'Loans total',
       'Credit load']
categorical = []
for c in data.columns:
    if data[c].dtype == 'object':
        categorical.append(c)
numerical = list(set(features) - set(categorical))

y = data['Marker']
X = data.drop(columns='Marker', inplace=False)
X = X[features]

# кодируем категориальные признаки
label_encoders = {}
for col in categorical:
        le = LabelEncoder()
        le.fit(X[col].astype('str'))
        X[col] = le.transform(X[col].astype('str'))
        label_encoders[col] = le
print("Закодировали данные")
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
print("Запускаем гридсерч")
xgb_model = xgb.XGBClassifier()
grid_search = GridSearchCV(
    estimator=xgb_model, param_grid=param_grid, cv=5, n_jobs=-1)
grid_search.fit(X_train, y_train)
parameters = grid_search.best_params_
parameters["early_stopping_rounds"] = 10
model_best = xgb.XGBClassifier(**parameters)

model_best.fit(X_train, y_train, eval_set=[(X_valid, y_valid)])
pred = model_best.predict_proba(X_test)[:,1]
print(roc_auc_score(y_test, pred))
