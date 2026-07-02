<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\PatientList;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PatientListController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $profile = $request->user()->doctorProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Doctor profile not found.',
                'data' => null,
            ], 404);
        }

        $entries = $profile->patientListEntries()
            ->with('patient')
            ->orderByDesc('updated_at')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Patient list retrieved.',
            'data' => ['patients' => $entries],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $profile = $request->user()->doctorProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Doctor profile not found.',
                'data' => null,
            ], 404);
        }

        $validated = $request->validate([
            'patient_id' => ['required', 'integer', 'exists:patient_profiles,id'],
        ]);

        $exists = PatientList::query()
            ->where('doctor_id', $profile->id)
            ->where('patient_id', $validated['patient_id'])
            ->exists();

        if ($exists) {
            return response()->json([
                'success' => false,
                'message' => 'Patient is already on your list.',
                'data' => null,
            ], 422);
        }

        $entry = PatientList::create([
            'doctor_id' => $profile->id,
            'patient_id' => $validated['patient_id'],
            'status' => 'active',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Patient added to list.',
            'data' => ['patient_list' => $entry->load('patient')],
        ], 201);
    }
}
