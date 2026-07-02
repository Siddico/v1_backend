<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\DoctorProfile;
use App\Models\PatientList;
use App\Models\QrScan;
use App\Models\RelationshipRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QrController extends Controller
{
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
            'qr_data'     => ['nullable', 'string'],
            'description' => ['nullable', 'string'],
            'scanned_at'  => ['nullable', 'date'],
        ]);

        $scan = QrScan::create([
            'user_id'     => $request->user()->id,
            'description' => $validated['qr_data'] ?? $validated['description'] ?? null,
            'scanned_at'  => $validated['scanned_at'] ?? now(),
        ]);

        $qrData = $validated['qr_data'] ?? $validated['description'] ?? '';

        if (str_starts_with($qrData, 'DOCTOR_')) {
            $doctorId = (int) substr($qrData, strlen('DOCTOR_'));

            $doctor = DoctorProfile::with('user')->find($doctorId);

            if (! $doctor) {
                return response()->json([
                    'success' => false,
                    'message' => 'Doctor not found.',
                    'data'    => null,
                ], 404);
            }

            $hasPendingRequest = RelationshipRequest::query()
                ->where('patient_id', $profile->id)
                ->where('doctor_id', $doctorId)
                ->where('status', 'pending')
                ->exists();

            $isConnected = PatientList::query()
                ->where('doctor_id', $doctorId)
                ->where('patient_id', $profile->id)
                ->exists();

            $connectionStatus = $isConnected
                ? 'connected'
                : ($hasPendingRequest ? 'pending' : 'none');

            $doctorData = [
                'id'            => $doctor->id,
                'full_name'     => $doctor->full_name,
                'specialty'     => $doctor->specialty,
                'hospital'      => $doctor->hospital,
                'rating'        => $doctor->rating,
                'working_hours' => $doctor->working_hours,
                'is_available'  => $doctor->is_available,
                'photo_url'     => $doctor->image ? asset('storage/' . $doctor->image) : null,
            ];

            return response()->json([
                'success' => true,
                'message' => 'QR scan recorded.',
                'data'    => [
                    'qr_scan'            => $scan,
                    'type'               => 'doctor',
                    'doctor'             => $doctorData,
                    'connection_status'  => $connectionStatus,
                ],
            ], 201);
        }

        $type = str_starts_with($qrData, 'PATIENT_') ? 'patient' : 'unknown';

        return response()->json([
            'success' => true,
            'message' => 'QR scan recorded.',
            'data'    => [
                'qr_scan' => $scan,
                'type'    => $type,
            ],
        ], 201);
    }
}
