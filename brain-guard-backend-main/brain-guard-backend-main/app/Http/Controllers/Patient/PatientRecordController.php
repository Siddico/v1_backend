<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PatientRecordController extends Controller
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

        $files = $profile->patientFiles()->orderByDesc('created_at')->get()->map(function ($file) {
            return [
                'id'         => $file->id,
                'type'       => 'patient_file',
                'category'   => $file->category,
                'file_name'  => $file->file_name,
                'file_url'   => $file->file_url,
                'extension'  => $file->extension,
                'created_at' => $file->created_at,
            ];
        });

        $signals = $profile->ecgPpgSignals()->orderByDesc('recorded_at')->get()->map(function ($signal) {
            return [
                'id'         => $signal->id,
                'type'       => 'signal',
                'category'   => $signal->signal_type,
                'file_name'  => $signal->signal_type . ' Signal Data',
                'file_url'   => $signal->file_url,
                'extension'  => 'mat',
                'created_at' => $signal->recorded_at,
            ];
        });

        $radiology = $profile->radiologyUploads()->orderByDesc('uploaded_at')->get()->map(function ($radio) {
            return [
                'id'         => $radio->id,
                'type'       => 'radiology',
                'category'   => 'radiology',
                'file_name'  => 'Radiology Image',
                'file_url'   => asset('storage/' . $radio->image_path),
                'extension'  => 'png', // or logic to extract extension from path
                'created_at' => $radio->uploaded_at,
            ];
        });

        $allRecords = collect($files)->merge($signals)->merge($radiology)->sortByDesc('created_at')->values();

        // Group by extension type as requested
        $images = $allRecords->filter(fn($item) => in_array(strtolower($item['extension']), ['jpg', 'jpeg', 'png', 'webp']))->values();
        $pdfs = $allRecords->filter(fn($item) => strtolower($item['extension']) === 'pdf')->values();
        $dataFiles = $allRecords->filter(fn($item) => strtolower($item['extension']) === 'mat' || strtolower($item['extension']) === 'csv')->values();

        return response()->json([
            'success' => true,
            'message' => 'Unified patient records retrieved.',
            'data'    => [
                'images'     => $images,
                'pdfs'       => $pdfs,
                'data_files' => $dataFiles,
                'all'        => $allRecords,
            ],
        ]);
    }
}
