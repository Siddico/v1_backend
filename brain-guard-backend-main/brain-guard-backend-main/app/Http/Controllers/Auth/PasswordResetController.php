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
    public function resetPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email'    => ['required', 'email'],
            'token'    => ['required', 'string'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ], [
            'email.required'     => 'يرجى إدخال بريدك الإلكتروني.',
            'email.email'        => 'صيغة البريد الإلكتروني غير صحيحة.',
            'token.required'     => 'رمز استعادة كلمة المرور مفقود.',
            'password.required'  => 'يرجى إدخال كلمة المرور الجديدة.',
            'password.min'       => 'كلمة المرور يجب ألا تقل عن 8 أحرف.',
            'password.confirmed' => 'تأكيد كلمة المرور غير متطابق.',
        ]);

        $reset = PasswordReset::where('email', $data['email'])
            ->where('reset_token', $data['token'])
            ->where('expires_at', '>', Carbon::now())
            ->latest()
            ->first();

        if (! $reset) {
            return response()->json([
                'success' => false,
                'message' => 'رمز استعادة كلمة المرور غير صالح أو منتهي الصلاحية.',
                'data'    => null,
            ], 422);
        }

        /** @var \App\Models\User|null $user */
        $user = User::where('id', $reset->user_id)
            ->where('email', $data['email'])
            ->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'المستخدم غير موجود.',
                'data'    => null,
            ], 404);
        }

        $user->update([
            'password' => Hash::make($data['password']),
        ]);

        $reset->delete();

        return response()->json([
            'success' => true,
            'message' => 'تم إعادة تعيين كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول.',
            'data'    => null,
        ]);
    }
}

