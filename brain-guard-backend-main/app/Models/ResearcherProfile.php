<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ResearcherProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'full_name',
        'institution',
        'research_field',
        'phone',
        'gender',
        'email',
        'image',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function researchPapers()
    {
        return $this->hasMany(ResearchPaper::class, 'researcher_id');
    }

    public function savedPapers()
    {
        return $this->hasMany(SavedPaper::class, 'researcher_id');
    }

    public function paperSearchLogs()
    {
        return $this->hasMany(PaperSearchLog::class, 'researcher_id');
    }

    public function publisherProfile()
    {
        return $this->hasOne(PublisherProfile::class, 'researcher_id');
    }

    public function researchAlerts()
    {
        return $this->hasMany(ResearchAlert::class, 'researcher_id');
    }

    public function paperInteractions()
    {
        return $this->hasMany(PaperInteraction::class, 'researcher_id');
    }
}
