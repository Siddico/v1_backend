<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\RadiologyUpload;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RadiologyController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data' => null,
            ], 404);
        }

        $validated = $request->validate([
            'upload_type' => ['required', 'in:xray,mri,ct,other'],
            'description' => ['nullable', 'string'],
            'file_url' => ['required', 'string', 'max:255'],
            'uploaded_at' => ['nullable', 'date'],
        ]);

        $upload = RadiologyUpload::create([
            'patient_id' => $profile->id,
            'upload_type' => $validated['upload_type'],
            'description' => $validated['description'] ?? null,
            'file_url' => $validated['file_url'],
            'uploaded_at' => isset($validated['uploaded_at']) ? $validated['uploaded_at'] : now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Radiology upload recorded.',
            'data' => ['radiology_upload' => $upload],
        ], 201);
    }
}
