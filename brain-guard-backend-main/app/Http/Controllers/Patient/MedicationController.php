<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\Medication;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MedicationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $medications = $profile->medications()
            ->where('is_active', true)
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Medications retrieved.',
            'data'    => ['medications' => $medications],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'name'          => ['required', 'string', 'max:255'],
            'dosage'        => ['nullable', 'string', 'max:100'],
            'frequency'     => ['nullable', 'string', 'max:100'],
            'reminder_time' => ['nullable', 'date_format:H:i'],
            'image_url'     => ['nullable', 'string', 'max:500'],
        ]);

        $medication = Medication::create([
            'patient_id'    => $profile->id,
            'name'          => $validated['name'],
            'dosage'        => $validated['dosage'] ?? null,
            'frequency'     => $validated['frequency'] ?? null,
            'reminder_time' => $validated['reminder_time'] ?? null,
            'image_url'     => $validated['image_url'] ?? null,
            'is_active'     => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Medication added.',
            'data'    => ['medication' => $medication],
        ], 201);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $medication = Medication::query()
            ->where('id', $id)
            ->where('patient_id', $profile->id)
            ->first();

        if (! $medication) {
            return response()->json([
                'success' => false,
                'message' => 'Medication not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'name'          => ['sometimes', 'string', 'max:255'],
            'dosage'        => ['nullable', 'string', 'max:100'],
            'frequency'     => ['nullable', 'string', 'max:100'],
            'reminder_time' => ['nullable', 'date_format:H:i'],
            'image_url'     => ['nullable', 'string', 'max:500'],
            'is_active'     => ['nullable', 'boolean'],
        ]);

        $medication->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Medication updated.',
            'data'    => ['medication' => $medication->fresh()],
        ]);
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $medication = Medication::query()
            ->where('id', $id)
            ->where('patient_id', $profile->id)
            ->first();

        if (! $medication) {
            return response()->json([
                'success' => false,
                'message' => 'Medication not found.',
                'data'    => null,
            ], 404);
        }

        $medication->update(['is_active' => false]);

        return response()->json([
            'success' => true,
            'message' => 'Medication deactivated.',
            'data'    => null,
        ]);
    }
}
