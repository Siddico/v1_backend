<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DoctorProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'full_name',
        'license_number',
        'specialty',
        'hospital',
        'years_of_experience',
        'bio',
        'phone',
        'gender',
        'email',
        'image',
        'rating',
        'total_reviews',
        'working_hours',
        'is_available',
    ];

    protected $appends = [
        'specialization',
        'hospital_affiliation',
        'years_experience',
    ];

    protected function casts(): array
    {
        return [
            'is_available' => 'boolean',
        ];
    }

    public function getSpecializationAttribute()
    {
        return $this->specialty;
    }

    public function getHospitalAffiliationAttribute()
    {
        return $this->hospital;
    }

    public function getYearsExperienceAttribute()
    {
        return $this->years_of_experience;
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function patientListEntries()
    {
        return $this->hasMany(PatientList::class, 'doctor_id');
    }

    public function doctorAlerts()
    {
        return $this->hasMany(DoctorAlert::class, 'doctor_id');
    }

    public function followUps()
    {
        return $this->hasMany(DoctorFollowUp::class, 'doctor_id');
    }

    public function medicalDataRecords()
    {
        return $this->hasMany(MedicalData::class, 'doctor_id');
    }

    public function appointments()
    {
        return $this->hasMany(Appointment::class, 'doctor_id');
    }

    public function relationshipRequests()
    {
        return $this->hasMany(RelationshipRequest::class, 'doctor_id');
    }
}
