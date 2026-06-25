<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\LabDocument;
use App\Models\PatientList;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LabDocumentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $profile = $request->user()->doctorProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Doctor profile not found.',
                'data'    => null,
            ], 404);
        }

        $patientIds = PatientList::query()
            ->where('doctor_id', $profile->id)
            ->pluck('patient_id');

        $documents = LabDocument::query()
            ->whereIn('patient_id', $patientIds)
            ->with('patient')
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Lab documents retrieved.',
            'data'    => ['lab_documents' => $documents],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $profile = $request->user()->doctorProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Doctor profile not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'patient_id'    => ['required', 'integer', 'exists:patient_profiles,id'],
            'lab_name'      => ['required', 'string', 'max:255'],
            'document_type' => ['nullable', 'string', 'max:100'],
            'category'      => ['nullable', 'string', 'max:100'],
            'description'   => ['nullable', 'string'],
            'file_url'      => ['nullable', 'string', 'max:500'],
            'uploaded_at'   => ['nullable', 'date'],
        ]);

        $linked = PatientList::query()
            ->where('doctor_id', $profile->id)
            ->where('patient_id', $validated['patient_id'])
            ->exists();

        if (! $linked) {
            return response()->json([
                'success' => false,
                'message' => 'Patient is not on your list.',
                'data'    => null,
            ], 403);
        }

        // قبول document_type أو category — الاتنين نفس الحاجة
        $category = $validated['category'] ?? $validated['document_type'] ?? null;

        $doc = LabDocument::create([
            'patient_id'  => $validated['patient_id'],
            'lab_name'    => $validated['lab_name'],
            'category'    => $category,
            'description' => $validated['description'] ?? null,
            'file_url'    => $validated['file_url'] ?? null,
            'uploaded_at' => $validated['uploaded_at'] ?? now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Lab document created.',
            'data'    => ['lab_document' => $doc->load('patient')],
        ], 201);
    }
}
