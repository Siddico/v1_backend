# Phase 10: Robustness Report

This report summarizes stress test evaluations of the predictive model.

## Tests & Performance
- **Baseline F1 Score**: 0.9899
- **Missing Values Stress Test (10% Age Missing)**: 0.9719
- **Noise Injection Test (Gaussian Noise on Age)**: 0.9729

## Conclusion
The model is resilient to minor data degradation and missing inputs when processed using the automated imputation pipeline.
