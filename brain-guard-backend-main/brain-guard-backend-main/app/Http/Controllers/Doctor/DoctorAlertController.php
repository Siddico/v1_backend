<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\DoctorAlert;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DoctorAlertController extends Controller
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

        $alerts = $profile->doctorAlerts()
            ->with(['patient', 'prediction'])
            ->orderByDesc('alert_time')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Alerts retrieved.',
            'data'    => ['alerts' => $alerts],
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

        $alert = DoctorAlert::query()
            ->where('id', $id)
            ->where('doctor_id', $profile->id)
            ->first();

        if (! $alert) {
            return response()->json([
                'success' => false,
                'message' => 'Alert not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'is_read' => ['sometimes', 'boolean'],
            'status'  => ['sometimes', 'boolean'],
        ]);

        // قبول is_read أو status — الاتنين بيعملوا نفس الحاجة
        $isRead = $validated['is_read'] ?? $validated['status'] ?? true;

        $alert->update([
            'is_read' => $isRead,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Alert marked as read.',
            'data'    => ['alert' => $alert->fresh()],
        ]);
    }
}
