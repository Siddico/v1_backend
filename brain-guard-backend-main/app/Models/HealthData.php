<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class HealthData extends Model
{
    use HasFactory;

    protected $table = 'health_data';

    protected $fillable = [
        'patient_id',
        'heart_rate',
        'blood_pressure',
        'blood_glucose',
        'cholesterol',
        'spo2_level',
        'stability_index',
        'recorded_at',
    ];

    protected function casts(): array
    {
        return [
            'recorded_at' => 'datetime',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(PatientProfile::class, 'patient_id');
    }

    public function strokeRiskPredictions(): HasMany
    {
        return $this->hasMany(StrokeRiskPrediction::class, 'health_data_id');
    }
}
