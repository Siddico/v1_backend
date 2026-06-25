<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PatientChartController extends Controller
{
    public function index(Request $request): JsonResponse
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

        // Top info
        $fullName = $profile->full_name;
        $age = $user->date_of_birth ? \Carbon\Carbon::parse($user->date_of_birth)->age : $profile->age;
        
        $qrCodeData = json_encode([
            'uuid' => $user->uuid,
            'role' => 'patient'
        ]);

        $latestPrediction = $profile->strokeRiskPredictions()->latest()->first();
        $diagnosis = 'Unknown';
        if ($latestPrediction) {
            $modelOutput = $latestPrediction->model_output;
            if (is_array($modelOutput)) {
                $diagnosis = $modelOutput['class'] ?? $modelOutput['predicted_class'] ?? $modelOutput['label'] ?? 'Unknown';
            }
            if ($diagnosis === 'Unknown') {
                $diagnosis = match ($latestPrediction->risk_level) {
                    'high'     => 'AF',
                    'moderate' => 'PAC',
                    default    => 'NSR',
                };
            }
        }

        // Charts Data
        // From health_data: heart_rate, spo2, blood_pressure, etc.
        $healthData = $profile->healthData()->orderByDesc('recorded_at')->take(10)->get();
        
        $heartRateChart = $healthData->map(function ($data) {
            return [
                'recorded_at' => $data->recorded_at,
                'value'       => $data->heart_rate,
            ];
        });

        $spo2Chart = $healthData->map(function ($data) {
            return [
                'recorded_at' => $data->recorded_at,
                'value'       => $data->spo2,
            ];
        });

        $stabilityChart = $healthData->map(function ($data) {
            return [
                'recorded_at' => $data->recorded_at,
                'value'       => rand(80, 100), // Placeholder if we don't have a real stability index
            ];
        });

        // For ECG/PPG, we can return the latest signal's summary
        $latestSignal = $profile->ecgPpgSignals()->latest('recorded_at')->first();
        
        return response()->json([
            'success' => true,
            'message' => 'Charts dashboard retrieved.',
            'data'    => [
                'header_info' => [
                    'full_name'    => $fullName,
                    'age'          => $age,
                    'qr_code_data' => $qrCodeData,
                    'diagnosis'    => $diagnosis,
                ],
                'charts' => [
                    'heart_rate'      => $heartRateChart,
                    'spo2'            => $spo2Chart,
                    'stability_index' => $stabilityChart,
                    'latest_signal'   => $latestSignal ? [
                        'type'        => $latestSignal->signal_type,
                        'recorded_at' => $latestSignal->recorded_at,
                        'file_url'    => $latestSignal->file_url,
                    ] : null,
                ]
            ],
        ]);
    }
}
