<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Report extends Model
{
    use HasFactory;

    protected $fillable = [
        'patient_id',
        'prediction_id',
        'report_format',
        'file_url',
        'is_encrypted',
        'shared_to',
        'generated_at',
    ];

    protected function casts(): array
    {
        return [
            'is_encrypted' => 'boolean',
            'generated_at' => 'datetime',
        ];
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
