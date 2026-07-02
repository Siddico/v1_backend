<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\PatientList;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppointmentController extends Controller
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

        $appointments = $profile->appointments()
            ->with('doctor')
            ->orderByDesc('appointment_date')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Appointments retrieved.',
            'data'    => ['appointments' => $appointments],
        ]);
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $appointment = Appointment::query()
            ->where('id', $id)
            ->where('patient_id', $profile->id)
            ->with('doctor')
            ->first();

        if (! $appointment) {
            return response()->json([
                'success' => false,
                'message' => 'Appointment not found.',
                'data'    => null,
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Appointment retrieved.',
            'data'    => ['appointment' => $appointment],
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
            'doctor_id'        => ['required', 'integer', 'exists:doctor_profiles,id'],
            'appointment_date' => ['required', 'date', 'after:now'],
            'specialty'        => ['nullable', 'string', 'max:255'],
            'notes'            => ['nullable', 'string'],
        ]);

        $linked = PatientList::query()
            ->where('patient_id', $profile->id)
            ->where('doctor_id', $validated['doctor_id'])
            ->exists();

        if (! $linked) {
            return response()->json([
                'success' => false,
                'message' => 'Doctor is not on your list.',
                'data'    => null,
            ], 403);
        }

        $appointment = Appointment::create([
            'patient_id'       => $profile->id,
            'doctor_id'        => $validated['doctor_id'],
            'appointment_date' => $validated['appointment_date'],
            'specialty'        => $validated['specialty'] ?? null,
            'notes'            => $validated['notes'] ?? null,
            'status'           => 'upcoming',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Appointment created.',
            'data'    => ['appointment' => $appointment->load('doctor')],
        ], 201);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $appointment = Appointment::query()
            ->where('id', $id)
            ->where('patient_id', $profile->id)
            ->where('status', 'upcoming')
            ->first();

        if (! $appointment) {
            return response()->json([
                'success' => false,
                'message' => 'Upcoming appointment not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'status' => ['required', 'in:cancelled'],
        ]);

        $appointment->update(['status' => $validated['status']]);

        return response()->json([
            'success' => true,
            'message' => 'Appointment cancelled.',
            'data'    => ['appointment' => $appointment->fresh()->load('doctor')],
        ]);
    }
}
