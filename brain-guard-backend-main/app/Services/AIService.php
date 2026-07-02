<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AIService
{
    private string $baseUrl;

    private string $ehrUrl;

    public function __construct()
    {
        $this->baseUrl = config('services.ai.url', 'http://127.0.0.1:8001');
        $this->ehrUrl = config('services.ai.ehr_url', 'http://127.0.0.1:8002');
    }

    public function predict(int $patientId, ?int $healthDataId = null, array $signal = []): array
    {
        if (empty($signal)) {
            return $this->mockResponse();
        }

        try {
            $response = Http::timeout(60)->post("{$this->baseUrl}/predict", [
                'signal'     => $signal,
                'patient_id' => $patientId,
            ]);

            if ($response->successful()) {
                $body = $response->json();

                // Handle both formats: {data: {...}} or flat {...}
                $data = $body['data'] ?? $body;

                $predictionClass = $data['prediction'] ?? $data['class'] ?? null;

                $riskLevel = $predictionClass !== null
                    ? match (strtoupper(trim($predictionClass))) {
                        'AF'  => 'high',
                        'PAC' => 'moderate',
                        'NSR' => 'low',
                        default => $data['risk_level'] ?? 'low',
                    }
                    : ($data['risk_level'] ?? $data['stroke_risk'] ?? 'low');

                $score = isset($data['risk_score'])
                    ? (float) $data['risk_score']
                    : (float) ($data['score'] ?? 20.0);

                $confidence = (float) ($data['confidence'] ?? 0.0);
                if ($confidence > 1.0) {
                    $confidence = $confidence / 100.0;
                }
                $modelVersion = $data['model_version'] ?? 'attention-cnn-v1.0';
                $overview     = $data['overview']     ?? $data['message']      ?? $this->riskOverview($riskLevel);
                $prediction   = $data['prediction']   ?? $data['class']        ?? $this->riskToClass($riskLevel);
                $probabilities  = $data['probabilities']  ?? null;
                $recommendations = $data['recommendations'] ?? null;

                return [
                    'score'           => (float) $score,
                    'risk_level'      => $riskLevel,
                    'overview'        => $overview,
                    'confidence'      => $confidence,
                    'model_version'   => $modelVersion,
                    'prediction'      => $prediction,
                    'probabilities'   => $probabilities,
                    'recommendations' => $recommendations,
                ];
            }

            Log::error('AI Service error: ' . $response->status() . ' — ' . $response->body());
            return $this->mockResponse();

        } catch (\Exception $e) {
            Log::error('AI Service exception: ' . $e->getMessage());
            return $this->mockResponse();
        }
    }

    public function predictFromQuestionnaire(array $symptoms): array
    {
        if (empty($symptoms)) {
            return $this->ehrMockResponse();
        }

        try {
            $response = Http::timeout(30)->post("{$this->ehrUrl}/predict", $symptoms);

            if ($response->successful()) {
                $body = $response->json();
                $data = $body['data'] ?? $body;

                $probability = (float) ($data['stroke_risk_probability'] ?? 0.0);
                if ($probability > 1.0) {
                    $probability = $probability / 100.0;
                }
                $atRisk = (int) ($data['at_risk'] ?? 0);

                $riskLevel = $atRisk === 1
                    ? ($probability >= 0.7 ? 'high' : 'moderate')
                    : 'low';

                $score = round($probability * 100, 1);
                $overview = $this->riskOverview($riskLevel);

                return [
                    'score'           => $score,
                    'risk_level'      => $riskLevel,
                    'overview'        => $overview,
                    'confidence'      => $probability,
                    'model_version'   => 'ehr-lgbm-v1.0',
                    'prediction'      => $this->riskToClass($riskLevel),
                    'probabilities'   => null,
                    'recommendations' => null,
                ];
            }

            Log::error('EHR AI Service error: ' . $response->status() . ' — ' . $response->body());
            return $this->ehrMockResponse();

        } catch (\Exception $e) {
            Log::error('EHR AI Service exception: ' . $e->getMessage());
            return $this->ehrMockResponse();
        }
    }

    private function riskToClass(string $riskLevel): string
    {
        return match ($riskLevel) {
            'high'     => 'AF',
            'moderate' => 'PAC',
            default    => 'NSR',
        };
    }

    private function riskOverview(string $riskLevel): string
    {
        return match ($riskLevel) {
            'high'     => 'High stroke risk detected. Seek immediate medical attention.',
            'moderate' => 'Moderate stroke risk detected. Please consult your doctor.',
            default    => 'Low stroke risk. Continue maintaining a healthy lifestyle.',
        };
    }

    private function mockResponse(): array
    {
        return [
            'score'           => 45.5,
            'risk_level'      => 'moderate',
            'overview'        => 'Mock prediction - AI service unavailable.',
            'confidence'      => 0.90,
            'model_version'   => 'mock-v1.0',
            'prediction'      => 'PAC',
            'probabilities'   => ['AF' => 0.10, 'NSR' => 0.70, 'PAC' => 0.20],
            'recommendations' => ['Monitor blood pressure regularly', 'Avoid high sodium diet'],
        ];
    }

    private function ehrMockResponse(): array
    {
        return [
            'score'           => 30.0,
            'risk_level'      => 'low',
            'overview'        => 'Mock EHR prediction - AI service unavailable.',
            'confidence'      => 0.70,
            'model_version'   => 'ehr-mock-v1.0',
            'prediction'      => 'NSR',
            'probabilities'   => null,
            'recommendations' => null,
        ];
    }
}
