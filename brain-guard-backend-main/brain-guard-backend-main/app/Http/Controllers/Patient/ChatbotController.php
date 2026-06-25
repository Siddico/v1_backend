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

    public function destroySession(Request $request, string $id): JsonResponse
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

        $session->delete();

        return response()->json([
            'success' => true,
            'message' => 'Chatbot session deleted.',
            'data'    => null,
        ]);
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

    public function sendMessage(Request $request, string $id)
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
            'content'        => ['required', 'string'],
            'attachment_url' => ['nullable', 'url'],
        ]);

        $userMessage = ChatbotMessage::create([
            'session_id'     => $session->id,
            'sender'         => 'user',
            'content'        => $validated['content'],
            'attachment_url' => $validated['attachment_url'] ?? null,
        ]);

        $session->touch();

        // Build context for AI
        $previousMessages = $session->messages()->orderBy('created_at')->get();
        $aiMessages = [
            [
                'role' => 'system',
                'content' => "You are BrainGuard AI, a medical assistant chatbot for stroke risk prediction. The patient's name is {$profile->full_name}, age {$profile->age}. Be helpful, concise, and professional."
            ]
        ];

        foreach ($previousMessages as $msg) {
            $aiMessages[] = [
                'role' => $msg->sender === 'user' ? 'user' : 'assistant',
                'content' => $msg->content,
            ];
        }

        $openRouterKey = config('services.openrouter.key');

        return new \Symfony\Component\HttpFoundation\StreamedResponse(function () use ($session, $aiMessages, $openRouterKey) {
            $client = new \GuzzleHttp\Client();
            
            try {
                $response = $client->post('https://openrouter.ai/api/v1/chat/completions', [
                    'headers' => [
                        'Authorization' => 'Bearer ' . $openRouterKey,
                        'HTTP-Referer' => url('/'), // Optional, for OpenRouter rankings
                        'X-Title' => 'BrainGuard', // Optional, for OpenRouter rankings
                        'Content-Type' => 'application/json',
                    ],
                    'json' => [
                        'model' => 'google/gemini-2.5-flash',
                        'messages' => $aiMessages,
                        'stream' => true,
                    ],
                    'stream' => true,
                ]);

                $body = $response->getBody();
                $fullResponse = '';

                while (!$body->eof()) {
                    $chunk = $body->read(1024);
                    
                    // OpenRouter streams chunks starting with "data: "
                    $lines = explode("\n", $chunk);
                    foreach ($lines as $line) {
                        if (str_starts_with($line, 'data: ') && $line !== 'data: [DONE]') {
                            $data = json_decode(substr($line, 6), true);
                            if (isset($data['choices'][0]['delta']['content'])) {
                                $content = $data['choices'][0]['delta']['content'];
                                $fullResponse .= $content;
                                
                                // Send SSE format
                                echo "data: " . json_encode(['content' => $content]) . "\n\n";
                                ob_flush();
                                flush();
                            }
                        }
                    }
                }

                // Stream ended, save the full response to database
                ChatbotMessage::create([
                    'session_id' => $session->id,
                    'sender'     => 'ai',
                    'content'    => $fullResponse,
                ]);

                echo "data: [DONE]\n\n";
                ob_flush();
                flush();

            } catch (\Exception $e) {
                echo "data: " . json_encode(['error' => 'Failed to reach AI service.']) . "\n\n";
                echo "data: [DONE]\n\n";
                ob_flush();
                flush();
                \Illuminate\Support\Facades\Log::error('OpenRouter Streaming Error: ' . $e->getMessage());
            }
        }, 200, [
            'Cache-Control' => 'no-cache',
            'Content-Type'  => 'text/event-stream',
            'X-Accel-Buffering' => 'no',
            'Connection'    => 'keep-alive',
        ]);
    }
}
