<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\DoctorFollowUp;
use App\Models\PatientList;
use App\Models\PatientProfile;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FollowUpController extends Controller
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

        $items = $profile->followUps()
            ->with('patient')
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Follow-ups retrieved.',
            'data'    => ['follow_ups' => $items],
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
            'patient_id'      => ['required', 'integer', 'exists:patient_profiles,id'],
            'suggestion_text' => ['sometimes', 'string'],
            'notes'           => ['sometimes', 'string'],
            'description'     => ['nullable', 'string'],
            'next_visit'      => ['nullable', 'date'],
            'follow_up_type'  => ['nullable', 'string', 'max:50'],
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

        // Accept notes or suggestion_text
        $suggestionText = $validated['suggestion_text'] ?? $validated['notes'] ?? null;

        if (! $suggestionText) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed.',
                'errors'  => ['suggestion_text' => ['The suggestion text or notes field is required.']],
                'data'    => null,
            ], 422);
        }

        $followUp = DoctorFollowUp::create([
            'doctor_id'       => $profile->id,
            'patient_id'      => $validated['patient_id'],
            'suggestion_text' => $suggestionText,
            'description'     => $validated['description'] ?? null,
            'next_visit'      => $validated['next_visit'] ?? null,
            'follow_up_type'  => $validated['follow_up_type'] ?? null,
            'status'          => 'pending',
        ]);

        // Notify patient
        $patientProfile = PatientProfile::find($validated['patient_id']);
        $patientUser    = $patientProfile?->user;

        if ($patientUser) {
            $doctorName          = $profile->full_name ?? 'Your doctor';
            $notificationService = new NotificationService();
            $notificationService->notify(
                $patientUser,
                'New follow-up from your doctor',
                "{$doctorName}: {$suggestionText}",
                [
                    'type'        => 'follow_up',
                    'follow_up_id'=> (string) $followUp->id,
                ]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Follow-up created.',
            'data'    => ['follow_up' => $followUp->load('patient')],
        ], 201);
    }
}
