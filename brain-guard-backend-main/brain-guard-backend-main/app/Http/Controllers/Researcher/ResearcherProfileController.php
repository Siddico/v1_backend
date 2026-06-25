<?php

namespace App\Http\Controllers\Researcher;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ResearcherProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $profile = $request->user()->researcherProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Researcher profile not found.',
                'data'    => null,
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Researcher profile retrieved.',
            'data'    => [
                'profile'   => $profile,
                'image_url' => $profile->image
                    ? asset('storage/' . $profile->image)
                    : null,
            ],
        ]);
    }

    public function update(Request $request): JsonResponse
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
            'full_name'      => ['sometimes', 'string', 'max:255'],
            'institution'    => ['nullable', 'string', 'max:255'],
            'research_field' => ['nullable', 'string', 'max:255'],
            'phone'          => ['nullable', 'string', 'max:20'],
            'gender'         => ['nullable', 'in:male,female'],
            'email'          => ['nullable', 'string', 'email', 'max:255'],
            'image'          => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ]);

        if ($request->hasFile('image')) {
            if ($profile->image && ! str_starts_with($profile->image, 'http')) {
                Storage::disk('public')->delete($profile->image);
            }
            $path = $request->file('image')->store('researcher_images', 'public');
            $validated['image'] = $path;
        } else {
            unset($validated['image']);
        }

        $profile->update($validated);

        $syncData = [];
        if (isset($validated['phone']))     $syncData['phone']     = $validated['phone'];
        if (isset($validated['gender']))    $syncData['gender']    = $validated['gender'];
        if (isset($validated['full_name'])) $syncData['full_name'] = $validated['full_name'];
        if (! empty($syncData)) {
            $request->user()->update($syncData);
        }

        $fresh = $profile->fresh();

        return response()->json([
            'success' => true,
            'message' => 'Researcher profile updated.',
            'data'    => [
                'profile'   => $fresh,
                'image_url' => $fresh->image
                    ? asset('storage/' . $fresh->image)
                    : null,
            ],
        ]);
    }
}
