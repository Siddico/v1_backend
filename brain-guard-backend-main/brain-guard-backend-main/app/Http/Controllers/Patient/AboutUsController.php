<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AboutUsController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $team = [
            [
                'name'     => 'Eng. Ali',
                'role'     => 'AI Engineer & Backend Developer',
                'image'    => 'https://ui-avatars.com/api/?name=Ali+Hassan&background=random',
                'linkedin' => 'https://linkedin.com/in/ali',
            ],
            [
                'name'     => 'Eng. Siddiq',
                'role'     => 'Flutter Developer',
                'image'    => 'https://ui-avatars.com/api/?name=Siddiq&background=random',
                'linkedin' => 'https://linkedin.com/in/siddiq',
            ],
            // Add other team members as required based on the real screenshot data.
        ];

        return response()->json([
            'success' => true,
            'message' => 'About Us data retrieved.',
            'data'    => [
                'team' => $team,
            ],
        ]);
    }
}
