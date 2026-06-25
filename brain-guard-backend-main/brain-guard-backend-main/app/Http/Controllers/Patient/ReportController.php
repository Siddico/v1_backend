<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data' => null,
            ], 404);
        }

        $reports = $profile->reports()->orderByDesc('generated_at')->get();

        return response()->json([
            'success' => true,
            'message' => 'Reports retrieved.',
            'data' => ['reports' => $reports],
        ]);
    }
}
