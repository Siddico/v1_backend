# Database Design

## Schema
### Prediction Table
- `id`: UUID (Primary Key)
- `patient_id`: VARCHAR(50)
- `age`: INT
- `gender`: VARCHAR(10)
- `prediction_probability`: FLOAT
- `at_risk`: INT
- `created_at`: TIMESTAMP

### Audit Table
- `id`: UUID
- `event_name`: VARCHAR(255)
- `user_id`: VARCHAR(50)
- `created_at`: TIMESTAMP
