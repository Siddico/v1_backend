<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\StrokeRiskPrediction;
use App\Services\AIService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QuestionnaireController extends Controller
{
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
            'stroke_risk'          => $prediction->risk_level,
            'risk_score'           => round($prediction->score / 100, 4),
            'prediction_timestamp' => $prediction->predicted_at,
            'user_id'              => $prediction->patient_id,
            'message'              => $prediction->overview,
            'prediction'           => $predictionClass,
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
            'age'                 => ['required', 'integer', 'min:0', 'max:120'],
            'gender'              => ['required', 'string', 'in:Male,Female,male,female'],
            'chest_pain'          => ['required', 'integer', 'in:0,1'],
            'high_blood_pressure' => ['required', 'integer', 'in:0,1'],
            'irregular_heartbeat' => ['required', 'integer', 'in:0,1'],
            'shortness_of_breath' => ['required', 'integer', 'in:0,1'],
            'fatigue_weakness'    => ['required', 'integer', 'in:0,1'],
            'dizziness'           => ['required', 'integer', 'in:0,1'],
            'swelling_edema'      => ['required', 'integer', 'in:0,1'],
            'neck_jaw_pain'       => ['required', 'integer', 'in:0,1'],
            'excessive_sweating'  => ['required', 'integer', 'in:0,1'],
            'persistent_cough'    => ['required', 'integer', 'in:0,1'],
            'nausea_vomiting'     => ['required', 'integer', 'in:0,1'],
            'chest_discomfort'    => ['required', 'integer', 'in:0,1'],
            'cold_hands_feet'     => ['required', 'integer', 'in:0,1'],
            'snoring_sleep_apnea' => ['required', 'integer', 'in:0,1'],
            'anxiety_doom'        => ['required', 'integer', 'in:0,1'],
        ]);

        $symptoms = $validated;
        $symptoms['gender'] = ucfirst(strtolower($validated['gender']));

        $ai = app(AIService::class)->predictFromQuestionnaire($symptoms);

        $prediction = StrokeRiskPrediction::create([
            'patient_id'             => $profile->id,
            'health_data_id'         => null,
            'score'                  => $ai['score'],
            'confidence'             => $ai['confidence'] ?? null,
            'risk_level'             => $ai['risk_level'],
            'overview'               => $ai['overview'],
            'predict_based_on_files' => false,
            'model_version'          => $ai['model_version'],
            'prediction_type'        => 'AI_QUESTIONNAIRE',
            'probabilities'          => null,
            'recommendations'        => null,
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

        if ($prediction->risk_level === 'high') {
            PredictionController::runHighRiskSideEffects($profile, $prediction, $ai['overview'] ?? '');
        }

        return response()->json([
            'success' => true,
            'message' => 'Prediction completed.',
            'data'    => ['prediction' => $this->formatPrediction($prediction)],
        ]);
    }
}
