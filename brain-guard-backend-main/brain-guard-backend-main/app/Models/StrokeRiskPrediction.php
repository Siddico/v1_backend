<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class StrokeRiskPrediction extends Model
{
    use HasFactory;

    protected $fillable = [
        'patient_id',
        'health_data_id',
        'score',
        'confidence',
        'risk_level',
        'overview',
        'predict_based_on_files',
        'model_version',
        'prediction_type',
        'model_output',
        'probabilities',
        'recommendations',
        'symptoms',
        'status',
        'predicted_at',
    ];

    protected function casts(): array
    {
        return [
            'predict_based_on_files' => 'boolean',
            'predicted_at'           => 'datetime',
            'model_output'           => 'array',
            'probabilities'          => 'array',
            'recommendations'        => 'array',
            'symptoms'               => 'array',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(PatientProfile::class, 'patient_id');
    }

    public function healthData(): BelongsTo
    {
        return $this->belongsTo(HealthData::class, 'health_data_id');
    }

    public function emergencyRecommendations(): HasMany
    {
        return $this->hasMany(EmergencyRecommendation::class, 'prediction_id');
    }

    public function reports(): HasMany
    {
        return $this->hasMany(Report::class, 'prediction_id');
    }

    public function doctorAlerts(): HasMany
    {
        return $this->hasMany(DoctorAlert::class, 'prediction_id');
    }
}
