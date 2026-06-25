<?php

namespace App\Http\Controllers\Researcher;

use App\Http\Controllers\Controller;
use App\Models\PaperSection;
use App\Models\ResearchPaper;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaperSectionController extends Controller
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

        $paper = ResearchPaper::query()->find($id);

        if (! $paper || (int) $paper->researcher_id !== (int) $profile->id) {
            return response()->json([
                'success' => false,
                'message' => 'Paper not found.',
                'data' => null,
            ], 404);
        }

        $validated = $request->validate([
            'abstract' => ['nullable', 'string'],
            'keywords' => ['nullable', 'string'],
            'appendices' => ['nullable', 'string'],
            'introduction' => ['nullable', 'string'],
            'methodology' => ['nullable', 'string'],
            'result' => ['nullable', 'string'],
            'discussion' => ['nullable', 'string'],
            'conclusion' => ['nullable', 'string'],
            'references' => ['nullable', 'string'],
        ]);

        $section = PaperSection::updateOrCreate(
            ['paper_id' => $paper->id],
            $validated
        );

        return response()->json([
            'success' => true,
            'message' => 'Paper sections saved.',
            'data' => ['paper_section' => $section],
        ], 201);
    }
}
