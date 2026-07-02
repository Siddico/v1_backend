<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\MedicalData;
use App\Models\PatientList;
use App\Models\PatientProfile;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MedicalDataController extends Controller
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

        $records = MedicalData::query()
            ->where('doctor_id', $profile->id)
            ->whereIn('patient_id', $patientIds)
            ->with('patient')
            ->orderByDesc('updated_at')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Medical data retrieved.',
            'data'    => ['medical_data' => $records],
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
            'patient_id'          => ['required', 'integer', 'exists:patient_profiles,id'],
            'diagnosis'           => ['nullable', 'string'],
            'treatment_plan'      => ['nullable', 'string'],
            'notes'               => ['nullable', 'string'],
            'doctor_notes'        => ['nullable', 'string'],
            'heart_rate'          => ['nullable', 'numeric'],
            'blood_pressure'      => ['nullable', 'string', 'max:20'],
            'blood_glucose'       => ['nullable', 'numeric'],
            'cholesterol'         => ['nullable', 'numeric'],
            'last_ecg_ppg_upload' => ['nullable', 'date'],
            'hrv'                 => ['nullable', 'numeric'],
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

        // Accept notes or doctor_notes
        $doctorNotes = $validated['doctor_notes'] ?? $validated['notes'] ?? null;

        $now    = now();
        $record = MedicalData::create([
            'patient_id'          => $validated['patient_id'],
            'doctor_id'           => $profile->id,
            'diagnosis'           => $validated['diagnosis'] ?? null,
            'treatment_plan'      => $validated['treatment_plan'] ?? null,
            'heart_rate'          => $validated['heart_rate'] ?? null,
            'blood_pressure'      => $validated['blood_pressure'] ?? null,
            'blood_glucose'       => $validated['blood_glucose'] ?? null,
            'cholesterol'         => $validated['cholesterol'] ?? null,
            'last_ecg_ppg_upload' => $validated['last_ecg_ppg_upload'] ?? null,
            'doctor_notes'        => $doctorNotes,
            'hrv'                 => $validated['hrv'] ?? null,
            'created_at'          => $now,
            'updated_at'          => $now,
        ]);

        // Notify patient
        $patientProfile = PatientProfile::find($validated['patient_id']);
        $patientUser    = $patientProfile?->user;

        if ($patientUser) {
            $notificationService = new NotificationService();
            $notificationService->notify(
                $patientUser,
                'New medical record added',
                'Your doctor added a new medical record to your file.',
                [
                    'type'           => 'medical_data',
                    'medical_data_id'=> (string) $record->id,
                ]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Medical data created.',
            'data'    => ['medical_data' => $record->load('patient')],
        ], 201);
    }
}
