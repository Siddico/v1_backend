<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\PatientList;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppointmentController extends Controller
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

        $appointments = Appointment::query()
            ->where('doctor_id', $profile->id)
            ->whereIn('patient_id', $patientIds)
            ->with('patient')
            ->orderByDesc('appointment_date')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Appointments retrieved.',
            'data'    => ['appointments' => $appointments],
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

        $appointment = Appointment::query()
            ->where('id', $id)
            ->where('doctor_id', $profile->id)
            ->first();

        if (! $appointment) {
            return response()->json([
                'success' => false,
                'message' => 'Appointment not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'status' => ['required', 'in:upcoming,completed,cancelled'],
        ]);

        $appointment->update(['status' => $validated['status']]);

        return response()->json([
            'success' => true,
            'message' => 'Appointment updated.',
            'data'    => ['appointment' => $appointment->fresh()->load('patient')],
        ]);
    }
}
