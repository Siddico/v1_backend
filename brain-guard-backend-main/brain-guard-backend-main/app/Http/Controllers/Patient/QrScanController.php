<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QrScanController extends Controller
{
    public function verifyDoctor(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'uuid' => ['required', 'string'],
            'role' => ['required', 'string', 'in:doctor'],
        ]);

        $doctorUser = User::where('uuid', $validated['uuid'])
            ->where('role', 'doctor')
            ->first();

        if (! $doctorUser || ! $doctorUser->doctorProfile) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid QR Code. Doctor not found.',
                'data'    => null,
            ], 404);
        }

        $doctorProfile = $doctorUser->doctorProfile;

        return response()->json([
            'success' => true,
            'message' => 'Doctor verified successfully.',
            'data'    => [
                'doctor' => [
                    'id'        => $doctorProfile->id,
                    'full_name' => $doctorProfile->full_name,
                    'specialty' => $doctorProfile->specialty,
                    'image_url' => $doctorProfile->image ? asset('storage/' . $doctorProfile->image) : null,
                ]
            ],
        ]);
    }
}
