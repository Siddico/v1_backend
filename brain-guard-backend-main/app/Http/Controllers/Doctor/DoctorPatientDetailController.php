<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\PatientList;
use App\Models\PatientProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DoctorPatientDetailController extends Controller
{
    public function show(Request $request, int $id): JsonResponse
    {
        $profile = $request->user()->doctorProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Doctor profile not found.',
                'data'    => null,
            ], 404);
        }

        $isLinked = PatientList::query()
            ->where('doctor_id', $profile->id)
            ->where('patient_id', $id)
            ->exists();

        if (! $isLinked) {
            return response()->json([
                'success' => false,
                'message' => 'Patient is not on your list.',
                'data'    => null,
            ], 403);
        }

        $patient = PatientProfile::with('user')->find($id);

        if (! $patient) {
            return response()->json([
                'success' => false,
                'message' => 'Patient not found.',
                'data'    => null,
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Patient profile retrieved.',
            'data'    => [
                'patient' => [
                    'id'                      => $patient->id,
                    'user_id'                 => $patient->user_id,
                    'full_name'               => $patient->full_name,
                    'age'                     => $patient->age,
                    'weight'                  => $patient->weight,
                    'height'                  => $patient->height,
                    'bmi'                     => $patient->bmi,
                    'blood_type'              => $patient->blood_type,
                    'allergies'               => $patient->allergies,
                    'current_medications'     => $patient->current_medications,
                    'medical_history'         => $patient->medical_history,
                    'medical_history_summary' => $patient->medical_history,
                    'emergency_number'        => $patient->emergency_number,
                    'emergency_contact_phone' => $patient->emergency_number,
                    'phone'                   => $patient->phone,
                    'gender'                  => $patient->gender,
                    'hypertension'            => $patient->hypertension,
                    'heart_disease'           => $patient->heart_disease,
                    'smoking_status'          => $patient->smoking_status,
                    'work_type'               => $patient->work_type,
                    'residence_type'          => $patient->residence_type,
                    'ever_married'            => $patient->ever_married,
                    'avg_glucose_level'       => $patient->avg_glucose_level,
                    'ai_risk_stroke_rate'     => $patient->ai_risk_stroke_rate,
                    'status'                  => $patient->status,
                    'last_prediction_time'    => $patient->last_prediction_time,
                    'image'                   => $patient->image,
                    'photo_url'               => $patient->image ? asset('storage/' . $patient->image) : null,
                    'email'                   => $patient->user?->email,
                    'user'                    => [
                        'id'        => $patient->user?->id,
                        'email'     => $patient->user?->email,
                        'full_name' => $patient->user?->full_name,
                        'phone'     => $patient->user?->phone,
                    ],
                ],
            ],
        ]);
    }
}
