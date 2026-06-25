import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/enums/user_role.dart';
import '../core/networking/local_storage.dart';
import '../features/auth/presentation/controllers/auth_providers.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/onboarding_page.dart';
import '../features/auth/presentation/pages/otp_verification_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/pages/role_selection_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/domain/password_reset_session.dart';

import '../shared/presentation/pages/notification_page.dart';
import '../features/doctor/presentation/pages/doctor_home_page.dart';
import '../features/patient/presentation/pages/patient_dashboard_page.dart';
import '../features/patient/presentation/pages/patient_messages_page.dart';
import '../features/patient/presentation/pages/patient_scan_qr_page.dart';
import '../features/patient/presentation/pages/upload_files_page.dart';
import '../features/doctor/presentation/pages/doctor_profile_page.dart';
import '../features/doctor/presentation/pages/doctor_scan_qr_page.dart';
import '../features/doctor/presentation/pages/doctor_notification_page.dart';
import '../features/requests/doctor_requests_view.dart';
import '../features/patient/presentation/pages/emergency_contact_page.dart';
import '../features/patient/presentation/pages/medical_history_page.dart';
import '../features/patient/presentation/pages/edit_profile_page.dart';
import '../features/patient/presentation/pages/patient_prediction_setup_page.dart';
import '../shared/domain/entities/call_session_entity.dart';
import '../shared/presentation/pages/about_us_page.dart';
import '../shared/presentation/pages/chatbot_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppConstants.routeSplash,
    refreshListenable: GoRouterRefreshListenable(ref),
    redirect: (context, state) {
      // Allow SplashPage to handle its own timed navigation so animations finish.
      if (state.matchedLocation == AppConstants.routeSplash) {
        return null;
      }

      final authState = ref.read(authStateProvider);
      final authSession = ref.read(authControllerProvider);

      if (authState.isLoading || authSession.isLoading) {
        return null;
      }

      final user = authSession.valueOrNull ?? authState.value;
      final isAuthPage =
          state.matchedLocation == AppConstants.routeLogin ||
          state.matchedLocation == AppConstants.routeSignup ||
          state.matchedLocation == AppConstants.routeRole ||
          state.matchedLocation == AppConstants.routeOnboarding ||
          state.matchedLocation == AppConstants.routeForgot ||
          state.matchedLocation == AppConstants.routeOtp ||
          state.matchedLocation == AppConstants.routeResetPassword;

      if (user == null) {
        final storage = ref.read(localStorageProvider);
        final nextRoute = storage.isOnboardingCompleted()
            ? AppConstants.routeRole
            : AppConstants.routeOnboarding;
        return isAuthPage ? null : nextRoute;
      }

      // Patients are no longer forcefully redirected to PredictionSetup on login.
      // It is now a 'soft mandatory' action driven from the Wellness Dashboard.
      if (isAuthPage) {
        return user.role == UserRole.doctor
            ? AppConstants.routeDoctorHome
            : AppConstants.routeHome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppConstants.routePredictionSetup,
        builder: (context, state) => const PatientPredictionSetupPage(),
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppConstants.routeRole,
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: AppConstants.doctorNotifications,
        builder: (context, state) => const DoctorNotificationView(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: AppConstants.routeSignup,
        builder: (context, state) => const AuthPage(),
      ),
      GoRoute(
        path: AppConstants.routeForgot,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppConstants.routeOtp,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return OtpVerificationPage(
            phone: args?['phone'] as String?,
            email: args?['email'] as String?,
            verificationId: args?['verificationId'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeResetPassword,
        builder: (context, state) {
          final session = state.extra;
          if (session is PasswordResetSession) {
            return ResetPasswordPage(session: session);
          }
          return const AuthPage();
        },
      ),
      GoRoute(
        path: AppConstants.routeHome,
        builder: (context, state) {
          final extra = state.extra;
          final initialIndex = extra is int ? extra : 0;
          return PatientDashboardPage(initialIndex: initialIndex);
        },
      ),
      GoRoute(
        path: '/chatbot',
        builder: (context, state) => const ChatbotPage(),
      ),
      GoRoute(
        path: AppConstants.routeDoctorHome,
        builder: (context, state) => const DoctorHomePage(),
      ),
      GoRoute(
        path: AppConstants.routeMessages,
        builder: (context, state) {
          final args = state.extra as PatientChatArgs;
          return PatientMessagesPage(
            contactName: args.contactName,
            contactImage: args.contactImage,
            conversationId: args.conversationId,
            otherId: args.otherId,
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeScanQr,
        builder: (context, state) => const PatientScanQrPage(),
      ),
      GoRoute(
        path: AppConstants.routeDoctorScanQr,
        builder: (context, state) => const DoctorScanQrPage(),
      ),
      GoRoute(
        path: AppConstants.routeNotifications,
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: AppConstants.routeProfile,
        builder: (context, state) => const DoctorProfilePage(),
      ),
      GoRoute(
        path: AppConstants.routeEmergencyContact,
        builder: (context, state) => const EmergencyContactPage(),
      ),
      GoRoute(
        path: AppConstants.routeMedicalHistory,
        builder: (context, state) => const MedicalHistoryPage(),
      ),
      GoRoute(
        path: AppConstants.routeScanQr,
        builder: (context, state) => const PatientScanQrPage(),
      ),
      GoRoute(
        path: AppConstants.routeDoctorScanQr,
        builder: (context, state) => const DoctorScanQrPage(),
      ),
      GoRoute(
        path: AppConstants.routeUploadFilesStep1,
        builder: (context, state) => const UploadFilesPage(),
      ),
      GoRoute(
        path: AppConstants.routePatientEditProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppConstants.routeDoctorRequests,
        builder: (context, state) => const DoctorRequestsView(),
      ),
      GoRoute(
        path: AppConstants.routeDoctorAboutUs,
        builder: (context, state) => const AboutUsPage(isDoctor: true),
      ),
      GoRoute(
        path: AppConstants.routePatientAboutUs,
        builder: (context, state) => const AboutUsPage(isDoctor: false),
      ),
    ],
  );
});

class GoRouterRefreshListenable extends ChangeNotifier {
  GoRouterRefreshListenable(Ref ref) {
    // ignore: unnecessary_underscores
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    // ignore: unnecessary_underscores
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}
