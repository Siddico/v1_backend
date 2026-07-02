<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\PasswordReset;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class PasswordResetController extends Controller
{
    public function sendResetLink(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
        ]);

        /** @var \App\Models\User|null $user */
        $user = User::where('email', $data['email'])->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found.',
                'data' => null,
            ], 404);
        }

        $token = Str::random(64);

        PasswordReset::create([
            'user_id' => $user->id,
            'email' => $user->email,
            'reset_token' => $token,
            'expires_at' => Carbon::now()->addMinutes(60),
        ]);

        // TODO: Send password reset token via email.

        return response()->json([
            'success' => true,
            'message' => 'Password reset token generated.',
            'data' => [
                'token' => $token,
            ],
        ]);
    }

    public function resetPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'token' => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $reset = PasswordReset::where('email', $data['email'])
            ->where('reset_token', $data['token'])
            ->where('expires_at', '>', Carbon::now())
            ->latest()
            ->first();

        if (! $reset) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired password reset token.',
                'data' => null,
            ], 422);
        }

        /** @var \App\Models\User|null $user */
        $user = User::where('id', $reset->user_id)
            ->where('email', $data['email'])
            ->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found for this token.',
                'data' => null,
            ], 404);
        }

        $user->update([
            'password' => Hash::make($data['password']),
        ]);

        $reset->delete();

        return response()->json([
            'success' => true,
            'message' => 'Password has been reset successfully.',
            'data' => null,
        ]);
    }
}

