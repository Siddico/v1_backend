<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\PatientFile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PatientFileController extends Controller
{
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

        $files = $profile->patientFiles()->orderByDesc('created_at')->get();

        return response()->json([
            'success' => true,
            'message' => 'Patient files retrieved successfully.',
            'data'    => [
                'files' => $files
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
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
            'file_name' => ['nullable', 'string', 'max:255'],
            'file_url'  => ['required', 'url'],
            'category'  => ['nullable', 'string', 'max:50'],
            'extension' => ['nullable', 'string', 'max:10'],
        ]);

        $file = $profile->patientFiles()->create([
            'file_name' => $validated['file_name'] ?? 'Uploaded File',
            'file_url'  => $validated['file_url'],
            'category'  => $validated['category'] ?? 'general',
            'extension' => $validated['extension'] ?? null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'File saved successfully.',
            'data'    => [
                'file' => $file
            ],
        ], 201);
    }
}
