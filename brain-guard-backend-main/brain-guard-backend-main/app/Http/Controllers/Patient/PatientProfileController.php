<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PatientProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();
        $profile = $user->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $qrCodeData = json_encode([
            'uuid' => $user->uuid,
            'role' => 'patient'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Patient profile retrieved.',
            'data'    => [
                'profile'      => $profile,
                'image_url'    => $profile->image, // Since we store Cloudinary URL directly
                'date_of_birth'=> $user->date_of_birth,
                'qr_code_data' => $qrCodeData,
            ],
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $user = $request->user();
        $profile = $user->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'full_name'        => ['sometimes', 'string', 'max:255'],
            'age'              => ['sometimes', 'numeric', 'min:0', 'max:150'],
            'date_of_birth'    => ['sometimes', 'date'],
            'weight'           => ['nullable', 'numeric'],
            'medical_history'  => ['nullable', 'string'],
            'emergency_number' => ['nullable', 'string', 'max:20'],
            'phone'            => ['nullable', 'string', 'max:20'],
            'gender'           => ['nullable', 'in:male,female'],
            'image_url'        => ['nullable', 'url'], // Accept Cloudinary URL
            'height'           => ['nullable', 'numeric', 'min:0', 'max:300'],
            'bmi'              => ['nullable', 'numeric', 'min:0', 'max:100'],
            'blood_type'       => ['nullable', 'string', 'in:A+,A-,B+,B-,AB+,AB-,O+,O-'],
            'allergies'        => ['nullable', 'string'],
            'current_medications' => ['nullable', 'string'],
            'residence_type'   => ['nullable', 'in:urban,rural'],
            'work_type'        => ['nullable', 'in:private,self_employed,govt_job,children,never_worked'],
            'ever_married'     => ['nullable', 'boolean'],
            'smoking_status'   => ['nullable', 'in:never_smoked,formerly_smoked,smokes,unknown'],
            'hypertension'     => ['nullable', 'boolean'],
            'heart_disease'    => ['nullable', 'boolean'],
            'avg_glucose_level'=> ['nullable', 'numeric', 'min:0'],
        ]);

        if (array_key_exists('image_url', $validated)) {
            $validated['image'] = $validated['image_url'];
            unset($validated['image_url']);
        }

        if (isset($validated['age'])) {
            $validated['age'] = (int) $validated['age'];
        }

        $profile->update($validated);

        $syncData = [];
        if (isset($validated['phone']))         $syncData['phone']         = $validated['phone'];
        if (isset($validated['gender']))        $syncData['gender']        = $validated['gender'];
        if (isset($validated['full_name']))     $syncData['full_name']     = $validated['full_name'];
        if (isset($validated['date_of_birth'])) $syncData['date_of_birth'] = $validated['date_of_birth'];
        
        if (! empty($syncData)) {
            $user->update($syncData);
        }

        $fresh = $profile->fresh();
        $qrCodeData = json_encode([
            'uuid' => $user->uuid,
            'role' => 'patient'
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Patient profile updated.',
            'data'    => [
                'profile'      => $fresh,
                'image_url'    => $fresh->image,
                'date_of_birth'=> $user->date_of_birth,
                'qr_code_data' => $qrCodeData,
            ],
        ]);
    }
}
