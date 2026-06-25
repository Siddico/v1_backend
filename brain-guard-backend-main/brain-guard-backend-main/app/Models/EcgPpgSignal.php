<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EcgPpgSignal extends Model
{
    use HasFactory;

    protected $table = 'ecg_ppg_signals';

    protected $fillable = [
        'patient_id',
        'signal_type',
        'raw_data',
        'file_url',
        'source',
        'uploaded_at',
    ];

    protected function casts(): array
    {
        return [
            'raw_data' => 'array',
            'uploaded_at' => 'datetime',
        ];
    }

    public function patient(): BelongsTo
    {
        return $this->belongsTo(PatientProfile::class, 'patient_id');
    }
}
