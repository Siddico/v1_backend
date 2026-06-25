<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\OtpCode;
use App\Models\PasswordReset;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use App\Mail\SendOtpMail;

class OtpController extends Controller
{
    public function sendOtp(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
        ], [
            'email.required' => 'يرجى إدخال بريدك الإلكتروني.',
            'email.email'    => 'صيغة البريد الإلكتروني غير صحيحة.',
        ]);

        /** @var User|null $user */
        $user = User::where('email', $data['email'])->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'هذا البريد الإلكتروني غير مسجل لدينا.',
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

        // Send the OTP via Email
        Mail::to($user->email)->send(new SendOtpMail($code));

        return response()->json([
            'success' => true,
            'message' => 'تم إرسال رمز التحقق (OTP) إلى بريدك الإلكتروني بنجاح.',
            'data'    => [
                'masked_email' => Str::mask($user->email, '*', 3),
            ],
        ]);
    }

    public function verifyOtp(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'code'  => ['required', 'string', 'size:6'],
        ], [
            'email.required' => 'يرجى إدخال بريدك الإلكتروني.',
            'email.email'    => 'صيغة البريد الإلكتروني غير صحيحة.',
            'code.required'  => 'يرجى إدخال رمز التحقق.',
            'code.size'      => 'رمز التحقق يجب أن يتكون من 6 أرقام.',
        ]);

        /** @var User|null $user */
        $user = User::where('email', $data['email'])->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'المستخدم غير موجود.',
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
                'message' => 'رمز التحقق غير صحيح أو منتهي الصلاحية.',
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
            'message' => 'تم التحقق من الرمز بنجاح. يمكنك الآن تعيين كلمة مرور جديدة.',
            'data'    => [
                'reset_token' => $resetToken,
            ],
        ]);
    }
}
