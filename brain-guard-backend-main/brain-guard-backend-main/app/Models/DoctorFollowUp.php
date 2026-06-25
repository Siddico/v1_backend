<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DoctorFollowUp extends Model
{
    use HasFactory;

    protected $table = 'doctor_follow_up';

    protected $fillable = [
        'doctor_id',
        'patient_id',
        'suggestion_text',
        'description',
        'status',
        'next_visit',
        'follow_up_type',
    ];

    protected function casts(): array
    {
        return [
            'next_visit' => 'date',
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
