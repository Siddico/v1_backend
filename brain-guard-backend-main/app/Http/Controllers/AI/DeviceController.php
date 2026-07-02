<?php

namespace App\Http\Controllers\AI;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Patient\PredictionController;
use App\Models\EcgPpgSignal;
use App\Models\HealthData;
use App\Models\PatientList;
use App\Models\PatientProfile;
use App\Models\StrokeRiskPrediction;
use App\Services\AIService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DeviceController extends Controller
{
    public function __construct(
        protected AIService $aiService
    ) {}

    public function ingest(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'patient_id'   => ['required', 'integer', 'exists:patient_profiles,id'],
            'signal_type'  => ['required', 'in:ECG,PPG,IMU,SpO2,BP'],
            'raw_data'     => ['nullable', 'array'],
            'heart_rate'   => ['nullable', 'numeric'],
            'spo2_level'   => ['nullable', 'numeric'],
            'blood_pressure'=> ['nullable', 'string', 'max:20'],
        ]);

        $patient = PatientProfile::query()->findOrFail($validated['patient_id']);

        $authUser = $request->user();
        $roleName = optional($authUser->role)->name_of_role;

        if ($roleName === 'patient') {
            $ownProfile = $authUser->patientProfile;
            if ($ownProfile === null || $ownProfile->id !== $patient->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'You can only submit data for your own profile.',
                    'data'    => null,
                ], 403);
            }
        } elseif ($roleName === 'doctor') {
            $doctorProfile = $authUser->doctorProfile;
            $linked = PatientList::where('doctor_id', $doctorProfile?->id)
                ->where('patient_id', $patient->id)
                ->exists();
            if (! $linked) {
                return response()->json([
                    'success' => false,
                    'message' => 'Patient is not on your list.',
                    'data'    => null,
                ], 403);
            }
        } elseif ($roleName === 'researcher') {
            return response()->json([
                'success' => false,
                'message' => 'You are not authorized to submit device data.',
                'data'    => null,
            ], 403);
        }

        $signal = EcgPpgSignal::create([
            'patient_id'  => $patient->id,
            'signal_type' => $validated['signal_type'],
            'raw_data'    => $validated['raw_data'] ?? null,
            'source'      => 'wearable',
            'uploaded_at' => now(),
        ]);

        $healthDataId = null;
        if (
            array_key_exists('heart_rate', $validated)
            || array_key_exists('spo2_level', $validated)
            || array_key_exists('blood_pressure', $validated)
        ) {
            $health = HealthData::create([
                'patient_id'   => $patient->id,
                'heart_rate'   => $validated['heart_rate'] ?? null,
                'spo2_level'   => $validated['spo2_level'] ?? null,
                'blood_pressure'=> $validated['blood_pressure'] ?? null,
                'recorded_at'  => now(),
            ]);
            $healthDataId = $health->id;
        }

        $ai = $this->aiService->predict($patient->id, $healthDataId, $validated['raw_data'] ?? []);

        $prediction = DB::transaction(function () use ($patient, $healthDataId, $ai) {
            $prediction = StrokeRiskPrediction::create([
                'patient_id'             => $patient->id,
                'health_data_id'         => $healthDataId,
                'score'                  => $ai['score'],
                'confidence'             => $ai['confidence'] ?? null,
                'risk_level'             => $ai['risk_level'],
                'overview'               => $ai['overview'],
                'predict_based_on_files' => false,
                'model_version'          => $ai['model_version'],
                'predicted_at'           => now(),
            ]);

            $patient->update([
                'ai_risk_stroke_rate'  => $prediction->score,
                'last_prediction_time' => now(),
                'status'               => match ($prediction->risk_level) {
                    'high'     => 'critical',
                    'moderate' => 'at_risk',
                    default    => 'normal',
                },
            ]);

            if ($ai['risk_level'] === 'high') {
                PredictionController::runHighRiskSideEffects($patient, $prediction, $ai['overview'] ?? '');
            }

            return $prediction;
        });

        return response()->json([
            'success' => true,
            'message' => 'Data received and processed.',
            'data'    => [
                'signal_id'           => $signal->id,
                'health_data_id'      => $healthDataId,
                'prediction_id'       => $prediction->id,
                'prediction_triggered'=> true,
            ],
        ], 201);
    }
}
