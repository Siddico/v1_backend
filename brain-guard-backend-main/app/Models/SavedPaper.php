<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SavedPaper extends Model
{
    use HasFactory;

    protected $fillable = [
        'researcher_id',
        'paper_id',
        'is_favorite',
        'saved_at',
    ];

    protected function casts(): array
    {
        return [
            'is_favorite' => 'boolean',
            'saved_at' => 'datetime',
        ];
    }

    public function researcher(): BelongsTo
    {
        return $this->belongsTo(ResearcherProfile::class, 'researcher_id');
    }

    public function paper(): BelongsTo
    {
        return $this->belongsTo(ResearchPaper::class, 'paper_id');
    }
}
