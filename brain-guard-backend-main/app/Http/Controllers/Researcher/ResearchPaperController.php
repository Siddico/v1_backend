<?php

namespace App\Http\Controllers\Researcher;

use App\Http\Controllers\Controller;
use App\Models\PaperSearchLog;
use App\Models\ResearchPaper;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ResearchPaperController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $papers = ResearchPaper::query()
            ->with(['researcher', 'paperSection'])
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Papers retrieved.',
            'data'    => ['papers' => $papers],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $profile = $request->user()->researcherProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Researcher profile not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'paper_name'     => ['required', 'string', 'max:255'],
            'publisher_name' => ['nullable', 'string', 'max:255'],
            'category_topic' => ['nullable', 'string', 'max:255'],
            'date'           => ['nullable', 'date'],
            'description'    => ['nullable', 'string'],
            'upload_type'    => ['nullable', 'in:manual,direct'],
            'file_path'      => ['nullable', 'string', 'max:255'],
        ]);

        $paper = ResearchPaper::create([
            'researcher_id'  => $profile->id,
            'paper_name'     => $validated['paper_name'],
            'publisher_name' => $validated['publisher_name'] ?? null,
            'category_topic' => $validated['category_topic'] ?? null,
            'date'           => $validated['date'] ?? null,
            'description'    => $validated['description'] ?? null,
            'upload_type'    => $validated['upload_type'] ?? 'manual',
            'file_path'      => $validated['file_path'] ?? null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Paper created.',
            'data'    => ['paper' => $paper->load('paperSection')],
        ], 201);
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $paper = ResearchPaper::query()
            ->with(['researcher', 'paperSection'])
            ->find($id);

        if (! $paper) {
            return response()->json([
                'success' => false,
                'message' => 'Paper not found.',
                'data'    => null,
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Paper retrieved.',
            'data'    => ['paper' => $paper],
        ]);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $profile = $request->user()->researcherProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Researcher profile not found.',
                'data'    => null,
            ], 404);
        }

        $paper = ResearchPaper::query()->find($id);

        if (! $paper || (int) $paper->researcher_id !== (int) $profile->id) {
            return response()->json([
                'success' => false,
                'message' => 'Paper not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'paper_name'     => ['sometimes', 'string', 'max:255'],
            'publisher_name' => ['nullable', 'string', 'max:255'],
            'category_topic' => ['nullable', 'string', 'max:255'],
            'date'           => ['nullable', 'date'],
            'description'    => ['nullable', 'string'],
            'upload_type'    => ['nullable', 'in:manual,direct'],
            'file_path'      => ['nullable', 'string', 'max:255'],
            'status'         => ['nullable', 'in:pending,approved,rejected'],
            'is_verified'    => ['nullable', 'boolean'],
        ]);

        $paper->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Paper updated.',
            'data'    => ['paper' => $paper->fresh()->load('paperSection')],
        ]);
    }

    public function search(Request $request): JsonResponse
    {
        $profile = $request->user()->researcherProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Researcher profile not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'keyword'              => ['required', 'string', 'max:255'],
            'filter_field'         => ['nullable', 'string', 'max:100'],
            'field'                => ['nullable', 'string', 'max:100'],
            'filter_year'          => ['nullable', 'integer', 'min:1900', 'max:2100'],
            'year'                 => ['nullable', 'integer', 'min:1900', 'max:2100'],
            'filter_institution'   => ['nullable', 'string', 'max:255'],
        ]);

        // قبول field أو filter_field — الاتنين نفس الحاجة
        $filterField = $validated['filter_field'] ?? $validated['field'] ?? null;
        $filterYear  = $validated['filter_year']  ?? $validated['year']  ?? null;

        PaperSearchLog::create([
            'researcher_id'      => $profile->id,
            'keyword'            => $validated['keyword'],
            'filter_field'       => $filterField,
            'filter_year'        => $filterYear,
            'filter_institution' => $validated['filter_institution'] ?? null,
            'searched_at'        => now(),
        ]);

        $query = ResearchPaper::query()
            ->where(function ($q) use ($validated) {
                $kw = '%' . $validated['keyword'] . '%';
                $q->where('paper_name', 'like', $kw)
                    ->orWhere('description', 'like', $kw)
                    ->orWhere('category_topic', 'like', $kw)
                    ->orWhere('publisher_name', 'like', $kw);
            });

        if ($filterField) {
            $query->where('category_topic', 'like', '%' . $filterField . '%');
        }

        if ($filterYear) {
            $query->whereYear('date', $filterYear);
        }

        $papers = $query->orderByDesc('created_at')->get();

        return response()->json([
            'success' => true,
            'message' => 'Search completed.',
            'data'    => ['papers' => $papers],
        ]);
    }
}
