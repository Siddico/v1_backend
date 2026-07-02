<?php

namespace App\Http\Controllers\Doctor;

use App\Http\Controllers\Controller;
use App\Models\Chat;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $chats = Chat::query()
            ->where('sender_id', $userId)
            ->orWhere('receiver_id', $userId)
            ->orderByDesc('sent_at')
            ->with(['sender:id,full_name,email', 'receiver:id,full_name,email'])
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Chats retrieved.',
            'data' => ['chats' => $chats],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'receiver_id' => ['required', 'integer', 'exists:users,id'],
            'message' => ['required', 'string'],
            'phone_call' => ['nullable', 'boolean'],
        ]);

        $chat = Chat::create([
            'sender_id' => $request->user()->id,
            'receiver_id' => $validated['receiver_id'],
            'chat_message' => $validated['message'],
            'phone_call' => $validated['phone_call'] ?? false,
            'sent_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Message sent.',
            'data' => ['chat' => $chat->load(['sender:id,full_name,email', 'receiver:id,full_name,email'])],
        ], 201);
    }
}
