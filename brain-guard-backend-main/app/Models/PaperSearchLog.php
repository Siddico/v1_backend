<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PaperSearchLog extends Model
{
    use HasFactory;

    protected $table = 'paper_search_logs';

    protected $fillable = [
        'researcher_id',
        'keyword',
        'filter_field',
        'filter_year',
        'filter_institution',
        'searched_at',
    ];

    protected function casts(): array
    {
        return [
            'searched_at' => 'datetime',
        ];
    }

    public function researcher(): BelongsTo
    {
        return $this->belongsTo(ResearcherProfile::class, 'researcher_id');
    }
}
