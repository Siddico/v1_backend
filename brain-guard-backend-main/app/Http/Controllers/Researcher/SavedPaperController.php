<?php

namespace App\Http\Controllers\Researcher;

use App\Http\Controllers\Controller;
use App\Models\ResearchPaper;
use App\Models\SavedPaper;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SavedPaperController extends Controller
{
    public function store(Request $request, string $id): JsonResponse
    {
        $profile = $request->user()->researcherProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Researcher profile not found.',
                'data' => null,
            ], 404);
        }

        if (! ResearchPaper::query()->whereKey($id)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Paper not found.',
                'data' => null,
            ], 404);
        }

        $validated = $request->validate([
            'is_favorite' => ['nullable', 'boolean'],
        ]);

        $saved = SavedPaper::updateOrCreate(
            [
                'researcher_id' => $profile->id,
                'paper_id' => $id,
            ],
            [
                'is_favorite' => $validated['is_favorite'] ?? false,
                'saved_at' => now(),
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Paper saved.',
            'data' => ['saved_paper' => $saved->load('paper')],
        ], 201);
    }
}
