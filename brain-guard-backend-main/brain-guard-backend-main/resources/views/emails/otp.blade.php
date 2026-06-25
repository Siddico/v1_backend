<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <title>رمز التحقق الخاص بك</title>
</head>
<body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f3f4f6; margin: 0; padding: 40px 0;">
    <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 40px; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); text-align: center;">
        
        <!-- Logo Area -->
        <div style="margin-bottom: 30px;">
            <img src="{{ asset('images/logo.png') }}" alt="BrainGuard Logo" style="max-height: 80px;">
        </div>

        <h2 style="color: #1f2937; font-size: 24px; margin-bottom: 15px;">إعادة تعيين كلمة المرور</h2>
        
        <p style="color: #4b5563; font-size: 16px; line-height: 1.6; margin-bottom: 25px;">
            مرحباً، <br>
            لقد تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بحسابك في <strong>BrainGuard</strong>. 
            الرجاء استخدام رمز التحقق (OTP) التالي لإكمال العملية:
        </p>

        <div style="background-color: #f0fdf4; border: 2px dashed #22c55e; border-radius: 8px; padding: 20px; margin: 30px 0;">
            <h1 style="margin: 0; font-size: 40px; letter-spacing: 8px; color: #166534;">{{ $otpCode }}</h1>
        </div>

        <p style="color: #ef4444; font-size: 14px; margin-bottom: 30px;">
            ⚠️ تنبيه: هذا الرمز صالح لمدة <strong>10 دقائق</strong> فقط لأسباب أمنية.
        </p>

        <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;">

        <p style="color: #9ca3af; font-size: 13px; line-height: 1.5;">
            إذا لم تقم بطلب رمز التحقق هذا، يمكنك تجاهل هذه الرسالة بأمان. لا تقم بمشاركة هذا الرمز مع أي شخص.
            <br><br>
            أطيب التحيات،<br>
            <strong>فريق دعم BrainGuard</strong>
        </p>
    </div>
</body>
</html>
