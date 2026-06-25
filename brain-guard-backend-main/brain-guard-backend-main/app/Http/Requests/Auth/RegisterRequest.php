<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'full_name' => ['required', 'string', 'max:255'],
            'email'     => ['required', 'email', 'max:255', 'unique:users,email'],
            'password'  => ['required', 'string', 'min:8', 'confirmed'],
            'role'      => ['required', 'string', 'in:patient,doctor,researcher'],
            'phone'     => ['required', 'string', 'max:20'],
            'gender'    => ['required', 'in:male,female'],
            'agreement' => ['accepted'],
        ];
    }

    public function messages(): array
    {
        return [
            'full_name.required' => 'يرجى إدخال اسمك الكامل.',
            'full_name.string'   => 'الاسم يجب أن يكون نصاً.',
            'email.required'     => 'يرجى إدخال بريدك الإلكتروني.',
            'email.email'        => 'صيغة البريد الإلكتروني غير صحيحة.',
            'email.unique'       => 'البريد الإلكتروني مسجل مسبقاً.',
            'password.required'  => 'يرجى إدخال كلمة المرور.',
            'password.min'       => 'كلمة المرور يجب ألا تقل عن 8 أحرف.',
            'password.confirmed' => 'تأكيد كلمة المرور غير متطابق.',
            'role.required'      => 'يرجى تحديد دور المستخدم.',
            'role.in'            => 'الدور المحدد غير صالح.',
            'phone.required'     => 'يرجى إدخال رقم هاتفك.',
            'gender.required'    => 'يرجاء اختيار جنسك.',
            'gender.in'          => 'يرجى اختيار جنس صحيح (ذكر/أنثى).',
            'agreement.accepted' => 'يجب الموافقة على اتفاقية البيانات لإنشاء حساب.',
        ];
    }
}

