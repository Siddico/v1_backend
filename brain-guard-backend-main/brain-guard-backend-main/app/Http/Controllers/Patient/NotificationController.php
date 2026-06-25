<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    private function formatNotification(Notification $notification): array
    {
        return array_merge($notification->toArray(), [
            'subtitle'        => $notification->description,
            'is_unread'       => ! $notification->is_read,
            'sender_image'    => $notification->image,
            'sender_id'       => null,
            'conversation_id' => null,
        ]);
    }

    public function index(Request $request): JsonResponse
    {
        $notifications = $request->user()
            ->notifications()
            ->orderByDesc('created_at')
            ->get()
            ->map(fn (Notification $notification) => $this->formatNotification($notification));

        return response()->json([
            'success' => true,
            'message' => 'Notifications retrieved.',
            'data'    => ['notifications' => $notifications],
        ]);
    }

    public function markAsRead(Request $request, int $id): JsonResponse
    {
        $notification = Notification::query()
            ->where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (! $notification) {
            return response()->json([
                'success' => false,
                'message' => 'Notification not found.',
                'data'    => null,
            ], 404);
        }

        $notification->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read.',
            'data'    => null,
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $notification = Notification::query()
            ->where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (! $notification) {
            return response()->json([
                'success' => false,
                'message' => 'Notification not found.',
                'data'    => null,
            ], 404);
        }

        $notification->delete();

        return response()->json([
            'success' => true,
            'message' => 'Notification deleted.',
            'data'    => null,
        ]);
    }
}
