<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\ChatbotMessage;
use App\Models\ChatbotSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChatbotController extends Controller
{
    public function sessions(Request $request): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $sessions = $profile->chatbotSessions()
            ->orderByDesc('updated_at')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Chatbot sessions retrieved.',
            'data'    => ['sessions' => $sessions],
        ]);
    }

    public function createSession(Request $request): JsonResponse
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
            'title' => ['nullable', 'string', 'max:255'],
        ]);

        $session = ChatbotSession::create([
            'patient_id' => $profile->id,
            'title'      => $validated['title'] ?? null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Chatbot session created.',
            'data'    => ['session' => $session],
        ], 201);
    }

    public function messages(Request $request, string $id): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $session = ChatbotSession::query()
            ->where('id', $id)
            ->where('patient_id', $profile->id)
            ->first();

        if (! $session) {
            return response()->json([
                'success' => false,
                'message' => 'Chatbot session not found.',
                'data'    => null,
            ], 404);
        }

        $messages = $session->messages()->orderBy('created_at')->get();

        return response()->json([
            'success' => true,
            'message' => 'Chatbot messages retrieved.',
            'data'    => ['messages' => $messages],
        ]);
    }

    public function sendMessage(Request $request, string $id): JsonResponse
    {
        $profile = $request->user()->patientProfile;

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Patient profile not found.',
                'data'    => null,
            ], 404);
        }

        $session = ChatbotSession::query()
            ->where('id', $id)
            ->where('patient_id', $profile->id)
            ->first();

        if (! $session) {
            return response()->json([
                'success' => false,
                'message' => 'Chatbot session not found.',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'content' => ['required', 'string'],
        ]);

        $userMessage = ChatbotMessage::create([
            'session_id' => $session->id,
            'sender'     => 'user',
            'content'    => $validated['content'],
        ]);

        // TODO: Integrate real Gemini API for AI responses.
        $aiContent = "I'm BrainGuard AI. Based on your stroke risk profile, I recommend consulting your doctor.";

        $aiMessage = ChatbotMessage::create([
            'session_id' => $session->id,
            'sender'     => 'ai',
            'content'    => $aiContent,
        ]);

        $session->touch();

        return response()->json([
            'success' => true,
            'message' => 'Message sent.',
            'data'    => [
                'user_message' => $userMessage,
                'ai_message'   => $aiMessage,
            ],
        ], 201);
    }
}
