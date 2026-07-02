<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ChatbotSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'patient_id',
        'title',
    ];

    public function patient(): BelongsTo
    {
        return $this->belongsTo(PatientProfile::class, 'patient_id');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(ChatbotMessage::class, 'session_id');
    }
}
