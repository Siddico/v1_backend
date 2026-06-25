<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class AIService
{
    private string $baseUrl;

    public function __construct()
    {
        $this->baseUrl = env('AI_SERVICE_URL', 'http://127.0.0.1:8001');
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

                $riskLevel    = $data['risk_level']  ?? $data['stroke_risk']  ?? 'low';
                $score        = $data['score']        ?? $data['risk_score']   ?? 20.0;
                $confidence   = $data['confidence']   ?? 0.0;
                $modelVersion = $data['model_version'] ?? 'attention-cnn-v1.0';
                $overview     = $data['overview']     ?? $data['message']      ?? $this->riskOverview($riskLevel);
                $prediction   = $data['prediction']   ?? $data['class']        ?? $this->riskToClass($riskLevel);
                $probabilities  = $data['probabilities']  ?? null;
                $recommendations = $data['recommendations'] ?? null;

                return [
                    'score'           => (float) $score,
                    'risk_level'      => $riskLevel,
                    'overview'        => $overview,
                    'confidence'      => (float) $confidence,
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
            'confidence'      => 90.0,
            'model_version'   => 'mock-v1.0',
            'prediction'      => 'PAC',
            'probabilities'   => ['AF' => 0.10, 'NSR' => 0.70, 'PAC' => 0.20],
            'recommendations' => ['Monitor blood pressure regularly', 'Avoid high sodium diet'],
        ];
    }
}
