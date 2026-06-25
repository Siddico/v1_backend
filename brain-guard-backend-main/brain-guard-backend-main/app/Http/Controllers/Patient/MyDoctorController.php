<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\PatientList;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MyDoctorController extends Controller
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

        $query = PatientList::query()
            ->where('patient_id', $profile->id)
            ->with(['doctor', 'doctor.user']);

        // Search by full_name
        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->whereHas('doctor', function ($q) use ($search) {
                $q->where('full_name', 'like', "%{$search}%");
            });
        }

        // Filter by specialty
        if ($request->filled('specialty')) {
            $specialty = $request->input('specialty');
            $query->whereHas('doctor', function ($q) use ($specialty) {
                $q->where('specialty', $specialty);
            });
        }

        $linkedDoctors = $query->get()->map(function ($patientList) {
            $doctor = $patientList->doctor;
            return [
                'id'         => $doctor->id,
                'full_name'  => $doctor->full_name,
                'specialty'  => $doctor->specialty,
                'image_url'  => $doctor->image ? asset('storage/' . $doctor->image) : null,
                'linked_at'  => $patientList->created_at,
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Linked doctors retrieved.',
            'data'    => ['doctors' => $linkedDoctors],
        ]);
    }
}
