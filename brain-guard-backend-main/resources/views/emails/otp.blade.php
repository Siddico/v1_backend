<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Brain Guard — Your OTP Code</title>
</head>
<body style="margin: 0; padding: 0; background-color: #f8f9fa; font-family: Arial, Helvetica, sans-serif;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background-color: #f8f9fa; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width: 520px; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);">
                    <tr>
                        <td style="padding: 32px 40px 24px 40px; text-align: center; border-bottom: 1px solid #e9ecef;">
                            <h1 style="margin: 0; font-size: 24px; font-weight: 700; color: #1a73e8; letter-spacing: 0.5px;">
                                Brain Guard
                            </h1>
                            <p style="margin: 8px 0 0 0; font-size: 13px; color: #6c757d;">
                                Medical Stroke Risk Monitoring
                            </p>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 32px 40px;">
                            <p style="margin: 0 0 8px 0; font-size: 15px; color: #495057;">
                                Hello,
                            </p>
                            <p style="margin: 0 0 24px 0; font-size: 15px; color: #495057; line-height: 1.6;">
                                Your One-Time Password (OTP) is:
                            </p>
                            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
                                <tr>
                                    <td align="center" style="background-color: #1a73e8; border-radius: 8px; padding: 20px 32px;">
                                        <span style="font-size: 32px; font-weight: 700; color: #ffffff; letter-spacing: 8px; font-family: 'Courier New', Courier, monospace;">
                                            {{ $code }}
                                        </span>
                                    </td>
                                </tr>
                            </table>
                            <p style="margin: 24px 0 0 0; font-size: 14px; color: #6c757d; line-height: 1.6;">
                                This code expires in <strong style="color: #495057;">10 minutes</strong>.
                            </p>
                            <p style="margin: 16px 0 0 0; font-size: 13px; color: #adb5bd; line-height: 1.6;">
                                Sent to: {{ $maskedEmail }}
                            </p>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 20px 40px 32px 40px; border-top: 1px solid #e9ecef;">
                            <p style="margin: 0; font-size: 13px; color: #dc3545; line-height: 1.6; text-align: center;">
                                If you did not request this, please ignore this email.
                            </p>
                            <p style="margin: 16px 0 0 0; font-size: 12px; color: #adb5bd; text-align: center; line-height: 1.5;">
                                &copy; {{ date('Y') }} Brain Guard. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
