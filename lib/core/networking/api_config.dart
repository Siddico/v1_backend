import '../constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Configuration constants
class ApiConfig {
  // API Base URLs
  static String get baseUrl => AppConstants.baseUrl;
  static String get webSocketUrl => dotenv.env['WEBSOCKET_URL'] ?? 'wss://brainguard.devawy.com';

  // Endpoints (these are appended to baseUrl which already contains /api/v1)
  static const String healthSignalsEndpoint = '/health-signals';
  static const String predictionsEndpoint = '/predictions';
  static const String userHealthDataEndpoint = '/users';

  // Auth endpoints
  static String authMe() => '/auth/me';
  static String authLogin() => '/auth/login';
  static String authRegister() => '/auth/register';
  static String authLogout() => '/auth/logout';
  static String authOtpSend() => '/auth/otp/send';
  static String authOtpVerify() => '/auth/otp/verify';
  static String authPasswordReset() => '/auth/password/reset-link';

  // User scoped endpoints
  static String userById(String userId) => '$userHealthDataEndpoint/$userId';
  static String userHealthData(String userId) =>
      '$userHealthDataEndpoint/$userId/health-data';
  static String userUploads(String userId) =>
      '$userHealthDataEndpoint/$userId/uploads';
  static String userNotifications(String userId) =>
      '$userHealthDataEndpoint/$userId/notifications';
  static String userNotification(String userId, String notificationId) =>
      '$userHealthDataEndpoint/$userId/notifications/$notificationId';
  static String userDoctorAssignments(String userId) =>
      '$userHealthDataEndpoint/$userId/doctor-assignments';
  static String userDoctorDashboard(String userId) =>
      '$userHealthDataEndpoint/$userId/doctor_home/dashboard';
  static String userDoctorInbox(String userId) =>
      '$userHealthDataEndpoint/$userId/doctor_messages/inbox';

  // WebSocket Endpoints
  static const String predictionsStreamEndpoint = '/ws/predictions';
  static const String healthSignalsStreamEndpoint = '/ws/health-signals';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Signal Collection Frequency
  static const Duration signalCollectionFrequency = Duration(seconds: 1);
}
