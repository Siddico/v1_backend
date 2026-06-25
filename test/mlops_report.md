# MLOps Report

## Experiment Tracking (MLflow)
The experiment tracking captures:
- All training hyperparameters.
- Model artifacts (.pkl).
- Evaluation metrics.

## Drift Detection
We design Evidently AI / Neptune.ai scripts to track feature drift (using Kolmogorov-Smirnov test for `age`) and target drift.
