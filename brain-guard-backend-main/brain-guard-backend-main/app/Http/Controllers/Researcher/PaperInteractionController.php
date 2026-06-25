<?php

namespace App\Http\Controllers\Researcher;

use App\Http\Controllers\Controller;
use App\Models\PaperInteraction;
use App\Models\ResearchPaper;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaperInteractionController extends Controller
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
            'is_liked' => ['nullable', 'boolean'],
            'increment_view' => ['nullable', 'boolean'],
        ]);

        $existing = PaperInteraction::query()
            ->where('researcher_id', $profile->id)
            ->where('paper_id', $id)
            ->first();

        $viewCount = $existing?->view_count ?? 0;
        if ($validated['increment_view'] ?? true) {
            $viewCount++;
        }

        $isLiked = array_key_exists('is_liked', $validated)
            ? (bool) $validated['is_liked']
            : (bool) ($existing?->is_liked ?? false);

        $interaction = PaperInteraction::updateOrCreate(
            [
                'researcher_id' => $profile->id,
                'paper_id' => $id,
            ],
            [
                'is_liked' => $isLiked,
                'view_count' => $viewCount,
                'interacted_at' => now(),
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Interaction recorded.',
            'data' => ['interaction' => $interaction->load('paper')],
        ], 201);
    }
}
