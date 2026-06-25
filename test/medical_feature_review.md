# Phase 2: Medical Feature Review

A medical classification of each feature in the Stroke Risk Prediction Dataset V2, categorizing their clinical relevance and leakage risk.

| Feature Name | Type | Medical Classification | Clinical Justification & Risk |
| :--- | :--- | :--- | :--- |
| `age` | Continuous | Useful | Age is the single most significant non-modifiable risk factor for stroke. |
| `gender` | Categorical | Useful | Cardiovascular risk profiles vary between biological sexes. |
| `chest_pain` | Binary | Useful | Symptom of coronary artery disease, which increases ischemic stroke risk. |
| `high_blood_pressure` | Binary | Useful | Hypertension is the leading modifiable cause of stroke. |
| `irregular_heartbeat` | Binary | Useful | Atrial fibrillation and irregular heartbeats are direct causes of embolic stroke. |
| `shortness_of_breath` | Binary | Useful | Indicator of potential congestive heart failure or pulmonary issues, linked to cardiovascular stroke risk. |
| `fatigue_weakness` | Binary | Potentially useful | Non-specific symptom but can be associated with chronic cardiovascular/cerebrovascular insufficiency. |
| `dizziness` | Binary | Potentially useful | Symptom of transient ischemic attacks (TIA) or hypotension/hypertension issues. |
| `swelling_edema` | Binary | Potentially useful | Sign of heart failure, chronic venous insufficiency, or renal issues. |
| `neck_jaw_pain` | Binary | Potentially useful | Can indicate atypical myocardial infarction, which is a major risk factor for cardiogenic stroke. |
| `excessive_sweating` | Binary | Potentially useful | Associated with acute autonomic arousal, cardiac events, or endocrine conditions. |
| `persistent_cough` | Binary | Irrelevant | Typically pulmonary or medication-related (e.g., ACE inhibitors), low direct relevance to stroke risk. |
| `nausea_vomiting` | Binary | Potentially useful | Associated with elevated intracranial pressure or acute cardiac symptoms, but mostly non-specific. |
| `chest_discomfort` | Binary | Useful | Symptom of coronary heart disease and angina. |
| `cold_hands_feet` | Binary | Potentially useful | Indicator of peripheral artery disease (PAD) or poor circulation, reflecting systemic atherosclerosis. |
| `snoring_sleep_apnea` | Binary | Potentially useful | Obstructive sleep apnea (OSA) is strongly linked to stroke risk, hypertension, and atrial fibrillation. |
| `anxiety_doom` | Binary | Potentially useful | Psychological distress and panic-like states can trigger acute cardiovascular stress. |
| `stroke_risk_percentage` | Continuous | Leakage risk | This is a derived target probability metric and represents pure data leakage. It must be excluded. |
| `at_risk` | Binary | Target | The primary prediction target representing high stroke risk. |
