<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PatientProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'full_name',
        'age',
        'weight',
        'medical_history',
        'emergency_number',
        'phone',
        'gender',
        'image',
        'height',
        'bmi',
        'blood_type',
        'allergies',
        'current_medications',
        'residence_type',
        'work_type',
        'ever_married',
        'smoking_status',
        'hypertension',
        'heart_disease',
        'avg_glucose_level',
        'ai_risk_stroke_rate',
        'last_prediction_time',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'ever_married' => 'boolean',
            'hypertension' => 'boolean',
            'heart_disease' => 'boolean',
            'last_prediction_time' => 'datetime',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function healthData()
    {
        return $this->hasMany(HealthData::class, 'patient_id');
    }

    public function ecgPpgSignals()
    {
        return $this->hasMany(EcgPpgSignal::class, 'patient_id');
    }

    public function strokeRiskPredictions()
    {
        return $this->hasMany(StrokeRiskPrediction::class, 'patient_id');
    }

    public function emergencyRecommendations()
    {
        return $this->hasMany(EmergencyRecommendation::class, 'patient_id');
    }

    public function reports()
    {
        return $this->hasMany(Report::class, 'patient_id');
    }

    public function radiologyUploads()
    {
        return $this->hasMany(RadiologyUpload::class, 'patient_id');
    }

    public function patientListEntries()
    {
        return $this->hasMany(PatientList::class, 'patient_id');
    }

    public function medicalDataRecords()
    {
        return $this->hasMany(MedicalData::class, 'patient_id');
    }

    public function doctorAlerts()
    {
        return $this->hasMany(DoctorAlert::class, 'patient_id');
    }

    public function doctorFollowUps()
    {
        return $this->hasMany(DoctorFollowUp::class, 'patient_id');
    }

    public function labDocuments()
    {
        return $this->hasMany(LabDocument::class, 'patient_id');
    }

    public function radiologyImagingRecords()
    {
        return $this->hasMany(RadiologyImaging::class, 'patient_id');
    }

    public function medications()
    {
        return $this->hasMany(Medication::class, 'patient_id');
    }

    public function appointments()
    {
        return $this->hasMany(Appointment::class, 'patient_id');
    }

    public function chatbotSessions()
    {
        return $this->hasMany(ChatbotSession::class, 'patient_id');
    }

    public function relationshipRequests()
    {
        return $this->hasMany(RelationshipRequest::class, 'patient_id');
    }

    public function patientFiles()
    {
        return $this->hasMany(PatientFile::class, 'patient_id');
    }
}

