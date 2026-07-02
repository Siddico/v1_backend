<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\PatientList;
use App\Models\PatientProfile;
use App\Models\QrScan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QrScanController extends Controller
{
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
            'qr_data' => ['required', 'string', 'max:500'],
        ]);

        $qrData = $validated['qr_data'];

        // Save the scan record in the database
        QrScan::create([
            'user_id'     => $request->user()->id,
            'description' => $qrData,
            'scanned_at'  => now(),
        ]);

        if (! str_starts_with($qrData, 'PATIENT_')) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid QR code format. Expected format: PATIENT_{id}',
                'data'    => null,
            ], 422);
        }

        $patientId = (int) substr($qrData, strlen('PATIENT_'));

        $patient = PatientProfile::with('user')->find($patientId);

        if (! $patient) {
            return response()->json([
                'success' => false,
                'message' => 'Patient not found.',
                'data'    => null,
            ], 404);
        }

        $isConnected = PatientList::query()
            ->where('doctor_id', $profile->id)
            ->where('patient_id', $patientId)
            ->exists();

        $patientData = [
            'id'                   => $patient->id,
            'user_id'              => $patient->user_id,
            'full_name'            => $patient->full_name,
            'age'                  => $patient->age,
            'blood_type'           => $patient->blood_type,
            'allergies'            => $patient->allergies,
            'hypertension'         => $patient->hypertension,
            'heart_disease'        => $patient->heart_disease,
            'avg_glucose_level'    => $patient->avg_glucose_level,
            'ai_risk_stroke_rate'  => $patient->ai_risk_stroke_rate,
            'status'               => $patient->status,
            'last_prediction_time' => $patient->last_prediction_time,
            'phone'                => $patient->phone,
            'gender'               => $patient->gender,
            'medical_history'      => $patient->medical_history,
            'emergency_number'     => $patient->emergency_number,
            'photo_url'            => $patient->image ? asset('storage/' . $patient->image) : null,
            'email'                => $patient->user?->email,
        ];

        return response()->json([
            'success' => true,
            'message' => 'Patient QR scanned.',
            'data'    => [
                'type'          => 'patient',
                'patient'       => $patientData,
                'is_connected'  => $isConnected,
            ],
        ]);
    }
}
