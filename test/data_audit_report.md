# Phase 1: Data Audit Report

This report summarizes the data quality and audit results for the Stroke Risk Prediction Dataset V2.

## Dataset Shape
- **Rows**: 35000
- **Columns**: 19

## Data Types
| Column                 | Dtype   |
|:-----------------------|:--------|
| age                    | int64   |
| gender                 | object  |
| chest_pain             | int64   |
| high_blood_pressure    | int64   |
| irregular_heartbeat    | int64   |
| shortness_of_breath    | int64   |
| fatigue_weakness       | int64   |
| dizziness              | int64   |
| swelling_edema         | int64   |
| neck_jaw_pain          | int64   |
| excessive_sweating     | int64   |
| persistent_cough       | int64   |
| nausea_vomiting        | int64   |
| chest_discomfort       | int64   |
| cold_hands_feet        | int64   |
| snoring_sleep_apnea    | int64   |
| anxiety_doom           | int64   |
| stroke_risk_percentage | float64 |
| at_risk                | int64   |

## Missing Values
| Column                 |   Missing Count |
|:-----------------------|----------------:|
| age                    |               0 |
| gender                 |               0 |
| chest_pain             |               0 |
| high_blood_pressure    |               0 |
| irregular_heartbeat    |               0 |
| shortness_of_breath    |               0 |
| fatigue_weakness       |               0 |
| dizziness              |               0 |
| swelling_edema         |               0 |
| neck_jaw_pain          |               0 |
| excessive_sweating     |               0 |
| persistent_cough       |               0 |
| nausea_vomiting        |               0 |
| chest_discomfort       |               0 |
| cold_hands_feet        |               0 |
| snoring_sleep_apnea    |               0 |
| anxiety_doom           |               0 |
| stroke_risk_percentage |               0 |
| at_risk                |               0 |

## Duplicate Rows
- **Total Duplicates**: 16279

## Outliers Analysis (IQR Method)
- **Age Outliers**: 238 (Age range: 18 to 86)

## Target Distribution & Class Imbalance
- **Class 0 (Not At Risk)**: 22113 (63.18%)
- **Class 1 (At Risk)**: 12887 (36.82%)
- **Class Imbalance Status**: Moderate class imbalance is observed. Resampling or balanced loss/class weights should be employed.

## Correlation with Target (at_risk)
| Feature                |   Correlation coefficient |
|:-----------------------|--------------------------:|
| at_risk                |                  1        |
| stroke_risk_percentage |                  0.852185 |
| age                    |                  0.664524 |
| high_blood_pressure    |                  0.393487 |
| chest_pain             |                  0.295271 |
| snoring_sleep_apnea    |                  0.266177 |
| shortness_of_breath    |                  0.258746 |
| chest_discomfort       |                  0.248903 |
| irregular_heartbeat    |                  0.239826 |
| cold_hands_feet        |                  0.204342 |
| fatigue_weakness       |                  0.202815 |
| dizziness              |                  0.200802 |
| swelling_edema         |                  0.198199 |
| neck_jaw_pain          |                  0.186125 |
| persistent_cough       |                  0.173854 |
| excessive_sweating     |                  0.107098 |
| anxiety_doom           |                  0.104957 |
| nausea_vomiting        |                  0.100022 |

## Data Leakage Detection
- **Stroke Risk Percentage Correlation**: 0.8522
- **Conclusion**: `stroke_risk_percentage` is highly correlated with the target and acts as a direct representation of the target threshold (`at_risk` is exactly 1 if `stroke_risk_percentage` >= 50.0). This feature represents absolute data leakage and must be dropped before modeling.

## Feature Importance Exploration (Baseline Random Forest)
| Feature             |   Importance |
|:--------------------|-------------:|
| age                 |   0.443911   |
| high_blood_pressure |   0.115206   |
| chest_pain          |   0.0691229  |
| shortness_of_breath |   0.0503028  |
| snoring_sleep_apnea |   0.0471613  |
| chest_discomfort    |   0.0439693  |
| irregular_heartbeat |   0.0336927  |
| fatigue_weakness    |   0.0316587  |
| cold_hands_feet     |   0.0279025  |
| dizziness           |   0.0272119  |
| swelling_edema      |   0.0236667  |
| gender_code         |   0.023313   |
| persistent_cough    |   0.0177343  |
| neck_jaw_pain       |   0.0171911  |
| excessive_sweating  |   0.0098235  |
| anxiety_doom        |   0.00931874 |
| nausea_vomiting     |   0.00881309 |
