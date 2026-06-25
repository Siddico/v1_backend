# Phase 4: Feature Engineering Report

This report evaluates candidate engineered features and their predictive power.

## Candidate Engineered Features
1. **Age Group**: Categorizes numerical age into four distinct classes (Young, Adult, Middle-Aged, Senior).
2. **Cardiovascular Risk Score**: Sum of key cardiovascular symptom indicators (`chest_pain`, `high_blood_pressure`, `irregular_heartbeat`, `chest_discomfort`).
3. **Hypertension & Irregular Heartbeat Interaction**: Multiplicative interaction of high blood pressure and irregular heartbeat.
4. **General Symptoms Score**: Sum of auxiliary symptoms (`shortness_of_breath`, `fatigue_weakness`, `dizziness`, `swelling_edema`, `excessive_sweating`).

## Mutual Information Scores (Including Engineered Features)
| Feature                 |   Mutual Information |
|:------------------------|---------------------:|
| age                     |           0.288975   |
| cardio_risk_score       |           0.173378   |
| age_group_Middle-Aged   |           0.119447   |
| general_symptoms_score  |           0.0921103  |
| high_blood_pressure     |           0.0755845  |
| age_group_Senior        |           0.0503012  |
| chest_pain              |           0.04312    |
| snoring_sleep_apnea     |           0.0353532  |
| shortness_of_breath     |           0.0291679  |
| hbp_irregular_heartbeat |           0.0286082  |
| chest_discomfort        |           0.0282833  |
| irregular_heartbeat     |           0.028282   |
| fatigue_weakness        |           0.0225772  |
| dizziness               |           0.0215298  |
| cold_hands_feet         |           0.0208796  |
| swelling_edema          |           0.0206382  |
| neck_jaw_pain           |           0.0178903  |
| persistent_cough        |           0.0170532  |
| age_group_Adult         |           0.00993743 |
| excessive_sweating      |           0.00713989 |
| gender_Male             |           0.00647174 |
| nausea_vomiting         |           0.00414857 |
| anxiety_doom            |           0.00238515 |

## Final Strategy
To maintain model parsimony and avoid overfitting, the baseline features plus the highly interpretable `cardio_risk_score` and `age_group` features are recommended.
