<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\QrScan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class QrController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'qr_data'    => ['nullable', 'string'],
            'description'=> ['nullable', 'string'],
            'scanned_at' => ['nullable', 'date'],
        ]);

        $scan = QrScan::create([
            'user_id'     => $request->user()->id,
            'description' => $validated['qr_data'] ?? $validated['description'] ?? null,
            'scanned_at'  => $validated['scanned_at'] ?? now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'QR scan recorded.',
            'data'    => ['qr_scan' => $scan],
        ], 201);
    }
}
