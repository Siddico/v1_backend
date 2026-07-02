<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\PatientList;
use App\Models\RadiologyImaging;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RadiologyImagingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $profile = $request->user()->doctorProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Doctor profile not found.',
                'data'    => null,
            ], 404);
        }

        $patientIds = PatientList::query()
            ->where('doctor_id', $profile->id)
            ->pluck('patient_id');

        $records = RadiologyImaging::query()
            ->whereIn('patient_id', $patientIds)
            ->with('patient')
            ->orderByDesc('uploaded_at')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Radiology imaging retrieved.',
            'data'    => ['radiology_imaging' => $records],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $profile = $request->user()->doctorProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Doctor profile not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'patient_id'   => ['required', 'integer', 'exists:patient_profiles,id'],
            'imaging_type' => ['required', 'in:xray,mri,ct,ultrasound'],
            'description'  => ['nullable', 'string'],
            'file_url'     => ['nullable', 'string', 'max:500'],
            'uploaded_at'  => ['nullable', 'date'],
        ]);

        $linked = PatientList::query()
            ->where('doctor_id', $profile->id)
            ->where('patient_id', $validated['patient_id'])
            ->exists();

        if (! $linked) {
            return response()->json([
                'success' => false,
                'message' => 'Patient is not on your list.',
                'data'    => null,
            ], 403);
        }

        $record = RadiologyImaging::create([
            'patient_id'   => $validated['patient_id'],
            'imaging_type' => $validated['imaging_type'],
            'description'  => $validated['description'] ?? null,
            'file_url'     => $validated['file_url'] ?? null,
            'uploaded_at'  => $validated['uploaded_at'] ?? now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Radiology imaging recorded.',
            'data'    => ['radiology_imaging' => $record->load('patient')],
        ], 201);
    }
}
