<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Mail\SendOtpMail;
use App\Models\OtpCode;
use App\Models\PasswordReset;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class OtpController extends Controller
{
    public function sendOtp(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
        ]);

        /** @var User|null $user */
        $user = User::where('email', $data['email'])->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found.',
                'data'    => null,
            ], 404);
        }

        $code = (string) random_int(100000, 999999);

        OtpCode::create([
            'user_id'    => $user->id,
            'email'      => $user->email,
            'code'       => $code,
            'expires_at' => Carbon::now()->addMinutes(10),
            'is_used'    => false,
        ]);

        try {
            Mail::to($user->email)->send(new SendOtpMail($code, Str::mask($user->email, '*', 3)));
        } catch (\Exception $e) {
            Log::error('OTP email failed: ' . $e->getMessage());
        }

        $responseData = ['masked_email' => Str::mask($user->email, '*', 3)];
        if (app()->environment('local', 'testing')) {
            $responseData['otp_code'] = $code; // DEV ONLY
        }

        return response()->json([
            'success' => true,
            'message' => 'OTP sent to your email.',
            'data'    => $responseData,
        ]);
    }

    public function verifyOtp(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'code'  => ['required', 'string', 'size:6'],
        ]);

        /** @var User|null $user */
        $user = User::where('email', $data['email'])->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found.',
                'data'    => null,
            ], 404);
        }

        $otp = OtpCode::where('user_id', $user->id)
            ->where('code', $data['code'])
            ->where('is_used', false)
            ->where('expires_at', '>', Carbon::now())
            ->latest()
            ->first();

        if (! $otp) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired OTP code.',
                'data'    => null,
            ], 422);
        }

        $otp->update(['is_used' => true]);

        // Generate reset token automatically after OTP verified
        $resetToken = Str::random(64);

        PasswordReset::create([
            'user_id'     => $user->id,
            'email'       => $user->email,
            'reset_token' => $resetToken,
            'expires_at'  => Carbon::now()->addMinutes(60),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'OTP verified successfully.',
            'data'    => [
                'reset_token' => $resetToken,
                'token'       => $resetToken,
            ],
        ]);
    }
}
