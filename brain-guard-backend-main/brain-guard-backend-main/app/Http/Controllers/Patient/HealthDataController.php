<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\HealthData;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HealthDataController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data' => null,
            ], 404);
        }

        $items = $profile->healthData()->orderByDesc('recorded_at')->get();

        return response()->json([
            'success' => true,
            'message' => 'Health data retrieved.',
            'data' => ['health_data' => $items],
        ]);
    }

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
        'heart_rate'      => ['nullable', 'numeric', 'min:30', 'max:250'],
        'blood_pressure'  => ['nullable', 'string', 'max:20'],
        'blood_glucose'   => ['nullable', 'numeric', 'min:0', 'max:2000'],
        'cholesterol'     => ['nullable', 'numeric', 'min:0', 'max:2000'],
        'spo2_level'      => ['nullable', 'numeric', 'min:0', 'max:100'],
        'stability_index' => ['nullable', 'numeric', 'min:0', 'max:1'],
        'recorded_at'     => ['required', 'date'],
]);

        $record = HealthData::create([
            'patient_id' => $profile->id,
            ...$validated,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Health data recorded.',
            'data' => ['health_data' => $record],
        ], 201);
    }
}
