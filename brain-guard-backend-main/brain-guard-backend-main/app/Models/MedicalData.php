<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MedicalData extends Model
{
    use HasFactory;

    protected $table = 'medical_data';

    public $timestamps = false;

    protected $fillable = [
        'patient_id',
        'doctor_id',
        'diagnosis',
        'treatment_plan',
        'heart_rate',
        'blood_pressure',
        'blood_glucose',
        'cholesterol',
        'last_ecg_ppg_upload',
        'doctor_notes',
        'hrv',
        'updated_at',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'last_ecg_ppg_upload' => 'datetime',
            'updated_at'          => 'datetime',
            'created_at'          => 'datetime',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(PatientProfile::class, 'patient_id');
    }

    public function doctor(): BelongsTo
    {
        return $this->belongsTo(DoctorProfile::class, 'doctor_id');
    }
}
