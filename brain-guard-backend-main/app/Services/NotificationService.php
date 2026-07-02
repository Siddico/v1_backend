<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;
use Google\Auth\Credentials\ServiceAccountCredentials;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    private string $projectId;
    private string $credentialsPath;
    private string $fcmUrl;

    public function __construct()
    {
        $this->projectId       = config('services.firebase.project_id', 'grad-implementation-ver-1');
        $this->credentialsPath = config('services.firebase.credentials');
        $this->fcmUrl          = "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send";
    }

    public function getAccessToken(): ?string
    {
        return Cache::remember('firebase_access_token', 55 * 60, function () {
            try {
                if (! file_exists($this->credentialsPath)) {
                    Log::error('Firebase credentials file not found: ' . $this->credentialsPath);
                    return null;
                }

                $scopes      = ['https://www.googleapis.com/auth/firebase.messaging'];
                $credentials = new ServiceAccountCredentials($scopes, $this->credentialsPath);
                $token       = $credentials->fetchAuthToken();

                return $token['access_token'] ?? null;
            } catch (\Exception $e) {
                Log::error('Firebase getAccessToken error: ' . $e->getMessage());
                return null;
            }
        });
    }

    public function sendPush(string $fcmToken, string $title, string $body, array $data = []): bool
    {
        try {
            $accessToken = $this->getAccessToken();

            if (! $accessToken) {
                Log::error('Firebase sendPush: No access token available.');
                return false;
            }

            // FCM data values must be strings
            $stringData = array_map('strval', $data);

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type'  => 'application/json',
            ])->post($this->fcmUrl, [
                'message' => [
                    'token'        => $fcmToken,
                    'notification' => [
                        'title' => $title,
                        'body'  => $body,
                    ],
                    'data' => $stringData,
                ],
            ]);

            if ($response->successful()) {
                return true;
            }

            Log::error('Firebase sendPush failed: ' . $response->status() . ' — ' . $response->body());
            return false;

        } catch (\Exception $e) {
            Log::error('Firebase sendPush exception: ' . $e->getMessage());
            return false;
        }
    }

    public function notify(User $user, string $title, string $body, array $data = []): void
    {
        try {
            // Save to DB always
            Notification::create([
                'user_id'     => $user->id,
                'title'       => $title,
                'description' => $body,
                'day'         => now()->toDateString(),
                'time'        => now()->format('H:i:s'),
                'is_enabled'  => true,
                'is_read'     => false,
            ]);

            // Send push only if FCM token exists
            if (! empty($user->fcm_token)) {
                $this->sendPush($user->fcm_token, $title, $body, $data);
            }

        } catch (\Exception $e) {
            Log::error('NotificationService::notify error: ' . $e->getMessage());
        }
    }
}
