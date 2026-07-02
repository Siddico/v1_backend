<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DoctorAlert extends Model
{
    use HasFactory;

    protected $fillable = [
        'doctor_id',
        'patient_id',
        'prediction_id',
        'risk_level',
        'alert_time',
        'is_read',
    ];

    protected function casts(): array
    {
        return [
            'alert_time' => 'datetime',
            'is_read' => 'boolean',
        ];
    }

    public function doctor(): BelongsTo
    {
        return $this->belongsTo(DoctorProfile::class, 'doctor_id');
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(PatientProfile::class, 'patient_id');
    }

    public function prediction(): BelongsTo
    {
        return $this->belongsTo(StrokeRiskPrediction::class, 'prediction_id');
    }
}
