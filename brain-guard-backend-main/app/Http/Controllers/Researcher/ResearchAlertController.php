<?php

namespace App\Http\Controllers\Researcher;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ResearchAlertController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $profile = $request->user()->researcherProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Researcher profile not found.',
                'data' => null,
            ], 404);
        }

        $alerts = $profile->researchAlerts()
            ->with('paper')
            ->orderByDesc('alert_time')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Research alerts retrieved.',
            'data' => ['alerts' => $alerts],
        ]);
    }
}
