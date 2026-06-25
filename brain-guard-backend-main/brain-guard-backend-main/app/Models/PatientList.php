<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PatientList extends Model
{
    use HasFactory;

    protected $table = 'patient_list';

    protected $fillable = [
        'doctor_id',
        'patient_id',
        'diagnoses',
        'status',
        'last_review',
    ];

    protected function casts(): array
    {
        return [
            'last_review' => 'datetime',
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
}
