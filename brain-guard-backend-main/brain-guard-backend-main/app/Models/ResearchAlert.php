<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ResearchAlert extends Model
{
    use HasFactory;

    protected $fillable = [
        'researcher_id',
        'paper_id',
        'alert_type',
        'alert_time',
        'is_read',
    ];

    protected function casts(): array
    {
        return [
            'alert_time' => 'datetime',
            'is_read' => 'boolean',
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
