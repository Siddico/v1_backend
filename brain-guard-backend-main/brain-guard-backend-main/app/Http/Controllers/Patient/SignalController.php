<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\EcgPpgSignal;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SignalController extends Controller
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

        $signals = $profile->ecgPpgSignals()->orderByDesc('uploaded_at')->get();

        return response()->json([
            'success' => true,
            'message' => 'Signals retrieved.',
            'data' => ['signals' => $signals],
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
            'signal_type' => ['required', 'in:ECG,PPG,IMU,SpO2,BP'],
            'raw_data' => ['nullable', 'array'],
            'source' => ['nullable', 'in:upload,wearable'],
            'file_url' => ['nullable', 'string', 'max:255'],
            'uploaded_at' => ['nullable', 'date'],
        ]);

        $signal = EcgPpgSignal::create([
            'patient_id' => $profile->id,
            'signal_type' => $validated['signal_type'],
            'raw_data' => $validated['raw_data'] ?? null,
            'source' => $validated['source'] ?? 'upload',
            'file_url' => $validated['file_url'] ?? null,
            'uploaded_at' => isset($validated['uploaded_at'])
                ? $validated['uploaded_at']
                : now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Signal stored.',
            'data' => ['signal' => $signal],
        ], 201);
    }
}
