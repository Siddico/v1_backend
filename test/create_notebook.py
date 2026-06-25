import json

notebook = {
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Stroke Risk Prediction System - Complete End-to-End Pipeline\n",
    "\n",
    "This notebook implements a complete, production-ready ML pipeline for stroke risk prediction based on the Stroke Risk Prediction Dataset V2."
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Phase 1: Environment Setup and Library Imports"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": None,
   "metadata": {},
   "outputs": [],
   "source": [
    "!pip install -q lightgbm catboost optuna shap imbalanced-learn pandas numpy scikit-learn matplotlib seaborn tabulate"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": None,
   "metadata": {},
   "outputs": [],
   "source": [
    "import os\n",
    "import json\n",
    "import pickle\n",
    "import numpy as np\n",
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "from sklearn.model_selection import StratifiedKFold, train_test_split\n",
    "from sklearn.preprocessing import StandardScaler, OneHotEncoder\n",
    "from sklearn.compose import ColumnTransformer\n",
    "from sklearn.pipeline import Pipeline\n",
    "from sklearn.impute import SimpleImputer\n",
    "from sklearn.metrics import (\n",
    "    accuracy_score, precision_score, recall_score, f1_score,\n",
    "    roc_auc_score, precision_recall_curve, auc, confusion_matrix,\n",
    "    balanced_accuracy_score, matthews_corrcoef, cohen_kappa_score,\n",
    "    brier_score_loss\n",
    ")\n",
    "from sklearn.linear_model import LogisticRegression\n",
    "from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier, HistGradientBoostingClassifier\n",
    "from sklearn.calibration import CalibratedClassifierCV, calibration_curve\n",
    "import xgboost as xgb\n",
    "import lightgbm as lgb\n",
    "from catboost import CatBoostClassifier\n",
    "from imblearn.ensemble import BalancedRandomForestClassifier\n",
    "import optuna\n",
    "import shap\n",
    "import warnings\n",
    "warnings.filterwarnings('ignore')"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Phase 2: Load and Audit the Dataset"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": None,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Load dataset\n",
    "df = pd.read_csv('stroke_risk_dataset_v2.csv')\n",
    "print(f\"Shape: {df.shape}\")\n",
    "print(df.head())"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Phase 3: Preprocessing Pipeline"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": None,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Separate target leakage and features\n",
    "X = df.drop(columns=['at_risk', 'stroke_risk_percentage'])\n",
    "y = df['at_risk']\n",
    "\n",
    "# Define column transformer\n",
    "numeric_features = ['age']\n",
    "categorical_features = ['gender']\n",
    "\n",
    "preprocessor = ColumnTransformer(\n",
    "    transformers=[\n",
    "        ('num', Pipeline(steps=[\n",
    "            ('imputer', SimpleImputer(strategy='median')),\n",
    "            ('scaler', StandardScaler())\n",
    "        ]), numeric_features),\n",
    "        ('cat', Pipeline(steps=[\n",
    "            ('imputer', SimpleImputer(strategy='most_frequent')),\n",
    "            ('onehot', OneHotEncoder(drop='first', handle_unknown='ignore'))\n",
    "        ]), categorical_features)\n",
    "    ],\n",
    "    remainder='passthrough'\n",
    ")\n",
    "\n",
    "X_prep = preprocessor.fit_transform(X)\n",
    "print(\"Preprocessing Complete.\")"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Phase 4: Model Comparison"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": None,
   "metadata": {},
   "outputs": [],
   "source": [
    "X_train, X_val, y_train, y_val = train_test_split(X_prep, y, test_size=0.2, stratify=y, random_state=42)\n",
    "\n",
    "models = {\n",
    "    \"Logistic Regression\": LogisticRegression(max_iter=1000, random_state=42),\n",
    "    \"Random Forest\": RandomForestClassifier(random_state=42),\n",
    "    \"XGBoost\": xgb.XGBClassifier(random_state=42, eval_metric='logloss'),\n",
    "    \"LightGBM\": lgb.LGBMClassifier(random_state=42, verbose=-1),\n",
    "    \"CatBoost\": CatBoostClassifier(random_state=42, verbose=0),\n",
    "    \"Extra Trees\": ExtraTreesClassifier(random_state=42),\n",
    "    \"HistGradientBoosting\": HistGradientBoostingClassifier(random_state=42),\n",
    "    \"Balanced Random Forest\": BalancedRandomForestClassifier(random_state=42)\n",
    "}\n",
    "\n",
    "results = []\n",
    "for name, model in models.items():\n",
    "    model.fit(X_train, y_train)\n",
    "    preds = model.predict(X_val)\n",
    "    results.append({\n",
    "        'Model': name,\n",
    "        'Accuracy': accuracy_score(y_val, preds),\n",
    "        'F1 Score': f1_score(y_val, preds),\n",
    "        'Recall': recall_score(y_val, preds)\n",
    "    })\n",
    "\n",
    "comparison = pd.DataFrame(results)\n",
    "print(comparison)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Phase 5: Hyperparameter Optimization"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": None,
   "metadata": {},
   "outputs": [],
   "source": [
    "def objective(trial):\n",
    "    params = {\n",
    "        'n_estimators': trial.suggest_int('n_estimators', 50, 150),\n",
    "        'max_depth': trial.suggest_int('max_depth', 3, 7),\n",
    "        'learning_rate': trial.suggest_float('learning_rate', 0.05, 0.15),\n",
    "        'verbose': -1,\n",
    "        'random_state': 42\n",
    "    }\n",
    "    clf = lgb.LGBMClassifier(**params)\n",
    "    clf.fit(X_train, y_train)\n",
    "    return f1_score(y_val, clf.predict(X_val))\n",
    "\n",
    "study = optuna.create_study(direction='maximize')\n",
    "study.optimize(objective, n_trials=20) # Running subset for demo\n",
    "print(\"Best F1 Score:\", study.best_value)"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Phase 6: Explainability and SHAP"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": None,
   "metadata": {},
   "outputs": [],
   "source": [
    "best_clf = lgb.LGBMClassifier(**study.best_params)\n",
    "best_clf.fit(X_train, y_train)\n",
    "explainer = shap.TreeExplainer(best_clf)\n",
    "shap_values = explainer.shap_values(X_val)\n",
    "shap.summary_plot(shap_values, X_val, show=False)\n",
    "plt.savefig('shap_summary.png')"
   ]
  }
 ],
 "metadata": {
  "language_info": {
   "name": "python"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 2
}

with open('stroke_prediction_system.ipynb', 'w') as f:
    json.dump(notebook, f, indent=4)
print("Notebook JSON created successfully.")
