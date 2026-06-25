<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\RelationshipRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RelationshipRequestController extends Controller
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

        $requests = $profile->relationshipRequests()
            ->with('doctor')
            ->orderByDesc('requested_at')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Relationship requests retrieved.',
            'data'    => ['relationship_requests' => $requests],
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
            'doctor_id' => ['required', 'integer', 'exists:doctor_profiles,id'],
            'message'   => ['nullable', 'string'],
        ]);

        $pendingExists = RelationshipRequest::query()
            ->where('patient_id', $profile->id)
            ->where('doctor_id', $validated['doctor_id'])
            ->where('status', 'pending')
            ->exists();

        if ($pendingExists) {
            return response()->json([
                'success' => false,
                'message' => 'A pending request already exists for this doctor.',
                'data'    => null,
            ], 422);
        }

        $relationshipRequest = RelationshipRequest::create([
            'patient_id'   => $profile->id,
            'doctor_id'    => $validated['doctor_id'],
            'message'      => $validated['message'] ?? null,
            'status'       => 'pending',
            'requested_at' => now(),
        ]);

        $doctorProfile = \App\Models\DoctorProfile::find($validated['doctor_id']);
        if ($doctorProfile && $doctorProfile->user) {
            $notificationService = new \App\Services\NotificationService();
            $notificationService->notify(
                $doctorProfile->user,
                'New Connection Request',
                "Patient {$profile->full_name} has sent you a connection request.",
                ['type' => 'relationship_request', 'request_id' => (string) $relationshipRequest->id]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Relationship request sent.',
            'data'    => ['relationship_request' => $relationshipRequest->load('doctor')],
        ], 201);
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

        $relationshipRequest = RelationshipRequest::query()
            ->where('id', $id)
            ->where('patient_id', $profile->id)
            ->where('status', 'pending')
            ->first();

        if (! $relationshipRequest) {
            return response()->json([
                'success' => false,
                'message' => 'Pending relationship request not found.',
                'data'    => null,
            ], 404);
        }

        $relationshipRequest->delete();

        return response()->json([
            'success' => true,
            'message' => 'Relationship request cancelled.',
            'data'    => null,
        ]);
    }
}
