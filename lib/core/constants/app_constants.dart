import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // API
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://brainguard.devawy.com/api/v1';
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int pageSize = 20;

  // Routes
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeRole = '/role';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeForgot = '/forgot';
  static const String routeOtp = '/otp';
  static const String routeResetPassword = '/reset-password';
  static const String routePredictionSetup = '/prediction-setup';
  static const String routeHome = '/home';
  static const String routeDoctorHome = '/doctor-home';
  static const String routeMessages = '/messages';

  static const String routeNotifications = '/notifications';
  static const String routeProfile = '/profile';
  static const String routeEmergencyContact = '/emergency-contact';
  static const String routeMedicalHistory = '/medical-history';
  static const String routeScanQr = '/scan-qr';
  static const String routeDoctorScanQr = '/doctor-scan-qr';
  static const String routeUploadFilesStep1 = '/upload-files-step-1';
  static const String doctorNotifications = '/doctor-notifications';
  static const String routePatientEditProfile = '/patient-edit-profile';
  static const String routeDoctorRequests = '/doctor-requests';
  static const String routeDoctorAboutUs = '/doctor-about-us';
  static const String routePatientAboutUs = '/patient-about-us';
}
