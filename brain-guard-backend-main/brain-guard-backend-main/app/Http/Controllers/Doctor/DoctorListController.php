<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\DoctorProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DoctorListController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = DoctorProfile::query()->with('user');

        if ($request->filled('specialty')) {
            $query->where('specialty', 'like', '%' . $request->specialty . '%');
        }

        if ($request->filled('is_available') && in_array($request->is_available, ['1', 'true'], true)) {
            $query->where('is_available', true);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('full_name', 'like', '%' . $search . '%')
                    ->orWhere('specialty', 'like', '%' . $search . '%')
                    ->orWhere('hospital', 'like', '%' . $search . '%');
            });
        }

        $doctors = $query->get()->map(fn (DoctorProfile $doctor) => [
            'id'                   => $doctor->id,
            'user_id'              => $doctor->user_id,
            'full_name'            => $doctor->full_name,
            'specialty'            => $doctor->specialty,
            'specialization'       => $doctor->specialty,
            'hospital'             => $doctor->hospital,
            'hospital_affiliation' => $doctor->hospital,
            'bio'                  => $doctor->bio,
            'phone'                => $doctor->phone,
            'gender'               => $doctor->gender,
            'email'                => $doctor->email,
            'image'                => $doctor->image,
            'photo_url'            => $doctor->image ? asset('storage/' . $doctor->image) : null,
            'rating'               => $doctor->rating ?? 0.0,
            'total_reviews'        => $doctor->total_reviews ?? 0,
            'working_hours'        => $doctor->working_hours,
            'years_of_experience'  => $doctor->years_of_experience,
            'is_available'         => $doctor->is_available ?? true,
            'license_number'       => $doctor->license_number,
            'user'                 => [
                'id'        => $doctor->user?->id,
                'email'     => $doctor->user?->email,
                'full_name' => $doctor->user?->full_name,
            ],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Doctors retrieved.',
            'data'    => ['doctors' => $doctors],
        ]);
    }
}
