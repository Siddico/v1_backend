<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\PatientList;
use App\Models\PatientProfile;
use App\Models\RelationshipRequest;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RelationshipRequestController extends Controller
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

        $requests = $profile->relationshipRequests()
            ->where('status', 'pending')
            ->with('patient')
            ->orderByDesc('requested_at')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Pending relationship requests retrieved.',
            'data'    => ['relationship_requests' => $requests],
        ]);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $profile = $request->user()->doctorProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Doctor profile not found.',
                'data'    => null,
            ], 404);
        }

        $relationshipRequest = RelationshipRequest::query()
            ->where('id', $id)
            ->where('doctor_id', $profile->id)
            ->where('status', 'pending')
            ->first();

        if (! $relationshipRequest) {
            return response()->json([
                'success' => false,
                'message' => 'Pending relationship request not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'status' => ['required', 'in:accepted,rejected'],
        ]);

        $relationshipRequest->update([
            'status'       => $validated['status'],
            'responded_at' => now(),
        ]);

        if ($validated['status'] === 'accepted') {
            $exists = PatientList::query()
                ->where('doctor_id', $profile->id)
                ->where('patient_id', $relationshipRequest->patient_id)
                ->exists();

            if (! $exists) {
                PatientList::create([
                    'doctor_id'  => $profile->id,
                    'patient_id' => $relationshipRequest->patient_id,
                    'status'     => 'active',
                ]);
            }

            $patientProfile = PatientProfile::find($relationshipRequest->patient_id);
            $patientUser    = $patientProfile?->user;

            if ($patientUser) {
                $doctorName          = $profile->full_name ?? 'Your doctor';
                $notificationService = new NotificationService();
                $notificationService->notify(
                    $patientUser,
                    'Doctor request accepted',
                    "{$doctorName} has accepted your connection request.",
                    [
                        'type'      => 'relationship_accepted',
                        'doctor_id' => (string) $profile->id,
                    ]
                );
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Relationship request updated.',
            'data'    => ['relationship_request' => $relationshipRequest->fresh()->load('patient')],
        ]);
    }
}
