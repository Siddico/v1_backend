class ApiConstants {
  static const String baseUrl = 'https://brainguard.devawy.com/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String resetPasswordLink = '/auth/password/reset-link';
  static const String resetPassword = '/auth/password/reset';

  // Patient
  static const String patientProfile = '/patient/profile';
  static const String patientHealthData = '/patient/health-data';
  static const String patientSignals = '/patient/signals';
  static const String patientPredict = '/patient/predict';
  static const String medications = '/patient/medications';
  static const String chatbotSessions = '/patient/chatbot/sessions';
  static const String patientPredictions = '/patient/predictions';
  static const String patientNotifications = '/patient/notifications';
  static const String patientReports = '/patient/reports';
  static const String patientEmergency = '/patient/emergency';
  static const String patientChat = '/patient/chat';
  static const String patientRadiology = '/patient/radiology';
  static const String patientQr = '/patient/qr';

  // Doctor
  static const String doctorProfile = '/doctor/profile';
  static const String doctorPatients = '/doctor/patients';
  static const String doctorAlerts = '/doctor/alerts';
  static const String doctorFollowUp = '/doctor/follow-up';
  static const String doctorMedicalData = '/doctor/medical-data';
  static const String doctorLabDocuments = '/doctor/lab-documents';
  static const String doctorRadiology = '/doctor/radiology';
  static const String doctorChat = '/doctor/chat';
  static const String doctorAppointments = '/doctor/appointments';
}
