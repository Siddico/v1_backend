<?php

namespace App\Http\Controllers\Patient;

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
            'data' => [
                'chats'        => $chats,
                'unread_count' => Chat::where('receiver_id', $userId)->where('is_read', false)->count(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'receiver_id' => ['required', 'integer', 'exists:users,id'],
            'message' => ['required', 'string'],
            'phone_call' => ['nullable', 'boolean'],
            'message_type' => ['nullable', 'in:text,image'],
        ]);

        $chat = Chat::create([
            'sender_id' => $request->user()->id,
            'receiver_id' => $validated['receiver_id'],
            'chat_message' => $validated['message'],
            'message_type' => $validated['message_type'] ?? 'text',
            'phone_call' => $validated['phone_call'] ?? false,
            'sent_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Message sent.',
            'data' => ['chat' => $chat->load(['sender:id,full_name,email', 'receiver:id,full_name,email'])],
        ], 201);
    }

    public function markAsRead(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        Chat::where('receiver_id', $userId)->where('is_read', false)->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Messages marked as read.',
            'data'    => null,
        ]);
    }
}
