<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LabDocument extends Model
{
    use HasFactory;

    protected $fillable = [
        'patient_id',
        'lab_name',
        'category',
        'description',
        'file_url',
        'uploaded_at',
    ];

    protected function casts(): array
    {
        return [
            'uploaded_at' => 'datetime',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(PatientProfile::class, 'patient_id');
    }
}
