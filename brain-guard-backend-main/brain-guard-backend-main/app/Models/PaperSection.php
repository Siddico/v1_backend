<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PaperSection extends Model
{
    use HasFactory;

    protected $fillable = [
        'paper_id',
        'abstract',
        'keywords',
        'appendices',
        'introduction',
        'methodology',
        'result',
        'discussion',
        'conclusion',
        'references',
    ];

    public function paper(): BelongsTo
    {
        return $this->belongsTo(ResearchPaper::class, 'paper_id');
    }
}
