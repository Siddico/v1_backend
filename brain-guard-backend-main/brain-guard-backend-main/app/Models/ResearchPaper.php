<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class ResearchPaper extends Model
{
    use HasFactory;

    protected $fillable = [
        'researcher_id',
        'paper_name',
        'publisher_name',
        'category_topic',
        'date',
        'description',
        'upload_type',
        'file_path',
        'is_verified',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'is_verified' => 'boolean',
        ];
    }

    public function researcher(): BelongsTo
    {
        return $this->belongsTo(ResearcherProfile::class, 'researcher_id');
    }

    public function paperSection(): HasOne
    {
        return $this->hasOne(PaperSection::class, 'paper_id');
    }

    public function savedBy(): HasMany
    {
        return $this->hasMany(SavedPaper::class, 'paper_id');
    }

    public function researchAlerts(): HasMany
    {
        return $this->hasMany(ResearchAlert::class, 'paper_id');
    }

    public function interactions(): HasMany
    {
        return $this->hasMany(PaperInteraction::class, 'paper_id');
    }
}
