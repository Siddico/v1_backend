<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EmergencyRecommendation extends Model
{
    use HasFactory;

    protected $fillable = [
        'patient_id',
        'prediction_id',
        'advice_text',
    ];

    public function patient(): BelongsTo
    {
        return $this->belongsTo(PatientProfile::class, 'patient_id');
    }

    public function prediction(): BelongsTo
    {
        return $this->belongsTo(StrokeRiskPrediction::class, 'prediction_id');
    }
}
