<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PublisherProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'researcher_id',
        'bio',
        'institution',
        'total_papers',
        'research_field',
    ];

    public function researcher(): BelongsTo
    {
        return $this->belongsTo(ResearcherProfile::class, 'researcher_id');
    }
}
