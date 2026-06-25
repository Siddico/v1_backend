<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\DoctorProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DoctorProfileController extends Controller
{
    public function show(Request $request, string $id): JsonResponse
    {
        $profile = clone $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $doctor = DoctorProfile::find($id);

        if (! $doctor) {
            return response()->json([
                'success' => false,
                'message' => 'Doctor not found.',
                'data'    => null,
            ], 404);
        }

        $patientsCount = $doctor->patientListEntries()->count();

        return response()->json([
            'success' => true,
            'message' => 'Doctor profile retrieved.',
            'data'    => [
                'doctor' => [
                    'id'                   => $doctor->id,
                    'full_name'            => $doctor->full_name,
                    'specialty'            => $doctor->specialty,
                    'license_number'       => $doctor->license_number,
                    'years_of_experience'  => $doctor->years_of_experience,
                    'about'                => $doctor->about,
                    'patients_count'       => $patientsCount,
                    'image_url'            => $doctor->image ? asset('storage/' . $doctor->image) : null,
                ]
            ],
        ]);
    }
}
