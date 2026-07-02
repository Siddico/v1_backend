<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PatientProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Patient profile retrieved.',
            'data'    => [
                'profile'         => $profile,
                'patient_profile' => $profile,
                'image_url'       => $profile->image
                    ? asset('storage/' . $profile->image)
                    : null,
            ],
        ]);
    }

    public function update(Request $request): JsonResponse
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
            'full_name'        => ['sometimes', 'string', 'max:255'],
            'age'              => ['sometimes', 'numeric', 'min:0', 'max:150'],
            'weight'           => ['nullable', 'numeric'],
            'medical_history'  => ['nullable', 'string'],
            'medical_history_summary' => ['nullable', 'string'],
            'emergency_number' => ['nullable', 'string', 'max:20'],
            'emergency_contact_phone' => ['nullable', 'string', 'max:20'],
            'phone'            => ['nullable', 'string', 'max:20'],
            'gender'           => ['nullable', 'in:male,female'],
            'image'            => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
            'height'               => ['nullable', 'numeric', 'min:0', 'max:300'],
            'bmi'                  => ['nullable', 'numeric', 'min:0', 'max:100'],
            'blood_type'           => ['nullable', 'string', 'in:A+,A-,B+,B-,AB+,AB-,O+,O-'],
            'allergies'            => ['nullable', 'string'],
            'current_medications'  => ['nullable', 'string'],
            'residence_type'       => ['nullable', 'in:urban,rural'],
            'work_type'            => ['nullable', 'in:private,self_employed,govt_job,children,never_worked'],
            'ever_married'         => ['nullable', 'boolean'],
            'smoking_status'       => ['nullable', 'in:never_smoked,formerly_smoked,smokes,unknown'],
            'hypertension'         => ['nullable', 'boolean'],
            'heart_disease'        => ['nullable', 'boolean'],
            'avg_glucose_level'    => ['nullable', 'numeric', 'min:0'],
        ]);

        if (array_key_exists('emergency_contact_phone', $validated)
            && ! array_key_exists('emergency_number', $validated)) {
            $validated['emergency_number'] = $validated['emergency_contact_phone'];
        }
        unset($validated['emergency_contact_phone']);

        if (array_key_exists('medical_history_summary', $validated)
            && ! array_key_exists('medical_history', $validated)) {
            $validated['medical_history'] = $validated['medical_history_summary'];
        }
        unset($validated['medical_history_summary']);

        if ($request->hasFile('image')) {
            if ($profile->image && ! str_starts_with($profile->image, 'http')) {
                Storage::disk('public')->delete($profile->image);
            }
            $path = $request->file('image')->store('patient_images', 'public');
            $validated['image'] = $path;
        } else {
            unset($validated['image']);
        }

        if (isset($validated['age'])) {
            $validated['age'] = (int) $validated['age'];
        }

        $profile->update($validated);

        $syncData = [];
        if (isset($validated['phone']))     $syncData['phone']     = $validated['phone'];
        if (isset($validated['gender']))    $syncData['gender']    = $validated['gender'];
        if (isset($validated['full_name'])) $syncData['full_name'] = $validated['full_name'];
        if (! empty($syncData)) {
            $request->user()->update($syncData);
        }

        $fresh = $profile->fresh();

        return response()->json([
            'success' => true,
            'message' => 'Patient profile updated.',
            'data'    => [
                'profile'   => $fresh,
                'image_url' => $fresh->image
                    ? asset('storage/' . $fresh->image)
                    : null,
            ],
        ]);
    }
}
