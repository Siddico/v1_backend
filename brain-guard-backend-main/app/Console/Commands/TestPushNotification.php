<?php

namespace App\Console\Commands;

use App\Models\Notification;
use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Console\Command;

class TestPushNotification extends Command
{
    protected $signature   = 'firebase:test {user_id}';
    protected $description = 'Test Firebase push notification for a specific user';

    public function handle(): void
    {
        $userId = $this->argument('user_id');

        $user = User::find($userId);

        if (! $user) {
            $this->error("❌ User with ID {$userId} not found.");
            return;
        }

        $this->info("✅ User found: {$user->full_name} ({$user->email})");
        $this->info("   FCM Token: " . ($user->fcm_token ? substr($user->fcm_token, 0, 20) . '...' : 'NOT SET'));

        $countBefore = Notification::where('user_id', $user->id)->count();

        $service = new NotificationService();
        $service->notify(
            $user,
            'Test Notification',
            'This is a test from Brain Guard backend'
        );

        $countAfter = Notification::where('user_id', $user->id)->count();

        if ($countAfter > $countBefore) {
            $this->info("✅ DB record created successfully.");
        } else {
            $this->error("❌ DB record was NOT created.");
        }

        if (! empty($user->fcm_token)) {
            $this->info("✅ Push notification attempted (check logs for result).");

            $token    = $service->getAccessToken();
            if ($token) {
                $this->info("✅ Firebase access token retrieved successfully.");
            } else {
                $this->error("❌ Failed to get Firebase access token — check credentials file path and content.");
            }
        } else {
            $this->warn("⚠️  Push NOT sent — user has no FCM token.");
            $this->warn("    To test push: login from Flutter with a real device and the FCM token will be saved.");
        }

        $this->info("Done.");
    }
}
