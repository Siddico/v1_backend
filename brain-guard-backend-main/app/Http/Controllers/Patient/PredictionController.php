<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\DoctorAlert;
use App\Models\DoctorProfile;
use App\Models\EmergencyRecommendation;
use App\Models\PatientList;
use App\Models\PatientProfile;
use App\Models\StrokeRiskPrediction;
use App\Services\AIService;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PredictionController extends Controller
{
    public function __construct(
        protected AIService $aiService
    ) {}

    private function formatPrediction(StrokeRiskPrediction $prediction): array
    {
        $data = $prediction->toArray();

        $modelOutput = $prediction->model_output;
        $predictionClass = null;

        if (is_array($modelOutput)) {
            foreach (['class', 'predicted_class', 'label'] as $key) {
                if (isset($modelOutput[$key])) {
                    $predictionClass = $modelOutput[$key];
                    break;
                }
            }
        }

        if ($predictionClass === null) {
            $predictionClass = match ($prediction->risk_level) {
                'high'     => 'AF',
                'moderate' => 'PAC',
                default    => 'NSR',
            };
        }

        return array_merge($data, [
            'stroke_risk'           => $prediction->risk_level,
            'risk_score'            => round($prediction->score / 100, 4),
            'prediction_timestamp'  => $prediction->predicted_at,
            'user_id'               => $prediction->patient_id,
            'message'               => $prediction->overview,
            'prediction'            => $predictionClass,
        ]);
    }

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

        $predictions = $profile->strokeRiskPredictions()
            ->orderByDesc('predicted_at')
            ->get()
            ->map(fn (StrokeRiskPrediction $prediction) => $this->formatPrediction($prediction));

        return response()->json([
            'success' => true,
            'message' => 'Predictions retrieved.',
            'data'    => ['predictions' => $predictions],
        ]);
    }

    public function predict(Request $request): JsonResponse
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
            'health_data_id'         => ['nullable', 'integer', 'exists:health_data,id'],
            'predict_based_on_files' => ['nullable', 'boolean'],
            'prediction_type'        => ['nullable', 'string', 'in:AI_PPG,AI_QUESTIONNAIRE'],
        ]);

        $healthDataId = $validated['health_data_id'] ?? null;

        if ($healthDataId !== null) {
            $owns = $profile->healthData()->where('id', $healthDataId)->exists();
            if (! $owns) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid health data for this patient.',
                    'data'    => null,
                ], 422);
            }
        }

        $latestSignal = $profile->ecgPpgSignals()->latest()->first();
        $signalData   = $latestSignal?->raw_data ?? [];

        $ai = $this->aiService->predict($profile->id, $healthDataId, $signalData);

        $prediction = DB::transaction(function () use ($profile, $healthDataId, $ai, $validated) {
            $prediction = StrokeRiskPrediction::create([
                'patient_id'             => $profile->id,
                'health_data_id'         => $healthDataId,
                'score'                  => $ai['score'],
                'confidence'             => $ai['confidence'] ?? null,
                'risk_level'             => $ai['risk_level'],
                'overview'               => $ai['overview'],
                'predict_based_on_files' => $validated['predict_based_on_files'] ?? false,
                'model_version'          => $ai['model_version'],
                'prediction_type'        => $validated['prediction_type'] ?? 'AI_PPG',
                'probabilities'          => $ai['probabilities'] ?? null,
                'recommendations'        => $ai['recommendations'] ?? null,
                'status'                 => 'completed',
                'predicted_at'           => now(),
            ]);

            $profile->update([
                'ai_risk_stroke_rate'  => $prediction->score,
                'last_prediction_time' => now(),
                'status'               => match ($prediction->risk_level) {
                    'high'     => 'critical',
                    'moderate' => 'at_risk',
                    default    => 'normal',
                },
            ]);

            if ($ai['risk_level'] === 'high') {
                static::runHighRiskSideEffects($profile, $prediction, $ai['overview'] ?? '');
            }

            return $prediction;
        });

        return response()->json([
            'success' => true,
            'message' => 'Prediction completed.',
            'data'    => ['prediction' => $this->formatPrediction($prediction)],
        ]);
    }

    public static function runHighRiskSideEffects(
        PatientProfile $profile,
        StrokeRiskPrediction $prediction,
        string $overview
    ): void {
        $advice = $overview !== ''
            ? $overview
            : 'High stroke risk detected. Seek immediate medical attention.';

        EmergencyRecommendation::create([
            'patient_id'    => $profile->id,
            'prediction_id' => $prediction->id,
            'advice_text'   => $advice,
        ]);

        $notificationService = new NotificationService();
        $patientUser         = $profile->user;

        if ($patientUser) {
            $notificationService->notify(
                $patientUser,
                'High stroke risk alert',
                $advice,
                [
                    'type'          => 'high_risk_prediction',
                    'prediction_id' => (string) $prediction->id,
                    'risk_level'    => 'high',
                ]
            );
        }

        $doctorIds = PatientList::query()
            ->where('patient_id', $profile->id)
            ->pluck('doctor_id')
            ->unique();

        foreach ($doctorIds as $doctorId) {
            DoctorAlert::create([
                'doctor_id'     => $doctorId,
                'patient_id'    => $profile->id,
                'prediction_id' => $prediction->id,
                'risk_level'    => 'high',
                'alert_time'    => now(),
                'is_read'       => false,
            ]);

            $doctorProfile = DoctorProfile::find($doctorId);
            $doctorUser    = $doctorProfile?->user;

            if ($doctorUser) {
                $notificationService->notify(
                    $doctorUser,
                    'High risk patient alert',
                    "Patient {$profile->full_name} has a high stroke risk prediction.",
                    [
                        'type'          => 'doctor_high_risk_alert',
                        'patient_name'  => $profile->full_name,
                        'prediction_id' => (string) $prediction->id,
                    ]
                );
            }
        }
    }
}
